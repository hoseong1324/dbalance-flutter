# D-Balance - 회식/여행 정산 앱

확실한 정산을 경험해보세요! 회식이나 여행에서 발생하는 비용을 쉽고 정확하게 정산할 수 있는 Flutter 앱입니다.

## 🎯 주요 기능

- **게스트 모드**: 로그인 없이도 바로 사용 가능
- **소셜 로그인**: Google, Apple, Kakao, Naver 로그인 지원
- **방 관리**: 회식/여행별 방 생성 및 관리
- **라운드 관리**: 장소별 라운드 추가 및 관리
- **참가자 관리**: 참가자 추가, 수정, 삭제
- **지출 관리**: 항목별 지출 추가 및 관리
- **자동 정산**: 가중치 및 음주 여부를 고려한 정산 계산

## 🏗️ 아키텍처

### Clean Architecture 구조
```
lib/
├── core/                    # 핵심 기능
│   ├── config/             # 앱 설정
│   ├── network/            # HTTP 클라이언트
│   ├── storage/            # 데이터 저장
│   ├── providers/          # Repository Providers
│   └── routing/            # 라우팅 설정
├── features/               # 기능별 모듈
│   ├── auth/               # 인증
│   ├── sessions/           # 세션 관리
│   ├── rooms/              # 방 관리
│   ├── participants/       # 참가자 관리
│   └── items/              # 지출 관리
└── shared/                 # 공통 모듈
    ├── models/             # 데이터 모델
    └── widgets/            # 공통 위젯
```

### 기술 스택
- **Flutter 3.x** + **Dart 3.x**
- **Riverpod**: 상태 관리 및 의존성 주입
- **Dio**: HTTP 클라이언트 with 인터셉터
- **Go Router**: 선언적 라우팅
- **JSON Serialization**: 자동 코드 생성
- **Flutter Secure Storage**: 보안 데이터 저장

## 🚀 시작하기

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. JSON 코드 생성
```bash
flutter packages pub run build_runner build
```

### 3. 앱 실행
```bash
# 개발 서버 실행
flutter run

# iOS 빌드
flutter build ios --debug --no-codesign

# Android 빌드
flutter build apk --debug
```

## 🔐 소셜 로그인 설정

### Google 로그인
- **Android**: `1052447286041-1rjieb0t4ckp4k60n50v2luogvcl9gr2.apps.googleusercontent.com`
- **iOS**: `1052447286041-iaq8igbcrrhmvsdhc5v5ccd1b5j7n06b.apps.googleusercontent.com`

### Kakao 로그인
- **Native App Key**: `21ececcc9510348d55784751f9f01a67`

### Naver 로그인
- **Client ID**: `hQfS5ST__8Q7Mm8g26Cw`
- **Client Secret**: `kRfF_spWVG`

## 📡 API 연동

### 서버 정보
- **Base URL**: `http://211.56.253.181:3000`
- **API Version**: `v1`

### 주요 엔드포인트
```
POST /api/v1/sessions/guest          # 게스트 세션 발급
POST /api/v1/auth/login              # 로컬 로그인
POST /api/v1/auth/register           # 회원가입
POST /api/v1/auth/social-login       # 소셜 로그인
POST /api/v1/rooms                   # 방 생성
GET  /api/v1/rooms/:id               # 방 조회
POST /api/v1/rooms/:id/rounds        # 라운드 생성
POST /api/v1/items/expenses          # 지출 생성
```

## 🎨 UI/UX 특징

- **Material Design 3** 적용
- **일관된 컬러 스킴** (Teal 기반)
- **반응형 레이아웃**
- **직관적인 네비게이션**
- **로딩 상태 및 에러 처리**

## 📱 앱 플로우

1. **앱 시작** → 스플래시 화면에서 게스트 세션 자동 발급
2. **로그인/회원가입** → 토큰 저장 및 홈으로 이동
3. **방 생성** → 새 방 만들기 및 상세 화면 이동
4. **라운드 관리** → 장소별 라운드 추가
5. **참가자 관리** → 참가자 추가/수정/삭제
6. **지출 관리** → 지출 추가/수정/삭제
7. **정산 계산** → 자동 정산 결과 표시

## 🔧 개발 환경

### 요구사항
- Flutter SDK 3.8.0+
- Dart 3.8.0+
- iOS 13.0+
- Android API 21+

### 개발 도구
- **VS Code** 또는 **Android Studio**
- **Flutter Inspector**
- **Dart DevTools**

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 문의

프로젝트에 대한 문의사항이 있으시면 이슈를 생성해주세요.

---

**D-Balance** - 확실한 정산을 경험해보세요! 🎯