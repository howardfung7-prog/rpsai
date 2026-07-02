# RPSAI — Rock·Paper·Scissors vs AI 🪨📄✂️

Play real-time Rock–Paper–Scissors against an AI using your webcam. Retro 90s pixel style.
Live at **[rpsai.io](https://rpsai.io)**.

## Features
- ✋ Real-time hand-gesture detection via MediaPipe (webcam)
- 👍 Thumbs-up gesture to start a round (hands-free)
- 🎭 Privacy masks (face-tracking overlays)
- 🌍 10 languages (auto-detected, RTL support)
- 🏆 Global & national leaderboards (Wilson score) — needs Supabase
- 🔒 Login (Google / email), editable username, SOL wallet binding
- 📷 Retro pixel score-card sharing (Web Share API)
- 🔥 Win-streak arcade effects (particles, shake, sound)
- 🧠 Player psychology analysis + 7 personality types (Wang et al. 2014 model)
- 🎯 Mind-Reader AI (win-stay/lose-shift prediction) + RPS IQ score
- ✅ Provably-fair commit–reveal + single-window lock (anti-cheat, client-side)

## Tech
Single static `index.html` (no build step). Loads MediaPipe Tasks Vision + Supabase JS from CDN.

## Deploy
Any static host with HTTPS (required for camera). See [DEPLOY.md](DEPLOY.md).
For login + leaderboards, configure Supabase — see [SETUP.md](SETUP.md) and [schema.sql](schema.sql).

## Files to deploy
`index.html`, `manifest.json`, `og.png`, `icon-192.png`, `icon-512.png`
