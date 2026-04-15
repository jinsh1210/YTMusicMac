# Project Harness FINAL: AI Agent & macOS Development Standard

이 문서는 AI 에이전트가 macOS 네이티브 앱 프로젝트에 참여할 때 준수해야 하는 최종 통합 표준입니다.

---

## 1. 브랜치 전략 (Git Flow)

- `main`: 제품 배포 브랜치. 직접 작업 및 Push 절대 금지.
- `develop`: 개발 통합 브랜치. 모든 기능 개발의 베이스라인.
- `feature/`: 신규 기능 개발. develop에서 분기.
- `fix/`: 버그 수정. develop에서 분기.
- `refactor/`: 코드 개선. develop에서 분기.
- `release/`: 배포 준비. 버전 태깅 및 문서 업데이트 수행.

**브랜치 보호**: GitHub Settings에서 `main`, `develop` 직접 Push 차단.

**브랜치 수명 원칙**: 원격에 Push한 즉시 로컬 브랜치를 삭제한다. 머지 완료된 원격 브랜치도 즉시 삭제한다.

---

## 2. Undercover Mode (필수)

AI 흔적을 코드, 커밋, PR에서 철저히 제거한다.

- **커밋 메시지**: "AI", "LLM", "Claude", "Gemini", "Co-Authored-By: Claude" 등 일체 금지.
- **코드 주석**: 자명한 코드에 설명 주석 달지 않기. 번호 매긴 절차 주석 (`// 1. Do this`) 금지.
- **PR 본문**: AI가 작성했다는 인상을 주는 표현 금지.
- **변수명**: 과도하게 verbose한 네이밍 지양. 숙련된 개발자 수준 유지.
- **서명**: 자동 생성 메타데이터, AI 서명 일체 남기지 않기.

---

## 3. 커밋 메시지 규칙 (Conventional Commits)

형식: `<type>: <description>`

| type       | 용도                                 |
| ---------- | ------------------------------------ |
| `feat`     | 새로운 기능 추가                     |
| `fix`      | 버그 수정                            |
| `docs`     | 문서 수정 (README, CHANGELOG 등)     |
| `style`    | 포맷팅, 세미콜론 등 (로직 변경 없음) |
| `refactor` | 리팩토링 (기능 변경 없음)            |
| `test`     | 테스트 코드 추가 및 수정             |
| `chore`    | 빌드, 패키지 매니저, 환경 설정 변경  |

---

## 4. PR 원칙 (PR First)

- 모든 코드는 PR을 통해서만 `develop` 또는 `main`에 병합한다.
- 최소 1인 이상의 승인(Approve)을 받아야 한다.
- `git commit`과 `git push`는 `&&`로 연결하지 않는다. 반드시 커밋 결과 확인 후 별도로 Push한다.

---

## 5. 코드 스타일 자동화 (SwiftLint & SwiftFormat)

- SwiftLint와 SwiftFormat을 XcodeGen 빌드 단계에 통합한다.
- 스타일 위반 시 빌드 실패 처리 (`--strict` 모드).
- `.swiftlint.yml`이 프로젝트의 유일한 코딩 기준이다.
- 작업 전후로 로컬에서 반드시 린트를 실행하고 위반 사항을 해결한다.

---

## 6. 표준 작업 워크플로우

### [A] 기능 개발

1. `develop` 최신 상태 Pull.
2. 목적에 맞는 Topic 브랜치 생성 (`feature/`, `fix/`, `refactor/`).
3. 린트 규칙 준수하여 작업.
4. 보안 민감 파일 (`.env`, key, cert 등) 스테이징 포함 여부 확인.
5. 로컬 빌드 및 실행 최종 확인.
6. Push 후 즉시 로컬 브랜치 삭제.
7. PR 생성 → Approve → 머지 → 원격 브랜치 삭제.

### [B] 릴리즈

1. `release/` 브랜치 생성.
2. `CHANGELOG.md` 업데이트 (Added / Changed / Fixed, 최신순).
3. `project.yml` 버전 갱신 (SemVer: `Major.Minor.Patch`).
4. `develop` → `main` PR 생성 → 머지.
5. `main`에 버전 태그 생성 후 Push (`git tag vX.Y.Z && git push origin vX.Y.Z`).

---

## 7. CI/CD (GitHub Actions + Fastlane)

- 모든 PR 생성 시 GitHub Actions가 자동으로 빌드 + 테스트를 수행한다.
- CI 파이프라인: `xcodegen generate` → SwiftLint → Build → Test.
- 배포 자동화 (코드 서명, 스크린샷, App Store Connect 업로드)는 Fastlane을 통해 처리한다.
- Fastlane Match로 인증서를 암호화된 private 레포에서 동기화한다.

---

## 8. 자동화 테스트 및 QA (ISTQB 기준)

- **단위 테스트**: 신규 로직 및 수정된 함수에 대한 테스트 코드를 반드시 포함한다.
- **회귀 테스트**: 수정 후 전체 테스트 스위트 실행, 기존 기능 영향 없음을 확인한다.
- **커버리지**: 핵심 로직 최소 80% 이상 유지.
- **TEST_REPORT.md**: 최신 결과를 문서 상단(Stack 방식)에 추가한다. 일시, 범위, 통과 여부, 특이사항 기록.

---

## 9. 보안 및 금지 사항

- **Force Push 금지**: 공용 브랜치 (`main`, `develop`)에 `--force` 절대 금지.
- **Secret 하드코딩 금지**: API Key, 인증 정보는 반드시 환경 변수 또는 GitHub Secrets 처리.
- **인증서 Git 업로드 금지**: Fastlane Match 사용.
- **범위 외 수정 자제**: 요청 범위와 무관한 대규모 코드 수정 지양.

---

## 10. 릴리즈 관리

- **SemVer**: `Major.Minor.Patch` 형식 엄수.
- **Git Tag**: `main` 머지 시 반드시 버전 태그 생성.
- **Artifact**: 배포용 Archive는 별도 보관 및 기록.

---

## 11. Pre-Push Checklist

1. [ ] 커밋 메시지에 AI 관련 흔적이 없는가? (Undercover 준수)
2. [ ] Conventional Commits 형식을 준수했는가?
3. [ ] `git commit`과 `git push`를 분리해서 실행했는가?
4. [ ] `.gitignore` 준수, 민감 정보 유출 없는가?
5. [ ] SwiftLint/SwiftFormat 실행하여 모든 위반 해결했는가?
6. [ ] 로컬 빌드 및 실행을 확인했는가?
7. [ ] 신규 테스트 케이스 포함, 전체 테스트 Pass 확인했는가?
8. [ ] `TEST_REPORT.md` 상단에 최신 이력을 기록했는가?
9. [ ] 릴리즈인 경우 `project.yml`과 `CHANGELOG.md` 버전을 갱신했는가?
10. [ ] Push 후 로컬 브랜치를 삭제했는가?
11. [ ] AI 특유의 주석이나 코드 패턴이 남아있지 않은지 최종 확인했는가?
