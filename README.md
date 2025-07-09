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
| 박건희  | 팀장, UIUX, 템플릿, 광고             |
| 강창선  | 예약, 주문, 결제       |
| 방민영  | 실시간 채팅, 사전질문        |
| 서민성  | 라이브 방송, 방송 스케줄, 방송 다시보기        |
| 이정수  | 회원가입, 로그인, 관리자 승인        |
| 정유진  | 법률 Q&A, chatbot, 대시보드        |

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
  [ERD cloud]()

- **아키텍쳐 구조**
  ![image](https://github.com/user-attachments/assets/253fb141-6950-4f6b-a9eb-1494a06ab6e8)


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

모든 설정이 끝나면 프로젝트를 성공적으로 실행할 수 있습니다! 🎉
