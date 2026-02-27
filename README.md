# Opticon iOS

Native iOS companion for the [Opticon](https://opticon.heyitsmejosh.com) financial terminal. Live market data, portfolio tracking, and price alerts — wired directly to the Vercel API backend.

## Architecture

![Architecture](architecture.svg)

SwiftUI views observe `AppState` (@Observable). `AppState` delegates all network calls to `OpticonAPI`, a URLSession singleton with shared cookie storage for seamless session auth against the Vercel backend.

## Build

Requires [xcodegen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen
cd opticon-ios
xcodegen generate
open Opticon.xcodeproj
```

Build target: iOS 17.0+, Swift 6.0.

## Roadmap

- [x] Cookie-based session auth (login / logout / me)
- [x] Live market data from `/api/stocks`
- [x] Portfolio sync from `/api/portfolio`
- [ ] Watchlist management
- [ ] Price alerts with push notifications
- [ ] Charts (Swift Charts framework)
- [ ] Stripe subscription status display

## License

MIT 2026, Joshua Trommel
