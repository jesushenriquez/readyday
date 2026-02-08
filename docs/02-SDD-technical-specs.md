# ReadyDay - SDD: Technical Specifications

> Specs Driven Development Document v1.0
> Last Updated: 2026-02-07

---

## 1. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         iOS App (SwiftUI)                       │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌───────────────┐  │
│  │  Views    │  │ViewModels│  │ UseCases  │  │ Repositories  │  │
│  │(SwiftUI) │──│(@Observ.)│──│ (Domain)  │──│   (Data)      │  │
│  └──────────┘  └──────────┘  └───────────┘  └───────┬───────┘  │
│                                                      │          │
│  ┌──────────────┐  ┌────────────┐  ┌────────────────┐│          │
│  │  EventKit    │  │ UserNotif. │  │ KeychainService││          │
│  │ (Calendar)   │  │ (Push)     │  │ (Tokens)       ││          │
│  └──────────────┘  └────────────┘  └────────────────┘│          │
└──────────────────────────────────────────────────────┼──────────┘
                                                       │
                              ┌─────────────────────────┤
                              │                         │
                    ┌─────────▼─────────┐    ┌─────────▼─────────┐
                    │   Supabase Cloud  │    │   Whoop API v2    │
                    │                   │    │                   │
                    │ ┌───────────────┐ │    │ /v2/cycle         │
                    │ │ Auth (Apple)  │ │    │ /v2/recovery      │
                    │ ├───────────────┤ │    │ /v2/activity/sleep│
                    │ │ PostgreSQL DB │ │    │ /v2/activity/     │
                    │ ├───────────────┤ │    │    workout        │
                    │ │ Edge Functions│ │    │ /v2/user/profile  │
                    │ ├───────────────┤ │    │ /v2/user/body     │
                    │ │ Realtime      │ │    │                   │
                    │ ├───────────────┤ │    │ Webhooks ─────┐   │
                    │ │ Storage       │ │    └───────────────┘   │
                    │ └───────────────┘ │              │         │
                    │         ▲         │              │         │
                    │         │         │    ┌─────────▼───────┐ │
                    │  ┌──────┴───────┐ │    │ Supabase Edge   │ │
                    │  │ RLS Policies │ │    │ Function:       │ │
                    │  └──────────────┘ │    │ webhook-handler │ │
                    └───────────────────┘    └─────────────────┘
```

---

## 2. Technology Stack

| Layer | Technology | Version | Justification |
|-------|-----------|---------|---------------|
| **UI** | SwiftUI | iOS 17+ | @Observable, latest APIs, modern declarative UI |
| **Language** | Swift | 5.9+ | Strict concurrency, macros |
| **Architecture** | MVVM + Clean Architecture | - | Testable, scalable, industry standard |
| **DI** | Swift native (Protocol + Environment) | - | No external dependency needed |
| **Backend** | Supabase | Latest | Auth, DB, Edge Functions, Realtime |
| **Database** | PostgreSQL (via Supabase) | 15+ | Relational data, RLS, full SQL |
| **Auth** | Supabase Auth + Apple Sign In | - | Native iOS feel, secure |
| **Calendar** | EventKit | iOS 17+ | Native Apple calendar access |
| **Networking** | URLSession + async/await | - | Native, no third-party dependency |
| **Keychain** | KeychainAccess or native | - | Secure token storage |
| **Charts** | Swift Charts | iOS 17+ | Native, performant |
| **Notifications** | UNUserNotificationCenter | - | Local + push notifications |
| **Analytics** | PostHog Swift SDK | - | Privacy-friendly, open source |
| **CI/CD** | Xcode Cloud | - | Native Apple, free tier available |
| **Package Manager** | Swift Package Manager | - | Native, standard |

### External Dependencies (Minimal)

```swift
// Package.swift dependencies
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
    .package(url: "https://github.com/PostHog/posthog-ios", from: "3.0.0"),
]
```

**Principio**: Minimizar dependencias externas. Usar APIs nativas de Apple cuando sea posible.

---

## 3. Project Structure

```
ReadyDay/
├── App/
│   ├── ReadyDayApp.swift              # @main entry point
│   ├── AppDelegate.swift              # Push notifications setup
│   └── DependencyContainer.swift      # DI container
│
├── Core/
│   ├── Network/
│   │   ├── WhoopAPIClient.swift       # Whoop REST client
│   │   ├── WhoopOAuthManager.swift    # OAuth flow + token refresh
│   │   └── APIError.swift             # Error types
│   ├── Storage/
│   │   ├── KeychainService.swift      # Secure token storage
│   │   └── UserDefaultsService.swift  # Preferences
│   ├── Calendar/
│   │   ├── CalendarService.swift      # EventKit wrapper
│   │   └── CalendarPermissions.swift  # Permission handling
│   ├── Notifications/
│   │   ├── NotificationService.swift  # Schedule & manage
│   │   └── NotificationContent.swift  # Content builders
│   └── Extensions/
│       ├── Date+Extensions.swift
│       └── Color+Recovery.swift
│
├── Domain/
│   ├── Models/
│   │   ├── RecoveryData.swift         # Recovery domain model
│   │   ├── SleepData.swift            # Sleep domain model
│   │   ├── WorkoutData.swift          # Workout domain model
│   │   ├── CalendarEvent.swift        # Calendar event model
│   │   ├── DayBriefing.swift          # Morning briefing model
│   │   ├── Recommendation.swift       # Recommendation model
│   │   └── EnergyDemand.swift         # Event demand classification
│   ├── UseCases/
│   │   ├── GenerateBriefingUseCase.swift
│   │   ├── ClassifyEventDemandUseCase.swift
│   │   ├── FindWorkoutWindowUseCase.swift
│   │   ├── SyncWhoopDataUseCase.swift
│   │   └── AnalyzeRecoveryTrendUseCase.swift
│   └── Repositories/
│       ├── WhoopRepository.swift      # Protocol
│       ├── CalendarRepository.swift   # Protocol
│       ├── BriefingRepository.swift   # Protocol
│       └── UserRepository.swift       # Protocol
│
├── Data/
│   ├── Repositories/
│   │   ├── WhoopRepositoryImpl.swift
│   │   ├── CalendarRepositoryImpl.swift
│   │   ├── BriefingRepositoryImpl.swift
│   │   └── UserRepositoryImpl.swift
│   ├── DTOs/
│   │   ├── WhoopRecoveryDTO.swift     # API response mapping
│   │   ├── WhoopSleepDTO.swift
│   │   ├── WhoopWorkoutDTO.swift
│   │   ├── WhoopCycleDTO.swift
│   │   └── WhoopProfileDTO.swift
│   └── Supabase/
│       ├── SupabaseClient.swift       # Configured client
│       ├── SupabaseModels.swift       # DB row models
│       └── SupabaseMigrations.swift   # Schema reference
│
├── Presentation/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── OnboardingViewModel.swift
│   │   ├── WhoopConnectView.swift
│   │   └── CalendarPermissionView.swift
│   ├── Briefing/
│   │   ├── BriefingView.swift         # Morning briefing
│   │   ├── BriefingViewModel.swift
│   │   ├── RecoveryScoreView.swift    # Recovery ring/card
│   │   ├── SleepSummaryView.swift
│   │   └── RecommendationCardView.swift
│   ├── Timeline/
│   │   ├── TimelineView.swift         # Day timeline
│   │   ├── TimelineViewModel.swift
│   │   ├── TimelineEventBlock.swift
│   │   └── TimelineGapView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift        # Recovery dashboard
│   │   ├── DashboardViewModel.swift
│   │   └── TrendChartView.swift
│   ├── Workout/
│   │   ├── WorkoutFinderView.swift
│   │   └── WorkoutFinderViewModel.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── SettingsViewModel.swift
│   └── Shared/
│       ├── RecoveryColorView.swift    # Reusable recovery indicator
│       ├── LoadingView.swift
│       ├── ErrorView.swift
│       └── EmptyStateView.swift
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.xcstrings         # EN + ES
│   └── Info.plist
│
└── Tests/
    ├── UnitTests/
    │   ├── UseCases/
    │   │   ├── GenerateBriefingTests.swift
    │   │   ├── ClassifyEventDemandTests.swift
    │   │   └── FindWorkoutWindowTests.swift
    │   ├── ViewModels/
    │   │   ├── BriefingViewModelTests.swift
    │   │   └── TimelineViewModelTests.swift
    │   └── Repositories/
    │       └── WhoopRepositoryTests.swift
    └── UITests/
        ├── OnboardingUITests.swift
        └── BriefingUITests.swift
