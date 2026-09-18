# Luckez

로또 번호 추천부터 저장 번호 관리, 당첨번호 확인, 커뮤니티까지 이어지는 Flutter 앱입니다.

예전에 만들던 로또 번호 생성 앱을 다시 이어서, 번호를 단순히 뽑는 데서 끝나지 않고 저장·구매 관리·당첨 확인·사용자 활동까지 관리할 수 있도록 확장하고 있습니다.

## 프로젝트 상태

현재는 기능 개발과 배포 준비를 진행 중인 단계입니다. 정식 배포 전이며, 일부 기능은 MVP 형태로 구현되어 있습니다.

현재 지원 및 검증 대상은 Android와 Web입니다. iOS는 앱 리소스는 준비돼 있지만 Firebase 연동과 릴리즈 검증을 보류하고 있습니다.

## 현재 기능

### 번호 추천과 내 번호

- 1부터 45까지 중복 없는 6개 번호 랜덤 추첨 및 오름차순 정렬
- 번호 구간별 색상 표시
- 추천 번호 저장, 수정, 삭제
- 회차별 저장 번호 조회 및 구매 완료 표시
- 구매 완료 번호 별도 조회
- 저장 번호와 같은 회차의 당첨번호 비교 및 등수 표시

### 당첨번호와 통계

- Firestore 기반 역대 당첨번호 조회
- 회차 이동과 직접 회차 선택
- 번호 출현 순위와 보너스 번호 포함/제외 조회
- 관리자 계정의 당첨번호 등록 및 수정

### 계정과 내 활동

- 이메일/비밀번호 회원가입 및 로그인
- Google 로그인
- 표시 이름 수정
- 저장 번호, 구매 번호, 내가 쓴 글, 내가 쓴 댓글, 좋아요한 글 조회

### 커뮤니티

- 게시글과 댓글 작성, 수정, 삭제
- 게시글 좋아요
- 게시글 및 댓글 신고 접수

### 앱 내 알림

- 댓글과 좋아요에 대한 앱 내 알림
- 알림 읽음 처리 및 관련 화면 이동
- 관리자 본인이 당첨번호를 등록하거나 수정할 때, 본인 저장 번호의 당첨 결과 알림 생성

## Firebase 사용

| 서비스 | 사용 목적 |
| --- | --- |
| Firebase Authentication | 이메일/비밀번호 및 Google 로그인 |
| Cloud Firestore | 사용자 정보, 저장 번호, 당첨번호, 커뮤니티, 앱 내 알림 |
| Firestore Security Rules | 사용자 데이터 소유권, 작성자 권한, 관리자 당첨번호 관리 제한 |

기본 Firebase 설정은 현재 프로젝트의 Android와 Web에 연결되어 있습니다. Firestore 규칙은 [firestore.rules](firestore.rules)를 Firebase Console에 배포해야 합니다.

`role`은 사용자 문서의 필드로 관리합니다. 일반 사용자는 `user`이며, 당첨번호를 등록하거나 수정할 관리자는 Firebase Console에서 해당 사용자의 `role`을 `admin`으로 설정해야 합니다.

## 보류 중인 기능

- Firebase Storage를 이용한 프로필 사진 업로드
- FCM 기반 기기 푸시 알림
- Cloud Functions를 이용한 알림, 좋아요 수, 댓글 수의 서버 측 처리
- 신고 검토와 제재를 위한 관리자 화면
- 구매 탭의 동행복권 연동 방식 확정
- 애니메이션 스플래시

현재 알림은 Firestore에 저장해 앱 안에서 보여주는 방식입니다. 스마트폰의 시스템 푸시 알림은 아직 지원하지 않습니다.

## 실행 방법

### 요구 사항

- Flutter 3.47.1 이상
- Android Studio 또는 Android SDK (Android 실행 시)
- Chrome (Web 실행 시)

```bash
git clone https://github.com/thisisyello/luckez.git
cd luckez
flutter pub get
```

Web에서 실행합니다.

```bash
flutter run -d chrome
```

연결된 Android 기기 또는 에뮬레이터에서 실행합니다.

```bash
flutter devices
flutter run -d <device-id>
```

### 다른 Firebase 프로젝트로 포크하는 경우

현재 설정과 분리된 Firebase 프로젝트를 사용하려면 Android와 Web 앱을 새 Firebase 프로젝트에 등록한 뒤 Firebase Authentication에서 이메일/비밀번호와 Google 로그인을 활성화해야 합니다. 이어서 Firestore 데이터베이스를 만들고 [firestore.rules](firestore.rules)를 배포합니다.

그 다음 `flutterfire configure`로 `lib/firebase_options.dart`를 새 프로젝트 기준으로 생성하고, Android의 `google-services.json`도 새 프로젝트 파일로 교체합니다. 이 과정은 기본 설정을 덮어쓰므로 별도 Firebase 프로젝트를 사용할 때만 진행합니다.

당첨번호 데이터는 `lottoWinningRounds` 컬렉션에서 관리합니다. 데이터가 비어 있는 환경에서는 관리자 계정으로 최초 당첨번호를 등록해야 통계와 당첨 판정이 정상 동작합니다.

## 배포 전 확인 사항

- iOS Firebase 연동, CocoaPods 설정, 실제 기기 릴리즈 검증
- Android 릴리즈 서명 키와 Play Console 배포 설정
- 앱 아이콘과 스플래시의 플랫폼별 표시 크기 확인
- Firestore Security Rules 운영 환경 재점검 및 배포
- 관리자 계정의 `role: admin` 부여 절차 정리
- 당첨번호를 매주 등록할 운영 절차 마련
- 개인정보처리방침과 커뮤니티 운영정책, 신고·제재 기준 준비
- 커뮤니티 사용량 및 Firestore 비용 모니터링 기준 마련

커뮤니티의 댓글 수, 좋아요 수, 일부 앱 내 알림은 현재 클라이언트가 Firestore에 기록하는 MVP 구조입니다. 운영 규모가 커지기 전 Cloud Functions 기반의 서버 측 처리로 전환하는 것을 전제로 합니다.

## 기술 스택

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
