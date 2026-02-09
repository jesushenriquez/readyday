# ReadyDay - SDD: MVP Roadmap, Testing & Sprint Plan

> Specs Driven Development Document v1.0
> Last Updated: 2026-02-07

---

## 1. MVP Definition

### 1.1 MVP Goal

Validar que usuarios de Whoop encuentran valor en cruzar sus datos fisiologicos con su calendario para optimizar su dia. Metrica de exito: **60% de usuarios activos abren la app al menos 5 de 7 dias.**

### 1.2 MVP Scope (IN)

| Feature | Priority | Ref |
|---------|----------|-----|
| Apple Sign In + Supabase Auth | P0 | F-001 |
| Whoop OAuth connection | P0 | F-001 |
| Calendar permission + read | P0 | F-001 |
| Onboarding tutorial (3 screens) | P1 | F-001 |
| Morning Briefing (core) | P0 | F-002 |
| Day Timeline View | P0 | F-003 |
| Recovery Dashboard (7-day) | P1 | F-004 |
| Morning push notification | P1 | F-005 |
| Workout Window Finder | P1 | F-007 |
| Settings (basic) | P1 | F-006 |

### 1.3 MVP Scope (OUT - Post-MVP)

| Feature | Target Version |
|---------|---------------|
| Pre-meeting smart alerts | v1.1 |
| 30-day trends + analytics | v1.1 |
| Weekly digest notification | v1.1 |
| Model D: Recovery-First Scheduler | v1.2 |
| AI-powered recommendations (LLM) | v1.5 |
| iPad support | v2.0 |
| Apple Watch complication | v2.0 |
| Social/Teams features | v2.5 |
| Multi-wearable support (Oura, Garmin) | v3.0 |
| B2B Teams dashboard | v3.0 |

---

## 2. Sprint Plan

### Pre-Sprint: Project Setup (3 dias)

**Objetivo**: Tener el proyecto configurado y listo para desarrollo.

| Task | Estimacion |
|------|-----------|
| Crear proyecto Xcode (iOS 17+, SwiftUI) | 1h |
| Configurar Swift Package Manager + dependencies | 1h |
| Crear cuenta Supabase + proyecto | 1h |
| Ejecutar SQL migrations (schema completo) | 2h |
| Configurar Supabase Auth con Apple Sign In | 2h |
| Registrar app en Whoop Developer Portal | 1h |
| Configurar OAuth redirect URI en Whoop | 1h |
| Setup repositorio Git + .gitignore + README | 1h |
| Crear estructura de carpetas del proyecto | 2h |
| Configurar PostHog para analytics | 1h |
| Setup Xcode Cloud o Fastlane basico | 2h |

**Entregable**: Proyecto compilable con estructura completa, Supabase conectado, Whoop app registrada.

---

### Sprint 1: Auth & Data Pipeline (2 semanas)

**Objetivo**: Usuario puede crear cuenta, conectar Whoop, y los datos fluyen a Supabase.

#### Semana 1: Authentication

| Task | Story | Estimacion |
|------|-------|-----------|
| Implementar SupabaseClient singleton | - | 3h |
| Implementar Apple Sign In flow | US-001 | 4h |
| Crear UserRepository + user creation en DB | US-001 | 3h |
| Implementar WhoopOAuthManager | US-002 | 8h |
| ASWebAuthenticationSession integration | US-002 | 4h |
| KeychainService para tokens | US-002 | 3h |
| Token refresh logic + auto-retry | US-002 | 4h |
| Onboarding UI (Welcome + Connect screens) | US-001, US-002 | 6h |
| **Tests**: Auth flow unit tests | - | 4h |

#### Semana 2: Data Pipeline

| Task | Story | Estimacion |
|------|-------|-----------|
| Implementar WhoopAPIClient (all endpoints) | - | 8h |
| DTOs: Recovery, Sleep, Workout, Cycle, Profile | - | 4h |
| WhoopRepository: fetch + store en Supabase | - | 6h |
| Initial data sync (last 30 days on first connect) | - | 4h |
| CalendarService: EventKit wrapper | US-003 | 4h |
| Calendar permission flow + UI | US-003 | 3h |
| CalendarRepository implementation | US-003 | 3h |
| Supabase Edge Function: webhook handler (basic) | - | 4h |
| **Tests**: API client tests with mocks | - | 4h |

