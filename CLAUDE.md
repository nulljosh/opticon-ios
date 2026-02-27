# Opticon iOS - Claude Guide

## Overview
iOS companion for [Opticon](https://opticon.heyitsmejosh.com). Financial terminal with 5-tab navigation: Markets, Predictions, Portfolio, Alerts, Settings.

## Stack
- SwiftUI, iOS 17+, @Observable, Swift 6.0
- Swift Charts for price history
- URLSession with shared cookie storage
- Vercel backend (opticon.heyitsmejosh.com)
- xcodegen for project generation

## Architecture

```
ContentView (TabView shell)
  |-- MarketsView -> StockDetailView (Charts)
  |-- PredictionsView
  |-- PortfolioView
  |-- AlertsView -> CreateAlertSheet
  |-- SettingsView
  |
  +-- LoginSheet (modal)

AppState (@Observable) -- single source of truth
OpticonAPI (URLSession singleton) -- all network calls
```

## File Structure

```
API/OpticonAPI.swift       -- 9 API methods + PriceHistory model
Models/
  AppState.swift           -- @Observable state container
  Stock.swift              -- Hashable, custom decoder for optional fields
  User.swift               -- email, tier
  Portfolio.swift          -- totalValue, holdings
  WatchlistItem.swift      -- Supabase-backed
  Alert.swift              -- PriceAlert with Direction enum
  Market.swift             -- PredictionMarket with computed URL/volume
  FinanceData.swift        -- Full finance schema (accounts, budget, debt, goals, spending)
Views/
  MarketsView.swift        -- Search, watchlist section, NavigationLink to detail
  StockDetailView.swift    -- Swift Charts line/area, range picker, 52w stats
  PredictionsView.swift    -- Polymarket feed
  PortfolioView.swift      -- Holdings with gain/loss
  AlertsView.swift         -- CRUD, swipe delete, CreateAlertSheet
  SettingsView.swift       -- Account, tier, watchlist management
  LoginSheet.swift         -- Login/register toggle
  Components/
    StockRow.swift         -- Watchlist star toggle
    HoldingRow.swift       -- Portfolio holding display
    MarketCard.swift       -- Prediction market card with volume + link
ContentView.swift          -- TabView shell (5 tabs)
Helpers.swift              -- Color(hex:) extension
OpticonApp.swift           -- @main entry point
Tests/
  ModelTests.swift         -- Decode tests for all models + edge cases
  AppStateTests.swift      -- Auth guards, computed properties, state management
```

## Design
- Dark mode enforced
- Market colors: green #34c759 (up), red #ff3b30 (down)
- Accent: #0071e3 blue
- Watchlist star: #f5a623 amber
- Monospaced numbers throughout
- Ultra-thin material backgrounds on list rows
- No emojis

## API Endpoints Used
- `POST /api/auth?action=login` -- login
- `POST /api/auth?action=register` -- register
- `GET /api/auth?action=me` -- session check
- `POST /api/auth?action=logout` -- logout
- `GET /api/stocks` -- all stock quotes
- `GET /api/history?symbol=X&range=1y` -- price history
- `GET /api/portfolio?action=get` -- portfolio
- `GET/POST/DELETE /api/watchlist` -- watchlist CRUD
- `GET/POST/DELETE /api/alerts` -- alerts CRUD
- `GET /api/markets` -- Polymarket prediction markets

## Auth
- httpOnly cookie-based sessions (shared HTTPCookieStorage)
- Cookie name: `opticon_session`
- All auth-required methods guard on `isLoggedIn` before making API calls

## Build
```bash
xcodegen generate
open Opticon.xcodeproj
# Build: Cmd+B, Run: Cmd+R
```

## Test
```bash
xcodegen generate
xcodebuild test -scheme OpticonTests -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Roadmap
- [x] Cookie-based session auth
- [x] Registration flow
- [x] Live market data
- [x] Portfolio sync
- [x] Watchlist management
- [x] Price alerts CRUD
- [x] Swift Charts
- [x] Subscription tier display
- [x] Prediction markets
- [x] Stock search
- [x] 5-tab navigation
- [x] Test suite
- [ ] Push notifications for alerts
- [ ] Portfolio analytics charts
- [ ] Offline caching
