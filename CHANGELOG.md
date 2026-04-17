# Changelog / 변경 이력

[English](#-english) | [한국어](#-한국어)

---

## 🇺🇸 English

### [0.1.16] - 2026-04-17

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

### [0.1.16] - 2026-04-17

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
