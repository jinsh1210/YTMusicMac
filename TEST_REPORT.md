# Test Report / 테스트 리포트

[English](#-english) | [한국어](#-한국어)

---

## 🇺🇸 English

### [2026-04-26] - v0.2.0 Floating Player & Playback Enhancements

- **Scope**: Floating Player UI, playback status tracking (time, shuffle, repeat), window coordination, settings view.
- **Results**:
    - [PASS] Floating Player toggle and always-on-top behavior
    - [PASS] Playback time and duration tracking from WebView
    - [PASS] Shuffle and Repeat mode status synchronization
    - [PASS] Album art fetching with proper headers (User-Agent fix)
    - [PASS] WindowCoordinator main/mini view switching
    - [PASS] Settings view presentation
- **Notes**: Tested on macOS 14.x. Mini player is highly responsive and album art loading is now stable.

---

### [2026-04-19] - v0.1.25 Scrollbar & Release Script Optimization

- **Scope**: Scrollbar CSS color refinement, MutationObserver performance, Release script UX.
- **Results**:
    - [PASS] Refined scrollbar track color to #0f0f0f (matches YT Music theme)
    - [PASS] Optimized MutationObserver to target document.head only
    - [PASS] Verified DMG creation with /Applications shortcut
- **Notes**: Improved overall UI consistency and localized deployment reliability.

---

### [2026-04-19] - v0.1.24 Scrollbar Background Final Fix

- **Scope**: AppKit NSAppearance force dark, NSScrollView background styling.
- **Results**:
    - [PASS] Verified scrollbar background remains black regardless of system theme
    - [PASS] Confirmed elimination of white background in the main scroll area
- **Notes**: Achieved consistent dark appearance by targeting the root causes at the AppKit level.

---

### [2026-04-19] - v0.1.23 Scrollbar UI Fix

- **Scope**: MutationObserver for CSS injection, scrollbar background styling.
- **Results**:
    - [PASS] Verified CSS remains applied after SPA navigation
    - [PASS] Confirmed atDocumentStart injection avoids white flicker
- **Notes**: Successfully resolved the persistent white scrollbar background issue.

---

### [2026-04-19] - v0.1.22 Security Setting Adjustment

- **Scope**: Disabling Hardened Runtime for unsigned app updates.
- **Results**:
    - [PASS] Disabled Hardened Runtime in project.yml
    - [PASS] Verified automated build and deployment pipeline
- **Notes**: Adjusted security settings to potentially allow Sparkle updates to bypass strict macOS code signing requirements for unsigned applications.

---

### [2026-04-19] - v0.1.17 Sparkle Signature Fix

- **Scope**: Re-signing DMG with EdDSA private key.
- **Results**:
    - [PASS] Automated signature generation via GitHub Actions
    - [PASS] Verified appcast.xml update with correct edSignature
- **Notes**: Resolved "improperly signed" error by re-releasing with consistent signatures.

---

### [2026-04-19] - v0.1.16 Scrollbar UI & Signing Reliability

- **Scope**: Scrollbar CSS injection, CI Keychain bypass for Sparkle signing.
- **Results**:
    - [PASS] Custom CSS for dark mode scrollbar (eliminated white background)
    - [PASS] Sparkle signing using temporary key files in GitHub Actions
    - [PASS] Refactored large JS string to satisfy SwiftLint function_body_length
- **Notes**: Successfully resolved persistent UI layout issues and stabilized the automated release pipeline.

---

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

### [2026-04-26] - v0.2.0 플로팅 플레이어 및 재생 기능 강화

- **범위**: 플로팅 플레이어 UI, 재생 상태 추적 (시간, 셔플, 반복), 윈도우 관리, 설정 뷰.
- **결과**:
    - [PASS] 플로팅 플레이어 토글 및 항상 위 기능 확인
    - [PASS] WebView로부터 재생 시간 및 총 시간 추적 확인
    - [PASS] 셔플 및 반복 모드 상태 동기화 확인
    - [PASS] 헤더 추가를 통한 앨범 아트 로딩 안정성 확인
    - [PASS] WindowCoordinator를 통한 메인/미니 뷰 전환 확인
    - [PASS] 설정 뷰 정상 표시 확인
- **특이사항**: macOS 14.x에서 테스트됨. 미니 플레이어의 응답성이 뛰어나며 앨범 아트 로딩이 안정화됨.

---

### [2026-04-19] - v0.1.25 스크롤바 및 배포 스크립트 최적화

- **범위**: 스크롤바 CSS 색상 조정, MutationObserver 성능 개선, 배포 스크립트 UX 향상.
- **결과**:
    - [PASS] 스크롤바 트랙 색상을 #0f0f0f로 조정 (YT Music 테마 일치)
    - [PASS] MutationObserver의 감시 대상을 head로 최적화 완료
    - [PASS] /Applications 바로가기가 포함된 DMG 생성 확인
- **특이사항**: 전체적인 UI 일관성 및 로컬 배포 안정성을 개선함.

---

### [2026-04-19] - v0.1.24 스크롤바 배경 최종 수정

- **범위**: AppKit NSAppearance 다크 모드 강제, NSScrollView 배경 스타일링.
- **결과**:
    - [PASS] 시스템 테마와 관계없이 스크롤바 배경이 검정색으로 유지됨을 확인
    - [PASS] 메인 스크롤 영역의 흰색 배경 제거 확인
- **특이사항**: AppKit 레벨에서 근본 원인을 해결하여 일관된 다크 테마 외관을 구현함.

---

### [2026-04-19] - v0.1.23 스크롤바 UI 수정

- **범위**: CSS 주입을 위한 MutationObserver 적용, 스크롤바 배경 스타일링.
- **결과**:
    - [PASS] SPA 네비게이션 후에도 CSS가 유지됨을 확인
    - [PASS] atDocumentStart 주입으로 흰색 깜빡임 현상 방지 확인
- **특이사항**: 지속되던 스크롤바 흰색 배경 문제를 최종적으로 해결함.

---

### [2026-04-19] - v0.1.22 보안 설정 조정

- **범위**: 서명되지 않은 앱 업데이트를 위해 Hardened Runtime 비활성화.
- **결과**:
    - [PASS] project.yml에서 Hardened Runtime 비활성화 완료
    - [PASS] 자동 빌드 및 배포 파이프라인 작동 확인
- **특이사항**: 서명되지 않은 앱에서 macOS의 엄격한 코드 서명 요구 사항을 우회하여 Sparkle 업데이트가 가능하도록 보안 설정을 조정함.

---

### [2026-04-19] - v0.1.17 Sparkle 서명 수정

- **범위**: EdDSA 개인 키를 사용하여 DMG 재서명.
- **결과**:
    - [PASS] GitHub Actions를 통한 자동 서명 생성 성공
    - [PASS] 올바른 edSignature를 포함한 appcast.xml 업데이트 확인
- **특이사항**: 서명 불일치로 인한 업데이트 오류를 해결하기 위해 재배포함.

---

### [2026-04-19] - v0.1.16 스크롤바 UI 및 서명 안정성

- **범위**: 스크롤바 CSS 주입, Sparkle 서명을 위한 CI 키체인 우회.
- **결과**:
    - [PASS] 다크 모드용 사용자 정의 스크롤바 CSS (흰색 배경 제거)
    - [PASS] GitHub Actions에서 임시 키 파일을 통한 Sparkle 서명 성공
    - [PASS] SwiftLint function_body_length 위반 해결을 위한 JS 문자열 리팩토링
- **특이사항**: 지속되던 UI 레이아웃 문제를 해결하고 자동화된 릴리즈 파이프라인을 안정화함.

---

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