**Sprint 1 Entregable**: App donde usuario crea cuenta, conecta Whoop, otorga calendario, y datos se sincronizan a Supabase. No hay UI de datos aun.

**Sprint 1 Demo Criteria**:
- [ ] Apple Sign In funcional
- [ ] Whoop OAuth completo con token storage
- [ ] Datos de recovery/sleep/workout en Supabase
- [ ] Calendario accesible
- [ ] Webhook handler recibiendo eventos

---

### Sprint 2: Morning Briefing (2 semanas)

**Objetivo**: La feature core funciona - el Morning Briefing.

#### Semana 3: Briefing Logic

| Task | Story | Estimacion |
|------|-------|-----------|
| Domain models: DayBriefing, Recommendation, etc. | - | 3h |
| ClassifyEventDemandUseCase | US-007 | 4h |
| GenerateBriefingUseCase | US-005-008 | 8h |
| RecommendationEngine (rule-based) | US-008 | 8h |
| FindWorkoutWindowUseCase | US-026, US-027 | 4h |
| BriefingRepository (generate + cache) | - | 3h |
| **Tests**: Briefing generation comprehensive tests | - | 6h |

#### Semana 4: Briefing UI

| Task | Story | Estimacion |
|------|-------|-----------|
| BriefingView (main screen) | US-005 | 6h |
| RecoveryScoreView (animated ring/card) | US-005 | 4h |
| SleepSummaryView | US-006 | 3h |
| RecommendationCardView | US-008 | 4h |
| BriefingViewModel | US-005-008 | 4h |
| Pull-to-refresh + loading states | - | 2h |
| Error states + empty states | - | 3h |
| Color system (recovery zones) | - | 2h |
| **Tests**: ViewModel tests + snapshot tests | - | 4h |

**Sprint 2 Entregable**: Morning Briefing completo y funcional. Usuario abre app y ve recovery, sueno, recomendaciones.

**Sprint 2 Demo Criteria**:
- [ ] Recovery score visible con color zone
- [ ] Sleep summary con metricas clave
- [ ] Recomendaciones generadas contextualmente
- [ ] Datos refrescandose correctamente
- [ ] Loading/error states funcionando

---

### Sprint 3: Timeline & Dashboard (2 semanas)

**Objetivo**: Timeline del dia y dashboard de trends.

#### Semana 5: Day Timeline

| Task | Story | Estimacion |
|------|-------|-----------|
| TimelineView (hora-por-hora) | US-010 | 8h |
| TimelineEventBlock (color por demanda) | US-011 | 4h |
| TimelineGapView (oportunidades) | US-012 | 3h |
| Swipe para dia siguiente | US-013 | 3h |
| TimelineViewModel | US-010-013 | 4h |
| Carga acumulada indicator | US-011 | 3h |
| WorkoutFinderView integration | US-026 | 4h |
| **Tests**: Timeline logic tests | - | 3h |

#### Semana 6: Recovery Dashboard

| Task | Story | Estimacion |
|------|-------|-----------|
| DashboardView layout | US-014 | 4h |
| TrendChartView (Swift Charts - recovery) | US-014 | 6h |
| HRV + RHR trend charts | US-015 | 4h |
| Sleep duration chart | US-015 | 3h |
| Trend indicators (arrows up/down/stable) | US-016 | 2h |
| Day detail on tap | US-016 | 3h |
| DashboardViewModel | US-014-016 | 4h |
| **Tests**: Chart data transformation tests | - | 3h |

**Sprint 3 Entregable**: App con timeline completo del dia y dashboard de metricas historicas.

**Sprint 3 Demo Criteria**:
- [ ] Timeline muestra eventos con color coding
- [ ] Gaps identificados visualmente
- [ ] Workout windows sugeridos
- [ ] Dashboard con graficos de 7 dias
- [ ] Trend indicators funcionando