```

---

## 4. Database Schema (Supabase PostgreSQL)

### 4.1 Tables

```sql
-- ============================================
-- USERS
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supabase_auth_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    whoop_user_id BIGINT UNIQUE,
    email TEXT,
    display_name TEXT,
    timezone TEXT DEFAULT 'UTC',
    morning_briefing_time TIME DEFAULT '07:30',
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- WHOOP TOKENS (encrypted)
-- ============================================
CREATE TABLE whoop_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    access_token TEXT NOT NULL,       -- encrypted via pgcrypto
    refresh_token TEXT NOT NULL,      -- encrypted via pgcrypto
    token_expires_at TIMESTAMPTZ NOT NULL,
    scopes TEXT[] NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ============================================
-- RECOVERY DATA
-- ============================================
CREATE TABLE recovery_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    whoop_cycle_id BIGINT NOT NULL,
    whoop_sleep_id UUID,
    score_state TEXT NOT NULL,         -- SCORED, PENDING_SCORE, UNSCORABLE
    recovery_score INTEGER,            -- 0-100
    resting_heart_rate REAL,           -- bpm
    hrv_rmssd_milli REAL,              -- ms
    spo2_percentage REAL,              -- % (4.0 members)
    skin_temp_celsius REAL,            -- C (4.0 members)
    user_calibrating BOOLEAN,
    recorded_at TIMESTAMPTZ NOT NULL,  -- when this recovery was for
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, whoop_cycle_id)
);

-- ============================================
-- SLEEP DATA
-- ============================================
CREATE TABLE sleep_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    whoop_sleep_id UUID NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    is_nap BOOLEAN DEFAULT FALSE,
    score_state TEXT NOT NULL,
    -- Sleep score fields
    stage_summary JSONB,               -- {light_ms, deep_ms, rem_ms, wake_ms}
    sleep_needed_ms BIGINT,
    sleep_debt_ms BIGINT,
    sleep_efficiency REAL,             -- 0-1
    sleep_consistency REAL,            -- 0-100
    respiratory_rate REAL,
    recorded_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, whoop_sleep_id)
);

-- ============================================
-- WORKOUT DATA
-- ============================================
CREATE TABLE workout_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    whoop_workout_id UUID NOT NULL,
    sport_name TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    score_state TEXT NOT NULL,
    strain REAL,                        -- 0-21
    average_heart_rate INTEGER,
    max_heart_rate INTEGER,
    kilojoule REAL,
    distance_meter REAL,
    zone_durations JSONB,              -- {zone_0_ms, zone_1_ms, ..., zone_5_ms}
    recorded_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, whoop_workout_id)
);

-- ============================================
-- DAILY BRIEFINGS (cached/generated)
-- ============================================
CREATE TABLE daily_briefings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    briefing_date DATE NOT NULL,
    recovery_zone TEXT NOT NULL,        -- GREEN, YELLOW, RED
    recovery_score INTEGER,
    recommendations JSONB NOT NULL,     -- [{type, title, body, priority}]
    calendar_load_score REAL,           -- 0-100 estimated day load
    event_count INTEGER,
    high_demand_event_count INTEGER,
    generated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, briefing_date)
);

-- ============================================
-- USER PREFERENCES
-- ============================================
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_morning_briefing BOOLEAN DEFAULT TRUE,
    notification_pre_meeting BOOLEAN DEFAULT TRUE,
    notification_break_suggestion BOOLEAN DEFAULT TRUE,
    selected_calendar_ids TEXT[],      -- EventKit calendar identifiers
    workout_prep_time_minutes INTEGER DEFAULT 30,
    preferred_workout_times TEXT[],     -- ['morning', 'afternoon', 'evening']
    language TEXT DEFAULT 'en',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX idx_recovery_user_date ON recovery_data(user_id, recorded_at DESC);
CREATE INDEX idx_sleep_user_date ON sleep_data(user_id, recorded_at DESC);
CREATE INDEX idx_workout_user_date ON workout_data(user_id, recorded_at DESC);
CREATE INDEX idx_briefings_user_date ON daily_briefings(user_id, briefing_date DESC);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE whoop_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE recovery_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE sleep_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_briefings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own data
CREATE POLICY "Users can view own data" ON users
    FOR ALL USING (supabase_auth_id = auth.uid());

CREATE POLICY "Users can view own tokens" ON whoop_tokens
    FOR ALL USING (user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid()));

CREATE POLICY "Users can view own recovery" ON recovery_data
    FOR ALL USING (user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid()));

CREATE POLICY "Users can view own sleep" ON sleep_data
    FOR ALL USING (user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid()));

CREATE POLICY "Users can view own workouts" ON workout_data
    FOR ALL USING (user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid()));

CREATE POLICY "Users can view own briefings" ON daily_briefings
    FOR ALL USING (user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid()));

CREATE POLICY "Users can view own preferences" ON user_preferences
    FOR ALL USING (user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid()));
