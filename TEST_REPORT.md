# Test Report / 테스트 리포트

[English](#-english) | [한국어](#-한국어)

---

## 🇺🇸 English

### [2026-04-17] - v0.1.4 Login & UX Improvements

- **Scope**: Google Auth popup flow, DMG Auto-eject logic.
- **Results**:
    - [PASS] Login state detection and blur UI interaction
    - [PASS] Automatic DMG unmounting from /Applications
    - [PASS] create-dmg professional installer layout
- **Notes**: Successfully resolved Google Auth stability concerns and improved the post-installation cleanup experience.

---

### [2026-04-17] - v0.1.2 CI & Compatibility Fix

- **Scope**: CI environment (macos-15), Xcode project format compatibility.
- **Results**:
    - [PASS] CI Runner upgrade to macOS-15 (Xcode 16 support)
    - [PASS] Project objectVersion reduction to 56 (Xcode 14+ compatibility)
    - [PASS] Remote tag cleanup (v0.1.0, v0.1.1)
- **Notes**: Resolved the "future Xcode project file format (77)" error by lowering objectVersion and upgrading the CI runner.

---

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

### [2026-04-17] - v0.1.4 로그인 및 UX 개선

- **범위**: Google 인증 팝업 흐름, DMG 자동 추출 로직.
- **결과**:
    - [PASS] 로그인 상태 감지 및 블러 UI 상호작용
    - [PASS] /Applications 에서 실행 시 DMG 자동 언마운트
    - [PASS] create-dmg 기반 전문 설치 레이아웃
- **특이사항**: Google 인증 안정성 문제를 해결하고 설치 후 정리 과정을 자동화하여 사용자 경험을 개선함.

---

### [2026-04-17] - v0.1.2 CI 및 호환성 수정

- **범위**: CI 환경 (macos-15), Xcode 프로젝트 형식 호환성.
- **결과**:
    - [PASS] CI 러너를 macOS-15로 업그레이드 (Xcode 16 지원)
    - [PASS] 프로젝트 objectVersion을 56으로 하향 조정 (Xcode 14+ 호환)
    - [PASS] 원격 태그 정리 (v0.1.0, v0.1.1)
- **특이사항**: objectVersion 하향 조정 및 CI 러너 업그레이드를 통해 "future Xcode project file format (77)" 오류를 해결함.

---

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