---

### Sprint 4: Notifications, Settings & Polish (2 semanas)

**Objetivo**: Notificaciones, settings, y polish para lanzamiento.

#### Semana 7: Notifications & Settings

| Task | Story | Estimacion |
|------|-------|-----------|
| NotificationService setup | US-017 | 3h |
| Morning briefing local notification | US-017 | 4h |
| Notification permission flow | US-017 | 2h |
| Deep links desde notifications | US-017 | 3h |
| SettingsView completo | US-020-025 | 6h |
| Calendar selector (multi-calendar) | US-022 | 3h |
| Whoop reconnect flow | US-021 | 3h |
| Data export (JSON) | US-024 | 3h |
| Account deletion flow | US-025 | 4h |

#### Semana 8: Polish & Launch Prep

| Task | Story | Estimacion |
|------|-------|-----------|
| Dark mode support completo | NFR-004 | 4h |
| Dynamic Type / Accessibility audit | NFR-004 | 3h |
| Onboarding tutorial (3 screens) | US-004 | 4h |
| App icon + launch screen | - | 3h |
| Performance optimization (launch time) | NFR-001 | 3h |
| Offline mode / cached data handling | NFR-002 | 4h |
| Error handling comprehensive review | - | 3h |
| Localization (EN + ES) | - | 4h |
| App Store assets (screenshots, description) | - | 4h |
| Privacy policy + terms of service | - | 2h |
| Whoop app approval submission | - | 2h |
| TestFlight beta distribution | - | 2h |

**Sprint 4 Entregable**: App lista para TestFlight y submission a App Store + Whoop approval.

**Sprint 4 Demo Criteria**:
- [ ] Morning notification funcional
- [ ] Settings completos
- [ ] Dark mode impecable
- [ ] Accessibility basica
- [ ] Offline mode graceful
- [ ] 0 crashes en 24h de uso
- [ ] App Store metadata lista

---

## 3. Testing Strategy

### 3.1 Test Pyramid

```
        ┌─────────┐
        │  E2E /  │  ~5 tests
        │   UI    │  (critical flows)
        ├─────────┤
        │ Integr. │  ~15 tests
        │  Tests  │  (API + DB)
        ├─────────┤
        │         │
        │  Unit   │  ~60+ tests
        │  Tests  │  (logic, VMs, use cases)
        │         │
        └─────────┘
```

### 3.2 Unit Tests

| Module | What to Test | Priority |
|--------|-------------|----------|
| `ClassifyEventDemandUseCase` | Event classification logic with various inputs | P0 |
| `GenerateBriefingUseCase` | Briefing generation for each recovery zone | P0 |
| `RecommendationEngine` | All rule branches, edge cases | P0 |
| `FindWorkoutWindowUseCase` | Gap detection, recommendation logic | P1 |
| `WhoopOAuthManager` | Token refresh, expiry detection | P0 |
| `WhoopAPIClient` | Response parsing, error handling | P0 |
| `BriefingViewModel` | State management, data transformation | P1 |
| `TimelineViewModel` | Event ordering, gap calculation | P1 |
| `DashboardViewModel` | Trend calculation, data aggregation | P2 |
| `CalendarService` | Event fetching, filtering | P1 |

**Ejemplo test case (ClassifyEventDemandUseCase)**:

```swift
final class ClassifyEventDemandTests: XCTestCase {

    let sut = ClassifyEventDemandUseCase()

    func test_longMeetingWithManyAttendees_isHighDemand() {
        let event = MockEvent(
            title: "Q4 Strategy Review",
            duration: 7200,  // 2 hours
            attendees: 10,
            hour: 10
        )
        XCTAssertEqual(sut.classify(event: event), .high)
    }

    func test_shortStandup_isLowDemand() {
        let event = MockEvent(
            title: "Daily Standup",
            duration: 900,  // 15 min
            attendees: 3,
            hour: 9
        )
        XCTAssertEqual(sut.classify(event: event), .low)
    }

    func test_postLunchMeeting_getsExtraWeight() {
        let event = MockEvent(
            title: "Team Sync",
            duration: 3600,
            attendees: 5,
            hour: 14  // 2pm - post-lunch dip
        )
        // Same event at 10am would be medium, but post-lunch bump makes it high
        XCTAssertEqual(sut.classify(event: event), .high)
    }

    func test_lunchEvent_isLowDemand() {
        let event = MockEvent(
            title: "Team Lunch",
            duration: 3600,
            attendees: 6,
            hour: 12
        )
        XCTAssertEqual(sut.classify(event: event), .low)
    }
}
```

