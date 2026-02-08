# ReadyDay - SDD: Functional Specifications

> Specs Driven Development Document v1.0
> Last Updated: 2026-02-07

---

## 1. Product Vision

**ReadyDay** es una app iOS que cruza datos fisiologicos reales de Whoop (recovery, sleep, strain) con tu calendario para generar un plan de dia optimizado. La app responde una pregunta simple: **"Dado como se siente mi cuerpo hoy, como deberia organizar mi dia?"**

### 1.1 Mission Statement

Ayudar a profesionales y atletas a tomar decisiones diarias mas inteligentes alineando su agenda con su estado fisiologico real, maximizando rendimiento y previniendo burnout.

### 1.2 Value Proposition (One-liner)

"Optimiza tu dia segun tu cuerpo" - ReadyDay cruza tus datos de Whoop con tu calendario para decirte cuando rendir al maximo y cuando recuperarte.

### 1.3 Target Audience

- **Primary**: Profesionales 25-45 anos, usuarios de Whoop, con agendas demandantes que buscan optimizar su rendimiento
- **Secondary**: Atletas amateur/semi-profesionales que equilibran entrenamiento con trabajo
- **Tertiary**: Ejecutivos/founders que priorizan su salud como ventaja competitiva

---

## 2. User Personas

### Persona 1: "Carlos" - Tech Lead (Primary)

- **Edad**: 32, Ciudad de Mexico
- **Contexto**: Lleva Whoop 1 ano, tiene 6-8 reuniones diarias, entrena CrossFit 4x/semana
- **Pain Point**: "Programo reuniones importantes en dias que amanezco destrozado y no rindo. Hago workouts intensos en dias que deberia descansar."
- **Goal**: Saber cada manana como distribuir su energia entre trabajo y ejercicio
- **Devices**: iPhone 15 Pro, Whoop 4.0

### Persona 2: "Maria" - Product Manager (Secondary)

- **Edad**: 28, Madrid
- **Contexto**: Whoop reciente, agenda caótica, corre 3x/semana, problemas de sueno
- **Pain Point**: "Siempre estoy cansada pero no se si es porque duermo mal o porque mi agenda es insostenible."
- **Goal**: Entender la relacion entre su sueno, su agenda, y como se siente
- **Devices**: iPhone 14, Whoop 4.0

### Persona 3: "James" - Founder/CEO (Tertiary)

- **Edad**: 40, San Francisco
- **Contexto**: Power user de Whoop, agenda de 12h, biohacker, viaja frecuentemente
- **Pain Point**: "Tengo los datos de Whoop y mi calendario, pero los analizo por separado. Quiero insights cruzados automaticos."
- **Goal**: Datos accionables que conecten su fisiologia con su productividad
- **Devices**: iPhone 16 Pro Max, Whoop 4.0, iPad Pro

---

## 3. Feature Specifications - MVP (v1.0)

### F-001: Onboarding & Authentication

**Descripcion**: Flujo de onboarding que conecta la cuenta de Whoop y el calendario del dispositivo.

**User Stories**:
- US-001: Como usuario nuevo, quiero crear una cuenta con Apple Sign In para empezar rapidamente
- US-002: Como usuario nuevo, quiero conectar mi cuenta de Whoop via OAuth para que la app acceda a mis datos
- US-003: Como usuario nuevo, quiero otorgar acceso a mi calendario para que la app lea mis eventos
- US-004: Como usuario nuevo, quiero ver un tutorial breve (3 pantallas max) que explique como funciona la app

**Acceptance Criteria**:
- [ ] Apple Sign In funciona y crea cuenta en Supabase
- [ ] OAuth flow de Whoop completa exitosamente y almacena tokens
- [ ] Permiso de calendario (EventKit) se solicita con explicacion clara
- [ ] Tutorial muestra valor inmediato en max 3 pantallas
- [ ] Si falla conexion con Whoop, muestra mensaje de error claro con retry
- [ ] Onboarding se puede completar en menos de 60 segundos

