# HydroMind

A hydration tracker that knows coffee isn't water. Tracks different drink types with real hydration factors, syncs with HealthKit, and gamifies the boring act of drinking enough water.

## Features

- **Drink type awareness** — water, coffee, tea, juice, and more with accurate hydration multipliers
- **HealthKit integration** — reads and writes hydration data
- **Smart daily goals** adjusting for activity level
- **Streak tracking** with milestone celebrations
- **Unit conversion** — ml, oz, cups
- **Visual hydration timeline** showing intake throughout the day
- **Customizable quick-add buttons** for your regular drinks

## Tech Stack

- SwiftUI
- HealthKit
- SwiftData
- Charts framework
- StoreKit 2

## Getting Started

```bash
git clone https://github.com/sebastiandoyle/hydromind.git
cd hydromind
open *.xcodeproj
```

Requires Xcode 15+ and iOS 17+. Enable HealthKit capability in signing settings.

## How It Works

Not all liquids hydrate equally. HydroMind applies hydration factors to each drink type (coffee at ~0.8x, herbal tea at ~1.0x, alcohol at negative values) so your daily total reflects actual hydration, not just volume consumed.

## License

MIT
