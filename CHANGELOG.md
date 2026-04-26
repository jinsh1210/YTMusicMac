# Changelog / 변경 이력

[English](#-english) | [한국어](#-한국어)

---

## 🇺🇸 English

### [0.2.0] - 2026-04-26

#### Added
- **Floating Player (Mini Player)**: Added a sleek, always-on-top mini player for quick control and album art display.
- **Enhanced Playback Tracking**: Now tracks current time, duration, shuffle state, and repeat mode.
- **Settings View**: New configuration panel for app-wide settings.
- **Window Coordination**: Improved window management for switching between main and mini player views.

#### Fixed
- **Album Art Loading**: Improved reliability of album art fetching with proper User-Agent and Referer headers.

### [0.1.25] - 2026-04-19

#### Fixed
- **Scrollbar UI Optimization**: Refined CSS colors to match YouTube Music dark theme (#0f0f0f) and optimized MutationObserver performance by targeting only the document head.

#### Changed
- **Release Process**: Improved local DMG creation script with path safety and automatic `/Applications` symbolic link inclusion.

### [0.1.24] - 2026-04-19

#### Fixed
- **Scrollbar UI (Final)**: Resolved the white background issue by forcing Dark Mode appearance at the AppKit level and applying solid black backgrounds to the WebView and ScrollView.

### [0.1.23] - 2026-04-19

#### Fixed
- **Scrollbar UI**: Improved CSS injection timing and robustness using MutationObserver to ensure the scrollbar background remains dark across all YouTube Music pages.

### [0.1.22] - 2026-04-19

#### Changed
- **Security Settings**: Disabled Hardened Runtime to improve update reliability for non-Apple Developer signed builds.

### [0.1.17] - 2026-04-19

#### Fixed
- **Sparkle Signing Fix**: Re-released with correct EdDSA signatures for improved auto-update reliability.

### [0.1.16] - 2026-04-19

#### Fixed
- **Scrollbar UI Fix**: Resolved the white background issue on the scrollbar and styled it for a cleaner dark mode appearance.
- **Sparkle Signing Reliability**: Improved CI/CD signing by using temporary key files, bypassing macOS keychain permission errors.

### [0.1.15] - 2026-04-17

### [0.1.8] - 2026-04-17

#### Fixed
- Resolved sidebar/scrollbar layout issues by enforcing desktop mode on every navigation action.
- Fixed a memory leak in the App entry point.
- Optimized performance with Content Rule List and JS DOM caching.

### [0.1.0] - 2026-04-17
...

---

## 🇰🇷 한국어

### [0.2.0] - 2026-04-26

#### 추가된 기능
- **플로팅 플레이어 (미니 플레이어)**: 앨범 아트 표시 및 간편 제어가 가능한 상단 고정형 미니 플레이어 추가.
- **향상된 재생 상태 추적**: 현재 재생 시간, 총 시간, 셔플 상태 및 반복 모드 추적 기능 추가.
- **설정 창**: 앱 설정을 위한 전용 설정 뷰 추가.
- **윈도우 코디네이션**: 메인 윈도우와 미니 플레이어 간의 전환 및 관리 로직 개선.

#### 수정된 기능
- **앨범 아트 로딩**: User-Agent 및 Referer 헤더 추가를 통해 앨범 아트 이미지 로딩 안정성 개선.

### [0.1.25] - 2026-04-19

#### 수정된 기능
- **스크롤바 UI 최적화**: YouTube Music 다크 테마(#0f0f0f)에 맞게 색상을 조정하고, MutationObserver의 대상을 head로 한정하여 성능을 최적화했습니다.

#### 변경된 기능
- **배포 프로세스**: 로컬 DMG 생성 스크립트에 경로 안전 로직 및 `/Applications` 바로가기 심볼릭 링크를 자동으로 포함하도록 개선했습니다.

### [0.1.24] - 2026-04-19

#### 수정된 기능
- **스크롤바 UI (최종)**: AppKit 레벨에서 다크 모드 외관을 강제하고 WebView 및 ScrollView에 검정색 배경을 적용하여 스크롤바의 흰색 배경 문제를 완전히 해결했습니다.

### [0.1.23] - 2026-04-19

#### 수정된 기능
- **스크롤바 UI**: MutationObserver를 사용하여 모든 페이지에서 스크롤바 배경이 다크 모드로 유지되도록 CSS 주입 로직을 개선했습니다.

### [0.1.22] - 2026-04-19

#### 변경된 기능
- **보안 설정**: Apple 개발자 서명이 없는 빌드의 업데이트 안정성을 높이기 위해 Hardened Runtime을 비활성화했습니다.

### [0.1.17] - 2026-04-19

#### 수정된 기능
- **Sparkle 서명 수정**: 자동 업데이트 안정성을 위해 EdDSA 서명을 다시 생성하여 재배포했습니다.

### [0.1.16] - 2026-04-19

#### 수정된 기능
- **스크롤바 UI 개선**: 스크롤바의 흰색 배경 문제를 해결하고 다크 모드에 최적화된 스타일을 적용했습니다.
- **Sparkle 서명 안정성 향상**: CI 환경에서 macOS 키체인 제약을 우회하기 위해 임시 키 파일을 사용하는 방식으로 서명 로직을 개선했습니다.

### [0.1.15] - 2026-04-17

#### 수정된 기능
- **완전 자동화된 Sparkle 업데이트**: GitHub Actions에서 EdDSA 서명을 생성하고 `appcast.xml`을 자동으로 갱신하는 프로세스를 최종 완성함.
- **CI 안정성 향상**: macOS 키체인 제약을 우회하기 위해 임시 키 파일을 사용하는 방식으로 서명 로직을 개선함.

### [0.1.8] - 2026-04-17

#### 수정된 기능
- 모든 네비게이션 시 데스크탑 모드를 강제하여 사이드바/스크롤바 레이아웃 이슈 해결.
- 앱 진입점의 메모리 누수 수정.
- 콘텐츠 규칙 및 JS DOM 캐싱을 통한 성능 최적화.

### [0.1.0] - 2026-04-17
...
