import Foundation

struct GenerateBriefingUseCase: Sendable {
    let whoopRepo: any WhoopRepository
    let calendarRepo: any CalendarRepository
    let classifyDemand: ClassifyEventDemandUseCase
    let findWorkoutWindow: FindWorkoutWindowUseCase

    func execute(for date: Date, userId: UUID) async throws -> DayBriefing {
        // 1. Parallel fetch
        async let recoveryTask = whoopRepo.getLatestRecovery(userId: userId)
        async let sleepTask = whoopRepo.getLatestSleep(userId: userId)
        async let eventsTask = calendarRepo.getEvents(for: date)

        let recovery = try await recoveryTask
        let sleep = try await sleepTask
        let rawEvents = (try? await eventsTask) ?? []

        // 2. Classify events
        let classifiedEvents = classifyDemand.classifyAll(events: rawEvents)

        // 3. Find workout windows
        let workoutWindows = try await findWorkoutWindow.execute(
            date: date,
            events: rawEvents,
            recoveryZone: recovery.zone
        )

        // 4. Calendar load score (0-100)
        let calendarLoad = calculateCalendarLoad(events: classifiedEvents)

        // 5. Generate recommendations
        let recommendations = generateRecommendations(
            recovery: recovery,
            sleep: sleep,
            classifiedEvents: classifiedEvents,
            calendarLoad: calendarLoad,
            workoutWindows: workoutWindows
        )

        // 6. Assemble briefing
        return DayBriefing(
            date: date,
            recoveryZone: recovery.zone,
            recoveryScore: recovery.recoveryScore ?? 0,
            sleepSummary: SleepSummary(from: sleep),
            events: classifiedEvents,
            recommendations: recommendations,
            calendarLoadScore: calendarLoad,
            suggestedWorkoutWindows: workoutWindows
        )
    }

    // MARK: - Private Helpers

    private func calculateCalendarLoad(events: [ClassifiedEvent]) -> Double {
        let countComponent = min(Double(events.count) * 8, 60)
        let demandWeighted = events.reduce(0.0) { total, event in
            switch event.demand {
            case .high: total + 3
            case .medium: total + 2
            case .low: total + 1
            }
        }
        let demandComponent = min(demandWeighted / 30 * 40, 40)
        return min(countComponent + demandComponent, 100)
    }

    private func generateRecommendations(
        recovery: RecoveryData,
        sleep: SleepData,
        classifiedEvents: [ClassifiedEvent],
        calendarLoad: Double,
        workoutWindows: [TimeWindow]
    ) -> [Recommendation] {
        var recs: [Recommendation] = []

        // Recovery-based recommendations
        switch recovery.zone {
        case .green:
            recs.append(Recommendation(
                type: .positive,
                title: "Recovery is strong",
                body: "Your body is well recovered. Great day for a challenging workout or demanding tasks.",
                priority: .medium
            ))
            if let window = workoutWindows.first {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                recs.append(Recommendation(
                    type: .workout,
                    title: "Workout window available",
                    body: "Best slot: \(formatter.string(from: window.start)) – \(formatter.string(from: window.end)) (\(window.durationMinutes) min).",
                    priority: .medium
                ))
            }
        case .yellow:
            recs.append(Recommendation(
                type: .info,
                title: "Moderate recovery",
                body: "Consider a lighter workout today. Focus on technique over intensity.",
                priority: .medium
            ))
        case .red:
            recs.append(Recommendation(
                type: .warning,
                title: "Low recovery — prioritize rest",
                body: "Your body needs recovery. Stick to light movement like walking or stretching.",
                priority: .high
            ))
            let highDemandEvents = classifiedEvents.filter { $0.demand == .high }
            if !highDemandEvents.isEmpty {
                let names = highDemandEvents.prefix(2).map(\.title).joined(separator: ", ")
                recs.append(Recommendation(
                    type: .warning,
                    title: "High-demand events today",
                    body: "You have demanding events (\(names)) on a low recovery day. Pace yourself and take breaks.",
                    priority: .high
                ))
            }
        case .unknown:
            recs.append(Recommendation(
                type: .info,
                title: "Recovery data pending",
                body: "Whoop hasn't scored your recovery yet. Check back soon.",
                priority: .low
            ))
        }

        // Sleep-based recommendations
        let sleepHours = sleep.totalDurationHours
        if sleepHours < 6 {
            recs.append(Recommendation(
                type: .sleep,
                title: "Sleep deficit detected",
                body: "You got \(String(format: "%.1f", sleepHours))h of sleep. Consider an earlier bedtime tonight.",
                priority: .high
            ))
        } else if sleepHours >= 7.5 {
            recs.append(Recommendation(
                type: .positive,
                title: "Great sleep",
                body: "You logged \(String(format: "%.1f", sleepHours))h of quality sleep. Well done!",
                priority: .low
            ))
        }

        // Calendar-based recommendations
        if calendarLoad >= 70 {
            recs.append(Recommendation(
                type: .calendar,
                title: "Heavy calendar day",
                body: "Your schedule is packed. Block time for short breaks between meetings.",
                priority: .medium
            ))
        } else if calendarLoad <= 20 {
            recs.append(Recommendation(
                type: .calendar,
                title: "Light schedule",
                body: "You have open time today — great opportunity for deep work or a longer workout.",
                priority: .low
            ))
        }

        return recs.sorted { $0.priority > $1.priority }
    }
}