```

### 4.2 Database Functions

```sql
-- Function to get latest recovery for a user
CREATE OR REPLACE FUNCTION get_latest_recovery(p_user_id UUID)
RETURNS TABLE (
    recovery_score INTEGER,
    resting_heart_rate REAL,
    hrv_rmssd_milli REAL,
    spo2_percentage REAL,
    score_state TEXT,
    recorded_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        rd.recovery_score,
        rd.resting_heart_rate,
        rd.hrv_rmssd_milli,
        rd.spo2_percentage,
        rd.score_state,
        rd.recorded_at
    FROM recovery_data rd
    WHERE rd.user_id = p_user_id
      AND rd.score_state = 'SCORED'
    ORDER BY rd.recorded_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get recovery trend (last N days)
CREATE OR REPLACE FUNCTION get_recovery_trend(p_user_id UUID, p_days INTEGER DEFAULT 7)
RETURNS TABLE (
    day DATE,
    recovery_score INTEGER,
    hrv_rmssd_milli REAL,
    resting_heart_rate REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        rd.recorded_at::DATE as day,
        rd.recovery_score,
        rd.hrv_rmssd_milli,
        rd.resting_heart_rate
    FROM recovery_data rd
    WHERE rd.user_id = p_user_id
      AND rd.score_state = 'SCORED'
      AND rd.recorded_at >= NOW() - (p_days || ' days')::INTERVAL
    ORDER BY rd.recorded_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 5. API Integration: Whoop

### 5.1 OAuth 2.0 Flow (iOS)

```
┌──────────┐     ┌──────────────┐     ┌──────────────┐
│  iOS App │     │ ASWebAuth    │     │ Whoop OAuth  │
│          │     │ Session      │     │ Server       │
└────┬─────┘     └──────┬───────┘     └──────┬───────┘
     │                  │                     │
     │  1. Start OAuth  │                     │
     │─────────────────>│                     │
     │                  │  2. Open auth URL   │
     │                  │────────────────────>│
     │                  │                     │
     │                  │  3. User logs in    │
     │                  │  4. User authorizes │
     │                  │                     │
     │                  │  5. Redirect w/code │
     │                  │<────────────────────│
     │  6. Auth code    │                     │
     │<─────────────────│                     │
     │                  │                     │
     │  7. Exchange code for tokens ─────────>│
     │                                        │
     │  8. Access + Refresh tokens <──────────│
     │                                        │
     │  9. Store in Keychain                  │
     │  10. Save refresh token to Supabase    │
     │     (encrypted)                        │
```

**Configuracion OAuth**:
```
Authorization URL: https://api.prod.whoop.com/oauth/oauth2/auth
Token URL: https://api.prod.whoop.com/oauth/oauth2/token
Redirect URI: readyday://oauth/callback
Scopes: read:recovery read:sleep read:workout read:cycles read:profile read:body_measurement offline
State: random 8+ char string (CSRF protection)
```

### 5.2 Token Management Strategy

```swift
// WhoopOAuthManager.swift - Pseudocode
@Observable
final class WhoopOAuthManager {
    // Access token stored in Keychain (short-lived)
    // Refresh token stored in Keychain + Supabase (encrypted backup)

    func getValidToken() async throws -> String {
        // 1. Check Keychain for access token
        // 2. If expired, use refresh token
        // 3. If refresh fails, prompt re-auth
        // 4. Token auto-refreshes 5 min before expiry
    }

    func refreshToken() async throws {
        // POST to token URL with refresh_token grant
        // Store new access + refresh tokens
        // Update Supabase backup
    }
}
```

### 5.3 Whoop API Client

```swift
// WhoopAPIClient.swift - Key endpoints

struct WhoopAPIClient {
    private let baseURL = "https://api.prod.whoop.com/developer"
    private let oauthManager: WhoopOAuthManager

    // GET /v2/cycle - Get physiological cycles
    func getCycles(start: Date?, end: Date?, limit: Int = 25) async throws -> PaginatedResponse<WhoopCycle>

    // GET /v2/recovery - Get recovery data (via cycles)
    func getRecoveries(start: Date?, end: Date?, limit: Int = 25) async throws -> PaginatedResponse<WhoopRecovery>

    // GET /v2/activity/sleep - Get sleep data
    func getSleeps(start: Date?, end: Date?, limit: Int = 25) async throws -> PaginatedResponse<WhoopSleep>

    // GET /v2/activity/workout - Get workouts
    func getWorkouts(start: Date?, end: Date?, limit: Int = 25) async throws -> PaginatedResponse<WhoopWorkout>

    // GET /v2/user/profile/basic - Get user profile
    func getProfile() async throws -> WhoopProfile

    // GET /v2/user/measurement/body - Get body measurements
    func getBodyMeasurement() async throws -> WhoopBodyMeasurement
}
```

### 5.4 Data Sync Strategy

```
[App Launch / Background Refresh]
    │
    ├── Check last sync timestamp
    │
    ├── If > 1 hour ago OR first launch today:
    │   ├── Fetch latest recovery (today)
    │   ├── Fetch latest sleep (last night)
    │   ├── Fetch workouts (today)
    │   └── Store in Supabase + local cache
    │
    ├── If first time ever:
    │   ├── Fetch last 30 days of recovery
    │   ├── Fetch last 30 days of sleep
    │   ├── Fetch last 30 days of workouts
    │   └── Batch store in Supabase
    │
    └── Webhooks (via Supabase Edge Function):
        ├── Listen for recovery.updated
        ├── Listen for sleep.updated
        ├── Listen for workout.updated
        └── Auto-update DB + trigger briefing regen
```

---

## 6. API Integration: EventKit (Calendar)

### 6.1 Calendar Service

```swift
// CalendarService.swift - Pseudocode

final class CalendarService {
    private let eventStore = EKEventStore()

    /// Request calendar access (iOS 17+)
    func requestAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToEvents()
    }

    /// Get events for a specific date
    func getEvents(for date: Date, calendarIDs: [String]?) -> [EKEvent] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: filteredCalendars(ids: calendarIDs)
        )
        return eventStore.events(matching: predicate)
    }

    /// Get available calendars for settings
    func getCalendars() -> [EKCalendar] {
        eventStore.calendars(for: .event)
    }

    /// Find gaps in schedule (for workout finder)
    func findGaps(for date: Date, minDuration: TimeInterval = 3600) -> [DateInterval] {
        // Returns time slots with no events >= minDuration
    }
}
```

### 6.2 Event Demand Classification Algorithm

```swift
// ClassifyEventDemandUseCase.swift

enum EnergyDemand: String, Codable {
    case high    // Red - demanding
    case medium  // Yellow - moderate
    case low     // Green - light
}

struct ClassifyEventDemandUseCase {

    func classify(event: EKEvent) -> EnergyDemand {
        var score: Double = 0

        // Factor 1: Duration (0-3 points)
        let hours = event.duration / 3600
        if hours >= 2.0 { score += 3 }
        else if hours >= 1.0 { score += 2 }
        else { score += 1 }

        // Factor 2: Attendees (0-3 points)
        let attendeeCount = event.attendees?.count ?? 0
        if attendeeCount >= 8 { score += 3 }
        else if attendeeCount >= 4 { score += 2 }
        else if attendeeCount >= 1 { score += 1 }

        // Factor 3: Time of day - post-lunch dip (0-1 points)
        let hour = Calendar.current.component(.hour, from: event.startDate)
        if hour >= 13 && hour <= 15 { score += 1 }

        // Factor 4: Title keywords (0-2 points)
        let title = event.title?.lowercased() ?? ""
        let highDemandKeywords = ["strategy", "review", "presentation", "interview",
                                   "planning", "brainstorm", "board", "all-hands",
                                   "pitch", "demo", "retrospective", "quarterly"]
        let lowDemandKeywords = ["lunch", "break", "coffee", "social", "happy hour",
                                  "walk", "1:1", "check-in", "standup", "daily"]

        if highDemandKeywords.contains(where: { title.contains($0) }) { score += 2 }
        else if lowDemandKeywords.contains(where: { title.contains($0) }) { score -= 1 }

        // Classification
        if score >= 6 { return .high }
        else if score >= 3 { return .medium }
        else { return .low }
    }
}
```

---

## 7. Core Algorithm: Briefing Generation

```swift
// GenerateBriefingUseCase.swift

struct DayBriefing {
    let date: Date
    let recoveryZone: RecoveryZone       // .green, .yellow, .red
    let recoveryScore: Int
    let sleepSummary: SleepSummary
    let events: [ClassifiedEvent]         // Calendar events with demand
    let recommendations: [Recommendation]
    let calendarLoadScore: Double         // 0-100
    let suggestedWorkoutWindows: [TimeWindow]
}

struct GenerateBriefingUseCase {
    let whoopRepo: WhoopRepository
    let calendarRepo: CalendarRepository
    let classifyDemand: ClassifyEventDemandUseCase
    let findWorkoutWindow: FindWorkoutWindowUseCase

    func execute(for date: Date, userId: UUID) async throws -> DayBriefing {
        // 1. Fetch recovery data
        let recovery = try await whoopRepo.getLatestRecovery(userId: userId)
        let zone = RecoveryZone.from(score: recovery.recoveryScore)

        // 2. Fetch sleep data
        let sleep = try await whoopRepo.getLatestSleep(userId: userId)

        // 3. Fetch calendar events
        let events = calendarRepo.getEvents(for: date)

        // 4. Classify each event
        let classified = events.map { event in
            ClassifiedEvent(event: event, demand: classifyDemand.classify(event: event))
        }

        // 5. Calculate calendar load
        let loadScore = calculateCalendarLoad(events: classified)

        // 6. Generate recommendations
        let recommendations = generateRecommendations(
            zone: zone,
            recovery: recovery,
            sleep: sleep,
            events: classified,
            load: loadScore
        )

        // 7. Find workout windows
        let windows = findWorkoutWindow.execute(
            date: date,
            events: events,
            recoveryZone: zone
        )

        return DayBriefing(
            date: date,
            recoveryZone: zone,
            recoveryScore: recovery.recoveryScore,
            sleepSummary: SleepSummary(from: sleep),
            events: classified,
            recommendations: recommendations,
            calendarLoadScore: loadScore,
            suggestedWorkoutWindows: windows
        )
    }

    private func calculateCalendarLoad(events: [ClassifiedEvent]) -> Double {
        // Weighted sum:
        // high demand event hour = 15 points
        // medium demand event hour = 8 points
        // low demand event hour = 3 points
        // Normalize to 0-100
        var totalLoad: Double = 0
        for event in events {
            let hours = event.duration / 3600
            switch event.demand {
            case .high: totalLoad += hours * 15
            case .medium: totalLoad += hours * 8
            case .low: totalLoad += hours * 3
            }
        }
        return min(totalLoad, 100)
    }
}
```

### 7.1 Recommendation Engine (Rule-Based v1)

```swift
// Recommendation generation rules - MVP uses rule-based system
// Future versions will use LLM for more nuanced recommendations

struct RecommendationEngine {

    func generate(
        zone: RecoveryZone,
        recovery: RecoveryData,
        sleep: SleepData,
        events: [ClassifiedEvent],
        load: Double
    ) -> [Recommendation] {
        var recs: [Recommendation] = []

        // === RECOVERY-BASED RULES ===

        switch zone {
        case .red:
            recs.append(.init(
                type: .warning,
                title: "Recovery baja (\(recovery.recoveryScore)%)",
                body: "Tu cuerpo necesita recuperarse. Prioriza tareas ligeras hoy.",
                priority: .high
            ))

            // Find highest demand event and suggest moving it
            if let hardest = events.filter({ $0.demand == .high }).first {
                recs.append(.init(
                    type: .calendar,
                    title: "Considera mover '\(hardest.title)'",
                    body: "Con recovery \(recovery.recoveryScore)%, una reunion de alta demanda puede ser contraproducente.",
                    priority: .high
                ))
            }

            recs.append(.init(
                type: .workout,
                title: "Solo active recovery hoy",
                body: "Si entrenas, mantente en zona 1-2. Caminata o yoga son ideales.",
                priority: .medium
            ))

        case .yellow:
            recs.append(.init(
                type: .info,
                title: "Recovery moderada (\(recovery.recoveryScore)%)",
                body: "Dia manejable. Modera la intensidad fisica y mental.",
                priority: .medium
            ))

            if load > 60 {
                recs.append(.init(
                    type: .warning,
                    title: "Agenda cargada + recovery moderada",
                    body: "Tu carga de calendario es alta. Toma breaks entre reuniones.",
                    priority: .high
                ))
            }

        case .green:
            recs.append(.init(
                type: .positive,
                title: "Excelente recovery (\(recovery.recoveryScore)%)",
                body: "Dia ideal para deep work y entrenamiento intenso.",
                priority: .medium
            ))

            recs.append(.init(
                type: .workout,
                title: "Aprovecha para entrenamiento intenso",
                body: "Tu cuerpo esta listo. Puedes ir all-out hoy.",
                priority: .low
            ))
        }

        // === SLEEP-BASED RULES ===

        if let efficiency = sleep.sleepEfficiency, efficiency < 0.75 {
            recs.append(.init(
                type: .sleep,
                title: "Eficiencia de sueno baja (\(Int(efficiency * 100))%)",
                body: "Considera acostarte mas temprano esta noche.",
                priority: .medium
            ))
        }

        if sleep.totalDurationHours < 6 {
            recs.append(.init(
                type: .sleep,
                title: "Dormiste solo \(String(format: "%.1f", sleep.totalDurationHours))h",
                body: "Deficit de sueno. Evita cafeina despues de 2pm y prioriza dormir temprano.",
                priority: .high
            ))
        }

        // === CALENDAR-BASED RULES ===

        // Detect 3+ consecutive hours of meetings
        let consecutiveBlocks = findConsecutiveMeetingBlocks(events: events)
        for block in consecutiveBlocks where block.duration >= 3 * 3600 {
            recs.append(.init(
                type: .calendar,
                title: "Maraton de reuniones detectado",
                body: "\(Int(block.duration / 3600))h consecutivas de reuniones desde \(block.startFormatted). Intenta tomar un break.",
                priority: .high
            ))
        }

        // Sort by priority and return top 5
        return Array(recs.sorted { $0.priority.rawValue > $1.priority.rawValue }.prefix(5))
    }
}
```

---

## 8. Supabase Edge Functions

### 8.1 Whoop Webhook Handler

```typescript
// supabase/functions/whoop-webhook/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
    const payload = await req.json()

    // Verify webhook signature (if Whoop provides one)
    // Process event type
    const { type, user_id, id } = payload

    const supabase = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    switch (type) {
        case 'recovery.updated':
            // Fetch full recovery data from Whoop API
            // Upsert into recovery_data table
            break
        case 'sleep.updated':
            // Fetch full sleep data from Whoop API
            // Upsert into sleep_data table
            break
        case 'workout.updated':
            // Fetch full workout data from Whoop API
            // Upsert into workout_data table
            break
    }

    return new Response(JSON.stringify({ success: true }), {
        headers: { 'Content-Type': 'application/json' },
        status: 200
    })
})
```

### 8.2 Token Refresh Function (Scheduled)

```typescript
// supabase/functions/refresh-whoop-tokens/index.ts
// Runs on a cron schedule to refresh tokens proactively

serve(async () => {
    const supabase = createClient(/* ... */)

    // Find tokens expiring in next 30 minutes
    const { data: expiringTokens } = await supabase
        .from('whoop_tokens')
        .select('*')
        .lt('token_expires_at', new Date(Date.now() + 30 * 60 * 1000).toISOString())

    for (const token of expiringTokens ?? []) {
        // Refresh each token
        // Update in database
    }

    return new Response(JSON.stringify({ refreshed: expiringTokens?.length ?? 0 }))
})
```

---

## 9. Security Architecture

### 9.1 Data Protection Layers

```
Layer 1: Network
├── All API calls over HTTPS (TLS 1.3)
├── Certificate pinning for Whoop API
└── Supabase connection via SSL

Layer 2: Authentication
├── Apple Sign In (biometric-backed)
├── Supabase JWT tokens (auto-managed)
├── Whoop OAuth tokens (Keychain + encrypted DB backup)
└── Session management with auto-expiry

Layer 3: Storage
├── Keychain: OAuth tokens (hardware-encrypted on device)
├── Supabase: RLS on all tables (user isolation)
├── pgcrypto: Whoop tokens encrypted at rest in DB
└── No sensitive data in UserDefaults

Layer 4: Application
├── No data logging in production
├── No analytics on health data values
├── Biometric lock option (Face ID/Touch ID)
└── Memory: sensitive data cleared on background
```

### 9.2 Privacy Compliance

| Requirement | Implementation |
|-------------|---------------|
| Data minimization | Only store data needed for features |
| Right to deletion | Account deletion removes all data (CASCADE) |
| Data portability | Export endpoint (JSON) |
| Consent | Explicit opt-in for each data source |
| Transparency | Privacy policy + in-app data usage explanation |
| Apple Health guidelines | Comply with App Store health data rules |

---

## 10. Error Handling Strategy

```swift
enum ReadyDayError: LocalizedError {
    // Auth
    case appleSignInFailed
    case whoopOAuthFailed(underlying: Error)
    case whoopTokenExpired
    case whoopTokenRefreshFailed

    // Data
    case whoopDataUnavailable
    case calendarAccessDenied
    case calendarAccessRestricted
    case noRecoveryData
    case noSleepData

    // Network
    case networkUnavailable
    case serverError(statusCode: Int)
    case rateLimited(retryAfter: TimeInterval)

    // General
    case unknown(underlying: Error)
}

// Graceful degradation strategy:
// - No Whoop data? Show calendar-only view with message
// - No calendar? Show recovery-only view with message
// - No internet? Show cached data with "last updated" timestamp
// - API rate limited? Use cached data, retry after delay
```

---

## 11. Caching Strategy

```
┌─────────────────────────────────────────┐
│            Caching Layers               │
├─────────────────────────────────────────┤
│                                         │
│  L1: In-Memory (ViewModels)             │
│  ├── Current briefing                   │
│  ├── Today's events                     │
│  └── TTL: app session                   │
│                                         │
│  L2: Supabase Local Cache               │
│  ├── Last 30 days recovery/sleep        │
│  ├── User preferences                   │
│  └── TTL: 1 hour (auto-refresh)         │
│                                         │
│  L3: Supabase Cloud (source of truth)   │
│  ├── All historical data                │
│  ├── User account data                  │
│  └── TTL: indefinite                    │
│                                         │
└─────────────────────────────────────────┘

Sync Strategy:
- App foreground: check if data > 1h old → refresh
- Background refresh: iOS BGAppRefreshTask (every 4-6h)
- Webhook-triggered: immediate update via Supabase Realtime
- Manual: pull-to-refresh in any view
```

---

## 12. Push Notification Architecture

```
Morning Briefing Flow:
1. Supabase Edge Function runs on CRON (per user's preferred time)
2. Checks if new recovery data available
3. Generates briefing (or uses cached)
4. Sends push via APNs (Supabase or direct)
5. Notification includes: recovery score + top recommendation
6. Tap → deep link to Briefing view

Pre-Meeting Alert Flow:
1. iOS app schedules local notifications based on calendar
2. When fired, checks current recovery from cache
3. If recovery < 50% AND event is high demand → show alert
4. Otherwise → suppress notification

Implementation: UNUserNotificationCenter for local scheduling
Future: Supabase + APNs for server-triggered push
```

---

## 13. Clean Architecture Guidelines

### 13.1 Layer Dependency Rules

```
┌─────────────────────────────────────────────────────────┐
│                    DEPENDENCY RULE                       │
│         Inner layers NEVER know about outer layers      │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Presentation (Views, ViewModels)               │    │
│  │  ├── CAN import: Domain                         │    │
│  │  ├── CANNOT import: Data                        │    │
│  │  └── ViewModels receive UseCases via init (DI)  │    │
│  │                                                 │    │
│  │  ┌─────────────────────────────────────────┐    │    │
│  │  │  Domain (Models, UseCases, Protocols)   │    │    │
│  │  │  ├── CANNOT import: Presentation, Data  │    │    │
│  │  │  ├── Defines Repository PROTOCOLS only  │    │    │
│  │  │  └── Zero external dependencies         │    │    │
│  │  │                                         │    │    │
│  │  │  ┌─────────────────────────────────┐    │    │    │
│  │  │  │  Data (Repos, DTOs, Services)  │    │    │    │
│  │  │  │  ├── CAN import: Domain         │    │    │    │
│  │  │  │  ├── CANNOT import: Presentation│    │    │    │
│  │  │  │  └── Implements Domain protocols│    │    │    │
│  │  │  └─────────────────────────────────┘    │    │    │
│  │  └─────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────┘    │
│                                                         │
│  Core (Network, Keychain, Calendar, Extensions)         │
│  └── Utility layer: any layer can import Core           │
└─────────────────────────────────────────────────────────┘
```

**Regla de oro**: Las dependencias apuntan SIEMPRE hacia adentro. Domain es el centro y no depende de nada externo.

### 13.2 Dependency Inversion in Practice

```swift
// ✅ CORRECTO: Domain define el protocolo
// Domain/Repositories/WhoopRepository.swift
protocol WhoopRepository {
    func getLatestRecovery(userId: UUID) async throws -> RecoveryData
    func getRecoveryTrend(userId: UUID, days: Int) async throws -> [RecoveryData]
    func getLatestSleep(userId: UUID) async throws -> SleepData
}

// ✅ CORRECTO: Data implementa el protocolo
// Data/Repositories/WhoopRepositoryImpl.swift
final class WhoopRepositoryImpl: WhoopRepository {
    private let apiClient: WhoopAPIClient
    private let supabase: SupabaseClient

    func getLatestRecovery(userId: UUID) async throws -> RecoveryData {
        // Implementation details here - Domain doesn't know about this
    }
}

// ✅ CORRECTO: UseCase depende del protocolo, no de la implementacion
// Domain/UseCases/GenerateBriefingUseCase.swift
struct GenerateBriefingUseCase {
    private let whoopRepo: WhoopRepository       // Protocol, not Impl
    private let calendarRepo: CalendarRepository  // Protocol, not Impl
}

// ✅ CORRECTO: ViewModel recibe UseCase, no Repository directamente
// Presentation/Briefing/BriefingViewModel.swift
@Observable
final class BriefingViewModel {
    private let generateBriefing: GenerateBriefingUseCase
    // ViewModel does NOT know about WhoopAPIClient or Supabase
}

// ❌ INCORRECTO: ViewModel importando Data layer
import WhoopAPIClient  // NEVER - ViewModel should not know about API details
```

### 13.3 Data Flow Direction

```
User Action → View → ViewModel → UseCase → Repository(Protocol)
                                                    ↓
                                           Repository(Impl) → API/DB
                                                    ↓
                                              Domain Model ←─┘
                                                    ↓
                                   ViewModel ← UseCase ← Repository
                                        ↓
                                  View (UI updates via @Observable)
```

**Reglas**:
- Views SOLO leen estado del ViewModel y envian acciones
- ViewModels transforman Domain Models en ViewState
- UseCases orquestan logica de negocio
- Repositories abstraen el origen de datos (API, DB, cache)
- DTOs se mapean a Domain Models en la capa Data, NUNCA pasan a Presentation

### 13.4 DTO → Domain Model Mapping

```swift
// ✅ DTOs solo existen en Data layer
// Data/DTOs/WhoopRecoveryDTO.swift
struct WhoopRecoveryDTO: Codable {
    let cycle_id: Int64
    let sleep_id: String?
    let user_id: Int64
    let score_state: String
    let score: ScoreDTO?

    struct ScoreDTO: Codable {
        let user_calibrating: Bool
        let recovery_score: Int
        let resting_heart_rate: Double
        let hrv_rmssd_milli: Double
        let spo2_percentage: Double?
        let skin_temp_celsius: Double?
    }
}

// ✅ Mapping extension lives in Data layer
extension WhoopRecoveryDTO {
    func toDomain() -> RecoveryData {
        RecoveryData(
            cycleId: cycle_id,
            sleepId: sleep_id.flatMap(UUID.init),
            scoreState: ScoreState(rawValue: score_state) ?? .unscorable,
            recoveryScore: score?.recovery_score,
            restingHeartRate: score?.resting_heart_rate,
            hrvRmssdMilli: score?.hrv_rmssd_milli,
            spo2Percentage: score?.spo2_percentage,
            skinTempCelsius: score?.skin_temp_celsius,
            isCalibrating: score?.user_calibrating ?? false
        )
    }
}

// ✅ Domain model uses Swift conventions (camelCase, strong types)
// Domain/Models/RecoveryData.swift
struct RecoveryData {
    let cycleId: Int64
    let sleepId: UUID?
    let scoreState: ScoreState
    let recoveryScore: Int?
    let restingHeartRate: Double?
    let hrvRmssdMilli: Double?
    let spo2Percentage: Double?
    let skinTempCelsius: Double?
    let isCalibrating: Bool

    var zone: RecoveryZone {
        guard let score = recoveryScore else { return .unknown }
        switch score {
        case 67...100: return .green
        case 34...66: return .yellow
        case 0...33: return .red
        default: return .unknown
        }
    }
}
```

---

## 14. Swift & SwiftUI Best Practices

### 14.1 SwiftUI View Guidelines

```swift
// ✅ RULE: Views should be small, focused, and composable
// Max ~40 lines per View body. If longer, extract subviews.

// ✅ Good: Composable, each piece is a separate view
struct BriefingView: View {
    let viewModel: BriefingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RecoveryScoreCard(score: viewModel.recoveryScore, zone: viewModel.zone)
                SleepSummaryCard(sleep: viewModel.sleepSummary)
                RecommendationsSection(items: viewModel.recommendations)
            }
            .padding()
        }
        .task { await viewModel.loadBriefing() }
        .refreshable { await viewModel.loadBriefing() }
    }
}

// ❌ Bad: Massive view body with inline logic
struct BriefingView: View {
    var body: some View {
        ScrollView {
            VStack {
                // 200 lines of nested views with inline conditionals...
            }
        }
    }
}
```

**View Composition Rules**:
- Each `View` has ONE responsibility
- Extract reusable components to `Shared/`
- Use `ViewModifier` for reusable styling, not copy-paste
- Keep `body` declarative: no heavy computation inside it
- Use `.task` for async loading, never `onAppear` with `Task {}`

### 14.2 @Observable ViewModel Pattern (iOS 17+)

```swift
// ✅ Standard ViewModel pattern for this project
@Observable
@MainActor
final class BriefingViewModel {

    // MARK: - State (observed by View automatically)
    private(set) var briefing: DayBriefing?
    private(set) var isLoading = false
    private(set) var error: ReadyDayError?

    var hasError: Bool { error != nil }
    var recoveryScore: Int { briefing?.recoveryScore ?? 0 }
    var zone: RecoveryZone { briefing?.recoveryZone ?? .unknown }

    // MARK: - Dependencies (injected)
    private let generateBriefing: GenerateBriefingUseCase

    // MARK: - Init
    init(generateBriefing: GenerateBriefingUseCase) {
        self.generateBriefing = generateBriefing
    }

    // MARK: - Actions
    func loadBriefing() async {
        isLoading = true
        error = nil
        do {
            briefing = try await generateBriefing.execute(for: .now, userId: currentUserId)
        } catch let err as ReadyDayError {
            error = err
        } catch {
            self.error = .unknown(underlying: error)
        }
        isLoading = false
    }
}
```

**ViewModel Rules**:
- Always `@Observable` + `@MainActor` (UI state must update on main thread)
- State properties are `private(set)` — Views read, only ViewModel writes
- Computed properties for derived state (avoid duplicating state)
- No `import SwiftUI` in ViewModels — they should be UI-framework agnostic
- Methods are the "actions" that Views call
- Error handling always produces a `ReadyDayError`, never raw `Error`

### 14.3 State Management Hierarchy

```swift
// @State: View-local state only (toggles, form inputs, animations)
@State private var showingSettings = false
@State private var selectedTab: Tab = .briefing

// @Observable ViewModel: Screen-level state (data, loading, errors)
// Injected via init or @Environment
let viewModel: BriefingViewModel

// @Environment: App-wide shared state (auth, theme, DI container)
@Environment(AuthManager.self) private var auth
@Environment(\.colorScheme) private var colorScheme

// NEVER use @State for data that comes from a ViewModel or network
// ❌ @State var recovery: RecoveryData?  // This belongs in ViewModel
```

### 14.4 Strict Concurrency & Sendable

```swift
// ✅ Domain models are value types (struct) → automatically Sendable
struct RecoveryData: Sendable { ... }
struct SleepData: Sendable { ... }
struct Recommendation: Sendable { ... }

// ✅ UseCases are structs with Sendable dependencies
struct GenerateBriefingUseCase: Sendable {
    let whoopRepo: any WhoopRepository & Sendable
    let calendarRepo: any CalendarRepository & Sendable
}

// ✅ ViewModels are @MainActor isolated
@Observable
@MainActor
final class BriefingViewModel { ... }

// ✅ Repository implementations use actor isolation or are Sendable
final class WhoopRepositoryImpl: WhoopRepository, Sendable {
    private let apiClient: WhoopAPIClient  // must also be Sendable
    private let supabase: SupabaseClient
}

// ✅ Use Task for fire-and-forget async work from sync context
func onPullToRefresh() {
    Task { await loadBriefing() }
}

// ✅ Use TaskGroup for parallel fetches
func loadDashboardData() async throws -> DashboardData {
    async let recovery = whoopRepo.getRecoveryTrend(userId: id, days: 7)
    async let sleep = whoopRepo.getSleepTrend(userId: id, days: 7)
    return DashboardData(
        recovery: try await recovery,
        sleep: try await sleep
    )
}

// ❌ NEVER: Blocking the main thread
// ❌ DispatchQueue.main.async { }  // Use @MainActor instead
// ❌ semaphore.wait()               // Use async/await instead
```

### 14.5 Naming Conventions

```swift
// Types: PascalCase
struct RecoveryData { }
enum RecoveryZone { }
protocol WhoopRepository { }
class BriefingViewModel { }

// Properties & methods: camelCase
let recoveryScore: Int
func loadBriefing() async { }
var isLoading: Bool

// Boolean properties: use is/has/should prefix
var isLoading: Bool
var hasError: Bool
var shouldShowOnboarding: Bool

// Constants: camelCase (NOT SCREAMING_SNAKE)
let maxRecommendations = 5
let tokenRefreshBuffer: TimeInterval = 300

// Files: match the primary type they contain
// RecoveryData.swift → struct RecoveryData
// BriefingViewModel.swift → class BriefingViewModel
// WhoopRepository.swift → protocol WhoopRepository

// Extensions: TypeName+Context.swift
// Date+Extensions.swift
// Color+Recovery.swift

// UseCases: VerbNounUseCase
// GenerateBriefingUseCase
// ClassifyEventDemandUseCase
// FindWorkoutWindowUseCase

// ViewModels: ScreenNameViewModel
// BriefingViewModel
// TimelineViewModel
// DashboardViewModel
```

### 14.6 SOLID Principles Applied

```swift
// S - Single Responsibility
// ✅ Each UseCase does ONE thing
struct GenerateBriefingUseCase { }     // Only generates briefings
struct ClassifyEventDemandUseCase { }  // Only classifies events
struct FindWorkoutWindowUseCase { }    // Only finds workout slots

// ❌ God UseCase that does everything
struct DoEverythingUseCase { }         // NEVER

// O - Open/Closed
// ✅ New recommendation rules = new struct, not modifying existing
protocol RecommendationRule {
    func evaluate(context: BriefingContext) -> Recommendation?
}
struct RecoveryRedRule: RecommendationRule { ... }
struct SleepDeficitRule: RecommendationRule { ... }
struct MeetingMarathonRule: RecommendationRule { ... }
// Adding new rule = new struct implementing protocol. No existing code changes.

// L - Liskov Substitution
// ✅ Any WhoopRepository implementation works identically
let repo: WhoopRepository = WhoopRepositoryImpl()     // Production
let repo: WhoopRepository = MockWhoopRepository()      // Testing
// Both satisfy the same contract

// I - Interface Segregation
// ✅ Focused protocols, not one massive protocol
protocol WhoopRepository {
    func getLatestRecovery(userId: UUID) async throws -> RecoveryData
    func getLatestSleep(userId: UUID) async throws -> SleepData
}
protocol CalendarRepository {
    func getEvents(for date: Date) -> [CalendarEvent]
}
// ❌ One protocol with 30 methods

// D - Dependency Inversion (see section 13.2)
// High-level modules (UseCases) depend on abstractions (protocols)
// Low-level modules (RepositoryImpl) implement those abstractions
```

---

## 15. Supabase Best Practices

### 15.1 Client Initialization

```swift
// ✅ Single shared Supabase client instance
// Data/Supabase/SupabaseManager.swift

import Supabase

@Observable
final class SupabaseManager: Sendable {

    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Configuration.supabaseURL)!,
            supabaseKey: Configuration.supabaseAnonKey
        )
    }
}

// ✅ Configuration from plist/xcconfig, NEVER hardcoded
// Core/Configuration.swift
enum Configuration {
    static var supabaseURL: String {
        Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
    }
    static var supabaseAnonKey: String {
        Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
    }
}

// ✅ Environment separation via Xcode schemes
// - ReadyDay-Dev.xcconfig  → dev Supabase project
// - ReadyDay-Prod.xcconfig → prod Supabase project
```

### 15.2 Authentication Pattern

```swift
// ✅ Auth state management
@Observable
@MainActor
final class AuthManager {
    private(set) var session: Session?
    private(set) var isAuthenticated = false

    private let supabase: SupabaseClient

    init(supabase: SupabaseClient = SupabaseManager.shared.client) {
        self.supabase = supabase
    }

    func signInWithApple(idToken: String, nonce: String) async throws {
        let session = try await supabase.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        self.session = session
        self.isAuthenticated = true
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
        session = nil
        isAuthenticated = false
    }

    func restoreSession() async {
        // Called on app launch - checks for existing valid session
        do {
            session = try await supabase.auth.session
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }
}
```

### 15.3 Query Patterns

```swift
// ✅ Type-safe queries with Codable models
struct RecoveryRow: Codable {
    let id: UUID
    let userId: UUID
    let recoveryScore: Int?
    let restingHeartRate: Double?
    let hrvRmssdMilli: Double?
    let scoreState: String
    let recordedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case recoveryScore = "recovery_score"
        case restingHeartRate = "resting_heart_rate"
        case hrvRmssdMilli = "hrv_rmssd_milli"
        case scoreState = "score_state"
        case recordedAt = "recorded_at"
    }
}

// ✅ Select only what you need, never SELECT *
let recoveries: [RecoveryRow] = try await supabase
    .from("recovery_data")
    .select("id, user_id, recovery_score, resting_heart_rate, hrv_rmssd_milli, score_state, recorded_at")
    .eq("user_id", value: userId)
    .eq("score_state", value: "SCORED")
    .order("recorded_at", ascending: false)
    .limit(7)
    .execute()
    .value

// ✅ Use .single() when expecting exactly one row
let latest: RecoveryRow = try await supabase
    .from("recovery_data")
    .select()
    .eq("user_id", value: userId)
    .eq("score_state", value: "SCORED")
    .order("recorded_at", ascending: false)
    .limit(1)
    .single()
    .execute()
    .value

// ✅ Upsert for webhook-driven data (idempotent)
try await supabase
    .from("recovery_data")
    .upsert(recoveryRow, onConflict: "user_id,whoop_cycle_id")
    .execute()

// ✅ RPC for complex queries (use Postgres functions)
let trend: [RecoveryTrendRow] = try await supabase
    .rpc("get_recovery_trend", params: ["p_user_id": userId, "p_days": 7])
    .execute()
    .value

// ❌ NEVER: String interpolation in queries (SQL injection risk)
// ❌ .eq("user_id", value: "\(someUserInput)")  // Use parameterized queries
```

### 15.4 RLS Best Practices

```sql
-- ✅ Principle: Deny by default, allow explicitly
-- RLS is enabled on ALL tables (already done in schema)

-- ✅ Separate policies per operation when needed
CREATE POLICY "Users can read own data" ON recovery_data
    FOR SELECT USING (user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid()));

CREATE POLICY "Service role can insert data" ON recovery_data
    FOR INSERT WITH CHECK (true);
    -- Edge Functions use service_role key, bypasses RLS
    -- Client-side inserts are blocked by this policy

-- ✅ NEVER use service_role key in iOS app
-- service_role bypasses ALL RLS — only use in Edge Functions

-- ✅ Test RLS policies with:
-- SET ROLE authenticated;
-- SET request.jwt.claims = '{"sub": "user-uuid"}';
-- SELECT * FROM recovery_data;  -- Should only return user's rows
```

### 15.5 Edge Functions Guidelines

```typescript
// ✅ Always validate input
const payload = await req.json()
if (!payload.type || !payload.user_id) {
    return new Response('Invalid payload', { status: 400 })
}

// ✅ Use service_role ONLY in Edge Functions, NEVER expose to client
const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!  // OK here, server-side only
)

// ✅ Handle errors and return proper HTTP status codes
try {
    // ... logic
    return new Response(JSON.stringify({ success: true }), { status: 200 })
} catch (error) {
    console.error('Webhook handler error:', error)
    return new Response(JSON.stringify({ error: 'Internal error' }), { status: 500 })
}

// ✅ Idempotent operations (webhooks may fire multiple times)
// Always use UPSERT, never INSERT for webhook data

// ✅ Keep Edge Functions small and focused (one function per concern)
// whoop-webhook/     → handles Whoop webhook events
// refresh-tokens/    → cron job for token refresh
// generate-briefing/ → generates and caches daily briefing
```

### 15.6 Migration & Environment Strategy

```
Environments:
├── Development  → Supabase project: readyday-dev
│   ├── Used for local development
│   ├── Test data, relaxed RLS for debugging
│   └── Free tier sufficient
│
├── Staging      → Supabase project: readyday-staging
│   ├── Mirrors production schema exactly
│   ├── Used for TestFlight builds
│   └── Pro tier (matches prod)
│
└── Production   → Supabase project: readyday-prod
    ├── Strict RLS, no debug access
    ├── Pro tier with backups enabled
    └── Point-in-time recovery enabled

Migration Strategy:
- SQL migrations versioned in: supabase/migrations/
- Format: YYYYMMDDHHMMSS_description.sql
- Applied via Supabase CLI: supabase db push
- NEVER modify production schema manually via dashboard
- All schema changes go through migration files in Git
```

---

## 16. Code Quality & Development Workflow

### 16.1 Git Workflow

```
Branch Strategy: GitHub Flow (simplified)

main ─────────────────────────────────────────── (always deployable)
  │
  ├── feature/onboarding-flow ──── PR → main
  ├── feature/briefing-engine ──── PR → main
  ├── feature/timeline-view ────── PR → main
  ├── fix/token-refresh-crash ──── PR → main
  └── chore/update-supabase-sdk ── PR → main

Branch Naming:
- feature/ → new features
- fix/     → bug fixes
- chore/   → maintenance, dependencies, config
- refactor/→ code restructuring, no behavior change

Commit Messages (Conventional Commits):
- feat: add morning briefing generation
- fix: token refresh failing on expired session
- refactor: extract recommendation rules to protocol
- chore: update supabase-swift to 2.5.0
- test: add briefing generation unit tests
```

### 16.2 Code Review Checklist

```
Before requesting review, verify:
□ Compiles with zero warnings
□ All existing tests pass
□ New logic has unit tests
□ No force unwraps (!) except in tests or clearly safe contexts
□ No print() statements (use os.Logger)
□ Follows layer dependency rules (section 13.1)
□ ViewModels don't import SwiftUI
□ DTOs don't leak to Presentation layer
□ Sensitive data not logged or stored in UserDefaults
□ Accessibility labels on interactive elements
□ Strings are localized (NSLocalizedString or String Catalogs)
```

### 16.3 Logging

```swift
import OSLog

// ✅ Use structured logging, one Logger per subsystem
extension Logger {
    static let auth = Logger(subsystem: "com.readyday.app", category: "auth")
    static let whoop = Logger(subsystem: "com.readyday.app", category: "whoop")
    static let briefing = Logger(subsystem: "com.readyday.app", category: "briefing")
    static let calendar = Logger(subsystem: "com.readyday.app", category: "calendar")
}

// ✅ Use appropriate log levels
Logger.whoop.debug("Fetching recovery for user \(userId)")
Logger.whoop.info("Recovery sync completed: \(count) records")
Logger.whoop.error("Token refresh failed: \(error.localizedDescription)")

// ❌ NEVER log sensitive data
// ❌ Logger.auth.debug("Token: \(accessToken)")
// ❌ Logger.auth.debug("User email: \(email)")

// ✅ Use privacy-aware interpolation
Logger.auth.debug("Token refresh for user: \(userId, privacy: .private)")
```

### 16.4 SwiftLint Configuration (Recommended)

```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace

opt_in_rules:
  - empty_count
  - closure_spacing
  - contains_over_filter_count
  - discouraged_optional_boolean
  - empty_string
  - fatal_error_message
  - first_where
  - force_unwrapping
  - implicitly_unwrapped_optional
  - last_where
  - modifier_order
  - overridden_super_call
  - private_action
  - private_outlet
  - unowned_variable_capture
  - vertical_whitespace_closing_braces

excluded:
  - Tests/

line_length:
  warning: 120
  error: 150

type_body_length:
  warning: 200
  error: 300

function_body_length:
  warning: 40
  error: 60

file_length:
  warning: 400
  error: 600

nesting:
  type_level: 2

identifier_name:
  min_length: 2
  excluded:
    - id
    - x
    - y
```

### 16.5 General Clean Code Rules

```swift
// ✅ Functions do ONE thing and are short (max ~40 lines)
func calculateCalendarLoad(events: [ClassifiedEvent]) -> Double { ... }

// ❌ Functions that do many things or are 200+ lines
func processEverything() { ... }

// ✅ Descriptive names over comments
func findAvailableWorkoutWindows(in gaps: [DateInterval], for zone: RecoveryZone) -> [TimeWindow]

// ❌ Cryptic names with comments explaining them
func proc(g: [DateInterval], z: Int) -> [TimeWindow]  // find workout windows

// ✅ Guard early, reduce nesting
func loadBriefing() async {
    guard let userId = session?.userId else { return }
    guard !isLoading else { return }
    // ... main logic at top level
}

// ❌ Deep nesting
func loadBriefing() async {
    if let userId = session?.userId {
        if !isLoading {
            // ... nested logic
        }
    }
}

// ✅ Prefer value types (struct, enum) over reference types (class)
struct RecoveryData { }      // immutable, Sendable, no shared state issues
enum RecoveryZone { }

// ✅ Use class only when identity/reference semantics are needed
// ViewModels (observed by Views) and Services (shared state) → class
@Observable final class BriefingViewModel { }

// ✅ Mark classes as final unless designed for inheritance
final class WhoopRepositoryImpl { }

// ✅ Avoid optionals when a default makes sense
struct UserPreferences {
    var morningBriefingEnabled: Bool = true  // ✅ default, not optional
    var workoutPrepMinutes: Int = 30         // ✅ default, not optional
    var selectedCalendarIds: [String]?       // ✅ optional makes sense here
}

// ✅ Use Result type or typed throws for clear error handling
func fetchRecovery() async throws(ReadyDayError) -> RecoveryData { ... }
```
