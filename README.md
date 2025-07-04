# 🚀 Law-n-Road 프로젝트 README

## ⚙️ 개발 환경 (로컬)
- Java 17  
- Spring Boot 3.3.12  
- Vue.js  
- MySQL 8.0
- MongoDB 
- Redis
- WebRTC
- Openvidu
- Docker & Docker Compose  

# Mysql 계정 생성 코드

```
CREATE DATABASE law_n_road;
CREATE USER 'lawnroad'@'localhost' IDENTIFIED BY 'lawnroad1234';
GRANT ALL PRIVILEGES ON law_n_road.* TO 'lawnroad'@'localhost';
FLUSH PRIVILEGES;
```


## 🐳 Docker 설치
도커 설치가 필요합니다. 운영체제별 가이드를 참고하세요.

- **Windows / Mac**  
  [https://docs.docker.com/desktop/install/](https://docs.docker.com/desktop/install/)


🍃 MongoDB & Redis Docker로 실행
아래 명령어를 사용해 MongoDB와 Redis, Openvidu를 도커에서 실행합니다.

```
docker run -d -p 27017:27017 --name mongo-prod -e MONGO_INITDB_ROOT_USERNAME=chat -e MONGO_INITDB_ROOT_PASSWORD=chat1234@ -e MONGO_INITDB_DATABASE=chatdb mongo

docker run -d -p 6379:6379 --name redis redis

docker run -d -p 4443:4443 -e OPENVIDU_SECRET=lawnroad1234 --name my-openvidu-dev openvidu/openvidu-dev:2.30.0

```

🛠️ 설정 파일
application.yaml (Spring Boot)
```
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

# --- image and vod size ---
spring.servlet.multipart.max-file-size=10GB
spring.servlet.multipart.max-request-size=10GB
server.tomcat.max-swallow-size=10GB

# --- OPENVIDU ---
OPENVIDU_URL=http://localhost:4443
OPENVIDU_SECRET=lawnroad1234

# --- mongoDB ---
spring.data.mongodb.host=localhost
spring.data.mongodb.port=27017
spring.data.mongodb.database=chatdb
spring.data.mongodb.username=chat
spring.data.mongodb.password=chat1234@
spring.data.mongodb.authentication-database=admin

# --- redis ---
spring.data.redis.host=localhost
spring.data.redis.port=6379
spring.data.redis.password=
spring.data.redis.timeout=2000

# --- Mail ---
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username="gmail을 넣어주세요"
spring.mail.password="비밀번호를 넣어주세요"
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

mail.verification.expire-time=180000

# --- Gemini api ---
gemini.api-key="api키를 넣어주세요"

# --- root path ---
# ex: file.upload-dir=file:///D:/Program/final/law-n-road/uploads/
file.upload-dir=본인 루트 경로

# --- naver img storage ---
ncp.storage.bucket=law-n-road
ncp.storage.region=kr-standard
ncp.storage.endpoint=https://kr.object.ncloudstorage.com
ncp.storage.accessKey=accessKey를 넣어주세요"
ncp.storage.secretKey="secretKey를 넣어주세요"

# --- naver ocr ---
ncp.ocr.secretKey="secretKey를 넣어주세요"
ncp.ocr.endpoint=https://qm4c7n6gsp.apigw.ntruss.com/custom/v1/43045/595ee773782c96e206788087fc0c6433e7b20cb7391fdbb5cd037ca18db83197/general

# Toss Payments
tosspayments.secret-key="secret키를 넣어주세요"
tosspayments.base-url=https://api.tosspayments.com
tosspayments.success-url=https://localhost:5173/pay/success
tosspayments.fail-url=https://localhost:5173/pay/fail

# Clova Chatbot 
chatbot.invoke-url=https://syt7difvlq.apigw.ntruss.com/custom/v1/17535/9ba4f0e8108b3e5b411f110b7aebcd5904b5d1ccf5e3ada99c5f39c8cf71e4e7
chatbot.secret-key="secret키를 넣어주세요"

# Clova Studio
clova.api-key="api키를 넣어주세요"
clova.api-url=https://clovastudio.stream.ntruss.com/testapp/v3/chat-completions/HCX-005

# VOD
spring.mvc.static-path-pattern=/uploads/**
spring.web.resources.static-locations=${file.upload-dir}


# Naver 소셜로그인
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

# dev vs prod (dev 개발자만 추가, 배포 서버에는 추가하지 않음)
spring.profiles.active=dev
```

# frontend/.env.development 파일 추가
- dev 개발자만 추가, 배포 서버에는 추가하지 않음

```
VITE_API_BASE=http://localhost:8080
```


# npm 설정
```
cd frontend
npm install
npm install axios
npm install --save solapi
npm install openvidu-browser@2.30.0
npm install sockjs-client @stomp/stompjs
npm install @fullcalendar/vue3 @fullcalendar/daygrid @fullcalendar/interaction
npm install @tiptap/vue-3 @tiptap/starter-kit
npm install @tiptap/extension-underline @tiptap/extension-text-style @tiptap/extension-ordered-list @tiptap/suggestion
npm install bootstrap
npm install html2pdf.js
npm install crypto-js
npm install webm-duration-fix
npm install chart.js
```

🟢 네이버 로그인
본 프로젝트는 네이버 OAuth2 로그인을 사용합니다.
반드시 관리자에게 Client ID & Secret 등록 허가를 받아야 정상적으로 사용할 수 있습니다.

🧪 더미 계정 (로그인 테스트용)
구분	아이디 (이메일)	비밀번호
회원	ssg, test09
변호사	lawyer001, test01
관리자	admin123,	admin123

🔥 초기 실행 순서

# Spring Boot (IntelliJ 또는 CLI) 실행

# Vue.js 실행
```
npm run dev
```

# 더미데이터 실행
- /dummy_data.sql 실행
