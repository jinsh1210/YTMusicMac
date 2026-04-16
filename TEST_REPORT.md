# Test Report / 테스트 리포트

[English](#-english) | [한국어](#-한국어)

---

## 🇺🇸 English

### [2026-04-17] - v0.1.0 Initial Release

- **Scope**: Core playback, Media key integration, Google Login, WebView security, Auto-update.
- **Results**:
    - [PASS] WebView Loading & YTMusic Redirect
    - [PASS] Google Account Login Flow
    - [PASS] Media Keys (Play/Pause, Next, Previous)
    - [PASS] MusicPlayerManager State Observation
    - [PASS] Entitlements & Hardened Runtime
    - [PASS] Sparkle Updater Integration
- **Notes**: Tested on macOS 14.4. Fixed deinit cleanup on MainActor to prevent race conditions.

---

## 🇰🇷 한국어

### [2026-04-17] - v0.1.0 초기 릴리스

- **범위**: 핵심 재생 기능, 미디어 키 통합, Google 로그인, WebView 보안, 자동 업데이트.
- **결과**:
    - [PASS] WebView 로딩 및 YTMusic 리다이렉트
    - [PASS] Google 계정 로그인 흐름
    - [PASS] 미디어 키 (재생/일시정지, 다음, 이전)
    - [PASS] MusicPlayerManager 상태 관찰
    - [PASS] 엔타이틀먼트 및 Hardened Runtime
    - [PASS] Sparkle 업데이트 도구 통합
- **특이사항**: macOS 14.4에서 테스트됨. 레이스 컨디션 방지를 위해 MainActor에서 deinit 정리를 수행하도록 수정함.
