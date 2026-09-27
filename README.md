# KidWhisperer Watchman

Privacy-first parent safety app and wearable companion.

- On-device GPS + geofencing
- On-device cry detection (audio never leaves the device)
- Local alerts only — no required cloud, no account, no subscription
- Designed with COPPA / child-data minimization in mind

GitHub account: `lampermichael00`  
Public repo: https://github.com/lampermichael00/Kidwhisperer-watchman

## Quick start

```bash
git clone https://github.com/lampermichael00/Kidwhisperer-watchman.git
cd Kidwhisperer-watchman
flutter create . --project-name kidwhisperer_watchman --org com.kidwhisperer.watchman
flutter pub get
flutter run
```

`flutter create .` generates android/ and ios/ without overwriting lib/.
Merge `docs/android-manifest-snippet.xml` into `android/app/src/main/AndroidManifest.xml`.

See [docs/PRIVACY.md](docs/PRIVACY.md), [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), and [docs/ROADMAP.md](docs/ROADMAP.md).