**Screens**:
1. Welcome screen con Apple Sign In
2. Conectar Whoop (OAuth web view)
3. Permiso de calendario con contexto
4. Tutorial rapido (3 slides)
5. Dashboard (destino final)

---

### F-002: Morning Briefing (Core Feature)

**Descripcion**: Cada manana, la app presenta un resumen accionable combinando recovery de Whoop con la agenda del dia.

**User Stories**:
- US-005: Como usuario, quiero ver mi recovery score al abrir la app para saber como amaneci
- US-006: Como usuario, quiero ver un resumen de mi sueno de anoche con metricas clave
- US-007: Como usuario, quiero ver mi agenda del dia con color-coding segun dificultad estimada
- US-008: Como usuario, quiero recibir recomendaciones personalizadas basadas en mi recovery + agenda
- US-009: Como usuario, quiero recibir una push notification matutina con mi briefing

**Acceptance Criteria**:
- [ ] Recovery score mostrado prominentemente con color (verde/amarillo/rojo)
- [ ] Resumen de sueno: duracion, eficiencia, HRV, RHR
- [ ] Timeline del dia mostrando eventos del calendario
- [ ] Cada evento categorizado por demanda estimada (alta/media/baja)
- [ ] Minimo 3 recomendaciones accionables generadas
- [ ] Carga en menos de 2 segundos
- [ ] Push notification configurable (hora, on/off)

**Recomendaciones Generadas (ejemplos por recovery zone)**:

Recovery ROJO (0-33%):
- "Tu recovery es 28%. Considera mover [Reunion de estrategia 2h] a otro dia."
- "Evita entrenamiento intenso hoy. Si entrenas, mantente en zona 1-2."
- "Prioriza hidratacion y bloques de descanso entre reuniones."

Recovery AMARILLO (34-66%):
- "Recovery moderada (52%). Tu dia es manejable pero evita sobre-cargarte."
- "Tienes un gap de 1h a las 3pm - ideal para una caminata o power nap."
- "El workout planificado esta bien, pero reduce intensidad 20%."

Recovery VERDE (67-100%):
- "Recovery excelente (85%). Dia ideal para deep work y entrenamiento intenso."
- "Mueve [Tarea creativa] a la manana para aprovechar tu pico cognitivo."
- "Tu slot de gym a las 6pm es perfecto. Puedes ir all-out hoy."

**Data Required**:
- Whoop: recovery score, sleep data (duration, efficiency, HRV, RHR, SpO2)
- Calendar: eventos del dia (titulo, hora, duracion, participantes count)

---

### F-003: Day Timeline View

**Descripcion**: Vista de timeline del dia que muestra eventos del calendario superpuestos con datos fisiologicos y recomendaciones.

**User Stories**:
- US-010: Como usuario, quiero ver mi dia como un timeline visual con mis eventos
- US-011: Como usuario, quiero que cada bloque de tiempo tenga un indicador de demanda energetica
- US-012: Como usuario, quiero ver gaps/oportunidades en mi agenda para descanso o ejercicio
- US-013: Como usuario, quiero poder ver el dia siguiente para planificar la noche anterior

**Acceptance Criteria**:
- [ ] Timeline vertical con bloques por hora (6am - 11pm default)
- [ ] Eventos del calendario mostrados como bloques con color por demanda
- [ ] Gaps identificados y marcados como oportunidades
- [ ] Indicador de "carga acumulada" a lo largo del dia
- [ ] Sugerencias insertadas en gaps relevantes
- [ ] Swipe para ver dia siguiente
- [ ] Pull to refresh para actualizar datos

**Demanda Energetica de Eventos (Heuristica v1)**:

La demanda se estima combinando:
- Duracion del evento (>1h = incrementa demanda)
- Numero de participantes (>5 = alta demanda cognitiva)
- Hora del dia (reuniones post-lunch = mayor fatiga)
- Titulo/keywords: "strategy", "review", "1:1" = alta; "standup", "sync" = media; "lunch", "break" = baja

Categorias:
- **Alta** (rojo): Reuniones largas, presentaciones, sesiones de estrategia
- **Media** (amarillo): Standups, syncs, trabajo regular
- **Baja** (verde): Breaks, lunch, eventos sociales ligeros

