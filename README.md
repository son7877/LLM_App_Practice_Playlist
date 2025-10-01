# LLM Playlist

### A. 프로젝트 목표

  - OpenAI(GPT-4o) API와 MusicKit을 활용하여 사용자 맞춤형 음악 추천 및 플레이리스트 생성 기능 구현
  - SwiftUI와 SwiftData를 사용하여 데이터 기반의 반응형 UI를 구축하고 MVVM 아키텍처 적용
  - Kakao 및 Apple 소셜 로그인을 구현하여 사용자 접근성 및 편의성 증대

### B. 프로젝트 구성

#### b-1 Project File Tree

```
LLMPractice
├── App
│   ├── AppDelegate.swift
│   └── LLMPracticeApp.swift
├── Core
│   ├── Constants
│   ├── Extension
│   └── Utilities
├── Feature
│   ├── Authentication
│   │   ├── View
│   │   └── ViewModel
│   ├── Chat
│   │   ├── View
│   │   └── ViewModel
│   └── PlayList
│       ├── View
│       └── ViewModel
├── Model
│   ├── Chatting.swift
│   ├── OpenAIResponse.swift
│   ├── PlayList.swift
│   ├── Song.swift
│   └── User.swift
└── Service
    ├── AiManager.swift
    └── MusicKitManager.swift
```

#### b-2 폴더 구조 선정

  - **App**: 앱의 생명주기 및 초기 설정을 관리합니다. `AppDelegate`와 `@main` 구조체인 `LLMPracticeApp`이 포함됩니다.
  - **Core**: 앱 전반에서 사용되는 핵심 로직 및 유틸리티를 포함합니다. API 상수, 확장(Extension), 로거, 사용자 데이터 관리자(`UserDataManager`) 등이 위치합니다.
  - **Feature**: 앱의 주요 기능별 모듈을 관리합니다. 각 기능은 **View**와 **ViewModel**로 구성되어 MVVM 아키텍처를 따릅니다. (예: `Authentication`, `Chat`, `PlayList`)
  - **Model**: 앱에서 사용하는 데이터 구조를 정의합니다. SwiftData 모델(`PlayList`, `Song`, `RequestMessage` 등)이 포함됩니다.
  - **Service**: 외부 서비스와의 통신을 담당합니다. `AiManager`(OpenAI API 연동), `MusicKitManager`(Apple MusicKit 연동)가 포함됩니다.

#### b-3 사용한 프레임워크 및 라이브러리

  - **프로그래밍 언어 및 프레임워크**

  - **라이브러리 및 SDK**

### C. 동작 과정

1.  **로그인**: 사용자는 Kakao 또는 Apple 계정을 통해 앱에 로그인합니다. 사용자 정보는 `UserDataManager`를 통해 기기에 안전하게 저장됩니다.
2.  **플레이리스트 조회**: 로그인 후, 사용자의 플레이리스트 목록이 표시됩니다. 데이터는 SwiftData를 통해 관리되며, 사용자별로 구분되어 조회됩니다.
3.  **음악 추천 요청**: 사용자는 '음악 추천 채팅' 화면으로 이동하여 원하는 음악 스타일에 대해 LLM 챗봇에게 질문합니다.
4.  **LLM 답변 및 파싱**: `AiManager`가 사용자의 질문을 OpenAI(GPT-4o) API로 전송하고, 추천 음악 목록이 담긴 답변을 받습니다.
5.  **음악 검색**: `LLMChatViewModel`은 LLM의 답변에서 '곡명 (아티스트)' 형식의 텍스트를 파싱하고, `MusicKitManager`를 통해 Apple Music에서 실제 음원을 검색합니다. (구현 예정)
6.  **결과 표시 및 추가**: 검색된 추천 곡들이 채팅 화면에 표시되며, 사용자는 '+' 버튼을 눌러 원하는 곡을 자신의 플레이리스트에 추가할 수 있습니다. (구현 예정)
7.  **플레이리스트 공유**: 사용자는 생성된 플레이리스트를 카카오톡을 통해 다른 사람에게 공유할 수 있습니다. (구현 예정)

### D. 개발 내용

  - **로그인**

      - KakaoSDK와 AuthenticationServices를 사용하여 소셜 로그인 기능 구현
      - `UserDataManager`를 통해 로그인 시 발급받는 사용자의 고유 ID와 이메일을 UserDefaults에 저장하여 사용자별 데이터 관리

  - **메인 플레이리스트 뷰**

      - SwiftData를 사용하여 사용자가 생성한 플레이리스트 목록을 표시
      - LLM 채팅, 플레이리스트 생성 및 공유 기능을 Floating Action Button으로 구현하여 사용자 편의성 고려


  - **LLM 채팅을 통한 음악 추천**

      - OpenAI(GPT-4o) API를 활용하여 사용자의 자연어 요청에 따라 음악을 추천하는 챗봇 기능 구현
      - `LLMChatViewModel`에서 LLM의 텍스트 답변을 파싱하여 MusicKit으로 실제 음악을 검색하고, 앨범 아트와 함께 사용자에게 시각적으로 제공
      - 추천받은 곡을 즉시 기존 플레이리스트에 추가하거나, 새 플레이리스트를 생성하여 추가할 수 있는 기능 구현
