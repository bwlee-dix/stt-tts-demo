# stt_tts_demo

## 구현 방식

STT & TTS 기능을 **2가지** 방법으로 구현해보았습니다.

1. **Android OS의 자체 기능**(Google Speach API) 사용

- STT: **_[RecognizerIntent | Android Developers](https://developer.android.com/reference/android/speech/RecognizerIntent)_**
- TTS: **_[TextToSpeech | Android Developers](https://developer.android.com/reference/android/speech/tts/TextToSpeech)_**
- `Kotlin`으로 작성

2. **Flutter 패키지** 사용

- STT: **_[speech_to_text | pub.dev](https://pub.dev/packages/speech_to_text)_**
- TTS: **_[flutter_tts | pub.dev](https://pub.dev/packages/flutter_tts)_**

<br>

## 중점 구현 부분

- `lib/flutter_screen.dart`: Flutter 패키지 스크린 구현(`speech_to_text`, `flutter_tts`)
- `lib/native_screen.dart`: Android natvie 스크린 구현
- `lib/service/native_service.dart`: Android natvie 서비스 구현
  - `Method Chenel`이용하여 `Kotlin`으로 작성한 함수 연결
- android/app/src/main/kotlin/com/example/stt_tts_demo/`MainActivity.kt`(네이티브 구현)
  - `RecognizerIntent`(STT), `TextToSpeech`(TTS)을 이용한 함수 작성

<br>

## 안드로이드 네이티브 기능 vs Flutter 패키지

각각의 장단점이 있었습니다.

`Flutter 패키지`가 러닝 커브도 없이 간단한 방법이나, `android`와 `ios`를 동시 개발하는 경우가 아닌 본 프로젝트에서는 **`android`만 사용하는 점**, **즉각적인 성능이 더 중요한 점**에서 `안드로이드 네이티브`를 사용하는 것이 적합해보입니다.

(단, 다은님이 조사해주신 바와 같이 안드로이드 네이티브 기능 중 `Samsung`의 방법도 있다는 것을 알게되었으나, `빅스비 api`를 사용하는 방법 외 발견하지 못하여 다른 좋은 방법을 알고 계신다면 알려주시면 감사하겠습니다!)

<br>

| **구분**                  | **안드로이드 네이티브 기능**                                                                                                | **Flutter 패키지**                                                                                             |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| **플랫폼 종속성**         | 안드로이드 전용으로 작동하며, iOS 등 다른 플랫폼에서는 별도 구현이 필요.                                                    | 크로스 플랫폼 지원(안드로이드, iOS 모두 사용 가능). Flutter 기반으로 멀티플랫폼에서 일관된 코드베이스 유지.    |
| **설정 및 초기화**        | 네이티브 코드 필요, 상대적으로 복잡하고 번거로움.                                                                           | Flutter 내에서 간단한 초기화 및 설정으로 동작. 설정이 쉽고 직관적.                                             |
| **커스터마이징**          | 네이티브 API를 직접 다루므로, 엔진 설정, 언어 지원 등 세부적인 커스터마이징 가능.                                           | 제한된 API 제공. 세부적인 커스터마이징은 어렵고, 패키지에서 지원하는 기능에 의존.                              |
| **언어 지원**             | 기본적으로 사용자의 디바이스에서 활성화된 엔진을 사용(Google Speech, Samsung 등). 따라서 지원 언어가 기기 설정에 따라 다름. | Google의 엔진을 사용하며, 패키지에서 제공하는 언어 목록에 제한.                                                |
| **성능**                  | 네이티브로 작동하므로 성능 면에서 더 빠르고 안정적.                                                                         | Flutter 패키지는 네이티브 레이어 위에서 동작하므로 약간의 성능 오버헤드가 있을 수 있음.                        |
| **다른 플랫폼 지원 여부** | 안드로이드 전용.                                                                                                            | Flutter로 작성된 코드는 다른 플랫폼에서도 실행 가능(iOS, Web).                                                 |
| **유지보수**              | 플랫폼별로 코드를 따로 작성해야 하므로, Flutter와 함께 사용할 때는 네이티브 브릿지를 구현해야 하며 관리 복잡도 증가.        | 유지보수가 쉬움. 한 번의 코드 작성으로 여러 플랫폼에서 재사용 가능.                                            |
| **사용 사례**             | 특정 안드로이드 디바이스에 최적화된 앱을 개발할 때 유리. 예를 들어, 하드웨어와 밀접한 통합이 필요한 경우.                   | 크로스 플랫폼 앱 개발 시 유리. 예를 들어, 동일한 음성 처리 기능을 안드로이드와 iOS에서 동시에 제공하려는 경우. |

<br>

## Kotlin vs Java

`Kotlin`을 선택하여 작성한 기준입니다.

| 기준                  | **Kotlin**                                      | **Java**                                             |
| --------------------- | ----------------------------------------------- | ---------------------------------------------------- |
| **문법의 간결함**     | 더 간결하고 현대적 (null safety, lambda 등)     | 더 복잡하고 길어질 수 있음                           |
| **구글의 공식 언어**  | 공식 언어로, 최신 Android API와 호환성이 뛰어남 | 아직도 많이 사용되지만, 점차 Kotlin으로 대체 중      |
| **코드의 효율성**     | 적은 코드로 동일한 작업을 처리                  | 상대적으로 더 많은 코드가 필요                       |
| **학습 난이도**       | Java 경험이 있다면 빠르게 적응 가능             | Java 경험자에게는 친숙하나 상대적으로 복잡할 수 있음 |
| **성능**              | Java와 비슷하지만, 최신 기능이 더 유리          | 성능상 차이는 크지 않음                              |
| **커뮤니티와 생태계** | 빠르게 성장하는 중, Google 지원                 | 오래된 커뮤니티, 방대한 라이브러리                   |
| **개발 툴 지원**      | Android Studio에서 완벽 지원                    | Android Studio에서 지원하나 Kotlin에 비해 덜 최적화  |
