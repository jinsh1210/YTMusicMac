# Changelog / 변경 이력

[English](#-english) | [한국어](#-한국어)

---

## 🇺🇸 English

### [0.1.5] - 2026-04-17

#### Fixed
- Optimized User-Agent to standard Safari 17.5 to resolve Google's "Insecure Browser" blocking while avoiding forced Passkey prompts.
- Fixed sidebar auto-collapsing issue by increasing window `minWidth` to 1050px.
- Restored automatic redirection to `music.youtube.com` after successful Google Login.
- Resolved multiple SwiftLint violations and cleaned up codebase.

### [0.1.4] - 2026-04-17

#### Added
- Enhanced login flow with dedicated popup interface to improve Google Authentication stability.
- Automatic DMG ejection when app is launched from `/Applications` folder.
- Professional installer experience with custom DMG layout and Applications folder shortcut.

### [0.1.2] - 2026-04-17

#### Fixed
- Switched CI runner to `macos-15` for latest Xcode and project format support.
- Reduced `objectVersion` to `56` for broader Xcode compatibility.
- Cleaned up failed release tags and normalized repository state.

### [0.1.0] - 2026-04-17

#### Added
- Initial release of YTMusicMac.
- Native integration with media keys (Play/Pause, Next, Previous).
- Hybrid architecture with hidden `WKWebView` for YouTube Music.
- Optimized performance with debounced callbacks and third-party tracker blocking.
- SwiftLint and SwiftFormat integration for code quality.
- Secure entitlements configuration.
- Detailed README and documentation.
- Auto-update support via Sparkle.

---

## 🇰🇷 한국어

### [0.1.5] - 2026-04-17

#### 수정된 기능
- 구글의 "안전하지 않은 브라우저" 차단 문제를 해결하고 패스키 강제 호출을 방지하기 위해 User-Agent를 표준 Safari 17.5로 최적화.
- 창 최소 너비를 1050px로 상향하여 사이드바가 자동으로 접히는 현상 해결.
- 구글 로그인 완료 후 `music.youtube.com`으로 자동 복귀하는 리다이렉트 로직 복구.
- 모든 SwiftLint 위반 사항 수정 및 코드 베이스 정리.

### [0.1.4] - 2026-04-17

#### 추가된 기능
- Google 인증 안정성 향상을 위한 전용 팝업 인터페이스 적용.
- `/Applications` 폴더에서 실행 시 설치용 DMG 자동 추출(Eject) 기능 추가.
- 커스텀 DMG 레이아웃 및 응용 프로그램 폴더 바로가기를 통한 전문적인 설치 경험 제공.

### [0.1.2] - 2026-04-17

#### 수정된 기능
- 최신 Xcode 및 프로젝트 형식을 지원하기 위해 CI 러너를 `macos-15`로 전환.
- 광범위한 Xcode 호환성을 위해 `objectVersion`을 `56`으로 하향 조정.
- 실패한 릴리스 태그 정리 및 저장소 상태 정상화.

### [0.1.0] - 2026-04-17

#### 추가된 기능
- YTMusicMac 초기 릴리스.
- 미디어 키(재생/일시정지, 다음, 이전) 네이티브 통합.
- YouTube Music을 위한 숨겨진 `WKWebView` 기반 하이브리드 아키텍처.
- 콜백 디바운싱 및 서드파티 트래커 차단을 통한 성능 최적화.
- 코드 품질을 위한 SwiftLint 및 SwiftFormat 통합.
- 보안 엔타이틀먼트 설정.
- 상세 README 및 문서 작성.
- Sparkle을 통한 자동 업데이트 지원.
