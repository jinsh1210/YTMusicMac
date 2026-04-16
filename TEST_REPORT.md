# TEST REPORT

## [2026-04-17] - v0.1.0 Initial Release

- **Scope**: Core playback, Media key integration, Google Login, WebView security.
- **Results**:
    - [PASS] WebView Loading & YTMusic Redirect
    - [PASS] Google Account Login Flow
    - [PASS] Media Keys (Play/Pause, Next, Previous)
    - [PASS] MusicPlayerManager State Observation
    - [PASS] Entitlements & Hardened Runtime
- **Notes**: Tested on macOS 14.4. Fixed deinit cleanup on MainActor to prevent race conditions.
