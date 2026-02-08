# ReadyDay - SDD: Design System

> Specs Driven Development Document v1.0
> Last Updated: 2026-02-07

---

## 1. Design Philosophy

### 1.1 Brand Essence

ReadyDay NO es una app de fitness ni de atletismo. Es un **optimizador diario inteligente** que conecta tu cuerpo con tu agenda. La experiencia visual debe transmitir:

- **Calma informada**: datos complejos presentados con claridad y serenidad
- **Confianza**: "sé exactamente como abordar mi dia"
- **Inteligencia sutil**: la app es smart, no agresiva
- **Energia matutina**: sensacion de amanecer, comienzo fresco, posibilidad

### 1.2 Diferenciacion Visual vs Whoop

| Aspecto | Whoop | ReadyDay |
|---------|-------|----------|
| Mood | Intenso, atletico, elite | Calmo, inteligente, accesible |
| Background | Negro puro (#0B0B0B) | Azul profundo / Blanco calido |
| Accent | Rojo intenso (#FF0100) | Indigo + Amber dorado |
| Tipografia | Bold, compacta | Rounded, legible, aireada |
| Iconografia | Minimal, tecnica | SF Symbols, friendly |
| Target feeling | "Soy un atleta de elite" | "Tengo el control de mi dia" |

### 1.3 Design Principles

1. **Clarity over decoration** — Cada pixel comunica algo util. Cero ornamento sin proposito.
2. **Glanceable** — El usuario entiende su estado en < 3 segundos al abrir la app.
3. **Recovery zones are the language** — Verde/amarillo/rojo es el vocabulario visual universal de la app.
4. **Native-first** — Seguir Apple HIG, usar componentes nativos, sentirse parte del ecosistema iOS.
5. **Accessible by default** — Contraste 4.5:1 minimo, Dynamic Type, VoiceOver labels.

---

## 2. Color System

### 2.1 Brand Colors

```
PRIMARY (Indigo)
├── indigo-50:  #EEF2FF   ← Light mode backgrounds
├── indigo-100: #E0E7FF
├── indigo-200: #C7D2FE
├── indigo-300: #A5B4FC
├── indigo-400: #818CF8
├── indigo-500: #6366F1   ← Primary brand color
├── indigo-600: #4F46E5   ← Primary buttons, CTAs
├── indigo-700: #4338CA
├── indigo-800: #3730A3
├── indigo-900: #312E81   ← Dark mode surfaces
└── indigo-950: #1E1B4B   ← Dark mode background

ACCENT (Amber)
├── amber-50:  #FFFBEB
├── amber-100: #FEF3C7
├── amber-200: #FDE68A
├── amber-300: #FCD34D
├── amber-400: #FBBF24   ← Highlights, badges, energy
├── amber-500: #F59E0B   ← Accent actions
└── amber-600: #D97706
```

### 2.2 Semantic Colors (Recovery Zones)

Estos colores NO son los de Whoop. Son tonos propios de ReadyDay, diferenciados intencionalmente.

```
RECOVERY GREEN (Ready)
├── Light: #10B981 (emerald-500)
├── Dark:  #34D399 (emerald-400)
├── Background Light: #ECFDF5 (emerald-50)
└── Background Dark:  #064E3B (emerald-900) @ 30% opacity

RECOVERY YELLOW (Moderate)
├── Light: #F59E0B (amber-500)
├── Dark:  #FBBF24 (amber-400)
├── Background Light: #FFFBEB (amber-50)
└── Background Dark:  #78350F (amber-900) @ 30% opacity

RECOVERY RED (Low)
├── Light: #EF4444 (red-500)
├── Dark:  #F87171 (red-400)
├── Background Light: #FEF2F2 (red-50)
└── Background Dark:  #7F1D1D (red-900) @ 30% opacity
```

### 2.3 Neutral Palette

```
NEUTRALS
├── white:    #FFFFFF
├── gray-50:  #F9FAFB   ← Light mode background
├── gray-100: #F3F4F6   ← Light mode card background
├── gray-200: #E5E7EB   ← Light mode borders
├── gray-300: #D1D5DB
├── gray-400: #9CA3AF   ← Secondary text (light)
├── gray-500: #6B7280   ← Tertiary text
├── gray-600: #4B5563
├── gray-700: #374151   ← Primary text (dark mode)
├── gray-800: #1F2937   ← Dark mode card background
├── gray-900: #111827   ← Dark mode background
└── gray-950: #030712   ← Dark mode deepest
```

### 2.4 SwiftUI Color Implementation

```swift
// Core/DesignSystem/Colors.swift

import SwiftUI

extension Color {

    // MARK: - Brand
    static let rdPrimary = Color("Primary")          // indigo-600 / indigo-400
    static let rdPrimaryLight = Color("PrimaryLight") // indigo-100 / indigo-900
    static let rdAccent = Color("Accent")             // amber-500 / amber-400

    // MARK: - Recovery Zones
    static let rdRecoveryGreen = Color("RecoveryGreen")
    static let rdRecoveryYellow = Color("RecoveryYellow")
    static let rdRecoveryRed = Color("RecoveryRed")
    static let rdRecoveryGreenBg = Color("RecoveryGreenBg")
    static let rdRecoveryYellowBg = Color("RecoveryYellowBg")
    static let rdRecoveryRedBg = Color("RecoveryRedBg")

    // MARK: - Surfaces
    static let rdBackground = Color("Background")         // gray-50 / gray-950
    static let rdSurface = Color("Surface")               // white / gray-800
    static let rdSurfaceElevated = Color("SurfaceElevated") // white / gray-700

    // MARK: - Text
    static let rdTextPrimary = Color("TextPrimary")       // gray-900 / gray-50
    static let rdTextSecondary = Color("TextSecondary")    // gray-500 / gray-400
    static let rdTextTertiary = Color("TextTertiary")      // gray-400 / gray-500

    // MARK: - Utility
    static let rdBorder = Color("Border")                  // gray-200 / gray-700
    static let rdShadow = Color.black.opacity(0.08)
}

// Recovery zone color helper
extension RecoveryZone {
    var color: Color {
        switch self {
        case .green: return .rdRecoveryGreen
        case .yellow: return .rdRecoveryYellow
        case .red: return .rdRecoveryRed
        case .unknown: return .rdTextTertiary
        }
    }

    var backgroundColor: Color {
        switch self {
        case .green: return .rdRecoveryGreenBg
        case .yellow: return .rdRecoveryYellowBg
        case .red: return .rdRecoveryRedBg
        case .unknown: return .rdSurface
        }
    }
}
```

**Nota**: Todos los colores se definen en `Assets.xcassets` con variantes Light/Dark usando los valores hex de arriba. Esto permite que SwiftUI adapte automaticamente segun el color scheme del sistema.

---

## 3. Typography

### 3.1 Type Scale

ReadyDay usa **SF Pro Rounded** como tipografia principal para transmitir accesibilidad y calidez. SF Pro (standard) se usa para datos numericos donde se necesita precision.

```
DISPLAY
├── displayLarge:  .largeTitle  (34pt, bold, rounded)    ← Recovery score number
└── displayMedium: .title       (28pt, bold, rounded)    ← Screen titles

HEADING
├── headingLarge:  .title2      (22pt, semibold, rounded) ← Section headers
├── headingMedium: .title3      (20pt, semibold, rounded) ← Card titles
└── headingSmall:  .headline    (17pt, semibold, rounded) ← Subsections

BODY
├── bodyLarge:     .body        (17pt, regular, rounded)  ← Primary content
├── bodyMedium:    .callout     (16pt, regular, rounded)  ← Card content
└── bodySmall:     .subheadline (15pt, regular, rounded)  ← Secondary content

CAPTION
├── captionLarge:  .footnote    (13pt, regular, rounded)  ← Labels, metadata
└── captionSmall:  .caption2    (11pt, regular, rounded)  ← Timestamps, units

DATA (SF Pro - no rounded, for numerical precision)
├── dataLarge:     .system(size: 48, weight: .bold, design: .default)  ← Big score
├── dataMedium:    .system(size: 24, weight: .semibold, design: .default) ← Metrics
└── dataSmall:     .system(size: 14, weight: .medium, design: .monospaced) ← Small numbers
```

### 3.2 SwiftUI Typography Implementation

```swift
// Core/DesignSystem/Typography.swift

import SwiftUI

extension Font {
    // Display
    static let rdDisplayLarge = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let rdDisplayMedium = Font.system(.title, design: .rounded, weight: .bold)

    // Heading
    static let rdHeadingLarge = Font.system(.title2, design: .rounded, weight: .semibold)
    static let rdHeadingMedium = Font.system(.title3, design: .rounded, weight: .semibold)
    static let rdHeadingSmall = Font.system(.headline, design: .rounded, weight: .semibold)

    // Body
    static let rdBodyLarge = Font.system(.body, design: .rounded)
    static let rdBodyMedium = Font.system(.callout, design: .rounded)
    static let rdBodySmall = Font.system(.subheadline, design: .rounded)

    // Caption
    static let rdCaptionLarge = Font.system(.footnote, design: .rounded)
    static let rdCaptionSmall = Font.system(.caption2, design: .rounded)

    // Data (standard SF Pro for precision)
    static let rdDataLarge = Font.system(size: 48, weight: .bold, design: .default)
    static let rdDataMedium = Font.system(size: 24, weight: .semibold, design: .default)
    static let rdDataSmall = Font.system(size: 14, weight: .medium, design: .monospaced)
}
```

---

## 4. Spacing & Layout

### 4.1 Spacing Scale (8pt grid)

```
spacing-1:   4pt    ← Inline spacing, icon-to-text
spacing-2:   8pt    ← Tight spacing within components
spacing-3:  12pt    ← Compact padding
spacing-4:  16pt    ← Standard padding, gaps between elements
spacing-5:  20pt    ← Card internal padding
spacing-6:  24pt    ← Section spacing
spacing-8:  32pt    ← Large section gaps
spacing-10: 40pt    ← Screen-level spacing
spacing-12: 48pt    ← Major visual separation
```

### 4.2 SwiftUI Spacing Implementation

```swift
// Core/DesignSystem/Spacing.swift

enum RDSpacing {
    static let xxxs: CGFloat = 4
    static let xxs: CGFloat = 8
    static let xs: CGFloat = 12
    static let sm: CGFloat = 16
    static let md: CGFloat = 20
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 48
}
```

### 4.3 Corner Radius

```
radius-sm:   8pt    ← Small buttons, tags, badges
radius-md:  12pt    ← Cards, input fields
radius-lg:  16pt    ← Large cards, bottom sheets
radius-xl:  20pt    ← Featured cards
radius-full: 9999pt ← Pills, circular elements
```

```swift
enum RDRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let full: CGFloat = 9999
}
```

### 4.4 Layout Guidelines

```
Screen Margins: 16pt horizontal (standard iOS)
Card Padding:   20pt internal
Card Gap:       12pt between cards
Section Gap:    24pt between sections
Tab Bar:        Standard iOS tab bar (native)
Navigation:     Standard iOS NavigationStack (native)
Safe Areas:     Always respect system safe areas
```

---

## 5. Component Specifications

### 5.1 Recovery Score Card (Hero Component)

El componente mas importante de la app. Es lo primero que ve el usuario.

```
┌──────────────────────────────────────────┐
│  ┌─────────┐                             │
│  │         │  Buenos dias, Carlos        │
│  │   72    │  Tu recovery es BUENA       │
│  │         │                             │
│  └─────────┘  Listo para un dia          │
│   ◯ ring      productivo                 │
│               ──────────────────         │
│               HRV        RHR      SpO2   │
│               48ms       58bpm    97%    │
└──────────────────────────────────────────┘

Specs:
- Background: zona.backgroundColor (sutil)
- Score number: .rdDataLarge, zona.color
- Ring: circular progress (0-100%), stroke 8pt, zona.color
- Greeting: .rdHeadingMedium, .rdTextPrimary
- Status text: .rdBodyMedium, .rdTextSecondary
- Metric pills: .rdDataSmall + .rdCaptionLarge
- Corner radius: radius-xl (20pt)
- Padding: spacing-5 (20pt)
- Shadow: 0 2pt 8pt rdShadow (light mode only)
```

```swift
// Presentation/Shared/RecoveryScoreCard.swift

struct RecoveryScoreCard: View {
    let score: Int
    let zone: RecoveryZone
    let userName: String
    let hrv: Double?
    let rhr: Double?
    let spo2: Double?

    var body: some View {
        HStack(spacing: RDSpacing.lg) {
            // Recovery ring with score
            RecoveryRing(score: score, zone: zone)
                .frame(width: 96, height: 96)

            VStack(alignment: .leading, spacing: RDSpacing.xxs) {
                Text(greeting)
                    .font(.rdHeadingMedium)
                    .foregroundStyle(.rdTextPrimary)

                Text(statusMessage)
                    .font(.rdBodyMedium)
                    .foregroundStyle(.rdTextSecondary)

                Divider().padding(.vertical, RDSpacing.xxs)

                // Metric pills
                HStack(spacing: RDSpacing.sm) {
                    MetricPill(label: "HRV", value: formatHRV(hrv), unit: "ms")
                    MetricPill(label: "RHR", value: formatRHR(rhr), unit: "bpm")
                    if let spo2 { MetricPill(label: "SpO2", value: "\(Int(spo2))", unit: "%") }
                }
            }
        }
        .padding(RDSpacing.md)
        .background(zone.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: RDRadius.xl))
    }
}
```

### 5.2 Recommendation Card

```
┌──────────────────────────────────────────┐
│  ⚠️  Recovery baja (28%)                 │
│                                          │
│  Tu cuerpo necesita recuperarse.         │
│  Prioriza tareas ligeras hoy.            │
│                                          │
│                            [Ver mas →]   │
└──────────────────────────────────────────┘

Specs:
- Icon: SF Symbol segun tipo (exclamationmark.triangle, bed.double, figure.run, calendar)
- Title: .rdHeadingSmall, .rdTextPrimary
- Body: .rdBodyMedium, .rdTextSecondary (max 2 lines)
- Action: .rdBodyMedium, .rdPrimary
- Background: .rdSurface
- Border: 1pt .rdBorder (light mode) / none (dark mode)
- Corner radius: radius-md (12pt)
- Padding: spacing-4 (16pt)
- Priority colors: high = left accent bar 3pt red, medium = amber, low = none

Type → SF Symbol mapping:
- .warning    → exclamationmark.triangle.fill
- .calendar   → calendar.badge.clock
- .workout    → figure.run
- .sleep      → bed.double.fill
- .positive   → checkmark.seal.fill
- .info       → lightbulb.fill
```

### 5.3 Timeline Event Block

```
09:00 ┃ ┌──────────────────────────┐
      ┃ │ 🔴 Q4 Strategy Review    │  ← High demand
      ┃ │    9:00 - 11:00 · 8 ppl  │
10:00 ┃ │                          │
      ┃ └──────────────────────────┘
11:00 ┃
      ┃ ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
      ┃   💡 Free: ideal para walk    ← Gap suggestion
      ┃ └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
12:00 ┃ ┌──────────────────────────┐
      ┃ │ 🟢 Team Lunch            │  ← Low demand
      ┃ │    12:00 - 13:00         │
      ┃ └──────────────────────────┘

Specs:
- Time labels: .rdCaptionLarge, .rdTextTertiary, monospacedDigit
- Timeline bar: 2pt wide, .rdBorder
- Event block background: .rdSurface
- Left accent: 4pt wide bar, demand.color
- Event title: .rdHeadingSmall, .rdTextPrimary
- Event meta: .rdCaptionLarge, .rdTextSecondary
- Demand dot: 8pt circle, demand.color
- Gap block: dashed border, .rdPrimaryLight background
- Gap suggestion: .rdBodySmall, .rdPrimary
- Corner radius: radius-md (12pt)
```

### 5.4 Sleep Summary Card

```
┌──────────────────────────────────────────┐
│  Sueno anoche                            │
│                                          │
│  7h 23m    ████████████░░ 85%            │
│  duracion          eficiencia            │
│                                          │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐    │
│  │ Deep │ │ REM  │ │Light │ │Awake │    │
│  │ 1h42 │ │ 2h05 │ │ 3h12 │ │ 24m  │    │
│  │ ████ │ │ ████ │ │ ████ │ │ ██   │    │
│  └──────┘ └──────┘ └──────┘ └──────┘    │
└──────────────────────────────────────────┘

Specs:
- Section title: .rdHeadingMedium, .rdTextPrimary
- Duration: .rdDataMedium, .rdTextPrimary
- Efficiency bar: height 6pt, radius-full, .rdPrimary fill
- Efficiency %: .rdDataSmall, .rdTextSecondary
- Stage labels: .rdCaptionLarge, .rdTextTertiary
- Stage values: .rdBodyMedium, .rdTextPrimary, semibold
- Stage mini bars: height 4pt, colors:
    Deep:  indigo-600
    REM:   indigo-400
    Light: indigo-200
    Awake: gray-300
- Background: .rdSurface
- Corner radius: radius-xl (20pt)
```

### 5.5 Metric Pill

```
┌──────────┐
│ HRV      │
│ 48 ms    │
└──────────┘

Specs:
- Label: .rdCaptionSmall, .rdTextTertiary, uppercased
- Value: .rdDataSmall, .rdTextPrimary
- Unit: .rdCaptionSmall, .rdTextTertiary
- Background: .rdBackground
- Corner radius: radius-sm (8pt)
- Padding: horizontal spacing-3 (12pt), vertical spacing-2 (8pt)
```

### 5.6 Trend Chart

```
Recovery (7 dias)
100 ┤
 75 ┤      ●───●
 50 ┤  ●──╱     ╲──●
 25 ┤ ╱                ╲──●
  0 ┤●
    └─┬──┬──┬──┬──┬──┬──┬─
     Lu Ma Mi Ju Vi Sa Do

Specs:
- Use Swift Charts (native)
- Line: 2.5pt, .rdPrimary, smooth interpolation
- Points: 6pt circle, .rdPrimary fill
- Area fill: .rdPrimary @ 10% opacity gradient to transparent
- Zone bands (background):
    0-33:  .rdRecoveryRedBg
    34-66: .rdRecoveryYellowBg
    67-100: .rdRecoveryGreenBg
- Grid lines: 0.5pt, .rdBorder
- Labels: .rdCaptionLarge, .rdTextTertiary
- Y axis: right side (standard for fitness charts)
- Animate on appear
```

### 5.7 Navigation Structure

```
TabView (3 tabs)
├── Tab 1: "Today" (house.fill)
│   └── NavigationStack
│       ├── BriefingView (Morning Briefing - home)
│       └── Push: EventDetailView, RecommendationDetail
│
├── Tab 2: "Timeline" (calendar.day.timeline.leading)
│   └── NavigationStack
│       ├── TimelineView (Day view)
│       └── Push: EventDetailView, WorkoutFinderView
│
├── Tab 3: "Trends" (chart.line.uptrend)
│   └── NavigationStack
│       ├── DashboardView (Recovery/Sleep trends)
│       └── Push: DayDetailView
│
└── Settings: via .toolbar gear icon on any tab

Tab Bar Specs:
- Standard iOS tab bar
- Selected: .rdPrimary
- Unselected: .rdTextTertiary
- Labels visible always
```

---

## 6. Iconography

### 6.1 SF Symbols (Primary Icon Set)

ReadyDay usa **exclusivamente SF Symbols** para consistencia con iOS y zero assets adicionales.

```
Navigation:
- house.fill                 → Today tab
- calendar.day.timeline.leading → Timeline tab
- chart.line.uptrend         → Trends tab
- gearshape                  → Settings

Recovery Zones:
- checkmark.seal.fill        → Green (ready)
- exclamationmark.circle.fill → Yellow (moderate)
- exclamationmark.triangle.fill → Red (low recovery)

Data Types:
- heart.fill                 → Heart rate / RHR
- waveform.path.ecg          → HRV
- bed.double.fill            → Sleep
- figure.run                 → Workout / Strain
- lungs.fill                 → SpO2
- thermometer.medium         → Skin temp

Actions:
- arrow.clockwise            → Refresh / Sync
- bell.fill                  → Notifications
- square.and.arrow.up        → Share / Export
- person.crop.circle         → Profile
- link                       → Connected / Whoop link

Recommendations:
- lightbulb.fill             → Insight / Tip
- calendar.badge.clock       → Calendar suggestion
- moon.stars.fill            → Sleep suggestion
- figure.walk                → Activity suggestion
```

### 6.2 Icon Rendering Rules

```swift
// ✅ Always use hierarchical or multicolor rendering
Image(systemName: "heart.fill")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.rdRecoveryRed)

// ✅ Use consistent sizes per context
// Navigation/Tab: 24pt
// Card icons: 20pt
// Inline: 16pt
// Badge: 12pt

// ✅ Always set symbol weight to match text
Image(systemName: "bed.double.fill")
    .fontWeight(.medium)  // match body text weight
```

---

## 7. Motion & Animation

### 7.1 Animation Principles

- **Purposeful**: Animaciones comunican cambio de estado, no solo decoran
- **Subtle**: Preferir transiciones suaves sobre animaciones llamativas
- **Native**: Usar `.animation(.spring)` de SwiftUI, no animaciones custom complejas

### 7.2 Standard Animations

```swift
// Core/DesignSystem/Animation.swift

extension Animation {
    /// Standard transition for content appearing
    static let rdAppear = Animation.spring(duration: 0.4, bounce: 0.15)

    /// Quick state change (toggle, button press)
    static let rdSnap = Animation.spring(duration: 0.2, bounce: 0.1)

    /// Chart/data animation on load
    static let rdChart = Animation.easeOut(duration: 0.6)

    /// Recovery ring fill animation
    static let rdRing = Animation.easeInOut(duration: 1.0)
}
```

### 7.3 Where to Animate

```
✅ DO animate:
- Recovery ring fill on appear (0→score, 1 second)
- Cards appearing in list (staggered fade-up, 0.05s delay each)
- Chart data drawing on appear
- Tab transitions
- Pull-to-refresh state changes
- Recovery zone color transitions (when data refreshes)

❌ DON'T animate:
- Navigation pushes (use system default)
- Text content changes (jarring to read)
- Skeleton loading (use simple opacity pulse)
- Anything that delays showing real content
```

### 7.4 Loading States

```
Loading Pattern: Skeleton → Content (no spinners for main content)

┌──────────────────────────────────────────┐
│  ┌─────────┐                             │
│  │  ░░░░░  │  ░░░░░░░░░░░░░░            │  ← Skeleton:
│  │  ░░░░░  │  ░░░░░░░░░░                │     rounded rects
│  │  ░░░░░  │                             │     .rdBorder color
│  └─────────┘  ░░░░░  ░░░░░  ░░░░░       │     pulse animation
└──────────────────────────────────────────┘     (opacity 0.4↔0.7)

For inline refreshes: subtle progress bar at top (like Safari)
For errors: error view replaces content area (not alert)
For empty state: illustration + message + CTA
```

---

## 8. Dark Mode Specifications

### 8.1 Philosophy

Dark mode NO es simplemente invertir colores. Es una experiencia distinta con sus propias reglas:

- **Background**: `gray-950` (#030712) — profundo pero no negro puro (reduce eye strain)
- **Surfaces**: Elevation = lighter shades (gray-800, gray-700) — mas alto = mas claro
- **Colors**: Recovery zone colors se ajustan (mas saturados en dark para mantener contraste)
- **Shadows**: Se eliminan en dark mode (no tienen sentido visual)
- **Borders**: Se usan en dark mode para definir cards (reemplazan shadows)

### 8.2 Elevation System

```
Dark Mode Elevation:
├── Level 0 (Background): gray-950 (#030712)
├── Level 1 (Card/Surface): gray-800 (#1F2937)
├── Level 2 (Elevated card): gray-700 (#374151)
└── Level 3 (Modal/Sheet): gray-700 (#374151) + 1pt gray-600 border

Light Mode Elevation:
├── Level 0 (Background): gray-50 (#F9FAFB)
├── Level 1 (Card/Surface): white (#FFFFFF) + shadow
├── Level 2 (Elevated card): white (#FFFFFF) + stronger shadow
└── Level 3 (Modal/Sheet): white (#FFFFFF) + overlay dimming
```

### 8.3 Color Adaptation Examples

```swift
// Assets.xcassets → Color Sets with Any/Dark variants:

"Primary":
  Any Appearance: #4F46E5 (indigo-600)
  Dark:           #818CF8 (indigo-400)  ← lighter in dark for contrast

"RecoveryGreen":
  Any Appearance: #10B981 (emerald-500)
  Dark:           #34D399 (emerald-400) ← more vibrant in dark

"TextPrimary":
  Any Appearance: #111827 (gray-900)
  Dark:           #F9FAFB (gray-50)

"Surface":
  Any Appearance: #FFFFFF
  Dark:           #1F2937 (gray-800)

"Border":
  Any Appearance: #E5E7EB (gray-200)
  Dark:           #374151 (gray-700)
```

---

## 9. Screen Layouts

### 9.1 Morning Briefing (Home)

```
┌─────────────────────────────────┐
│ ◀ ReadyDay    [today]    ⚙️     │ ← Navigation bar
├─────────────────────────────────┤
│                                 │
│ ┌─────────────────────────────┐ │
│ │                             │ │
│ │   Recovery Score Card       │ │ ← Hero component
│ │   (Section 5.1)             │ │    Full width
│ │                             │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  Sleep Summary Card         │ │ ← Sleep data
│ │  (Section 5.4)              │ │
│ └─────────────────────────────┘ │
│                                 │
│  Recommendations                │ ← Section header
│ ┌─────────────────────────────┐ │
│ │ Recommendation Card 1       │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ Recommendation Card 2       │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ Recommendation Card 3       │ │
│ └─────────────────────────────┘ │
│                                 │
│  Workout Windows                │ ← Section header
│ ┌─────────────────────────────┐ │
│ │ 🏃 10:30-11:30 · High OK    │ │ ← Compact cards
│ │ 🏃 16:00-17:30 · Moderate   │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  Next up: Team Standup 🟡   │ │ ← Next event preview
│ │  in 45 min · 15 min         │ │
│ └─────────────────────────────┘ │
│                                 │
├──────┬──────────┬───────────────┤
│ 🏠   │ 📅       │ 📈            │ ← Tab bar
│Today │ Timeline │ Trends        │
└──────┴──────────┴───────────────┘

Layout rules:
- ScrollView, vertical
- 16pt horizontal margins
- 12pt gap between cards
- 24pt gap between sections
- Pull-to-refresh enabled
- .task loads data on appear
```

### 9.2 Timeline View

```
┌─────────────────────────────────┐
│ ◀ Timeline  [Today ▼]   ⚙️     │ ← Date picker dropdown
├─────────────────────────────────┤
│                                 │
│  Day Load: ████████░░ 72/100   │ ← Calendar load bar
│  6 events · 2 high demand      │
│                                 │
│  08:00 ─────────────────────── │
│                                 │
│  09:00 ┃ ┌───────────────────┐ │
│        ┃ │🔴 Strategy Review │ │
│  10:00 ┃ │   9-11 · 8 people │ │
│        ┃ └───────────────────┘ │
│  11:00 ┃                       │
│        ┃ ┌ ─ ─ ─ ─ ─ ─ ─ ─ ┐ │
│        ┃   💡 Free 1h: walk?   │
│        ┃ └ ─ ─ ─ ─ ─ ─ ─ ─ ┘ │
│  12:00 ┃ ┌───────────────────┐ │
│        ┃ │🟢 Team Lunch      │ │
│  13:00 ┃ └───────────────────┘ │
│        ┃                       │
│  14:00 ┃ ┌───────────────────┐ │
│        ┃ │🟡 Sprint Planning │ │
│  15:00 ┃ └───────────────────┘ │
│        ┃                       │
│  ...                           │
│                                 │
├──────┬──────────┬───────────────┤
│ 🏠   │ 📅       │ 📈            │
│Today │ Timeline │ Trends        │
└──────┴──────────┴───────────────┘

Interactions:
- Swipe left: tomorrow
- Swipe right: yesterday (if available)
- Tap event: expand details
- Tap gap: show suggestions
```

### 9.3 Trends Dashboard

```
┌─────────────────────────────────┐
│ ◀ Trends    [7d / 30d]   ⚙️    │ ← Segmented control
├─────────────────────────────────┤
│                                 │
│  Recovery                       │
│  Avg: 62% · Trend: ↗ improving │
│ ┌─────────────────────────────┐ │
│ │                     ●       │ │
│ │         ●──●       ╱        │ │
│ │    ●──╱     ╲──●──╱         │ │ ← Swift Charts
│ │   ╱                         │ │    con zone bands
│ │  ●                          │ │
│ │ Lu Ma Mi Ju Vi Sa Do        │ │
│ └─────────────────────────────┘ │
│                                 │
│  HRV                            │
│  Avg: 45ms · Trend: → stable   │
│ ┌─────────────────────────────┐ │
│ │  [chart]                    │ │
│ └─────────────────────────────┘ │
│                                 │
│  Sleep                          │
│  Avg: 6h 48m · Need: 7h 30m   │
│ ┌─────────────────────────────┐ │
│ │  [stacked bar chart]        │ │ ← Sleep stages stacked
│ └─────────────────────────────┘ │
│                                 │
│  Resting Heart Rate             │
│  Avg: 58 bpm · Trend: ↘ good  │
│ ┌─────────────────────────────┐ │
│ │  [chart]                    │ │
│ └─────────────────────────────┘ │
│                                 │
├──────┬──────────┬───────────────┤
│ 🏠   │ 📅       │ 📈            │
│Today │ Timeline │ Trends        │
└──────┴──────────┴───────────────┘
```

### 9.4 Onboarding Flow

```
Screen 1: Welcome
┌─────────────────────────────────┐
│                                 │
│                                 │
│         [ReadyDay Logo]         │
│                                 │
│      Optimiza tu dia            │
│      segun tu cuerpo            │
│                                 │
│     Cruza tus datos de Whoop    │
│     con tu calendario para      │
│     rendir al maximo.           │
│                                 │
│                                 │
│  ┌─────────────────────────────┐│
│  │  Continue with Apple     │││
│  └─────────────────────────────┘│
│                                 │
│  By continuing you agree to     │
│  Terms & Privacy Policy         │
│                                 │
└─────────────────────────────────┘

Screen 2: Connect Whoop
┌─────────────────────────────────┐
│                                 │
│     [Whoop icon illustration]   │
│                                 │
│     Conecta tu Whoop            │
│                                 │
│     Necesitamos acceso a tu     │
│     recovery, sueno y strain    │
│     para generar tu briefing    │
│     diario.                     │
│                                 │
│  ┌─────────────────────────────┐│
│  │   Conectar Whoop   →       ││ ← Primary button
│  └─────────────────────────────┘│
│                                 │
│       Omitir por ahora          │ ← Text button
│                                 │
└─────────────────────────────────┘

Screen 3: Calendar Access
┌─────────────────────────────────┐
│                                 │
│     [Calendar illustration]     │
│                                 │
│     Accede a tu calendario      │
│                                 │
│     Leemos tu agenda para       │
│     entender la demanda de      │
│     tu dia y darte              │
│     recomendaciones             │
│     inteligentes.               │
│                                 │
│     Solo lectura. Nunca         │
│     modificamos tu calendario.  │
│                                 │
│  ┌─────────────────────────────┐│
│  │  Permitir acceso   →       ││
│  └─────────────────────────────┘│
│                                 │
└─────────────────────────────────┘

Screen 4: Ready!
┌─────────────────────────────────┐
│                                 │
│          ✓                      │
│                                 │
│     Todo listo                  │
│                                 │
│     Cada manana tendras tu      │
│     briefing personalizado.     │
│                                 │
│     ┌─────┐  ┌─────┐  ┌─────┐  │
│     │ 🟢  │  │ 🟡  │  │ 🔴  │  │ ← Zone previews
│     │Ready│  │ Mod │  │ Low │  │
│     └─────┘  └─────┘  └─────┘  │
│                                 │
│  ┌─────────────────────────────┐│
│  │  Ver mi briefing   →       ││
│  └─────────────────────────────┘│
│                                 │
└─────────────────────────────────┘
```

---

## 10. Buttons & Interactive Elements

### 10.1 Button Hierarchy

```swift
// Primary Button: main CTA per screen
// Background: .rdPrimary, text: white, radius-md, height 50pt
Button("Conectar Whoop") { }
    .buttonStyle(.rdPrimary)

// Secondary Button: alternative action
// Background: .rdPrimaryLight, text: .rdPrimary, radius-md, height 50pt
Button("Ver timeline") { }
    .buttonStyle(.rdSecondary)

// Tertiary Button: subtle action
// No background, text: .rdPrimary, underline optional
Button("Omitir por ahora") { }
    .buttonStyle(.rdTertiary)

// Destructive Button: dangerous actions
// Background: .rdRecoveryRed, text: white
Button("Eliminar cuenta") { }
    .buttonStyle(.rdDestructive)
```

```swift
// Core/DesignSystem/ButtonStyles.swift

struct RDPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.rdHeadingSmall)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.rdPrimary)
            .clipShape(RoundedRectangle(cornerRadius: RDRadius.md))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.rdSnap, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == RDPrimaryButtonStyle {
    static var rdPrimary: RDPrimaryButtonStyle { RDPrimaryButtonStyle() }
}
```

### 10.2 Interactive Element Sizes

```
Minimum tap target: 44x44pt (Apple HIG requirement)
Primary buttons: full width, 50pt height
Icon buttons: 44x44pt
Tab bar items: system default
List rows: min 44pt height
Segmented controls: system default
Toggle switches: system default (never custom)
```

---

## 11. Accessibility

### 11.1 Core Requirements

```swift
// ✅ Every interactive element has an accessibility label
RecoveryRing(score: 72, zone: .green)
    .accessibilityLabel("Recovery score: 72 percent, green zone, well recovered")

// ✅ Recovery colors always paired with text/icon (never color-only)
// The zone dot + text label together communicate state
HStack {
    Circle().fill(zone.color).frame(width: 8, height: 8)
    Text(zone.label)  // "Ready" / "Moderate" / "Low"
}

// ✅ Charts have accessibility representations
Chart { ... }
    .accessibilityLabel("Recovery trend over 7 days")
    .accessibilityChildren {
        ForEach(data) { point in
            Text("\(point.day): \(point.score) percent")
        }
    }

// ✅ Dynamic Type: all text uses system fonts (never hardcoded sizes)
// .rdHeadingMedium uses .title3 → scales automatically

// ✅ Reduce Motion: respect system setting
@Environment(\.accessibilityReduceMotion) var reduceMotion
// Skip ring fill animation, chart draw animation when enabled
```

### 11.2 Contrast Requirements

```
Minimum contrast ratios (WCAG AA):
- Normal text:  4.5:1
- Large text:   3:1
- UI components: 3:1

Our colors meet these requirements:
- .rdTextPrimary on .rdBackground: >12:1 ✓
- .rdTextSecondary on .rdBackground: >4.5:1 ✓
- .rdRecoveryGreen on .rdSurface: >4.5:1 ✓
- .rdRecoveryRed on .rdSurface: >4.5:1 ✓
- .rdPrimary on white: >4.8:1 ✓

Test with: Xcode Accessibility Inspector
```

---

## 12. App Icon & Branding

### 12.1 App Icon Concept

```
Concept: Abstract sunrise + checkmark (ready for the day)

Visual: A rounded square (standard iOS) with:
- Gradient background: indigo-600 → indigo-500 (top-left to bottom-right)
- Subtle amber glow at bottom center (sunrise feeling)
- White geometric mark combining:
  - A partial circle (representing recovery/cycle)
  - An upward checkmark integrated into the circle (ready/optimized)
- Clean, no text in icon

Color variants:
- Primary: indigo gradient + white mark
- Notification: same but small
- Settings: outlined version

DO NOT: include the word "ReadyDay" in the icon
DO NOT: use Whoop branding elements
DO NOT: use a literal sun or calendar icon (too generic)
```

### 12.2 Logo Usage

```
Logotype: "ReadyDay" in SF Pro Rounded Bold
- Primary: .rdTextPrimary (adapts to light/dark)
- On brand color: white
- Minimum size: 24pt
- Clear space: 8pt on all sides

Wordmark + icon: used together in onboarding and splash
Icon alone: app icon, tab bar, notifications
Wordmark alone: navigation title, settings header
```