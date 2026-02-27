# Opticon iOS - Claude Guide

## Overview
iOS companion for [Opticon](https://github.com/nulljosh/opticon). Financial terminal with markets, portfolio, alerts.

## Stack
- SwiftUI, iOS 17+, @Observable
- FMP / Yahoo Finance API (shared with web)
- Vercel KV for portfolio sync

## Design
- Dark mode default
- Market colors: green #34c759 (up), red #ff3b30 (down)
- Accent: #0071e3 blue
- Monospaced numbers
- No emojis

## Roadmap
- [ ] Live market data from FMP API
- [ ] Portfolio sync with web app (KV-backed)
- [ ] Watchlist management
- [ ] Price alerts with push notifications
- [ ] Charts (Swift Charts framework)
- [ ] Stripe subscription status display

## Build
```bash
open OpticonApp.swift  # Opens in Xcode
```