### 3.3 Integration Tests

| Test | What to Validate |
|------|-----------------|
| Whoop OAuth end-to-end | Token exchange, storage, refresh cycle |
| Supabase Auth + Apple Sign In | Account creation, session persistence |
| Data sync pipeline | Whoop API → DTO → Domain → Supabase → Read back |
| Webhook processing | Edge function receives event → DB updated |
| Calendar + Recovery cross-reference | Both data sources combine correctly in briefing |

### 3.4 UI Tests (XCUITest)

| Test | Flow |
|------|------|
| `test_onboarding_happyPath` | Welcome → Apple Sign In → Whoop → Calendar → Tutorial → Briefing |
| `test_onboarding_skipWhoop` | Welcome → Apple Sign In → Skip Whoop → Calendar → Limited briefing |
| `test_briefing_pullToRefresh` | Open app → Pull to refresh → Data updates |
| `test_timeline_swipeNextDay` | Timeline → Swipe left → Tomorrow's view |
| `test_settings_disconnectWhoop` | Settings → Disconnect → Confirmation → Status updated |

### 3.5 Performance Tests

| Metric | Target | How to Test |
|--------|--------|-------------|
| App launch (cold) | < 2s | XCTMetric + Instruments |
| Briefing generation | < 3s | Unit test with timing |
| Timeline render | 60fps | Instruments |
| Memory usage | < 100MB | Instruments |
| Battery impact | < 5% in 8h | Real device testing |

### 3.6 Quality Gates

Antes de cada merge a main:
- [ ] Todos los unit tests pasan
- [ ] 0 warnings del compilador
- [ ] SwiftLint clean (si configurado)
- [ ] Build exitoso en Xcode Cloud
- [ ] Code review aprobado

Antes de cada release:
- [ ] Todos los tests (unit + integration + UI) pasan
- [ ] Performance tests dentro de targets
- [ ] Accessibility audit manual
- [ ] Dark mode visual review
- [ ] 48h de TestFlight sin crashes

---

## 4. Release Strategy

### 4.1 Pre-Launch (Semana 8-9)

1. **Whoop App Approval**: Submit app para revision de Whoop (puede tomar 1-2 semanas)
2. **TestFlight Beta**: Invitar 10-20 beta testers (usuarios reales de Whoop)
3. **Beta Metrics**: Track daily opens, briefing views, time in app
4. **Bug fixes**: Iterar basado en feedback de beta

### 4.2 Launch (Semana 10)

1. **App Store Submission**: Con toda la metadata, screenshots, privacy labels
2. **Privacy Nutrition Labels**:
   - Data Linked to You: Name, Email, Health/Fitness (Whoop), Calendar
   - Data Used to Track You: None
3. **App Store Category**: Health & Fitness (primary), Productivity (secondary)
4. **Pricing**: Free download, premium features via in-app subscription
5. **Minimum iOS**: 17.0

### 4.3 Post-Launch Monitoring

| Metric | Tool | Alert Threshold |
|--------|------|----------------|
| Crash-free rate | Xcode Organizer | < 99% |
| DAU/MAU ratio | PostHog | < 30% |
| Briefing view rate | PostHog | < 50% DAU |
| Onboarding completion | PostHog | < 70% |
| App Store rating | App Store Connect | < 4.0 |
| API error rate | Supabase logs | > 5% |

---

## 5. Product Roadmap (Post-MVP)

### v1.1 - Enhanced Insights (4 semanas post-launch)