---

### F-004: Recovery Dashboard

**Descripcion**: Dashboard detallado de metricas de Whoop con trends historicos.

**User Stories**:
- US-014: Como usuario, quiero ver mi historico de recovery de los ultimos 7/30 dias
- US-015: Como usuario, quiero ver trends de HRV, RHR, y sueno
- US-016: Como usuario, quiero entender que factores afectan mi recovery (correlaciones)

**Acceptance Criteria**:
- [ ] Grafico de recovery scores ultimos 7/30 dias
- [ ] Graficos de HRV y RHR con trend lines
- [ ] Sleep duration vs sleep need comparativo
- [ ] Indicadores de tendencia (mejorando/estable/empeorando)
- [ ] Tap en cualquier dia para ver detalle

**Data Required**:
- Whoop: recovery historico, sleep historico, HRV trends, RHR trends

---

### F-005: Smart Notifications

**Descripcion**: Sistema de notificaciones inteligentes que alertan en momentos clave.

**User Stories**:
- US-017: Como usuario, quiero una notificacion matutina con mi briefing diario
- US-018: Como usuario, quiero ser alertado antes de una reunion de alta demanda si mi recovery es baja
- US-019: Como usuario, quiero recibir sugerencias de descanso cuando acumulo muchas horas de reuniones

**Acceptance Criteria**:
- [ ] Morning briefing notification (hora configurable, default 7:30am)
- [ ] Pre-meeting alert 15min antes si recovery < 50% y evento es alta demanda
- [ ] Break suggestion despues de 3+ horas consecutivas de reuniones
- [ ] Todas las notificaciones son configurables (on/off por tipo)
- [ ] Deep link desde notification a la vista relevante

---

### F-006: Settings & Profile

**Descripcion**: Configuracion de la app, manejo de conexiones y preferencias.

**User Stories**:
- US-020: Como usuario, quiero configurar la hora de mi morning briefing
- US-021: Como usuario, quiero poder desconectar/reconectar mi Whoop
- US-022: Como usuario, quiero elegir que calendarios incluir (trabajo, personal, etc.)
- US-023: Como usuario, quiero configurar que tipo de notificaciones recibo
- US-024: Como usuario, quiero poder exportar mis datos
- US-025: Como usuario, quiero poder eliminar mi cuenta y todos mis datos

**Acceptance Criteria**:
- [ ] Morning briefing time picker
- [ ] Whoop connection status con reconnect option
- [ ] Calendar selector (multi-calendar support)
- [ ] Notification preferences por tipo
- [ ] Data export (JSON/CSV)
- [ ] Account deletion con confirmacion (GDPR/privacy compliance)
- [ ] App version y links a privacy policy/terms

---

### F-007: Workout Window Finder

**Descripcion**: Encuentra el mejor momento para entrenar basado en recovery + calendario.

**User Stories**:
- US-026: Como usuario, quiero que la app me sugiera la mejor hora para entrenar hoy
- US-027: Como usuario, quiero saber que tipo de entrenamiento es apropiado segun mi recovery

**Acceptance Criteria**:
- [ ] Analiza gaps en calendario y sugiere top 3 ventanas para workout
- [ ] Cada sugerencia incluye tipo de entrenamiento recomendado
- [ ] Recovery verde: any workout, recovery amarillo: moderate, recovery rojo: active recovery only
- [ ] Considera tiempo de commute/preparation (configurable, default 30min)

---

## 4. Non-Functional Requirements - MVP

### NFR-001: Performance
- App launch to content: < 2 segundos (cached), < 4 segundos (fresh)
- Morning briefing generation: < 3 segundos
- Smooth scrolling 60fps en timeline view

### NFR-002: Reliability
- App debe funcionar con datos cached si no hay internet (modo offline basico)
- Whoop OAuth token refresh automatico sin intervencion del usuario
- Graceful degradation si Whoop API no esta disponible

