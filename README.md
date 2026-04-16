# YTMusicMac

[English](#-english) | [한국어](#-한국어)

---

## 🇺🇸 English

Native macOS app for YouTube Music.

### Features
- **Media Control**: Full support for system media keys (Play/Pause, Next, Previous).
- **Hybrid Engine**: Custom `WKWebView` integration with a native SwiftUI wrapper.
- **Performance**: Optimized resource management and third-party tracker blocking.
- **Privacy**: No built-in tracking, minimal entitlements.

### Requirements
- macOS 14.0 or later
- Xcode 15.0 or later
- `xcodegen` (for development)

### Installation
1. Download the latest `.dmg` from the [Releases](https://github.com/jinsh1210/YTMusicMac/releases) page.
2. Drag `YTMusicMac.app` to your `Applications` folder.
3. **Troubleshooting**: If you see an error saying the app is "damaged", run the following command in Terminal:
   ```bash
   sudo xattr -rd com.apple.quarantine /Applications/YTMusicMac.app
   ```

### Development
```bash
git clone https://github.com/jinsh1210/YTMusicMac.git
cd YTMusicMac
xcodegen generate
open YTMusicMac.xcodeproj
```
- **Linting**: SwiftLint and SwiftFormat are integrated into the build process.
- **Standards**: Adheres to the `HARNESS.md` project standards.

### License
MIT License. See `LICENSE` for details.

---

## 🇰🇷 한국어

YouTube Music을 위한 네이티브 macOS 앱입니다.

### 주요 기능
- **미디어 제어**: 시스템 미디어 키(재생/일시정지, 다음, 이전) 완벽 지원.
- **하이브리드 엔진**: 네이티브 SwiftUI 래퍼와 커스텀 `WKWebView` 통합.
- **성능**: 최적화된 리소스 관리 및 서드파티 트래커 차단.
- **개인정보 보호**: 내장된 트래킹 없음, 최소한의 권한 사용.

### 요구 사항
- macOS 14.0 이상
- Xcode 15.0 이상
- `xcodegen` (개발 시 필요)

### 설치 방법
1. [Releases](https://github.com/jinsh1210/YTMusicMac/releases) 페이지에서 최신 `.dmg` 파일을 다운로드합니다.
2. `YTMusicMac.app`을 `Applications` 폴더로 드래그합니다.
3. **실행 시 주의사항**: "파일이 손상되어 열 수 없습니다"라는 메시지가 뜨는 경우, 터미널에서 아래 명령어를 실행해 주세요:
   ```bash
   sudo xattr -rd com.apple.quarantine /Applications/YTMusicMac.app
   ```

### 개발 지원 방법
```bash
git clone https://github.com/jinsh1210/YTMusicMac.git
cd YTMusicMac
xcodegen generate
open YTMusicMac.xcodeproj
```
- **린트**: SwiftLint 및 SwiftFormat이 빌드 프로세스에 통합되어 있습니다.
- **표준**: `HARNESS.md` 개발 표준을 준수합니다.

### 라이선스
MIT 라이선스. 자세한 내용은 `LICENSE` 파일을 참조하세요.