- Pre-meeting smart alerts (notification 15min antes si recovery baja)
- 30-day historical trends
- Weekly digest notification con resumen semanal
- Break suggestion notification (despues de 3h+ de reuniones)
- Calendar selector: elegir que calendarios incluir en el briefing (US-022)
- Data export: exportar datos del usuario en JSON (US-024)
- Contenido personalizado en morning notification (requiere Notification Service Extension para mostrar recovery score)
- Server-side account deletion via Supabase Edge Function (actualmente solo limpia datos locales)
- Bug fixes basados en feedback v1.0

### v1.2 - Model D: RestoreAI Integration (6 semanas)

- "Recovery Budget" concept: energia disponible vs demanda del dia
- Auto-sugerencias de restructuracion de agenda
- "What-if" scenarios: "Si mueves esta reunion, tu carga baja a X"
- Integration con Apple Shortcuts para acciones rapidas

### v1.5 - AI-Powered Insights (8 semanas)

- Integracion con Claude API para recomendaciones naturales y personalizadas
- Pattern detection: "Los martes despues de dormir <6h tu HRV cae 20%"
- Predictive recovery: "Basado en tu agenda de manana, deberias dormir 8h+"
- Conversational UI: preguntale a ReadyDay sobre tu rendimiento

### v2.0 - Platform Expansion (12 semanas)

- iPad support con dashboard expandido (multi-column layout)
- Apple Watch complication con recovery score
- Widget para Home Screen (recovery + top recommendation)
- HealthKit integration para datos complementarios
- Siri Shortcuts integration

### v2.5 - Social & Teams (16 semanas)

- Compartir insights anonimizados con coach/trainer
- Team dashboard (para empresas con Whoop Unite)
- Leaderboards opcionales (gamification)
- Coach mode: un coach puede ver metricas de sus atletas

### v3.0 - Multi-Platform (20+ semanas)

- Soporte para Oura Ring, Garmin, Apple Watch nativo
- B2B offering con admin dashboard
- API publica para integraciones terceros
- Android version (Flutter o KMP)

---

## 6. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Whoop rechaza app approval | Media | Alto | Seguir guidelines estrictamente, contactar dev support previo a submission |
| Whoop API rate limiting | Baja | Medio | Caching agresivo, sync inteligente, webhook-first approach |
| Whoop cambia API/pricing | Baja | Alto | Abstraction layer, multi-source roadmap (Oura, Garmin) |
| Low user retention | Media | Alto | Focus en daily value (morning briefing), push notifications, iteration rapida |
| Apple rejects app | Baja | Medio | Follow HIG, proper health data handling, clear privacy policy |
| Supabase downtime | Baja | Medio | Local caching, graceful degradation |
| Competidor lanza algo similar | Media | Medio | First mover advantage, iterate fast, build community |

---

## 7. Success Metrics (MVP)

### North Star Metric
**Weekly Active Users que ven el Morning Briefing 5+ dias/semana**

### Supporting Metrics

| Metric | Target (Month 1) | Target (Month 3) |
|--------|-------------------|-------------------|
| Downloads | 500 | 2,000 |
| Onboarding completion rate | 70% | 80% |
| DAU/MAU ratio | 30% | 40% |
| Briefing daily view rate | 50% of DAU | 65% of DAU |
| Average session duration | 2 min | 3 min |
| App Store rating | 4.0+ | 4.3+ |
| Crash-free sessions | 99%+ | 99.5%+ |
| Paid conversion (when added) | - | 5% |

---

## 8. Cost Estimation (MVP - Monthly)

| Service | Tier | Cost/Month |
|---------|------|------------|
| Supabase | Pro plan | $25 |
| Apple Developer Account | Annual / 12 | $8.25 |
| PostHog | Free tier (1M events) | $0 |
| Whoop Developer API | Free | $0 |
| Domain + email | Basic | $10 |
| **Total (pre-revenue)** | | **~$43/month** |

Nota: Costos escalan con usuarios, pero Supabase Pro soporta facilmente 10,000+ usuarios para este caso de uso.
