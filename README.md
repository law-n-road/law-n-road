# 🚗 Law-n-Road 프로젝트 (신세계 I&C 최종 프로젝트 `도로의 판정단` 팀)
---
## 📌 프로젝트 소개
교통사고, 음주운전, 무면허 운전, 뺑소니 등 도로 위에서
누구나 겪을 수 있는 다양한 **법적 문제는 일상 속에서 예고 없이 발생**할 수 있습니다.

로앤로드는 이러한 어려움에 처한 이용자의
**진입장벽을 낮추기 위해 기획된 플랫폼**입니다.

---
## 📃 프로젝트 기획안
- [프로젝트 기획안](https://docs.google.com/document/d/1mc-cUZOW-KYeat83JRVeV2M-NRAJdS7S/edit?usp=sharing&ouid=107361260590998920399&rtpof=true&sd=true)

---
## 👥 멤버 및 역할 소개
| 이름    | 역할            |
|---------|-----------------|
| [박건희](https://github.com/psns0122)  | 팀장, UIUX, 템플릿, 광고             |
| [강창선](https://github.com/KangChangSeon)  | 예약, 주문, 결제, Cloud       |
| [방민영](https://github.com/My-Bang)  | 실시간 채팅, 사전질문        |
| [서민성](https://github.com/sminseong)  | 라이브 방송, 방송 스케줄, 방송 다시보기        |
| [이정수](https://github.com/dlwjdtn1112)  | 회원가입, 로그인, 관리자 승인        |
| [정유진](https://github.com/yujini02)  | 법률 Q&A, chatbot, 대시보드        |

---
## ⚙️ 기술 스택
### 🛠 Tech
- **Java** 17
- **Spring Boot** 3.3.12
- **Spring Security**
- **Vue.js**
- **WebRTC & OpenVidu**
- **WebSocket**
- **Stomp**
- **Redis**
- **Docker & Docker Compose**
- **NCP (Naver Cloud Platform)**

### 🗄 DB
- **MySQL** 8.0
- **MongoDB**

### 💻 IDE
- **IntelliJ IDEA**
- **Docker Desktop**
- **Termius**

### 🤝 협업 툴
- **Slack**
- **Github**
- **Notion**
- **Excalidraw**
- **ERD cloud**
- **Google Drive**

---
## 📝 프로젝트 설계
- [기능 명세서](https://docs.google.com/spreadsheets/d/1mXwbnh3IuJrlLThekPflOxNzQJKnhls7/edit?usp=sharing&ouid=107361260590998920399&rtpof=true&sd=true)
- [API 명세서](https://docs.google.com/spreadsheets/d/1uew40dinu_D6sRUtGRDv19p9Y2DdRD8-/edit?usp=sharing&ouid=107361260590998920399&rtpof=true&sd=true)
- [화면 정의서](https://drive.google.com/file/d/1n2KuYMtESO0OYgtiRpHilFUu7exAS7q2/view?usp=sharing)

- **ERD 다이어그램**
  ![image](https://github.com/user-attachments/assets/050acf32-19ea-4b9d-8179-899de1a88e73)
  [ERD cloud](https://www.erdcloud.com/d/EEX5kxToeHDtKrTsH)

- **아키텍쳐 구조**
  ![image](https://github.com/user-attachments/assets/253fb141-6950-4f6b-a9eb-1494a06ab6e8)
---
## 시연영상
- [로앤로드 시연영상](https://www.youtube.com/watch?v=mf17-FcomSA)

## 🛠️ 로컬 환경 구성

### ✅ MySQL 계정 생성
```sql
CREATE DATABASE law_n_road;
CREATE USER 'lawnroad'@'localhost' IDENTIFIED BY 'lawnroad1234';
GRANT ALL PRIVILEGES ON law_n_road.* TO 'lawnroad'@'localhost';
FLUSH PRIVILEGES;
```

---

## 🐳 Docker 설치
도커 설치가 필요합니다. 운영체제별 가이드를 참고하세요.

- **Windows / Mac**  
[Docker Desktop 설치 가이드](https://docs.docker.com/desktop/install/)

---

## 🍃 MongoDB & Redis & OpenVidu (Docker로 실행)

```bash
docker run -d -p 27017:27017 \
  --name mongo-prod \
  -e MONGO_INITDB_ROOT_USERNAME=chat \
  -e MONGO_INITDB_ROOT_PASSWORD=chat1234@ \
  -e MONGO_INITDB_DATABASE=chatdb \
  mongo

docker run -d -p 6379:6379 \
  --name redis \
  redis

docker run -d -p 4443:4443 \
  -e OPENVIDU_SECRET=lawnroad1234 \
  --name my-openvidu-dev \
  openvidu/openvidu-dev:2.30.0
```

---

## 📂 Spring Boot 설정 (`application.properties`)

`src/main/resources/application.properties`

```properties
spring.application.name=law-n-road
spring.datasource.url=jdbc:mysql://localhost:3306/law_n_road?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul
spring.datasource.username=lawnroad
spring.datasource.password=lawnroad1234

mybatis.mapper-locations=classpath:/mapper/**/*.xml
mybatis.type-aliases-package=com.lawnroad.**
mybatis.configuration.map-underscore-to-camel-case=true

# --- SOLAPI ---
solapi.api-key="api키를 넣어주세요"
solapi.api-secret="secret키를 넣어주세요"
solapi.api-url=https://api.solapi.com
solapi.from="전화번호를 넣어주세요"
solapi.pf-id="id를 넣어주세요"

# --- 이미지 및 VOD 용량 설정 ---
spring.servlet.multipart.max-file-size=10GB
spring.servlet.multipart.max-request-size=10GB
server.tomcat.max-swallow-size=10GB

# --- OPENVIDU ---
OPENVIDU_URL=http://localhost:4443
OPENVIDU_SECRET=lawnroad1234

# --- MongoDB 설정 ---
spring.data.mongodb.host=localhost
spring.data.mongodb.port=27017
spring.data.mongodb.database=chatdb
spring.data.mongodb.username=chat
spring.data.mongodb.password=chat1234@
spring.data.mongodb.authentication-database=admin

# --- Redis 설정 ---
spring.data.redis.host=localhost
spring.data.redis.port=6379
spring.data.redis.password=
spring.data.redis.timeout=2000

# --- 이메일 설정 ---
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username="gmail을 넣어주세요"
spring.mail.password="비밀번호를 넣어주세요"
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
mail.verification.expire-time=180000

# --- Gemini API ---
gemini.api-key="api키를 넣어주세요"

# --- 파일 업로드 경로 ---
# 예시: file.upload-dir=file:///D:/Program/final/law-n-road/uploads/
file.upload-dir=본인 루트 경로

# --- Naver 이미지 스토리지 ---
ncp.storage.bucket=law-n-road
ncp.storage.region=kr-standard
ncp.storage.endpoint=https://kr.object.ncloudstorage.com
ncp.storage.accessKey="accessKey를 넣어주세요"
ncp.storage.secretKey="secretKey를 넣어주세요"

# --- Naver OCR ---
ncp.ocr.secretKey="secretKey를 넣어주세요"
ncp.ocr.endpoint=https://qm4c7n6gsp.apigw.ntruss.com/custom/v1/43045/595ee773782c96e206788087fc0c6433e7b20cb7391fdbb5cd037ca18db83197/general

# --- Toss Payments ---
tosspayments.secret-key="secret키를 넣어주세요"
tosspayments.base-url=https://api.tosspayments.com
tosspayments.success-url=https://localhost:5173/pay/success
tosspayments.fail-url=https://localhost:5173/pay/fail

# --- Clova Chatbot ---
chatbot.invoke-url="invoke-url을 넣어주세요"
chatbot.secret-key="secret키를 넣어주세요"

# --- Clova Studio ---
clova.api-key="api키를 넣어주세요"
clova.api-url=https://clovastudio.stream.ntruss.com/testapp/v3/chat-completions/HCX-005

# --- VOD 설정 ---
spring.mvc.static-path-pattern=/uploads/**
spring.web.resources.static-locations=${file.upload-dir}

# --- Naver 소셜 로그인 ---
spring.security.oauth2.client.registration.naver.client-name=naver
spring.security.oauth2.client.registration.naver.client-id=Wy4hhh1etGeWpNOAGUTe
spring.security.oauth2.client.registration.naver.client-secret="secret키를 넣어주세요"
spring.security.oauth2.client.registration.naver.redirect-uri=http://localhost:8080/login/oauth2/code/naver
spring.security.oauth2.client.registration.naver.authorization-grant-type=authorization_code
spring.security.oauth2.client.registration.naver.scope=name,email

spring.security.oauth2.client.provider.naver.authorization-uri=https://nid.naver.com/oauth2.0/authorize
spring.security.oauth2.client.provider.naver.token-uri=https://nid.naver.com/oauth2.0/token
spring.security.oauth2.client.provider.naver.user-info-uri=https://openapi.naver.com/v1/nid/me
spring.security.oauth2.client.provider.naver.user-name-attribute=response

# --- 프로파일 ---
spring.profiles.active=dev
```

---

## 🖥️ Frontend 설정 (`frontend/.env.development`)

```
VITE_API_BASE=http://localhost:8080
```

---

## 📦 NPM 설치

```bash
cd frontend
npm install
npm install axios solapi openvidu-browser@2.30.0 \
sockjs-client @stomp/stompjs \
@fullcalendar/vue3 @fullcalendar/daygrid @fullcalendar/interaction \
@tiptap/vue-3 @tiptap/starter-kit \
@tiptap/extension-underline @tiptap/extension-text-style \
@tiptap/extension-ordered-list @tiptap/suggestion \
bootstrap html2pdf.js crypto-js webm-duration-fix chart.js
```

---

## 🟢 네이버 OAuth2 로그인
본 프로젝트는 네이버 OAuth2 로그인을 사용합니다.  
반드시 관리자에게 Client ID & Secret 등록 허가를 받아야 정상적으로 사용할 수 있습니다.

---

## 🧪 더미 계정 (로그인 테스트용)

| 구분    | 아이디 (이메일) | 비밀번호 |
|---------|-----------------|----------|
| 회원    | ssg             | test09   |
| 변호사  | lawyer001       | test01   |
| 관리자  | admin123        | admin123 |

---

## 🔥 초기 실행 순서

1. MongoDB, Redis, OpenVidu (Docker로 실행)
2. Spring Boot 프로젝트 실행 (IntelliJ 또는 CLI)
3. Vue.js 프로젝트 실행  
   ```bash
   npm run dev
   ```
4. MySQL에 더미 데이터 추가 (`/dummy_data.sql` 실행)

---
## 회고
- 박건희
    - 매주 기능 개발 완료 후 머지 및 통합 테스트를 진행하여 정상 동작 여부를 꾸준히 확인함.
    - 초반~중반까지는 WBS 기반으로 일정 관리가 잘 되었으나, 막바지에 일정이 밀리고 WBS 확인이 누락되는 등 일정 관리가 느슨해짐. → 추후에는 끝까지 일정관리를 책임지고 진행할 것.
    - 기능을 큰 단위로 계획하여 핵심 기능(MVP)과 부가 기능을 구분하지 못하고, 전부 완료한 후에야 데모를 진행함. → 추후에는 핵심 기능을 우선 완성하고 데모 및 피드백 후 보완하는 방식으로 개선하면 좋을 것 같음.
    - 기술 스택 및 아키텍처 선택 시 가능한 범위 내에서 직관적으로 선택했으나, 추후에는 타당성 검토와 설계 철학을 바탕으로 선정해야 함.
    - 코드 리뷰에 일부 인원만 참여함. → 앞으로는 모든 팀원이 코드 리뷰에 참여하여 코드 품질 관리 및 기술 공유를 활성화해야 함.
 
- 강창선
  - 결제/환불 기능을 웹훅 로그를 통해서 구현했다면 더 좋았을 것
  - 설계 단계에서 조금 더 많은 시간을 투자할 것 -> 놓치는 부분이 많았음
  - 일정을 조금 더 세세하게 나누는게 좋을 듯 함 -> 해당 기능의 완성도를 판단하기가 어려웠음
  - 해당 기술을 왜 그렇게 사용 했는지에 대한 내용을 기록 할 것

- 서민성
  - 프론트에서 녹화 파일을 직접 저장(MediaRecorder)하는 방식은 새로고침 등 예외 상황에 취약했음. → 다음에는 서버 기반 녹화(OpenVidu Pro 등)도 미리 검토하여 녹화 안정성 확보 방안을 설계단계에서 포함시켜야 할 것.
  - 방송 시청자 수 카운트, 중복 접속 제어 등은 단순한 수치 기반으로 처리되어 정확한 상태 관리가 어려웠음. → Redis나 세션 기반의 실시간 트래픽 관리 방식으로 확장 가능성을 고려했으면 더 완성도 있는 기능이 되었을 것.
  - 이슈 발생 시 어떤 건 이슈보드에 올리고, 어떤 건 말로만 전달하는 등 기록 기준이 명확하지 않아 누락되거나 중복 대응이 발생한 경우가 있었음. → 다음에는 이슈보드 작성 기준(예: 재현 가능한 버그, 연동 오류, UI 피드백 등)을 명확히 정의하고,     모든 팀원이 공통된 기준에 따라 이슈보드를 적극 활용하도록 유도했으면 더 효율적인 협업이 되었을 것이라고 느꼈음.
    
- 방민영
  - 한 가지 기능을 깊이 있게 고도화하지 못하고, 여러 기능을 구현하는 데 집중했던 점이 아쉬움으로 남는다. 앞으로는 다양한 기능을 시도하기보다는, 한 가지 핵심 기능에 집중해 더 완성도 있게 고도화하는 데 주력해야 할 것 같다.
  - 실시간 채팅의 금칙어를 처리하기 위한 AI 프롬프트를 더 정교하게 설계하지 못한 점도 아쉽다.
  - 배포 이후 서버에서 채팅 부하 테스트를 충분히 진행하지 못한 점이 아쉬움으로 남는다.
    
- 이정수
  - 회원 관리 및 인증 기능을 직접 구현하며 Spring Security와 JWT 구조에 대한 실전 경험을 쌓을 수 있었다.
  - 비록 짧은 기간이었지만, 기술적 이해와 적용 역량을 키울 수 있는 값진 시간이었고, 앞으로 실무에서도 더욱 잘할 수 있다는 자신감을 얻었다.
  - 예외 상황 처리나 보안 취약점 대응, 그리고 토큰 저장 및 재발급 관리 측면에서 보안적으로 미흡했던 부분은 아쉬움으로 남았고,
    향후에는 보다 정교한 예외 로직과 안전한 토큰 관리 체계까지 반영한 보안 중심 개발을 목표로 하고자 한다.

- 정유진
  - 게시판 CRUD, 챗봇 연동, 변호사 대시보드를 개발하며 처음부터 끝까지 전체적인 흐름과 구조를 직접 경험할 수 있었습니다.
  - 프론트엔드와 백엔드 간의 연결 구조를 깊이 이해하고, API 연동과 상태 관리를 배울 수 있었습니다.

---

모든 설정이 끝나면 프로젝트를 성공적으로 실행할 수 있습니다! 🎉
