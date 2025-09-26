# 덕업일체 (Dukeupilche) Flutter 앱

취미를 직업으로, 꿈을 현실로 만드는 소셜 로그인 기반 Flutter 앱입니다.

## 프로젝트 구조

```
lib/
├── models/                 # 데이터 모델
│   ├── social_login_request.dart
│   └── social_login_response.dart
├── screens/               # 화면
│   └── login_screen.dart
├── services/              # 서비스
│   ├── api_service.dart
│   └── social_login_service.dart
└── main.dart             # 앱 진입점
```

## 주요 기능

- **소셜 로그인**: Google, Apple, Kakao, Naver 로그인 지원
- **API 통신**: localhost:3000/api/v1 엔드포인트와 통신
- **현대적인 UI**: Material Design 3 기반의 깔끔한 인터페이스

## 설정 방법

### 1. 의존성 설치

```bash
flutter pub get
```

### 2. JSON 코드 생성

```bash
flutter packages pub run build_runner build
```

### 3. 소셜 로그인 설정

#### Google 로그인
1. [Google Cloud Console](https://console.cloud.google.com/)에서 프로젝트 생성
2. OAuth 2.0 클라이언트 ID 생성
3. Android: `android/app/src/main/res/values/strings.xml`에 클라이언트 ID 추가
4. iOS: `ios/Runner/Info.plist`에 URL 스키마 추가

#### Apple 로그인
1. Apple Developer Console에서 Sign in with Apple 활성화
2. Bundle ID 설정 확인

#### Kakao 로그인
1. [Kakao Developers](https://developers.kakao.com/)에서 앱 등록
2. `android/app/src/main/res/values/strings.xml`에 네이티브 앱 키 추가
3. `ios/Runner/Info.plist`에 URL 스키마 추가

#### Naver 로그인
1. [Naver Developers](https://developers.naver.com/)에서 앱 등록
2. 네이버 SDK 설정 (별도 구현 필요)

### 4. 서버 설정

서버는 다음 엔드포인트를 제공해야 합니다:

```
POST /api/v1/auth/social-login
```

요청 본문:
```json
{
  "provider": "google" | "apple" | "kakao" | "naver",
  "idToken": "string (optional)",
  "accessToken": "string (optional)",
  "device": "ios" | "android",
  "nonce": "string (optional)"
}
```

응답:
```json
{
  "success": true,
  "accessToken": "string (optional)",
  "refreshToken": "string (optional)",
  "message": "string (optional)"
}
```

## 실행 방법

```bash
# 개발 서버 실행
flutter run

# 릴리즈 빌드
flutter build apk --release
flutter build ios --release
```

## 필요한 키 정보

소셜 로그인을 사용하려면 다음 키들이 필요합니다:

1. **Google**: OAuth 2.0 클라이언트 ID
2. **Apple**: Bundle ID 및 Sign in with Apple 설정
3. **Kakao**: 네이티브 앱 키
4. **Naver**: 클라이언트 ID 및 클라이언트 시크릿

각 플랫폼의 개발자 콘솔에서 해당 키들을 발급받아 설정해주세요.