### NFR-003: Security & Privacy
- Datos de salud encriptados at rest y in transit
- Apple Sign In como unico metodo de auth (simplifica MVP)
- Row Level Security en Supabase (usuario solo ve sus datos)
- No compartir datos con terceros
- Cumplimiento con Apple Health data guidelines
- GDPR: derecho al olvido implementado

### NFR-004: Compatibility
- iOS 17.0+ (minimo) - permite usar @Observable, latest SwiftUI features
- iPhone only para MVP (iPad en v2)
- Light & Dark mode support
- Dynamic Type support (accessibility)

### NFR-005: Scalability
- Arquitectura preparada para 10,000+ usuarios
- Supabase connection pooling configurado
- Batch processing para sync de datos historicos

---

## 5. User Flows

### Flow 1: First Time User (Onboarding)

```
[App Store Download]
    |
[Welcome Screen]
    |
[Apple Sign In] --> [Error] --> [Retry/Cancel]
    |
[Cuenta creada en Supabase]
    |
[Conectar Whoop] --> [OAuth WebView] --> [Error] --> [Retry/Skip]
    |                                        |
    |                                [Tokens stored]
    |
[Permiso Calendario] --> [Denied] --> [Explain why + Settings link]
    |
[Tutorial (3 screens)]
    |
[Morning Briefing / Dashboard]
```

### Flow 2: Daily Usage (Morning)

```
[Push Notification: "Tu briefing esta listo"]
    |
[Open App]
    |
[Auto-fetch: Recovery + Sleep + Calendar]
    |
[Morning Briefing Screen]
    |-- [Recovery Score + Color Zone]
    |-- [Sleep Summary]
    |-- [Today's Agenda (color-coded)]
    |-- [3+ Recommendations]
    |
[Tap Timeline] --> [Day Timeline View]
    |
[Tap Recommendation] --> [Deep link to action]
```

### Flow 3: Pre-Meeting Alert

```
[Background: Recovery < 50%]
    |
[Calendar event in 15 min = high demand]
    |
[Push Notification: "Reunion de estrategia en 15min. Tu recovery es 42%. Considera..."]
    |
[Tap] --> [Morning Briefing with event highlighted]
```

---

## 6. Content Strategy

### Tone of Voice
- **Supportive, not prescriptive**: "Considera mover..." no "Debes mover..."
- **Data-backed**: Siempre referenciar el dato que respalda la recomendacion
- **Conciso**: Recomendaciones de 1-2 lineas max
- **Positivo**: Enfocar en oportunidades, no en limitaciones

### Localization (MVP)
- English (primary) - mercado mas grande de Whoop users
- Spanish (secondary) - facil de implementar desde el inicio

---

## 7. Analytics Events (MVP)

| Event | Trigger | Properties |
|-------|---------|------------|
| `onboarding_started` | Welcome screen viewed | - |
| `onboarding_whoop_connected` | OAuth success | time_to_connect |
| `onboarding_calendar_granted` | Permission granted | calendars_count |
| `onboarding_completed` | Tutorial finished | total_time |
| `briefing_viewed` | Morning briefing opened | recovery_zone, source(notification/organic) |
| `recommendation_tapped` | Recommendation interacted | rec_type, recovery_zone |
| `timeline_viewed` | Timeline opened | day(today/tomorrow) |
| `workout_window_viewed` | Workout finder opened | recovery_zone |
| `notification_opened` | Any notification tapped | notification_type |
| `settings_changed` | Any setting modified | setting_name, new_value |

---

## 8. MVP Scope Exclusions (Future Versions)

Estas features NO estan en el MVP pero estan en el roadmap:

- **v1.1**: Weekly digest email/notification con insights
- **v1.2**: Modelo D (RestoreAI) - auto-restructuracion de agenda
- **v1.5**: AI-powered insights con LLM (Claude/GPT)
- **v2.0**: iPad support con dashboard expandido
- **v2.0**: Apple Watch complication
- **v2.5**: Social/Teams features
- **v3.0**: Integraciones adicionales (Oura, Garmin, Apple Watch nativo)
- **v3.0**: B2B/Teams dashboard
