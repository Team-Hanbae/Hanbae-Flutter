> 이 문서는 `한배`에 기여하기 위한 프로세스에 대해 작성되었습니다.

## 목차
- [1. 개발 프로세스](#1-개발-프로세스)
  - [1-1. 이슈 생성 / 할당](#1-이슈-생성--할당)
  - [1-2. 브랜치 생성](#2-브랜치-생성)
  - [1-3. 작업](#3-작업)
  - [1-4. Pull Request (PR)](#4-pull-request-pr)
  - [1-5. Pre-Release](#5-pre-release)
  - [1-6. Release](#6-release)
- [2. Category](#2-category)
- [3. 브랜치 전략](#3-브랜치-전략)

<br>

## 1. 개발 프로세스
### 1. 이슈 생성 / 할당
```
- 적절한 Issue Template을 선택하여 작성합니다.
- 적절한 Label을 설정합니다.
- 이슈 제목 형식 : "[Category] 이슈 제목" - (Category는 대문자로 시작합니다)
  ex) [Feat] 백그라운드 재생 기능 추가
- 이슈에 본인을 Assignee로 지정합니다.
```
### 2. 브랜치 생성
```
- dev 브랜치를 Branch Source로 생성합니다.
- 브랜치 이름은 영문만 사용하여 작성합니다.
- 브랜치 이름 형식 : "category/#이슈번호-브랜치-이름" - (category는 소문자로 시작합니다)
  ex) feat/#234-Background-Playback
```
### 3. 작업
```
- 작은 Task마다 커밋을 분리하여 작성합니다.
- 커밋 이름 형식 : "[category] #이슈번호 커밋내용" - (category는 소문자로 시작합니다)
  ex) [feat] #234 백그라운드 재생 옵션 추가
- remote 브랜치로 push 합니다.
```
### 4. Pull Request (PR)
```
- 모든 PR은 정상적으로 빌드되어야 합니다.
- dev 브랜치를 타겟으로 PR을 생성합니다.
- 적절한 Asignee를 할당합니다.
- 적절한 Label을 설정합니다.
- PR 제목 형식 : "[Category] #이슈번호 PR내용" - (Category는 대문자로 시작합니다)
  ex) [Feat] #234 백그라운드 재생 기능 추가
- PR 내용을 작성합니다.
- PR 생성시 Xcode Cloud의 빌드, 테스트, 분석이 실행됩니다.
- PR 생성 이후 24시간 동안 코드리뷰를 진행합니다.
- Xcode Cloud를 통과하고 1인 이상의 Approve를 받으면 Merge가 가능합니다.
- PR 최종 Merge시 Xcode Cloud를 통해 빌드, 테스트, 분석, Archieve 되어 Testflight(내부) 배포됩니다.
- Merge는 PR 생성자가 하는 것을 원칙으로 합니다.
- Merge 이후 작업 브랜치는 삭제합니다.
```
### 5. Pre-Release
```
- 버전 업데이트시 가장 먼저 진행됩니다.
- 버전별 기능명세를 논의, 결정합니다.
- Pre-Release 카테고리로 이슈를 생성합니다.
- Xcode에서 프로젝트 버전넘버를 업데이트합니다.
- Pre-Release 카테고리로 PR을 생성, Merge합니다.
- 이후 다른 기능들을 구현합니다.
```
### 6. Release
```
- AppStore에 배포하기 위한 과정입니다.
- dev 브랜치에서 main 으로 Merge합니다.
- Release 카테고리로 이슈, PR 프로세스를 진행합니다.
- PR 생성시 Xcode Cloud의 빌드, 테스트, 분석이 실행됩니다.
- PR 최종 Merge시 Xcode Cloud를 통해 빌드, 테스트, 분석, Archieve 되어 AppStore 배포 준비가 완료됩니다.
- GitHub Repository에서 Releases 항목을 업데이트합니다.
- Notion에 업데이트 사항을 기록합니다.
```

## 2. Category
```
- feat: 새로운 기능 추가, 변경
- fix: 버그 수정
- docs: 문서 수정
- refactor: 코드 리팩토링
- test: 테스트 코드 작성
- chore: 빌드 업무 수정, 패키지 매니저 수정, 잡일
- design: 디자인 에셋 추가, 변경
```

## 3. 브랜치 전략
```
- main(default): AppStore 배포 코드
- dev: Testflight(내부) 배포 코드
```
