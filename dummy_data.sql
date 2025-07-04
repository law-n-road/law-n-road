DROP TABLE IF EXISTS `refresh_token`;
DROP TABLE IF EXISTS `tmpl_editor_based`;
DROP TABLE IF EXISTS `tmpl_file_based`;
DROP TABLE IF EXISTS `tmpl_orders_history`;
DROP TABLE IF EXISTS `cart`;
DROP TABLE IF EXISTS `template`;
DROP TABLE IF EXISTS `ad_purchase`;
DROP TABLE IF EXISTS `comment`;
DROP TABLE IF EXISTS `board`;
DROP TABLE IF EXISTS `refunds`;
DROP TABLE IF EXISTS `webhook_logs`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `reservations`;
DROP TABLE IF EXISTS `weekly_time_slots`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `keyword_alert`;
DROP TABLE IF EXISTS `keyword`;
DROP TABLE IF EXISTS `auto_reply`;
DROP TABLE IF EXISTS `pre_question`;
DROP TABLE IF EXISTS `broadcast_vod`;
DROP TABLE IF EXISTS `broadcast_report`;
DROP TABLE IF EXISTS `report_reason_code`;
DROP TABLE IF EXISTS `broadcast`;
DROP TABLE IF EXISTS `broadcast_schedule`;
DROP TABLE IF EXISTS `category`;
DROP TABLE IF EXISTS `admin`;
DROP TABLE IF EXISTS `lawyer`;
DROP TABLE IF EXISTS `client`;
DROP TABLE IF EXISTS `chat_report`;
DROP TABLE IF EXISTS `user`;

-- 유저
CREATE TABLE `user` (
                        `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                        `type` ENUM('LAWYER', 'CLIENT') NOT NULL,
                        PRIMARY KEY (`no`)
);

-- 사용자
CREATE TABLE `client` (
                          `no` BIGINT UNSIGNED NOT NULL,
                          `client_id` VARCHAR(30) UNIQUE,
                          `pw_hash` VARCHAR(255),
                          `email` VARCHAR(80) NOT NULL UNIQUE,
                          `name` VARCHAR(30) NOT NULL,
                          `nickname` VARCHAR(50) NOT NULL UNIQUE,
                          `phone` VARCHAR(20) NOT NULL,
                          `content` TINYINT NOT NULL,
                          `alert_content` TINYINT NOT NULL,
                          `stop_date` DATETIME,
                          `is_stopped` TINYINT NOT NULL DEFAULT 0,
                          `accumulated_reports` INT UNSIGNED NOT NULL DEFAULT 0,
                          `is_unregistered` TINYINT NOT NULL DEFAULT 0,
                          `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          `withdrawal_at` DATETIME,
                          `social_id` VARCHAR(255),
                          `is_consult_alert` TINYINT NOT NULL DEFAULT 0,
                          PRIMARY KEY (`no`),
                          CONSTRAINT `fk_client_user`
                              FOREIGN KEY (`no`) REFERENCES `user`(`no`)
                                  ON DELETE CASCADE
);

-- 변호사
CREATE TABLE `lawyer`
(
    `no`             BIGINT UNSIGNED NOT NULL,
    `lawyer_id`      VARCHAR(30) NOT NULL UNIQUE,
    `pw_hash`        VARCHAR(255) NOT NULL,
    `profile`        VARCHAR(255),
    `email`          VARCHAR(80) NOT NULL UNIQUE,
    `name`           VARCHAR(30) NOT NULL,
    `office_number`  VARCHAR(20),
    `phone`          VARCHAR(20) NOT NULL,
    `zipcode`        CHAR(6) NOT NULL,
    `road_address`   VARCHAR(100) NOT NULL,
    `land_address`   VARCHAR(100) NOT NULL,
    `detail_address` VARCHAR(100) NOT NULL,
    `point`          INT UNSIGNED NOT NULL DEFAULT 0,
    `consent`        TINYINT NOT NULL,
    `status`         ENUM ('APPROVED_JOIN', 'REJECTED_JOIN', 'PENDING_LEAVE', 'APPROVED_LEAVE') NOT NULL,
    `consult_price`  INT UNSIGNED NOT NULL DEFAULT 30000,
    `created_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`     DATETIME  NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `withdrawal_at`  DATETIME,
    `card_front`     VARCHAR(255),
    `card_back`      VARCHAR(255),
    `office_name`    varchar(100) not null,
    `lawyer_intro`   tinytext null,
    `intro_detail`   text null,
    PRIMARY KEY (`no`),
    CONSTRAINT `fk_lawyer_user`
        FOREIGN KEY (`no`) REFERENCES `user` (`no`)
            ON DELETE CASCADE
);

-- 관리자
CREATE TABLE `admin` (
                         `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                         `admin_id` VARCHAR(20) NOT NULL UNIQUE,
                         `pw_hash` VARCHAR(255) NOT NULL,
                         `name` VARCHAR(10) NOT NULL,
                         `phone` VARCHAR(15) NOT NULL,
                         `email` VARCHAR(50) NOT NULL UNIQUE,
                         `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         PRIMARY KEY (`no`)
);

-- 카테고리 테이블
CREATE TABLE `category` (
                            `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '카테고리 no',
                            `name` VARCHAR(20) NOT NULL COMMENT '카테고리명',
                            `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 일시',
                            PRIMARY KEY (`no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 방송 스케줄
CREATE TABLE `broadcast_schedule`
(
    `no`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '스케줄 no',
    `user_no`        BIGINT UNSIGNED NOT NULL COMMENT '유저 no',
    `category_no`    BIGINT UNSIGNED NOT NULL COMMENT '카테고리 no',
    `name`           VARCHAR(255)    NOT NULL COMMENT '방송 제목',
    `content`        TEXT            NOT NULL COMMENT '방송 설명',
    `thumbnail_path` VARCHAR(255)    NULL COMMENT '썸네일 경로',
    `date`           DATE            NOT NULL COMMENT '예정 날짜',
    `start_time`     DATETIME        NOT NULL,
    `end_time`       DATETIME        NOT NULL,
    `created_at`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`no`),
    CONSTRAINT `fk_schedule_lawyer` FOREIGN KEY (`user_no`) REFERENCES `user` (`no`) ON DELETE CASCADE,
    CONSTRAINT `fk_schedule_category` FOREIGN KEY (`category_no`) REFERENCES `category` (`no`) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- 방송
CREATE TABLE `broadcast`
(
    `no`            BIGINT UNSIGNED                             NOT NULL AUTO_INCREMENT COMMENT '방송 no',
    `user_no`       BIGINT UNSIGNED                             NOT NULL COMMENT '유저 no',
    `schedule_no`   BIGINT UNSIGNED                             NOT NULL COMMENT '스케줄 no',
    `session_id`    VARCHAR(255)                                NOT NULL,
    `start_time`    DATETIME                                    NOT NULL,
    `end_time`      DATETIME                                    NULL,
    `status`        ENUM ('RECORD', 'DONE') NOT NULL DEFAULT 'RECORD' COMMENT '방송 상태',
    `report_status` TINYINT                                     NOT NULL DEFAULT 0 COMMENT '기본:0, 신고:1',
    `created_at`    DATETIME                                    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`no`),
    CONSTRAINT `fk_broadcast_schedule` FOREIGN KEY (`schedule_no`) REFERENCES `broadcast_schedule` (`no`) ON DELETE CASCADE,
    CONSTRAINT `fk_broadcast_lawyer` FOREIGN KEY (`user_no`) REFERENCES `user` (`no`) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- 신고 사유
CREATE TABLE `report_reason_code`
(
    `code`  VARCHAR(50)  NOT NULL PRIMARY KEY COMMENT '사유 코드',
    `label` VARCHAR(100) NOT NULL COMMENT '화면에 보여줄 신고 사유'
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- 방송 신고
CREATE TABLE `broadcast_report`
(
    `no`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '신고 고유 번호',
    `broadcast_no`  BIGINT UNSIGNED NOT NULL COMMENT '신고 대상 방송 번호',
    `user_no`       BIGINT UNSIGNED NOT NULL COMMENT '신고자 유저 번호',
    `reason_code`   VARCHAR(50)     NOT NULL COMMENT '신고 사유 코드',
    `detail_reason` TEXT            NULL COMMENT '추가 입력한 상세 신고 내용',
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '신고 시간',
    PRIMARY KEY (`no`),
    CONSTRAINT `fk_report_broadcast` FOREIGN KEY (`broadcast_no`) REFERENCES `broadcast` (`no`) ON DELETE CASCADE,
    CONSTRAINT `fk_report_user` FOREIGN KEY (`user_no`) REFERENCES `user` (`no`) ON DELETE CASCADE,
    CONSTRAINT `fk_report_reason_code` FOREIGN KEY (`reason_code`) REFERENCES `report_reason_code` (`code`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- 방송　vod
CREATE TABLE `broadcast_vod`
(
    `no`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'VOD no',
    `broadcast_no` BIGINT UNSIGNED NOT NULL COMMENT '방송 no',
    `vod_path`     VARCHAR(255)    NOT NULL COMMENT 'VOD 파일 경로',
    `duration`     INT UNSIGNED    NOT NULL COMMENT '영상 길이 (초)',
    `view_count`   INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '영상 조회수',
    `status`       TINYINT         NOT NULL DEFAULT 0 COMMENT '0: 유지, 1: 삭제됨',
    `created_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`no`),
    CONSTRAINT `fk_vod_broadcast` FOREIGN KEY (`broadcast_no`) REFERENCES `broadcast` (`no`) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- 채팅 신고
CREATE TABLE `chat_report` (
                               `no`	BIGINT UNSIGNED	NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '채팅 신고 no',
                               `user_no` BIGINT UNSIGNED NOT NULL,
                               `reported_user_no` BIGINT UNSIGNED NOT NULL,
                               `nickname` VARCHAR(50)	NOT NULL,
                               `message` TEXT NOT NULL,
                               `report_status` TINYINT	NOT NULL DEFAULT 0 COMMENT '처리 대기:0, 처리 완료:1',
                               `created_at` DATETIME NOT NULL,

                               FOREIGN KEY (`user_no`) REFERENCES `user`(`no`) ON DELETE CASCADE

);

-- 사전질문
CREATE TABLE `pre_question` (

                                `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '사전질문 no',
                                `user_no` BIGINT UNSIGNED NOT NULL,
                                `schedule_no` BIGINT UNSIGNED NOT NULL COMMENT '스케줄 no',
                                `nickname` VARCHAR(50) NOT NULL COMMENT '닉네임',
                                `content` TEXT NOT NULL COMMENT '사전 질문 내용',
                                `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                FOREIGN KEY (`schedule_no`) REFERENCES `broadcast_schedule`(`no`) ON DELETE CASCADE, FOREIGN KEY (`user_no`) REFERENCES `user`(`no`) ON DELETE CASCADE

);

-- 자동응답
CREATE TABLE `auto_reply` (

                              `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '자동응답 no',
                              `schedule_no` BIGINT UNSIGNED NOT NULL COMMENT '스케줄 no',
                              `keyword` VARCHAR(50) NOT NULL COMMENT '자동응답 키워드',
                              `message` TEXT NOT NULL COMMENT '자동응답 메시지',
                              `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',

                              FOREIGN KEY (`schedule_no`) REFERENCES `broadcast_schedule`(`no`) ON DELETE CASCADE
);

-- 방송 키워드
CREATE TABLE `keyword`
(
    `no`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '키워드 no',
    `schedule_no`  BIGINT UNSIGNED NOT NULL COMMENT '스케줄 no',
    `keyword`      VARCHAR(50)     NOT NULL COMMENT '방송 키워드',
    `created_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`no`),
    CONSTRAINT `fk_keyword_broadcast` FOREIGN KEY (`schedule_no`) REFERENCES `broadcast_schedule` (`no`) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- 키워드 알림
CREATE TABLE `keyword_alert`
(
    `no`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '알림 신청 no',
    `user_no`    BIGINT UNSIGNED NOT NULL COMMENT '의뢰인 no (user 테이블 참조)',
    `keyword`    VARCHAR(50)     NOT NULL COMMENT '신청 키워드',
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '신청 일시',
    PRIMARY KEY (`no`),
    CONSTRAINT `fk_keyword_alert_user`
        FOREIGN KEY (`user_no`) REFERENCES `user` (`no`)
            ON DELETE CASCADE,
    UNIQUE KEY `uk_user_keyword` (`user_no`, `keyword`) -- 중복 신청 방지
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- 주문
CREATE TABLE `orders` (
                          `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                          `order_code` VARCHAR(64) NOT NULL UNIQUE,
                          `user_no` BIGINT UNSIGNED NOT NULL,
                          `amount` BIGINT UNSIGNED NOT NULL,
                          `status` ENUM('ORDERED', 'PAID', 'CANCELED') NOT NULL DEFAULT 'ORDERED',
                          `order_type` ENUM('RESERVATION', 'TEMPLATE', 'ADVERTISEMENT') NOT NULL,
                          `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          FOREIGN KEY (`user_no`) REFERENCES `user`(`no`)
);

-- 주간 예약
CREATE TABLE `weekly_time_slots` (
                                     `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                                     `user_no` BIGINT UNSIGNED NOT NULL,
                                     `slot_date` DATE NOT NULL,
                                     `slot_time` TIME NOT NULL,
                                     `status` TINYINT NOT NULL DEFAULT 0,
                                     `amount` BIGINT UNSIGNED NOT NULL,
                                     `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                     `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                     FOREIGN KEY (`user_no`) REFERENCES `user`(`no`)
);

-- 예약
CREATE TABLE `reservations` (
                                `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                                `order_no` BIGINT UNSIGNED NOT NULL,
                                `slot_no` BIGINT UNSIGNED NOT NULL,
                                `user_no` BIGINT UNSIGNED NOT NULL,
                                `status` ENUM('REQUESTED','CANCELED','DONE') NOT NULL DEFAULT 'REQUESTED',
                                `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                FOREIGN KEY (`order_no`) REFERENCES `orders`(`no`),
                                FOREIGN KEY (`slot_no`) REFERENCES `weekly_time_slots`(`no`),
                                FOREIGN KEY (`user_no`) REFERENCES `user`(`no`)
);


-- 결제내역
CREATE TABLE `payments` (
                            `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                            `order_no` BIGINT UNSIGNED NOT NULL,
                            `payment_key` VARCHAR(64) NOT NULL UNIQUE,
                            `order_code` VARCHAR(64) NOT NULL,
                            `amount` BIGINT UNSIGNED NOT NULL,
                            `status` ENUM('READY','DONE','FAILED','CANCELED') NOT NULL,
                            `installment_month` TINYINT NULL,
                            `purchased_at` DATETIME NULL,
                            `metadata` JSON NULL,
                            `pg` VARCHAR(32) NOT NULL,
                            `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                            FOREIGN KEY (order_no) REFERENCES orders(no)
);

-- 웹훅
CREATE TABLE `webhook_logs` (
                                `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                                `payment_no` BIGINT UNSIGNED NULL,
                                `event_type` VARCHAR(64) NOT NULL,
                                `payload` JSON NOT NULL,
                                `received_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                `processed` TINYINT NOT NULL DEFAULT 0,
                                `error_message` VARCHAR(255) NULL,
                                FOREIGN KEY (`payment_no`) REFERENCES `payments`(`no`)
);

-- 환불
CREATE TABLE `refunds` (
                           `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                           `payment_no` BIGINT UNSIGNED NOT NULL,
                           `refund_key` VARCHAR(64) NOT NULL UNIQUE,
                           `amount` BIGINT UNSIGNED NOT NULL,
                           `status` ENUM('PENDING', 'DONE', 'FAILED') NOT NULL,
                           `reason` VARCHAR(255) NULL,
                           `requested_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           `refunded_at` DATETIME NULL,
                           `metadata` JSON NULL,
                           `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                           FOREIGN KEY (`payment_no`) REFERENCES `payments`(`no`)
);

-- 게시글
CREATE TABLE `board` (
                         `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '게시글',
                         `category_no` BIGINT UNSIGNED NOT NULL COMMENT '카테고리',
                         `user_no` BIGINT UNSIGNED NOT NULL COMMENT '질문자(의뢰인)',
                         `title` VARCHAR(100) NOT NULL COMMENT '게시글 제목',
                         `content` TEXT NOT NULL COMMENT '게시글 내용',
                         `incident_date` DATE NOT NULL COMMENT '최초 사건 발생일자',
                         `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '작성 일시',
                         `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
                         PRIMARY KEY (`no`),
                         CONSTRAINT `fk_board_category` FOREIGN KEY (`category_no`) REFERENCES `category`(`no`) ON DELETE CASCADE,
                         CONSTRAINT `fk_board_user` FOREIGN KEY (`user_no`) REFERENCES `user`(`no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 변호사 답변
CREATE TABLE `comment` (
                           `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '답변',
                           `board_no` BIGINT UNSIGNED NOT NULL COMMENT '게시글 번호',
                           `user_no` BIGINT UNSIGNED NOT NULL COMMENT '답변자(변호사)',
                           `content` TEXT NOT NULL COMMENT '답변 내용',
                           `is_selected` TINYINT NOT NULL DEFAULT 0 COMMENT '채택 여부 (0=미채택,1=채택)',
                           `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '답변 작성 일시',
                           `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '답변 수정 일시',
                           PRIMARY KEY (`no`),
                           CONSTRAINT `fk_comment_board` FOREIGN KEY (`board_no`) REFERENCES `board`(`no`) ON DELETE CASCADE,
                           CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_no`) REFERENCES `user`(`no`) ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4;

-- 광고 구매내역 테이블
CREATE TABLE `ad_purchase` (
                               `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '광고 구매내역 no',
                               `orders_no` BIGINT UNSIGNED NOT NULL COMMENT '주문 no',
                               `user_no` BIGINT UNSIGNED NOT NULL COMMENT '신청 변호사 no',
                               `ad_path` VARCHAR(255) NOT NULL COMMENT '배너 이미지 경로',
                               `ad_type` ENUM('MAIN', 'SUB') NOT NULL COMMENT '광고 유형',
                               `main_text` VARCHAR(200) NOT NULL COMMENT '광고 메인 문구',
                               `detail_text` VARCHAR(255) NOT NULL COMMENT '광고 상세 문구',
                               `tip_text` VARCHAR(100) NULL COMMENT '광고 팁 문구',
                               `start_date` DATETIME NOT NULL COMMENT '광고 시작일',
                               `end_date` DATETIME NOT NULL COMMENT '광고 종료일',
                               `ad_status` TINYINT NOT NULL DEFAULT 0 COMMENT '광고 활성화 여부',
                               `approval_status` ENUM('PENDING', 'APPROVED', 'REJECTED') NOT NULL COMMENT '승인 여부',
                               `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 일시',
                               `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
                               PRIMARY KEY (`no`),
                               CONSTRAINT `fk_ad_purchase_orders` FOREIGN KEY (`orders_no`) REFERENCES `orders`(`no`) ON DELETE CASCADE,
                               CONSTRAINT `fk_ad_purchase_lawyer` FOREIGN KEY (`user_no`) REFERENCES `user`(`no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 템플릿 테이블
CREATE TABLE `template` (
                            `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '템플릿 no',
                            `user_no` BIGINT UNSIGNED NOT NULL COMMENT '유저 no',
                            `category_no` BIGINT UNSIGNED NOT NULL COMMENT '카테고리 no',
                            `type` ENUM('FILE', 'EDITOR') NOT NULL COMMENT '템플릿 타입',
                            `name` VARCHAR(50) NOT NULL COMMENT '템플릿명',
                            `description` TEXT NOT NULL COMMENT '상세설명',
                            `price` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '가격',
                            `thumbnail_path` VARCHAR(255) NOT NULL COMMENT '썸네일 이미지 경로',
                            `sales_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '누적 판매량',
                            `discount_rate` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '할인율',
                            `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '삭제여부 (0: 유지, 1: 삭제됨)',
                            `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 일시',
                            `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
                            PRIMARY KEY (`no`),
                            CONSTRAINT `fk_template_user` FOREIGN KEY (`user_no`) REFERENCES `user`(`no`) ON DELETE CASCADE,
                            CONSTRAINT `fk_template_category` FOREIGN KEY (`category_no`) REFERENCES `category`(`no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 파일 업로드 기반 템플릿
CREATE TABLE `tmpl_file_based` (
                                   `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '템플릿 no',
                                   `path_json` TEXT NOT NULL COMMENT '파일명+파일 경로 (JSON)',
                                   PRIMARY KEY (`no`),
                                   CONSTRAINT `fk_file_based_template` FOREIGN KEY (`no`) REFERENCES `template`(`no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 에디터 기반 템플릿
CREATE TABLE `tmpl_editor_based` (
                                     `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '템플릿 no',
                                     `content` TEXT NOT NULL COMMENT '문서 내용',
                                     `var_json` TEXT COMMENT '변수 목록 + 설명 (JSON)',
                                     `ai_enabled` TINYINT NOT NULL DEFAULT 0 COMMENT 'AI 활용 동의 여부',
                                     PRIMARY KEY (`no`),
                                     CONSTRAINT `fk_editor_based_template` FOREIGN KEY (`no`) REFERENCES `template`(`no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 장바구니 테이블
CREATE TABLE `cart` (
                        `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '장바구니 no',
                        `user_no` BIGINT UNSIGNED NOT NULL COMMENT '유저 no',
                        `tmpl_no` BIGINT UNSIGNED NOT NULL COMMENT '템플릿 no',
                        `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 일시',
                        `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
                        PRIMARY KEY (`no`),
                        CONSTRAINT `fk_cart_template` FOREIGN KEY (`tmpl_no`) REFERENCES `template`(`no`) ON DELETE CASCADE,
                        CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_no`) REFERENCES `user`(`no`) ON DELETE CASCADE,
                        UNIQUE(user_no, tmpl_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 템플릿 구매내역 테이블
CREATE TABLE `tmpl_orders_history` (
                                       `no` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '템플릿 구매내역 no',
                                       `tmpl_no` BIGINT UNSIGNED NOT NULL COMMENT '템플릿 no',
                                       `order_no` BIGINT UNSIGNED NOT NULL COMMENT '주문 no',
                                       `price` INT UNSIGNED NOT NULL COMMENT '구매 당시 가격',
                                       `is_downloaded` TINYINT NOT NULL DEFAULT 0 COMMENT '다운로드 여부',
                                       `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 일시',
                                       `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
                                       PRIMARY KEY (`no`),
                                       CONSTRAINT `fk_tmpl_orders_template` FOREIGN KEY (`tmpl_no`) REFERENCES `template`(`no`) ON DELETE CASCADE,
                                       CONSTRAINT `fk_tmpl_orders_order` FOREIGN KEY (`order_no`) REFERENCES `orders`(`no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 리플레시 토큰 테이블
CREATE TABLE `refresh_token` (
                                 `no` BIGINT UNSIGNED NOT NULL,        -- user.no 와 완전 동일
                                 `token` VARCHAR(512) NOT NULL,
                                 `issued_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 `expires_at` DATETIME NULL,
                                 PRIMARY KEY (`no`),
                                 CONSTRAINT `fk_refresh_user`
                                     FOREIGN KEY (`no`)
                                         REFERENCES `user` (`no`)
                                         ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4;

-- insert문 시작
INSERT INTO user (no, type) VALUES
                                (1, 'CLIENT'),
                                (2, 'CLIENT'),
                                (3, 'CLIENT'),
                                (4, 'CLIENT'),
                                (5, 'CLIENT'),
                                (6, 'CLIENT'),
                                (7, 'CLIENT'),
                                (8, 'CLIENT'),
                                (9, 'CLIENT'),
                                (10, 'CLIENT'),
                                (11, 'CLIENT'),
                                (12, 'CLIENT'),
                                (13, 'CLIENT'),
                                (14, 'CLIENT'),
                                (15, 'CLIENT'),
                                (16, 'CLIENT'),
                                (17, 'CLIENT'),
                                (18, 'CLIENT'),
                                (19, 'CLIENT'),
                                (20, 'CLIENT'),
                                (21, 'CLIENT'),
                                (22, 'CLIENT'),
                                (23, 'CLIENT'),
                                (24, 'CLIENT'),
                                (25, 'CLIENT'),
                                (26, 'CLIENT'),
                                (27, 'CLIENT'),
                                (28, 'CLIENT'),
                                (29, 'CLIENT');


-- 사용자 : 팀원 데이터
-- 1. mybang - test04 - 키워드알림수신X
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (4, 'mybang', '$2a$10$FFarEKvpA652hV9NJUm0feDUNzz2Cq.x90Q/140R2MsV1Kr8e1gvm', 'mybang@naver.com', '방민영', '용인시방민영', '010-3857-8216', 1, 0, NULL, 0, 0, 0, '2022-06-19 22:15:30', '2022-06-22 22:15:30', NULL, NULL, 1);

-- 2. minsungseo - test05 - 상담알림수신X
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (5, 'minsungseo', '$2a$10$515YWmGSCSBC8YRHQcNEbOaRbXIUDOZNdCaJnsoBEgi03m5k7dOlC', 'minsung@naver.com', '서민성', '대구남자', '010-4341-4356', 1, 1, NULL, 0, 0, 0, '2022-12-26 19:06:19', '2023-03-08 19:06:19', NULL, NULL, 0);

-- 3. changsun - test06 - 키워드알림수신X
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (6, 'changsun', '$2a$10$6zSuWWsJdqpSFWZ6Am5Mlu4idUL82sPhTy4vA74NBzgyqyNkiYbg2', 'changsun@gmail.com', '강창선', '부산남자', '010-9647-1213', 1, 0, NULL, 0, 0, 0, '2022-01-11 09:33:00', '2022-04-02 09:33:00', NULL,NULL, 1);

-- 4. gunhee - test07 - 신고 10건이지만 아직 정지 안 먹음 (관리자페이지에서 패널티 먹이는거 테스트 예정)
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (7, 'gunhee', '$2a$10$ETO9uQlxOl/EYlJVIjm6oOFA5ey8BcKViJVJpBnUkhxLkqICH8sya', 'park@gmail.com', '박건희', '박건희01', '010-8127-2572', 1, 1, NULL, 0, 10, 0, '2022-12-01 04:18:05', '2023-02-17 04:18:05', NULL, NULL, 1);

-- 5. yujin - test08 - 채팅 정지 이미 먹음 (6. 30. 오전 10시에)
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (8, 'yujin', '$2a$10$7SojuXsNwK2sxSMJVnfzJuVTvGBlDigfbcXjU4y.VExAnzprRnBWC', 'yujin@naver.com', '정유진', '정유진02', '010-2195-5758', 1, 1, '2025-06-30 00:10:00', 1, 60, 0, '2022-08-16 00:06:56', '2022-10-14 00:06:56', NULL, NULL, 1);


-- 탈퇴한 회원의 데이터 (7명)
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (1, 'LTS1112', '$2a$10$OcdSZ9r5jFDJ9vx.oZ75L.l1tMlwzat1eIHbez9ynVLG1CKypjI3m', 'LJS1112@naver.com', '이정수', '하이정수', '010-1112-1112', 1, 0, NULL, 0, 0, 1, '2022-09-03 23:50:08', '2022-10-28 23:50:08', '2022-10-28 23:50:08', NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (3, 'winter0101', ' $2a$10$1r.IxlMvZsAwqIB/PCTPTuFYHTMzBUzm4guOo64h8u75NCdiK6xcy', 'winter0101@gmail.com', '김민정', '하이윈터', '010-0101-2025', 1, 1, NULL, 0, 0, 1, '2023-10-05 22:45:34', '2023-12-24 22:45:34', '2023-12-24 22:45:34', NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (11, 'seulgi0210', '$2a$10$OcdSZ9r5jFDJ9vx.oZ75L.l1tMlwzat1eIHbez9ynVLG1CKypjI3m', 'seulgi@naver.com', '강슬기', '하이슬기', '010-0210-0210', 1, 0, NULL, 0, 0, 1, '2022-04-07 22:12:42', '2022-04-23 22:12:42', '2022-04-23 22:12:42', NULL, 0);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (23, 'incheon03', '$2a$10$1r.IxlMvZsAwqIB/PCTPTuFYHTMzBUzm4guOo64h8u75NCdiK6xcy', 'incheon@example.com', '인천', '미추홀구', '010-3424-2232', 1, 1, NULL, 0, 0, 1, '2023-06-04 05:26:37', '2023-08-24 05:26:37', '2023-08-24 05:26:37', NULL, 0);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (24, 'kakao', '$2a$10$FFarEKvpA652hV9NJUm0feDUNzz2Cq.x90Q/140R2MsV1Kr8e1gvm', 'kakao@kakao.com', '카카오', '카카오판교', '010-1239-8924', 1, 1, NULL, 0, 0, 1, '2023-10-29 12:32:55', '2023-11-08 12:32:55', '2023-11-08 12:32:55', NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (25, 'italian01', '$2a$10$515YWmGSCSBC8YRHQcNEbOaRbXIUDOZNdCaJnsoBEgi03m5k7dOlC', 'italian01@example.com', '악어', '봄바르 코로딜로', '010-2345-2325', 1, 0, NULL, 0, 0, 1, '2024-08-14 10:53:46', '2024-10-27 10:53:46', '2024-10-27 10:53:46', NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (26, 'italian02', '$2a$10$6zSuWWsJdqpSFWZ6Am5Mlu4idUL82sPhTy4vA74NBzgyqyNkiYbg2', 'italian02@example.com', '나무', '퉁퉁퉁 사후르', '010-2342-0808', 1, 1, NULL, 0, 0, 1, '2023-11-23 10:18:27', '2023-12-01 10:18:27', '2023-12-01 10:18:27', NULL, 1);


-- 일반 회원 데이터 (채팅정지 X)
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (2, 'dlwjdtn1112', '$2a$10$uPGdOUNadNbbs40pZaOnk.KolTWhktNSSpaLBQgNfBHYhQBvEVDi2', 'dlwjdtn1112@naver.com', '이장수', '하이장수', '010-1113-1112', 1, 1, NULL, 0, 0, 0, '2024-09-05 08:54:52', '2024-12-12 08:54:52', NULL, NULL, 0);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (9, 'ssg', '$2a$10$MAwnLb7iJp3nfCwHhO5shuCNzSnBTZF.35ixnW0Yyu27WZK1qoFS2', 'ssg06@myworld.com', '신세계', '신세계06', '010-6666-6666', 1, 0, NULL, 0, 0, 0, '2024-02-07 18:05:05', '2024-02-18 18:05:05', NULL,NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (10, 'irene0329', '$2a$10$uhSQ.4igpusve1xIEfWfserUwNrzbDrW20ss4YAowzOrEofAyvv4C', 'irene0329@naver.com', '배주현', '아이린', '010-0329-0329', 1, 1, NULL, 0, 0, 0, '2023-04-09 14:53:31', '2023-07-14 14:53:31', NULL, NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (12, 'wendy0422', '$2a$10$uPGdOUNadNbbs40pZaOnk.KolTWhktNSSpaLBQgNfBHYhQBvEVDi2', 'wendy@naver.com', '손승완', '웬디', '010-2342-2342', 1, 1, NULL, 0, 0, 0, '2022-02-23 05:28:38', '2022-04-27 05:28:38', NULL, NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (13, 'joy0903', '$2a$10$1r.IxlMvZsAwqIB/PCTPTuFYHTMzBUzm4guOo64h8u75NCdiK6xcy', 'joy0903@example.com', '박수영', '조이', '010-0000-0013', 1, 0, NULL, 0, 0, 0, '2022-09-23 03:41:45', '2022-10-31 03:41:45', NULL, NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (14, 'Yeri', '$2a$10$FFarEKvpA652hV9NJUm0feDUNzz2Cq.x90Q/140R2MsV1Kr8e1gvm', 'yeri@naver.com', '김예림', '예리', '010-0453-2345', 1, 1, NULL, 0, 0, 0, '2023-09-14 15:35:20', '2023-10-22 15:35:20', NULL, NULL, 0);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (15, 'Yeji0730', '$2a$10$515YWmGSCSBC8YRHQcNEbOaRbXIUDOZNdCaJnsoBEgi03m5k7dOlC', 'yeji@naver.com', '예지', 'itzy01', '010-3499-0015', 1, 1, NULL, 0, 0, 0, '2024-08-24 03:08:49', '2024-10-19 03:08:49', NULL, NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (16, 'lia0721', '$2a$10$6zSuWWsJdqpSFWZ6Am5Mlu4idUL82sPhTy4vA74NBzgyqyNkiYbg2', 'lia0721@naver.com', '리아', '있지리아', '010-2342-0721', 1, 0, NULL, 0, 0, 0, '2023-06-07 20:35:13', '2023-07-06 20:35:13', NULL, NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (17, 'Ryujin0417', '$2a$10$ETO9uQlxOl/EYlJVIjm6oOFA5ey8BcKViJVJpBnUkhxLkqICH8sya', 'Ryujin0417@naver.com', '신류진', '있지류진', '010-2346-0417', 1, 0, NULL, 0, 0, 0, '2023-03-29 03:45:16', '2023-05-10 03:45:16', NULL, NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (18, 'Chaeryeong0911', '$2a$10$7SojuXsNwK2sxSMJVnfzJuVTvGBlDigfbcXjU4y.VExAnzprRnBWC', 'Chaeryeong@naver.com', '채령', 'itzy채령', '010-2345-0018', 1, 1, NULL, 0, 0, 0, '2022-12-04 20:23:10', '2022-12-23 20:23:10', NULL, NULL, 0);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (19, 'Yuna1209', '$2a$10$MAwnLb7iJp3nfCwHhO5shuCNzSnBTZF.35ixnW0Yyu27WZK1qoFS2', 'Yuna1209@naver.com', '유나', '있지유나', '010-1209-1209', 1, 1, NULL, 0, 0, 0, '2024-08-26 09:37:19', '2024-12-01 09:37:19', NULL, NULL, 0);


-- 일반 회원 데이터 (채팅정지 O - 6. 30. 오전 10시에)
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (20, 'wjdxodus', '$2a$10$uhSQ.4igpusve1xIEfWfserUwNrzbDrW20ss4YAowzOrEofAyvv4C', 'wjdxodus@example.com', '태연', 'Kkolcho', '010-2342-0020', 1, 1, '2025-06-30 00:10:00', 1, 37, 0, '2022-06-25 23:22:01', '2022-07-07 23:22:01', NULL, NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (21, 'daegu01', '$2a$10$OcdSZ9r5jFDJ9vx.oZ75L.l1tMlwzat1eIHbez9ynVLG1CKypjI3m', 'daegu@example.com', '대구', '수성구', '010-0234-0021', 1, 0, '2025-06-30 00:10:00', 1, 49, 0, '2023-10-28 13:15:21', '2023-11-26 13:15:21', NULL, NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (22, 'busan02', '$2a$10$uPGdOUNadNbbs40pZaOnk.KolTWhktNSSpaLBQgNfBHYhQBvEVDi2', 'busan@example.com', '부산', '해운대', '010-2345-1234', 1, 1, '2025-06-30 00:10:00', 1, 18, 0, '2022-01-22 05:55:42', '2022-03-31 05:55:42', NULL, NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (27, 'test7777', '$2a$10$ETO9uQlxOl/EYlJVIjm6oOFA5ey8BcKViJVJpBnUkhxLkqICH8sya', 'test777@gmail.com', 'User27', 'test7777', '010-7788-0027', 1, 1, '2025-06-30 00:10:00', 1, 7, 0, '2022-06-28 12:59:31', '2022-09-18 12:59:31', NULL, NULL, 0);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (28, 'test8888', '$2a$10$7SojuXsNwK2sxSMJVnfzJuVTvGBlDigfbcXjU4y.VExAnzprRnBWC', 'dlwjdtn8888@naver.com', '이정수', '판교사랑이정수', '010-2014-3290', 1, 0, '2025-06-30 00:10:00', 1, 27, 0, '2024-04-12 03:24:21', '2024-05-28 03:24:21', NULL, NULL, 1);
INSERT INTO client (no, client_id, pw_hash, email, name, nickname, phone, content, alert_content, stop_date, is_stopped, accumulated_reports, is_unregistered, created_at, updated_at, withdrawal_at, social_id, is_consult_alert)
VALUES (29, 'italian03', '$2a$10$MAwnLb7iJp3nfCwHhO5shuCNzSnBTZF.35ixnW0Yyu27WZK1qoFS2', 'italian03@naver.com', '주전자', '타타타 사후르', '010-3422-2229', 1, 1, '2025-06-30 00:10:00', 1, 11, 0, '2023-07-12 03:23:21', '2023-09-11 03:23:21', NULL, NULL, 1);



INSERT INTO user (no, type) VALUES
                                (31, 'LAWYER'),
                                (32, 'LAWYER'),
                                (33, 'LAWYER'),
                                (34, 'LAWYER'),
                                (35, 'LAWYER'),
                                (36, 'LAWYER'),
                                (37, 'LAWYER'),
                                (38, 'LAWYER'),
                                (39, 'LAWYER'),
                                (40, 'LAWYER');

INSERT INTO lawyer (
    no, lawyer_id, pw_hash, profile, email, name, office_number, phone, zipcode,
    road_address, land_address, detail_address, point, consent, status, consult_price,
    created_at, updated_at, withdrawal_at, card_front, card_back, office_name, lawyer_intro, intro_detail
) VALUES

-- 서민영 변호사 (과실 분쟁·블랙박스 분석 전문)
(31, 'lawyer001', '$2a$10$OcdSZ9r5jFDJ9vx.oZ75L.l1tMlwzat1eIHbez9ynVLG1CKypjI3m', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile1.png', 'sumin1011@naver.com', '서민영', '02-593-2572', '010-8127-2572', '16705',
 '서울특별시 마포구 월드컵북로 396', '서울특별시 마포구 상암동 1601', 'DMC첨단빌딩 15층 1507호 로이어스앤파트너스', 800, 1, 'APPROVED_JOIN', 30000,
 '2022-06-24 12:12:00', '2025-07-01 12:12:00', NULL, 'card_front_1.jpg', 'card_back_1.jpg', '로이어스앤파트너스', '블랙박스 속 3초, 억울함을 밝히는 열쇠입니다.', '분야
과실 분쟁 조정, 블랙박스 분석, 보험사 과실 비율 이의제기
자문 영상 분석(드론·CCTV 포함), 민사 손해배상 소송
자격
교통사고 감정사 2급
변호사시험 제7회 (2018년)
학력
연세대학교 법학전문대학원 졸업
소개글
보험사 과실비율에 수긍할 수 없으신가요?
블랙박스, CCTV, 교통과학 원칙을 바탕으로 억울한 책임을 바로잡는 데 집중해온 변호사입니다.
상대 운전자·보험사에 끌려가지 않고, 직접 증거를 통해 사실을 밝히겠습니다.
과실 비율 10% 차이가 억 단위 손해로 이어질 수 있는 세상,
그 싸움에 함께하겠습니다.'),

-- 배서연 변호사 (보험·면허 정지 대응 전문)
(32, 'lawyer002', '$2a$10$uPGdOUNadNbbs40pZaOnk.KolTWhktNSSpaLBQgNfBHYhQBvEVDi2', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile2.png', 'seoyeon.bae.law@gmail.com', '배서연', '02-127-1001', '010-8127-2572', '16589',
 '서울특별시 강남구 테헤란로 152', '서울특별시 강남구 역삼동 721-1', '삼정빌딩 11층 1103호 신세계로교통법률센터', 700, 1, 'APPROVED_JOIN', 30000,
 '2025-06-24 12:12:00', '2025-06-24 12:12:00', NULL, 'card_front_2.jpg', 'card_back_2.jpg', '신세계로교통법률센터', '실수로 시작된 행정 리스크, 당신의 방패가 되겠습니다.', '분야
교통범죄 전담 (음주·무면허, 사고 후 도주, 보험사기 관련 사건 등)
자격
변호사시험 제5회 (2016년)
학력
아주대학교 법학전문대학원 석사 졸업
소개글
한순간의 실수로도 중한 처벌로 이어질 수 있는 교통범죄 사건. 저는 음주운전, 무면허, 사고 후 도주 등 위기 상황에 처한 의뢰인에게 가장 현실적이고 실효성 있는 방어 전략을 제시해왔습니다.
단순히 형량을 줄이는 것이 아니라, 민사책임과 행정처분(면허 정지·취소)까지 고려한 종합적인 대응을 목표로 하고 있습니다. 실수는 최소화할 수 있어야 합니다. 그 해답을 함께 찾겠습니다.'),

-- 한도현 변호사 (중대사고 피해자 대리 전문)
(33, 'lawyer003', '$2a$10$1r.IxlMvZsAwqIB/PCTPTuFYHTMzBUzm4guOo64h8u75NCdiK6xcy', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile3.png', 'do.hyun.han.law@gmail.com', '한도현', '02-567-9012', '010-8127-2572', '04050',
 '경기도 수원 영통 덕영대로 1701', '경기도 수원 영통동 17-2', '정우빌딩 6층 601호 정의법률사무소', 300, 1, 'APPROVED_JOIN', 30000,
 '2025-06-24 12:12:00', '2025-06-24 12:12:00', NULL, 'card_front_3.jpg', 'card_back_3.jpg', '정의법률사무소', '중대사고 피해자의 억울함, 끝까지 쫓아갑니다.', '분야
중상해, 사망사고 유족대리, 산재 유사사건
자격
前 검찰 교통범죄 전담부 근무
변호사시험 제4회 (2015년)
학력
서울대학교 법학과 졸업
소개글
중대한 사고를 당했음에도 가해자 처벌은 미약하고, 피해 보상조차 제대로 받지 못하는 분들이 많습니다.
검찰 교통사건 전담부서에서 근무한 경험을 바탕으로, 유족의 억울함을 덜고 실질적인 보상을 이끌어내기 위해 싸워왔습니다.
의뢰인의 입장에서, 가해자-보험사-경찰-검찰 간의 대응을 전략적으로 리드하겠습니다.'),

-- 김수현 변호사 (보행자·이륜차 등 차량 외 교통사고 전문)
(34, 'lawyer004', '$2a$10$FFarEKvpA652hV9NJUm0feDUNzz2Cq.x90Q/140R2MsV1Kr8e1gvm', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile4.png', 'soohyun.kim.law@gmail.com', '김수현', '02-3412-7821', '010-8127-2572', '04790',
 '서울특별시 성동구 왕십리로 222', '서울특별시 성동구 행당동 10-1', '한빛타워 8층 802호 법무법인SH', 660, 1, 'APPROVED_JOIN', 30000,
 '2025-06-24 12:12:00', '2025-06-24 12:12:00', NULL, 'card_front_4.jpg', 'card_back_4.jpg', '법무법인SH', '누구나 겪을 수 있는 사고, 누구나 받을 수 있는 보상.', '분야
보행자·자전거·킥보드 교통사고
어린이 보호구역·노약자 사고
도로공사·공원·학교 내 낙상사고
유사 산재 및 보험금 분쟁
자격
도로교통공단 법률자문 변호사
서울시 시민감사옴부즈만 위촉
학력
성균관대학교 법학전문대학원 석사 졸업
소개글
운전자가 아니더라도 피해자가 될 수 있는 교통사고는 많습니다.
보도 위에서 킥보드에 치이거나, 횡단보도를 건너다 차량에 부딪히는 등
차량 외 사고는 더욱 불리하게 처리되는 경우가 많습니다.
저는 블랙박스, CCTV, 의무기록, 사고지형을 꼼꼼히 분석해
의뢰인이 정당한 배상과 보험지원을 받을 수 있도록 도와드립니다.'),

-- 일반 변호사 (3명)
(35, 'lawyer005', '$2a$10$515YWmGSCSBC8YRHQcNEbOaRbXIUDOZNdCaJnsoBEgi03m5k7dOlC', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile5.png', 'lawyer5@example.com', '정민영', '02-1234-1004', '010-9000-1004', '617230',
 '서울 서초구 서초대로 123', '서울 서초구 서초동 12-3', '법조타워 5층', 210, 1, 'APPROVED_JOIN', 30000,
 '2025-06-24 12:12:00', '2025-06-24 12:12:00', NULL, 'card_front_5.jpg', 'card_back_5.jpg', '정민영법률사무소', '음주·무면허 형사사건 실무 전문', '분야
교통범죄 전문 (음주운전, 무면허, 교특법 위반, 면허구제 등)
자격
변호사시험 5회 (2016년)
학력
성균관대학교 법학전문대학원 석사 졸업
소개글
음주운전, 무면허, 교통사고 등은 수사기관의 판단에 따라 큰 불이익이 발생할 수 있는 사건입니다. 저는 교통범죄 사건에 집중해온 실무 경험을 바탕으로, 수사 초기부터 신속하고 정밀하게 대응하는 시스템을 갖추고 있습니다.
의뢰인의 상황을 정확히 진단하고, 불이익을 최소화할 수 있는 전략을 제시하겠습니다. 행정심판, 민사합의까지 고려한 전방위적 조력으로 함께하겠습니다.
'),
(36, 'lawyer006', '$2a$10$6zSuWWsJdqpSFWZ6Am5Mlu4idUL82sPhTy4vA74NBzgyqyNkiYbg2', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile6.png', 'lawyer6@example.com', '이주현', '02-1234-1005', '010-9000-1005', '701293',
 '서울 강남구 언주로 201', '서울 강남구 논현동 99-1', '엘지타워 10층', 130, 1, 'APPROVED_JOIN', 30000,
 '2025-06-24 12:12:00', '2025-06-24 12:12:00', NULL, 'card_front_6.jpg', 'card_back_6.jpg', '이주현법률사무소', '교통범죄, 초기 대응이 성패 좌우', '분야
교통범죄 전문 (음주운전, 무면허, 교특법 위반, 면허구제 등)
자격
변호사시험 5회 (2016년)
학력
성균관대학교 법학전문대학원 석사 졸업
소개글
음주운전, 무면허, 교통사고 등은 수사기관의 판단에 따라 큰 불이익이 발생할 수 있는 사건입니다. 저는 교통범죄 사건에 집중해온 실무 경험을 바탕으로, 수사 초기부터 신속하고 정밀하게 대응하는 시스템을 갖추고 있습니다.
의뢰인의 상황을 정확히 진단하고, 불이익을 최소화할 수 있는 전략을 제시하겠습니다. 행정심판, 민사합의까지 고려한 전방위적 조력으로 함께하겠습니다.'),
(37, 'lawyer007', '$2a$10$ETO9uQlxOl/EYlJVIjm6oOFA5ey8BcKViJVJpBnUkhxLkqICH8sya', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile7.png', 'lawyer7@example.com', '박준혁', '02-1234-1006', '010-9000-1006', '821045',
 '서울 중구 세종대로 66', '서울 중구 태평로1가 21-1', '시그니처타워 8층', 190, 1, 'APPROVED_JOIN', 30000,
 '2025-06-24 12:12:00', '2025-06-24 12:12:00', NULL, 'card_front_7.jpg', 'card_back_7.jpg', '박준혁법률사무소', '실수로 시작된 사건, 전략적 조력 필요', '분야
교통범죄 전문 (음주운전, 무면허, 교특법 위반, 면허구제 등)
자격
변호사시험 5회 (2016년)
학력
성균관대학교 법학전문대학원 석사 졸업
소개글
음주운전, 무면허, 교통사고 등은 수사기관의 판단에 따라 큰 불이익이 발생할 수 있는 사건입니다. 저는 교통범죄 사건에 집중해온 실무 경험을 바탕으로, 수사 초기부터 신속하고 정밀하게 대응하는 시스템을 갖추고 있습니다.
의뢰인의 상황을 정확히 진단하고, 불이익을 최소화할 수 있는 전략을 제시하겠습니다. 행정심판, 민사합의까지 고려한 전방위적 조력으로 함께하겠습니다.'),


-- 탈퇴 완료 변호사 (1명)
(38, 'lawyer008', '$2a$10$7SojuXsNwK2sxSMJVnfzJuVTvGBlDigfbcXjU4y.VExAnzprRnBWC', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile8.png', 'lawyer8@example.com', 'Lawyer8', '02-1234-1007', '010-9000-1007', '784231',
 '8 Lawyer-ro', '8 Beopjeong-gil', 'Building 8, Room 107', 230, 1, 'APPROVED_LEAVE', 30000,
 '2025-06-21 12:12:00', '2025-06-24 12:12:00', '2025-06-24 12:12:00', 'card_front_8.jpg', 'card_back_8.jpg', 'Law Office 8', '음주운전·뺑소니, 형사 대응 집중', '분야
교통범죄 전문 (음주운전, 무면허, 교특법 위반, 면허구제 등)
자격
변호사시험 5회 (2016년)
학력
성균관대학교 법학전문대학원 석사 졸업
소개글
음주운전, 무면허, 교통사고 등은 수사기관의 판단에 따라 큰 불이익이 발생할 수 있는 사건입니다. 저는 교통범죄 사건에 집중해온 실무 경험을 바탕으로, 수사 초기부터 신속하고 정밀하게 대응하는 시스템을 갖추고 있습니다.
의뢰인의 상황을 정확히 진단하고, 불이익을 최소화할 수 있는 전략을 제시하겠습니다. 행정심판, 민사합의까지 고려한 전방위적 조력으로 함께하겠습니다.'),


-- 가입 대기 중인 변호사 (2명)
(39, 'lawyer009', '$2a$10$MAwnLb7iJp3nfCwHhO5shuCNzSnBTZF.35ixnW0Yyu27WZK1qoFS2', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile9.png', 'haneul0911@gmail.com', '조하늘', '02-596-1008', '010-2236-1008', '430987',
 '서울특별시 은평구 통일로 715', '서울특별시 은평구 녹번동 100-1', '법조타워 8층 805호 조하늘법률사무소', 0, 1, 'REJECTED_JOIN', 30000,
 '2025-06-24 12:12:00', '2025-06-24 12:12:00', NULL, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile9-0.png', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile9-1.png', '조하늘법률사무소', '보험사가 놓친 장면, 저는 다시 봅니다.', '분야
과실비율 이의제기 및 보험사 대응
블랙박스·CCTV 분석을 통한 사고 재구성
보험 분쟁 및 손해배상 청구
자격
도로교통사고감정사 2급
변호사시험 제9회 (2020년)
학력
이화여자대학교 법학전문대학원 졸업
소개글
과실은 단순한 수치가 아니라, 해석의 결과입니다.
저는 블랙박스, CCTV, 사고기록을 재구성해
보험사의 일방적 판단을 검토하고 반박하는 데 주력해왔습니다.
수치가 아닌 증거로, 감정이 아닌 논리로
당신의 입장을 설득력 있게 바꾸겠습니다.'),
(40, 'lawyer010', '$2a$10$uhSQ.4igpusve1xIEfWfserUwNrzbDrW20ss4YAowzOrEofAyvv4C', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile10.png', 'truepark@gmail.com', '박진서', '02-2124-3390', '010-6032-9284', '378421',
 '서울특별시 서초구 서운로 168', '서울특별시 서초구 서초동 1308-5', '리더스타워 7층 705호 법무법인진(眞)', 0, 1, 'REJECTED_JOIN', 30000,
 '2025-06-24 12:12:00', '2025-06-24 12:12:00', NULL, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile10-0.png', 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/profile/profile10-1.png', '법무법인진(眞)', '작은 사고라도, 책임은 명확히 따져야 합니다.', '분야
상가·마트·공원 내 낙상사고
생활 중 안전사고 및 유사 산재 분쟁
보행 중 사고, 공공장소 시설물 책임 사고
자격
민사재해보상 자문 경력 다수
변호사시험 제8회 (2019년)
학력
한양대학교 법학전문대학원 졸업
소개글
낙상사고나 일상 중 사고는 `가벼운 사고`로 취급되기 쉽지만,
실제 피해자는 치료비, 후유증, 생계 문제까지 고통받습니다.
저는 시설물 하자, 미끄럼 사고, 공공장소 사고 등
산재로 처리되지 않는 생활 속 사고에 집중하여
실질적인 손해배상과 책임 규명을 이끌어왔습니다.');


-- admin123 / admin123 (비밀번호 아이디와 동일)
INSERT INTO admin (no, admin_id, pw_hash, name, phone, email, created_at)
VALUES (
           1,
           'admin123',
           '$2a$10$eBWaLDj8bsfmVF4wcOSO7eWSY0TjQmHCLmdsZdI91kc4DHJyxFOHe',
           '로앤로드',
           '010-3215-2572',
           'lawnroad@gmail.com',
           '2017-06-23 20:34:24'
       );



-- 카테고리 더미데이터
INSERT INTO `category` (`name`) VALUES
                                    ('사고 발생/처리'),
                                    ('중대사고·형사처벌'),
                                    ('음주·무면허 운전'),
                                    ('보험·행정처분'),
                                    ('과실 분쟁'),
                                    ('차량 외 사고');


-- 사용자 키워드 알림 테이블 더미 데이터
-- 방민영 (user_no = 4)
INSERT INTO keyword_alert (user_no, keyword, created_at) VALUES
                                                             (4,'사고과실','2024-07-01 10:12:00'),
                                                             (4,'블랙박스분석','2024-07-03 09:30:00'),
                                                             (4,'보험사과실','2024-07-05 14:22:00'),
                                                             (4,'교통사고반박','2024-07-06 11:11:00'),
                                                             (4,'과실비율','2024-07-09 15:47:00'),
                                                             (4,'영상증거','2024-07-10 12:00:00');

-- 서민성 (user_no = 5)
INSERT INTO keyword_alert (user_no, keyword, created_at) VALUES
                                                             (5,'음주운전','2024-06-20 11:11:00'),
                                                             (5,'무면허','2024-06-21 09:45:00'),
                                                             (5,'도주사고','2024-06-23 13:10:00'),
                                                             (5,'면허취소','2024-06-24 16:30:00'),
                                                             (5,'초범감형','2024-06-27 15:40:00'),
                                                             (5,'행정처분','2024-06-28 08:30:00');

-- 강창선 (user_no = 6)
INSERT INTO keyword_alert (user_no, keyword, created_at) VALUES
                                                             (6,'벌점감면','2024-05-01 10:00:00'),
                                                             (6,'책임제한','2024-05-03 11:30:00'),
                                                             (6,'운전자보험','2024-05-04 09:00:00'),
                                                             (6,'판례참고','2024-05-06 13:00:00'),
                                                             (6,'경미사고','2024-05-08 17:20:00');

-- 박건희 (user_no = 7)
INSERT INTO keyword_alert (user_no, keyword, created_at) VALUES
                                                             (7,'행정심판','2024-06-01 08:00:00'),
                                                             (7,'교통법규위반','2024-06-02 10:30:00'),
                                                             (7,'무보험차사고','2024-06-03 12:40:00'),
                                                             (7,'벌점조회','2024-06-04 09:15:00'),
                                                             (7,'운전면허구제','2024-06-05 14:10:00'),
                                                             (7,'과태료이의','2024-06-06 15:50:00'),
                                                             (7,'차대차사고','2024-06-07 11:00:00');

-- 정유진 (user_no = 8)
INSERT INTO keyword_alert (user_no, keyword, created_at) VALUES
                                                             (8,'보행자사고','2024-04-01 08:30:00'),
                                                             (8,'킥보드사고','2024-04-02 10:20:00'),
                                                             (8,'횡단보도사고','2024-04-03 11:15:00'),
                                                             (8,'CCTV증거','2024-04-04 12:45:00'),
                                                             (8,'어린이보호구역','2024-04-06 13:50:00'),
                                                             (8,'현장조사','2024-04-07 15:00:00'),
                                                             (8,'경찰조사','2024-04-08 14:40:00'),
                                                             (8,'합의금산정','2024-04-09 16:20:00');


-- 슬롯 테이블
INSERT INTO weekly_time_slots (
    no,user_no, slot_date, slot_time, status, amount, created_at, updated_at
) VALUES
      -- 31번 서민영 변호사
      (1,31, '2025-06-26', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (2,31, '2025-06-26', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (3,31, '2025-06-26', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (4,31, '2025-06-26', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (5,31, '2025-06-26', '12:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (6,31, '2025-06-26', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (7,31, '2025-06-26', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (8,31, '2025-06-26', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (9,31, '2025-06-26', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (10,31, '2025-06-26', '17:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (11,31, '2025-06-26', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (12,31, '2025-06-26', '19:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (13,31, '2025-06-26', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (14,31, '2025-06-26', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (15,31, '2025-06-26', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),

      (16,31, '2025-06-27', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (17,31, '2025-06-27', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (18,31, '2025-06-27', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (19,31, '2025-06-27', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (20,31, '2025-06-27', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (21,31, '2025-06-27', '13:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (22,31, '2025-06-27', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (23,31, '2025-06-27', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (24,31, '2025-06-27', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (25,31, '2025-06-27', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (26,31, '2025-06-27', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (27,31, '2025-06-27', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (28,31, '2025-06-27', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (29,31, '2025-06-27', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (30,31, '2025-06-27', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),

      (31,31, '2025-06-28', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (32,31, '2025-06-28', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (33,31, '2025-06-28', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (34,31, '2025-06-28', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (35,31, '2025-06-28', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (36,31, '2025-06-28', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (37,31, '2025-06-28', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (38,31, '2025-06-28', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (39,31, '2025-06-28', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (40,31, '2025-06-28', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (41,31, '2025-06-28', '18:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (42,31, '2025-06-28', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (43,31, '2025-06-28', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (44,31, '2025-06-28', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (45,31, '2025-06-28', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),

      (46,31, '2025-06-29', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (47,31, '2025-06-29', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (48,31, '2025-06-29', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (49,31, '2025-06-29', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (50,31, '2025-06-29', '12:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (51,31, '2025-06-29', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (52,31, '2025-06-29', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (53,31, '2025-06-29', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (54,31, '2025-06-29', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (55,31, '2025-06-29', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (56,31, '2025-06-29', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (57,31, '2025-06-29', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (58,31, '2025-06-29', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (59,31, '2025-06-29', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (60,31, '2025-06-29', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (61,31, '2025-06-30', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (62,31, '2025-06-30', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (63,31, '2025-06-30', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (64,31, '2025-06-30', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (65,31, '2025-06-30', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (66,31, '2025-06-30', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (67,31, '2025-06-30', '14:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (68,31, '2025-06-30', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (69,31, '2025-06-30', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (70,31, '2025-06-30', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (71,31, '2025-06-30', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (72,31, '2025-06-30', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (73,31, '2025-06-30', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (74,31, '2025-06-30', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (75,31, '2025-06-30', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (76,31, '2025-07-01', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (77,31, '2025-07-01', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (78,31, '2025-07-01', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (79,31, '2025-07-01', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (80,31, '2025-07-01', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (81,31, '2025-07-01', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (82,31, '2025-07-01', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (83,31, '2025-07-01', '15:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (84,31, '2025-07-01', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (85,31, '2025-07-01', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (86,31, '2025-07-01', '18:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (87,31, '2025-07-01', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (88,31, '2025-07-01', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (89,31, '2025-07-01', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (90,31, '2025-07-01', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (91,31, '2025-07-02', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (92,31, '2025-07-02', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (93,31, '2025-07-02', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (94,31, '2025-07-02', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (95,31, '2025-07-02', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (96,31, '2025-07-02', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (97,31, '2025-07-02', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (98,31, '2025-07-02', '15:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (99,31, '2025-07-02', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (100,31, '2025-07-02', '17:00:00',1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (101,31, '2025-07-02', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (102,31, '2025-07-02', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (103,31, '2025-07-02', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (104,31, '2025-07-02', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (105,31, '2025-07-02', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (106,31, '2025-07-03', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (107,31, '2025-07-03', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (108,31, '2025-07-03', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (109,31, '2025-07-03', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (110,31, '2025-07-03', '12:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (111,31, '2025-07-03', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (112,31, '2025-07-03', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (113,31, '2025-07-03', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (114,31, '2025-07-03', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (115,31, '2025-07-03', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (116,31, '2025-07-03', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (117,31, '2025-07-03', '19:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (118,31, '2025-07-03', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (119,31, '2025-07-03', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (120,31, '2025-07-03', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (121,31, '2025-07-04', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (122,31, '2025-07-04', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (123,31, '2025-07-04', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (124,31, '2025-07-04', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (125,31, '2025-07-04', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (126,31, '2025-07-04', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (127,31, '2025-07-04', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (128,31, '2025-07-04', '15:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (129,31, '2025-07-04', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (130,31, '2025-07-04', '17:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (131,31, '2025-07-04', '18:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (132,31, '2025-07-04', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (133,31, '2025-07-04', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (134,31, '2025-07-04', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (135,31, '2025-07-04', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (136,31, '2025-07-05', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (137,31, '2025-07-05', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (138,31, '2025-07-05', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (139,31, '2025-07-05', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (140,31, '2025-07-05', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (141,31, '2025-07-05', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (142,31, '2025-07-05', '14:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (143,31, '2025-07-05', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (144,31, '2025-07-05', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (145,31, '2025-07-05', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (146,31, '2025-07-05', '18:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (147,31, '2025-07-05', '19:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (148,31, '2025-07-05', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (149,31, '2025-07-05', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (150,31, '2025-07-05', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (151,31, '2025-07-06', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (152,31, '2025-07-06', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (153,31, '2025-07-06', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (154,31, '2025-07-06', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (155,31, '2025-07-06', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (156,31, '2025-07-06', '13:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (157,31, '2025-07-06', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (158,31, '2025-07-06', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (159,31, '2025-07-06', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (160,31, '2025-07-06', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (161,31, '2025-07-06', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (162,31, '2025-07-06', '19:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (163,31, '2025-07-06', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (164,31, '2025-07-06', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (165,31, '2025-07-06', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (166,31, '2025-07-07', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (167,31, '2025-07-07', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (168,31, '2025-07-07', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (169,31, '2025-07-07', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (170,31, '2025-07-07', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (171,31, '2025-07-07', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (172,31, '2025-07-07', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (173,31, '2025-07-07', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (174,31, '2025-07-07', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (175,31, '2025-07-07', '17:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (176,31, '2025-07-07', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (177,31, '2025-07-07', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (178,31, '2025-07-07', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (179,31, '2025-07-07', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (180,31, '2025-07-07', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),


      -- 32번 배서연 변호사
      (181,32, '2025-06-24', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (182,32, '2025-06-24', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (183,32, '2025-06-24', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (184,32, '2025-06-24', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (185,32, '2025-06-24', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (186,32, '2025-06-24', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (187,32, '2025-06-24', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (188,32, '2025-06-24', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (189,32, '2025-06-24', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (190,32, '2025-06-24', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (191,32, '2025-06-24', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (192,32, '2025-06-24', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (193,32, '2025-06-24', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (194,32, '2025-06-24', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (195,32, '2025-06-24', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (196,32, '2025-06-25', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (197,32, '2025-06-25', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (198,32, '2025-06-25', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (199,32, '2025-06-25', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (200,32, '2025-06-25', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (201,32, '2025-06-25', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (202,32, '2025-06-25', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (203,32, '2025-06-25', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (204,32, '2025-06-25', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (205,32, '2025-06-25', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (206,32, '2025-06-25', '18:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (207,32, '2025-06-25', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (208,32, '2025-06-25', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (209,32, '2025-06-25', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (210,32, '2025-06-25', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (211,32, '2025-06-26', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (212,32, '2025-06-26', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (213,32, '2025-06-26', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (214,32, '2025-06-26', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (215,32, '2025-06-26', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (216,32, '2025-06-26', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (217,32, '2025-06-26', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (218,32, '2025-06-26', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (219,32, '2025-06-26', '16:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (220,32, '2025-06-26', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (221,32, '2025-06-26', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (222,32, '2025-06-26', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (223,32, '2025-06-26', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (224,32, '2025-06-26', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (225,32, '2025-06-26', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (226,32, '2025-06-27', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (227,32, '2025-06-27', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (228,32, '2025-06-27', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (229,32, '2025-06-27', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (230,32, '2025-06-27', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (231,32, '2025-06-27', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (232,32, '2025-06-27', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (233,32, '2025-06-27', '15:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (234,32, '2025-06-27', '16:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (235,32, '2025-06-27', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (236,32, '2025-06-27', '18:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (237,32, '2025-06-27', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (238,32, '2025-06-27', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (239,32, '2025-06-27', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (240,32, '2025-06-27', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (241,32, '2025-06-28', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (242,32, '2025-06-28', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (243,32, '2025-06-28', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (244,32, '2025-06-28', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (245,32, '2025-06-28', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (246,32, '2025-06-28', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (247,32, '2025-06-28', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (248,32, '2025-06-28', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (249,32, '2025-06-28', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (250,32, '2025-06-28', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (251,32, '2025-06-28', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (252,32, '2025-06-28', '19:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (253,32, '2025-06-28', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (254,32, '2025-06-28', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (255,32, '2025-06-28', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (256,32, '2025-06-29', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (257,32, '2025-06-29', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (258,32, '2025-06-29', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (259,32, '2025-06-29', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (260,32, '2025-06-29', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (261,32, '2025-06-29', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (262,32, '2025-06-29', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (263,32, '2025-06-29', '15:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (264,32, '2025-06-29', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (265,32, '2025-06-29', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (266,32, '2025-06-29', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (267,32, '2025-06-29', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (268,32, '2025-06-29', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (269,32, '2025-06-29', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (270,32, '2025-06-29', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (271,32, '2025-06-30', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (272,32, '2025-06-30', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (273,32, '2025-06-30', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (274,32, '2025-06-30', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (275,32, '2025-06-30', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (276,32, '2025-06-30', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (277,32, '2025-06-30', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (278,32, '2025-06-30', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (279,32, '2025-06-30', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (280,32, '2025-06-30', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (281,32, '2025-06-30', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (282,32, '2025-06-30', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (283,32, '2025-06-30', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (284,32, '2025-06-30', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (285,32, '2025-06-30', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (286,32, '2025-07-01', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (287,32, '2025-07-01', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (288,32, '2025-07-01', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (289,32, '2025-07-01', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (290,32, '2025-07-01', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (291,32, '2025-07-01', '13:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (292,32, '2025-07-01', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (293,32, '2025-07-01', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (294,32, '2025-07-01', '16:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (295,32, '2025-07-01', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (296,32, '2025-07-01', '18:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (297,32, '2025-07-01', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (298,32, '2025-07-01', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (299,32, '2025-07-01', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (300,32, '2025-07-01', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (301,32, '2025-07-02', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (302,32, '2025-07-02', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (303,32, '2025-07-02', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (304,32, '2025-07-02', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (305,32, '2025-07-02', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (306,32, '2025-07-02', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (307,32, '2025-07-02', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (308,32, '2025-07-02', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (309,32, '2025-07-02', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (310,32, '2025-07-02', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (311,32, '2025-07-02', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (312,32, '2025-07-02', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (313,32, '2025-07-02', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (314,32, '2025-07-02', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (315,32, '2025-07-02', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (316,32, '2025-07-03', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (317,32, '2025-07-03', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (318,32, '2025-07-03', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (319,32, '2025-07-03', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (320,32, '2025-07-03', '12:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (321,32, '2025-07-03', '13:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (322,32, '2025-07-03', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (323,32, '2025-07-03', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (324,32, '2025-07-03', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (325,32, '2025-07-03', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (326,32, '2025-07-03', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (327,32, '2025-07-03', '19:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (328,32, '2025-07-03', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (329,32, '2025-07-03', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (330,32, '2025-07-03', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (331,32, '2025-07-04', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (332,32, '2025-07-04', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (333,32, '2025-07-04', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (334,32, '2025-07-04', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (335,32, '2025-07-04', '12:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (336,32, '2025-07-04', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (337,32, '2025-07-04', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (338,32, '2025-07-04', '15:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (339,32, '2025-07-04', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (340,32, '2025-07-04', '17:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (341,32, '2025-07-04', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (342,32, '2025-07-04', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (343,32, '2025-07-04', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (344,32, '2025-07-04', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (345,32, '2025-07-04', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (346,32, '2025-07-05', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (347,32, '2025-07-05', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (348,32, '2025-07-05', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (349,32, '2025-07-05', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (350,32, '2025-07-05', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (351,32, '2025-07-05', '13:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (352,32, '2025-07-05', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (353,32, '2025-07-05', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (354,32, '2025-07-05', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (355,32, '2025-07-05', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (356,32, '2025-07-05', '18:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (357,32, '2025-07-05', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (358,32, '2025-07-05', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (359,32, '2025-07-05', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (360,32, '2025-07-05', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (361,32, '2025-07-06', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (362,32, '2025-07-06', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (363,32, '2025-07-06', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (364,32, '2025-07-06', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (365,32, '2025-07-06', '12:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (366,32, '2025-07-06', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (367,32, '2025-07-06', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (368,32, '2025-07-06', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (369,32, '2025-07-06', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (370,32, '2025-07-06', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (371,32, '2025-07-06', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (372,32, '2025-07-06', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (373,32, '2025-07-06', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (374,32, '2025-07-06', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (375,32, '2025-07-06', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (376,32, '2025-07-07', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (377,32, '2025-07-07', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (378,32, '2025-07-07', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (379,32, '2025-07-07', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (380,32, '2025-07-07', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (381,32, '2025-07-07', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (382,32, '2025-07-07', '14:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (383,32, '2025-07-07', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (384,32, '2025-07-07', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (385,32, '2025-07-07', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (386,32, '2025-07-07', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (387,32, '2025-07-07', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (388,32, '2025-07-07', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (389,32, '2025-07-07', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-24 12:38:27'),
      (390, 32, '2025-07-07', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:11:20'),

      -- 33번 한도현 변호사
      (391, 33, '2025-06-24', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (392, 33, '2025-06-24', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (393, 33, '2025-06-24', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (394, 33, '2025-06-24', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (395, 33, '2025-06-24', '12:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (396, 33, '2025-06-24', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (397, 33, '2025-06-24', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (398, 33, '2025-06-24', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (399, 33, '2025-06-24', '16:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (400, 33, '2025-06-24', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (401, 33, '2025-06-24', '18:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 20:21:22'),
      (402, 33, '2025-06-24', '19:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 17:07:36'),
      (403, 33, '2025-06-24', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (404, 33, '2025-06-24', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (405, 33, '2025-06-24', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (406, 33, '2025-06-25', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (407, 33, '2025-06-25', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (408, 33, '2025-06-25', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (409, 33, '2025-06-25', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (410, 33, '2025-06-25', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (411, 33, '2025-06-25', '13:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 20:30:34'),
      (412, 33, '2025-06-25', '14:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (413, 33, '2025-06-25', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (414, 33, '2025-06-25', '16:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 20:32:22'),
      (415, 33, '2025-06-25', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (416, 33, '2025-06-25', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (417, 33, '2025-06-25', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (418, 33, '2025-06-25', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (419, 33, '2025-06-25', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (420, 33, '2025-06-25', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (421, 33, '2025-06-26', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (422, 33, '2025-06-26', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (423, 33, '2025-06-26', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (424, 33, '2025-06-26', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (425, 33, '2025-06-26', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (426, 33, '2025-06-26', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (427, 33, '2025-06-26', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (428, 33, '2025-06-26', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (429, 33, '2025-06-26', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (430, 33, '2025-06-26', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (431, 33, '2025-06-26', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (432, 33, '2025-06-26', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (433, 33, '2025-06-26', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (434, 33, '2025-06-26', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (435, 33, '2025-06-26', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (436, 33, '2025-06-27', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 20:33:43'),
      (437, 33, '2025-06-27', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (438, 33, '2025-06-27', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (439, 33, '2025-06-27', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (440, 33, '2025-06-27', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (441, 33, '2025-06-27', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (442, 33, '2025-06-27', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (443, 33, '2025-06-27', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (444, 33, '2025-06-27', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (445, 33, '2025-06-27', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (446, 33, '2025-06-27', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (447, 33, '2025-06-27', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (448, 33, '2025-06-27', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (449, 33, '2025-06-27', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (450, 33, '2025-06-27', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (451, 33, '2025-06-28', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (452, 33, '2025-06-28', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (453, 33, '2025-06-28', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (454, 33, '2025-06-28', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (455, 33, '2025-06-28', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (456, 33, '2025-06-28', '13:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (457, 33, '2025-06-28', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (458, 33, '2025-06-28', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (459, 33, '2025-06-28', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (460, 33, '2025-06-28', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (461, 33, '2025-06-28', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (462, 33, '2025-06-28', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (463, 33, '2025-06-28', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (464, 33, '2025-06-28', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (465, 33, '2025-06-28', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (466, 33, '2025-06-29', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (467, 33, '2025-06-29', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (468, 33, '2025-06-29', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (469, 33, '2025-06-29', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (470, 33, '2025-06-29', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (471, 33, '2025-06-29', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (472, 33, '2025-06-29', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (473, 33, '2025-06-29', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (474, 33, '2025-06-29', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (475, 33, '2025-06-29', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (476, 33, '2025-06-29', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (477, 33, '2025-06-29', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (478, 33, '2025-06-29', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (479, 33, '2025-06-29', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:57:59'),
      (480, 33, '2025-06-29', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (481, 33, '2025-06-30', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (482, 33, '2025-06-30', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (483, 33, '2025-06-30', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (484, 33, '2025-06-30', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (485, 33, '2025-06-30', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (486, 33, '2025-06-30', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (487, 33, '2025-06-30', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (488, 33, '2025-06-30', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (489, 33, '2025-06-30', '16:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (490, 33, '2025-06-30', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (491, 33, '2025-06-30', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (492, 33, '2025-06-30', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (493, 33, '2025-06-30', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (494, 33, '2025-06-30', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (495, 33, '2025-06-30', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (496, 33, '2025-07-01', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (497, 33, '2025-07-01', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (498, 33, '2025-07-01', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (499, 33, '2025-07-01', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (500, 33, '2025-07-01', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),

      -- 34번 김수현 변호사
      (501, 34, '2025-06-24', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (502, 34, '2025-06-24', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (503, 34, '2025-06-24', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (504, 34, '2025-06-24', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (505, 34, '2025-06-24', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (506, 34, '2025-06-24', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (507, 34, '2025-06-24', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (508, 34, '2025-06-24', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (509, 34, '2025-06-24', '16:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (510, 34, '2025-06-24', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (511, 34, '2025-06-24', '18:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 20:21:22'),
      (512, 34, '2025-06-24', '19:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 17:07:36'),
      (513, 34, '2025-06-24', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (514, 34, '2025-06-24', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (515, 34, '2025-06-24', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (516, 34, '2025-06-25', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (517, 34, '2025-06-25', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (518, 34, '2025-06-25', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (519, 34, '2025-06-25', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (520, 34, '2025-06-25', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (521, 34, '2025-06-25', '13:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 20:30:34'),
      (522, 34, '2025-06-25', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (523, 34, '2025-06-25', '15:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (524, 34, '2025-06-25', '16:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 20:32:22'),
      (525, 34, '2025-06-25', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (526, 34, '2025-06-25', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (527, 34, '2025-06-25', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (528, 34, '2025-06-25', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (529, 34, '2025-06-25', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (530, 34, '2025-06-25', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (531, 34, '2025-06-26', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (532, 34, '2025-06-26', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (533, 34, '2025-06-26', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (534, 34, '2025-06-26', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (535, 34, '2025-06-26', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (536, 34, '2025-06-26', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (537, 34, '2025-06-26', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (538, 34, '2025-06-26', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (539, 34, '2025-06-26', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (540, 34, '2025-06-26', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (541, 34, '2025-06-26', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (542, 34, '2025-06-26', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (543, 34, '2025-06-26', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (544, 34, '2025-06-26', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (545, 34, '2025-06-26', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (546, 34, '2025-06-27', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 20:33:43'),
      (547, 34, '2025-06-27', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (548, 34, '2025-06-27', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (549, 34, '2025-06-27', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (550, 34, '2025-06-27', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (551, 34, '2025-06-27', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (552, 34, '2025-06-27', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (553, 34, '2025-06-27', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (554, 34, '2025-06-27', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (555, 34, '2025-06-27', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (556, 34, '2025-06-27', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (557, 34, '2025-06-27', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (558, 34, '2025-06-27', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (559, 34, '2025-06-27', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (560, 34, '2025-06-27', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (561, 34, '2025-06-28', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (562, 34, '2025-06-28', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (563, 34, '2025-06-28', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (564, 34, '2025-06-28', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (565, 34, '2025-06-28', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (566, 34, '2025-06-28', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (567, 34, '2025-06-28', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (568, 34, '2025-06-28', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (569, 34, '2025-06-28', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (570, 34, '2025-06-28', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (571, 34, '2025-06-28', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (572, 34, '2025-06-28', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (573, 34, '2025-06-28', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (574, 34, '2025-06-28', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (575, 34, '2025-06-28', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (576, 34, '2025-06-29', '08:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (577, 34, '2025-06-29', '09:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (578, 34, '2025-06-29', '10:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (579, 34, '2025-06-29', '11:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (580, 34, '2025-06-29', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (581, 34, '2025-06-29', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (582, 34, '2025-06-29', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (583, 34, '2025-06-29', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (584, 34, '2025-06-29', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (585, 34, '2025-06-29', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (586, 34, '2025-06-29', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (587, 34, '2025-06-29', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (588, 34, '2025-06-29', '20:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (589, 34, '2025-06-29', '21:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:57:59'),
      (590, 34, '2025-06-29', '22:00:00', 0, 30000, '2025-06-24 12:38:27', '2025-06-29 12:58:00'),
      (591, 34, '2025-06-30', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (592, 34, '2025-06-30', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (593, 34, '2025-06-30', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (594, 34, '2025-06-30', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (595, 34, '2025-06-30', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (596, 34, '2025-06-30', '13:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (597, 34, '2025-06-30', '14:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (598, 34, '2025-06-30', '15:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (599, 34, '2025-06-30', '16:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (600, 34, '2025-06-30', '17:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (601, 34, '2025-06-30', '18:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (602, 34, '2025-06-30', '19:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (603, 34, '2025-06-30', '20:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (604, 34, '2025-06-30', '21:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (605, 34, '2025-06-30', '22:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (606, 34, '2025-07-01', '08:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (607, 34, '2025-07-01', '09:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (608, 34, '2025-07-01', '10:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (609, 34, '2025-07-01', '11:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23'),
      (610, 34, '2025-07-01', '12:00:00', 1, 30000, '2025-06-24 12:38:27', '2025-06-29 13:12:23');


-- 예약 order 더미 데이터
INSERT INTO `orders` (
    order_code, user_no, amount, status, order_type, created_at, updated_at
) VALUES
      ('ORD000000',  1, 30000, 'PAID',     'RESERVATION', '2025-06-24 21:21:50', '2025-06-29 16:04:50'),
      ('ORD000001',  4, 30000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:10:53'),
      ('ORD000002',  9, 45000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:14:36'),
      ('ORD000003', 13, 20000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:16:28'),
      ('ORD000004',  3, 60000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:18:14'),
      ('ORD000005', 15, 60000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:22:33'),
      ('ORD000006', 23, 30000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:24:48'),
      ('ORD000007', 22, 45000, 'CANCELED',    'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:26:44'),
      ('ORD000008', 29, 20000, 'CANCELED',    'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:29:31'),
      ('ORD000009', 13, 60000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:31:32'),
      ('ORD000010', 28, 60000, 'PAID',        'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:35:01'),
      ('ORD000011', 23, 30000, 'PAID',        'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:36:24'),
      ('ORD000012',  5, 45000, 'PAID',        'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:39:49'),
      ('ORD000013',  6, 20000, 'PAID',        'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:42:12'),
      ('ORD000014', 19, 60000, 'PAID',        'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 16:58:57'),
      ('ORD000015', 27, 60000, 'CANCELED',    'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 17:03:20'),
      ('ORD000016', 16, 30000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 17:05:37'),
      ('ORD000017',  8, 45000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 17:07:53'),
      ('ORD000018', 17, 20000, 'CANCELED',    'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 17:23:56'),
      ('ORD000019',  8, 60000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 17:25:54'),
      ('ORD000020', 22, 60000, 'CANCELED',    'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 17:27:29'),
      ('ORD000021', 24, 15000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 17:30:34'),
      ('ORD000022', 27, 60000, 'CANCELED',    'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 17:34:16'),
      ('ORD000023', 24, 60000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 17:40:49'),
      ('ORD000024', 12, 15000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 17:37:36'),
      ('ORD000025', 11, 60000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 20:13:16'),
      ('ORD000026', 21, 60000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 20:15:50'),
      ('ORD000027', 29, 15000, 'CANCELED',    'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 20:18:22'),
      ('ORD000028',  6, 60000, 'PAID',     'RESERVATION', '2025-06-26 15:04:29', '2025-06-29 20:19:41'),
      ('ORD000029', 14, 30000, 'PAID',     'RESERVATION', '2025-06-26 16:31:45', '2025-06-29 20:20:57'),
      ('ORD000030', 25, 45000, 'CANCELED',    'RESERVATION', '2025-06-26 16:31:45', '2025-06-29 20:27:06'),
      ('ORD000031', 19, 20000, 'PAID',     'RESERVATION', '2025-06-26 16:31:45', '2025-06-29 20:29:03'),
      ('ORD000032',  7, 60000, 'PAID',     'RESERVATION', '2025-06-26 16:31:45', '2025-06-29 20:31:40'),
      ('ORD000033',  9, 15000, 'PAID',        'RESERVATION', '2025-06-26 16:31:45', '2025-06-29 20:32:45'),
      ('ORD000034', 12, 50000, 'PAID',     'RESERVATION', '2025-06-26 16:31:45', '2025-06-29 20:34:00');


-- 예약 더미데이터
INSERT INTO reservations (
    no,
    order_no,
    slot_no,
    user_no,
    status,
    created_at,
    updated_at
) VALUES
      ( 1,  1,   1,   1,   'DONE', 		'2025-06-26 15:20:41', '2025-06-26 15:20:41'),
      ( 2,  2,   2,   4,   'DONE',      '2025-06-26 15:20:41', '2025-06-29 16:13:30'),
      ( 3,  3,   5,   9,   'DONE',      '2025-06-26 15:20:41', '2025-06-29 16:14:55'),
      ( 4,  4,  10,  13,   'DONE',      '2025-06-27 15:20:41', '2025-06-29 16:17:04'),
      ( 5,  5,  15,   3,   'DONE', 		'2025-06-27 15:20:41', '2025-06-29 16:18:50'),
      ( 6,  6,  12,  15,   'DONE',      '2025-06-27 15:20:41', '2025-06-29 16:23:28'),
      ( 7,  7,  18,  23,   'DONE', 		'2025-06-27 15:20:41', '2025-06-29 16:25:46'),
      ( 8,  8,  42,  22,   'CANCELED', 	'2025-06-26 15:20:41', '2025-06-29 16:28:20'),
      ( 9,  9,  41,  29,   'DONE',      '2025-06-26 15:20:41', '2025-06-29 16:29:54'),
      (10, 10,  21,  13,   'DONE',      '2025-06-28 15:20:41', '2025-06-29 16:32:11'),
      (11, 11, 211,  28,   'DONE',      '2025-06-28 15:20:41', '2025-06-29 16:35:20'),
      (12, 12, 213,  23,   'DONE',      '2025-06-28 15:20:41', '2025-06-29 16:36:52'),
      (13, 13,  90,   5,   'REQUESTED',      '2025-06-26 15:20:41', '2025-06-29 16:40:17'),
      (14, 14, 110,   6,   'REQUESTED',      '2025-06-25 15:20:41', '2025-06-29 16:42:33'),
      (15, 15, 240,  19,   'DONE',      '2025-06-25 15:20:41', '2025-06-29 17:01:18'),
      (16, 16, 320,  27,   'REQUESTED',  	'2025-06-29 15:20:41', '2025-06-29 17:03:40'),
      (17, 17, 236,  16,   'DONE',      '2025-06-29 15:20:41', '2025-06-29 17:05:58'),
      (18, 18, 402,   8,   'DONE', 		'2025-06-30 15:20:41', '2025-06-29 17:08:15'),
      (19, 19, 229,  17,   'DONE', 		'2025-06-26 15:20:41', '2025-06-29 17:24:30'),
      (20, 20,  83,   8,   'REQUESTED',      '2025-06-26 15:20:41', '2025-06-29 17:26:17'),
      (21, 21,  89,  22,   'CANCELED',  '2025-06-26 16:32:27', '2025-06-29 17:28:37'),
      (22, 22, 130,  24,   'REQUESTED',      '2025-06-26 16:32:27', '2025-06-29 17:33:04'),
      (23, 23, 199,  27,   'CANCELED',  '2025-06-26 16:32:27', '2025-06-29 17:34:34'),
      (24, 24, 146,  24,   'REQUESTED',      '2025-06-26 16:32:27', '2025-06-29 17:36:27'),
      (25, 25, 238,  12,   'DONE', 		'2025-06-26 16:32:27', '2025-06-29 17:37:59'),
      (26, 26, 181,  11,   'DONE',      '2025-06-26 16:32:27', '2025-06-29 20:14:40'),
      (27, 27, 193,  21,   'DONE',      '2025-06-26 16:32:27', '2025-06-29 20:16:19'),
      (28, 28, 298,  29,   'CANCELED',  '2025-06-26 16:32:27', '2025-06-29 20:18:10'),
      (29, 29, 333,   6,   'REQUESTED', 		'2025-06-26 16:32:27', '2025-06-29 20:19:58'),
      (30, 30, 401,  14,   'DONE',      '2025-06-26 16:32:27', '2025-06-29 20:21:10'),
      (31, 31, 438,  25,   'CANCELED',  '2025-06-26 16:32:27', '2025-06-29 20:27:47'),
      (32, 32, 411,  19,   'DONE',      '2025-06-26 16:32:27', '2025-06-29 20:30:24'),
      (33, 33, 399,   7,   'DONE', 		'2025-06-26 16:32:27', '2025-06-29 20:31:58'),
      (34, 34, 414,   9,   'DONE', 		'2025-06-26 16:32:27', '2025-06-29 20:33:08'),
      (35, 35, 436,  12,   'DONE',      '2025-06-26 16:32:27', '2025-06-29 20:34:17');


-- 사용자 4~8번 예약 더미데이터 (6월 30일 ~ 7월 7일)
-- PAID, CANCELED만 사용, 같은 날 같은 사용자가 여러 변호사 예약

-- 추가 Order 데이터
INSERT INTO `orders` (
    order_code, user_no, amount, status, order_type, created_at, updated_at
) VALUES
      -- 6월 30일 예약들 (18개)
      ('ORD000035',  4, 30000, 'PAID',        'RESERVATION', '2025-06-30 08:15:00', '2025-06-30 14:22:00'),
      ('ORD000036',  4, 30000, 'CANCELED',    'RESERVATION', '2025-06-30 10:30:00', '2025-06-30 16:45:00'),
      ('ORD000037',  4, 30000, 'PAID',        'RESERVATION', '2025-06-30 19:35:00', '2025-06-30 22:10:00'),
      ('ORD000038',  5, 30000, 'PAID',        'RESERVATION', '2025-06-30 09:45:00', '2025-06-30 15:30:00'),
      ('ORD000039',  5, 30000, 'CANCELED',    'RESERVATION', '2025-06-30 13:20:00', '2025-06-30 18:30:00'),
      ('ORD000040',  5, 30000, 'PAID',        'RESERVATION', '2025-06-30 20:45:00', '2025-06-30 23:15:00'),
      ('ORD000041',  6, 30000, 'CANCELED',    'RESERVATION', '2025-06-30 11:10:00', '2025-06-30 19:15:00'),
      ('ORD000042',  6, 30000, 'PAID',        'RESERVATION', '2025-06-30 15:25:00', '2025-06-30 20:40:00'),
      ('ORD000043',  6, 30000, 'CANCELED',    'RESERVATION', '2025-06-30 17:50:00', '2025-06-30 21:30:00'),
      ('ORD000044',  7, 30000, 'PAID',        'RESERVATION', '2025-06-30 12:40:00', '2025-06-30 17:50:00'),
      ('ORD000045',  7, 30000, 'CANCELED',    'RESERVATION', '2025-06-30 16:15:00', '2025-06-30 20:30:00'),
      ('ORD000046',  7, 30000, 'PAID',        'RESERVATION', '2025-06-30 21:20:00', '2025-06-30 23:45:00'),
      ('ORD000047',  8, 30000, 'PAID',        'RESERVATION', '2025-06-30 14:55:00', '2025-06-30 19:25:00'),
      ('ORD000048',  8, 30000, 'CANCELED',    'RESERVATION', '2025-06-30 18:20:00', '2025-06-30 21:40:00'),
      ('ORD000049',  8, 30000, 'PAID',        'RESERVATION', '2025-06-30 22:10:00', '2025-07-01 01:20:00'),
      ('ORD000050',  4, 30000, 'CANCELED',    'RESERVATION', '2025-06-30 21:45:00', '2025-07-01 00:15:00'),
      ('ORD000051',  5, 30000, 'CANCELED',    'RESERVATION', '2025-06-30 22:30:00', '2025-07-01 02:05:00'),
      ('ORD000052',  6, 30000, 'PAID',        'RESERVATION', '2025-06-30 23:15:00', '2025-07-01 03:30:00'),

      -- 7월 1일 예약들 (22개)
      ('ORD000053',  4, 30000, 'PAID',        'RESERVATION', '2025-07-01 08:30:00', '2025-07-01 15:20:00'),
      ('ORD000054',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 11:15:00', '2025-07-01 17:30:00'),
      ('ORD000055',  4, 30000, 'PAID',        'RESERVATION', '2025-07-01 16:45:00', '2025-07-01 21:15:00'),
      ('ORD000056',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 20:30:00', '2025-07-02 01:45:00'),
      ('ORD000057',  5, 30000, 'PAID',        'RESERVATION', '2025-07-01 09:45:00', '2025-07-01 16:30:00'),
      ('ORD000058',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 13:20:00', '2025-07-01 19:45:00'),
      ('ORD000059',  5, 30000, 'PAID',        'RESERVATION', '2025-07-01 18:15:00', '2025-07-01 23:30:00'),
      ('ORD000060',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 21:50:00', '2025-07-02 02:20:00'),
      ('ORD000061',  6, 30000, 'PAID',        'RESERVATION', '2025-07-01 10:15:00', '2025-07-01 14:45:00'),
      ('ORD000062',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 12:40:00', '2025-07-01 18:55:00'),
      ('ORD000063',  6, 30000, 'PAID',        'RESERVATION', '2025-07-01 17:25:00', '2025-07-01 22:10:00'),
      ('ORD000064',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 22:45:00', '2025-07-02 03:15:00'),
      ('ORD000065',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 12:40:00', '2025-07-01 17:50:00'),
      ('ORD000066',  7, 30000, 'PAID',        'RESERVATION', '2025-07-01 15:20:00', '2025-07-01 20:35:00'),
      ('ORD000067',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 19:10:00', '2025-07-02 00:25:00'),
      ('ORD000068',  7, 30000, 'PAID',        'RESERVATION', '2025-07-01 23:30:00', '2025-07-02 04:45:00'),
      ('ORD000069',  8, 30000, 'PAID',        'RESERVATION', '2025-07-01 14:55:00', '2025-07-01 19:40:00'),
      ('ORD000070',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 17:35:00', '2025-07-01 22:50:00'),
      ('ORD000071',  8, 30000, 'PAID',        'RESERVATION', '2025-07-01 20:20:00', '2025-07-02 01:35:00'),
      ('ORD000072',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 23:45:00', '2025-07-02 04:20:00'),
      ('ORD000073',  4, 30000, 'PAID',        'RESERVATION', '2025-07-01 22:15:00', '2025-07-02 03:30:00'),
      ('ORD000074',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-01 23:25:00', '2025-07-02 05:10:00'),

      -- 7월 2일 예약들 (20개)
      ('ORD000075',  4, 30000, 'PAID',        'RESERVATION', '2025-07-02 09:20:00', '2025-07-02 16:35:00'),
      ('ORD000076',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-02 13:45:00', '2025-07-02 19:20:00'),
      ('ORD000077',  4, 30000, 'PAID',        'RESERVATION', '2025-07-02 18:30:00', '2025-07-02 23:45:00'),
      ('ORD000078',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-02 21:15:00', '2025-07-03 02:30:00'),
      ('ORD000079',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-02 10:35:00', '2025-07-02 16:20:00'),
      ('ORD000080',  5, 30000, 'PAID',        'RESERVATION', '2025-07-02 14:25:00', '2025-07-02 20:40:00'),
      ('ORD000081',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-02 19:50:00', '2025-07-03 01:15:00'),
      ('ORD000082',  5, 30000, 'PAID',        'RESERVATION', '2025-07-02 22:35:00', '2025-07-03 04:20:00'),
      ('ORD000083',  6, 30000, 'PAID',        'RESERVATION', '2025-07-02 11:50:00', '2025-07-02 17:15:00'),
      ('ORD000084',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-02 15:30:00', '2025-07-02 21:45:00'),
      ('ORD000085',  6, 30000, 'PAID',        'RESERVATION', '2025-07-02 20:20:00', '2025-07-03 02:35:00'),
      ('ORD000086',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-02 13:25:00', '2025-07-02 18:40:00'),
      ('ORD000087',  7, 30000, 'PAID',        'RESERVATION', '2025-07-02 16:45:00', '2025-07-02 22:10:00'),
      ('ORD000088',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-02 21:30:00', '2025-07-03 03:45:00'),
      ('ORD000089',  8, 30000, 'PAID',        'RESERVATION', '2025-07-02 15:40:00', '2025-07-02 20:55:00'),
      ('ORD000090',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-02 18:25:00', '2025-07-03 00:40:00'),
      ('ORD000091',  8, 30000, 'PAID',        'RESERVATION', '2025-07-02 22:10:00', '2025-07-03 04:25:00'),
      ('ORD000092',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-02 23:45:00', '2025-07-03 05:20:00'),
      ('ORD000093',  7, 30000, 'PAID',        'RESERVATION', '2025-07-02 23:55:00', '2025-07-03 06:10:00'),
      ('ORD000094',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-02 23:30:00', '2025-07-03 05:45:00'),

      -- 7월 3일 예약들 (19개)
      ('ORD000095',  4, 30000, 'PAID',        'RESERVATION', '2025-07-03 08:45:00', '2025-07-03 14:20:00'),
      ('ORD000096',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-03 12:30:00', '2025-07-03 18:45:00'),
      ('ORD000097',  4, 30000, 'PAID',        'RESERVATION', '2025-07-03 17:20:00', '2025-07-03 22:35:00'),
      ('ORD000098',  5, 30000, 'PAID',        'RESERVATION', '2025-07-03 10:10:00', '2025-07-03 15:25:00'),
      ('ORD000099',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-03 14:40:00', '2025-07-03 20:55:00'),
      ('ORD000100',  5, 30000, 'PAID',        'RESERVATION', '2025-07-03 19:15:00', '2025-07-04 01:30:00'),
      ('ORD000101',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-03 11:30:00', '2025-07-03 17:45:00'),
      ('ORD000102',  6, 30000, 'PAID',        'RESERVATION', '2025-07-03 16:20:00', '2025-07-03 21:35:00'),
      ('ORD000103',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-03 20:45:00', '2025-07-04 02:20:00'),
      ('ORD000104',  7, 30000, 'PAID',        'RESERVATION', '2025-07-03 12:55:00', '2025-07-03 18:10:00'),
      ('ORD000105',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-03 15:30:00', '2025-07-03 21:45:00'),
      ('ORD000106',  7, 30000, 'PAID',        'RESERVATION', '2025-07-03 22:20:00', '2025-07-04 04:35:00'),
      ('ORD000107',  8, 30000, 'PAID',        'RESERVATION', '2025-07-03 14:40:00', '2025-07-03 19:55:00'),
      ('ORD000108',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-03 18:25:00', '2025-07-04 00:40:00'),
      ('ORD000109',  8, 30000, 'PAID',        'RESERVATION', '2025-07-03 21:50:00', '2025-07-04 03:15:00'),
      ('ORD000110',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-03 20:30:00', '2025-07-04 01:45:00'),
      ('ORD000111',  5, 30000, 'PAID',        'RESERVATION', '2025-07-03 21:40:00', '2025-07-04 02:55:00'),
      ('ORD000112',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-03 22:55:00', '2025-07-04 04:10:00'),
      ('ORD000113',  7, 30000, 'PAID',        'RESERVATION', '2025-07-03 23:25:00', '2025-07-04 05:40:00'),

      -- 7월 4일 예약들 (17개)
      ('ORD000114',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-04 09:15:00', '2025-07-04 16:30:00'),
      ('ORD000115',  4, 30000, 'PAID',        'RESERVATION', '2025-07-04 13:45:00', '2025-07-04 19:20:00'),
      ('ORD000116',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-04 18:30:00', '2025-07-05 00:45:00'),
      ('ORD000117',  5, 30000, 'PAID',        'RESERVATION', '2025-07-04 10:25:00', '2025-07-04 15:50:00'),
      ('ORD000118',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-04 14:15:00', '2025-07-04 20:30:00'),
      ('ORD000119',  5, 30000, 'PAID',        'RESERVATION', '2025-07-04 19:45:00', '2025-07-05 02:10:00'),
      ('ORD000120',  6, 30000, 'PAID',        'RESERVATION', '2025-07-04 11:40:00', '2025-07-04 17:25:00'),
      ('ORD000121',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-04 16:20:00', '2025-07-04 22:35:00'),
      ('ORD000122',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-04 13:20:00', '2025-07-04 18:45:00'),
      ('ORD000123',  7, 30000, 'PAID',        'RESERVATION', '2025-07-04 17:30:00', '2025-07-04 23:15:00'),
      ('ORD000124',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-04 21:25:00', '2025-07-05 03:40:00'),
      ('ORD000125',  8, 30000, 'PAID',        'RESERVATION', '2025-07-04 15:10:00', '2025-07-04 20:15:00'),
      ('ORD000126',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-04 19:45:00', '2025-07-05 01:20:00'),
      ('ORD000127',  8, 30000, 'PAID',        'RESERVATION', '2025-07-04 22:30:00', '2025-07-05 04:45:00'),
      ('ORD000128',  4, 30000, 'PAID',        'RESERVATION', '2025-07-04 21:15:00', '2025-07-05 02:30:00'),
      ('ORD000129',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-04 22:45:00', '2025-07-05 05:10:00'),
      ('ORD000130',  7, 30000, 'PAID',        'RESERVATION', '2025-07-04 23:55:00', '2025-07-05 06:20:00'),

      -- 7월 5일 예약들 (16개)
      ('ORD000131',  4, 30000, 'PAID',        'RESERVATION', '2025-07-05 08:50:00', '2025-07-05 14:15:00'),
      ('ORD000132',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-05 12:25:00', '2025-07-05 18:40:00'),
      ('ORD000133',  4, 30000, 'PAID',        'RESERVATION', '2025-07-05 17:30:00', '2025-07-05 23:45:00'),
      ('ORD000134',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-05 10:05:00', '2025-07-05 16:40:00'),
      ('ORD000135',  5, 30000, 'PAID',        'RESERVATION', '2025-07-05 15:20:00', '2025-07-05 21:35:00'),
      ('ORD000136',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-05 20:45:00', '2025-07-06 03:10:00'),
      ('ORD000137',  6, 30000, 'PAID',        'RESERVATION', '2025-07-05 11:20:00', '2025-07-05 17:25:00'),
      ('ORD000138',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-05 16:15:00', '2025-07-05 22:30:00'),
      ('ORD000139',  6, 30000, 'PAID',        'RESERVATION', '2025-07-05 21:40:00', '2025-07-06 04:55:00'),
      ('ORD000140',  7, 30000, 'PAID',        'RESERVATION', '2025-07-05 12:45:00', '2025-07-05 18:20:00'),
      ('ORD000141',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-05 17:10:00', '2025-07-05 23:25:00'),
      ('ORD000142',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-05 14:30:00', '2025-07-05 19:55:00'),
      ('ORD000143',  8, 30000, 'PAID',        'RESERVATION', '2025-07-05 18:45:00', '2025-07-06 01:10:00'),
      ('ORD000144',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-05 22:20:00', '2025-07-06 04:35:00'),
      ('ORD000145',  5, 30000, 'PAID',        'RESERVATION', '2025-07-05 23:15:00', '2025-07-06 05:30:00'),
      ('ORD000146',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-05 23:45:00', '2025-07-06 06:10:00'),

      -- 7월 6일 예약들 (15개)
      ('ORD000147',  4, 30000, 'PAID',        'RESERVATION', '2025-07-06 09:30:00', '2025-07-06 15:45:00'),
      ('ORD000148',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-06 13:15:00', '2025-07-06 19:30:00'),
      ('ORD000149',  4, 30000, 'PAID',        'RESERVATION', '2025-07-06 18:25:00', '2025-07-07 00:40:00'),
      ('ORD000150',  5, 30000, 'PAID',        'RESERVATION', '2025-07-06 10:45:00', '2025-07-06 16:20:00'),
      ('ORD000151',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-06 14:30:00', '2025-07-06 20:45:00'),
      ('ORD000152',  5, 30000, 'PAID',        'RESERVATION', '2025-07-06 19:55:00', '2025-07-07 02:20:00'),
      ('ORD000153',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-06 12:10:00', '2025-07-06 18:20:00'),
      ('ORD000154',  6, 30000, 'PAID',        'RESERVATION', '2025-07-06 17:35:00', '2025-07-06 23:50:00'),
      ('ORD000155',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-06 21:45:00', '2025-07-07 04:10:00'),
      ('ORD000156',  7, 30000, 'PAID',        'RESERVATION', '2025-07-06 13:35:00', '2025-07-06 19:10:00'),
      ('ORD000157',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-06 18:20:00', '2025-07-07 00:35:00'),
      ('ORD000158',  8, 30000, 'PAID',        'RESERVATION', '2025-07-06 15:25:00', '2025-07-06 21:40:00'),
      ('ORD000159',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-06 20:15:00', '2025-07-07 02:30:00'),
      ('ORD000160',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-06 22:30:00', '2025-07-07 04:45:00'),
      ('ORD000161',  6, 30000, 'PAID',        'RESERVATION', '2025-07-06 23:40:00', '2025-07-07 06:15:00'),

      -- 7월 7일 예약들 (14개)
      ('ORD000162',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-07 08:40:00', '2025-07-07 16:25:00'),
      ('ORD000163',  4, 30000, 'PAID',        'RESERVATION', '2025-07-07 14:20:00', '2025-07-07 20:35:00'),
      ('ORD000164',  4, 30000, 'CANCELED',    'RESERVATION', '2025-07-07 19:45:00', '2025-07-08 02:10:00'),
      ('ORD000165',  5, 30000, 'PAID',        'RESERVATION', '2025-07-07 09:55:00', '2025-07-07 14:30:00'),
      ('ORD000166',  5, 30000, 'CANCELED',    'RESERVATION', '2025-07-07 13:40:00', '2025-07-07 19:55:00'),
      ('ORD000167',  5, 30000, 'PAID',        'RESERVATION', '2025-07-07 21:15:00', '2025-07-08 03:30:00'),
      ('ORD000168',  6, 30000, 'PAID',        'RESERVATION', '2025-07-07 11:15:00', '2025-07-07 17:40:00'),
      ('ORD000169',  6, 30000, 'CANCELED',    'RESERVATION', '2025-07-07 16:25:00', '2025-07-07 22:40:00'),
      ('ORD000170',  7, 30000, 'CANCELED',    'RESERVATION', '2025-07-07 12:30:00', '2025-07-07 17:40:00'),
      ('ORD000171',  7, 30000, 'PAID',        'RESERVATION', '2025-07-07 18:50:00', '2025-07-08 01:15:00'),
      ('ORD000172',  8, 30000, 'PAID',        'RESERVATION', '2025-07-07 14:20:00', '2025-07-07 19:35:00'),
      ('ORD000173',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-07 20:30:00', '2025-07-08 02:45:00'),
      ('ORD000174',  7, 30000, 'PAID',        'RESERVATION', '2025-07-07 22:45:00', '2025-07-08 05:10:00'),
      ('ORD000175',  8, 30000, 'CANCELED',    'RESERVATION', '2025-07-07 23:30:00', '2025-07-08 05:55:00');

-- 기존 orders 데이터(ORD000000-ORD000034)에 대한 payments 더미데이터
-- PAID는 DONE, CANCELED는 CANCELED 상태로 생성
INSERT INTO payments (
    order_no, payment_key, order_code, amount,
    status, installment_month, purchased_at,
    metadata, pg, created_at, updated_at
) VALUES
-- 기존 예약 주문들 (ORD000000-ORD000034)
(1, 'tviva20250624000001Res001', 'ORD000000', 30000, 'DONE', NULL, '2025-06-29 16:04:50', NULL, '카드', '2025-06-24 21:21:50', '2025-06-29 16:04:50'),
(2, 'tviva20250626000001Res002', 'ORD000001', 30000, 'DONE', NULL, '2025-06-29 16:10:53', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:10:53'),
(3, 'tviva20250626000002Res003', 'ORD000002', 45000, 'DONE', NULL, '2025-06-29 16:14:36', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:14:36'),
(4, 'tviva20250626000003Res004', 'ORD000003', 20000, 'DONE', NULL, '2025-06-29 16:16:28', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:16:28'),
(5, 'tviva20250626000004Res005', 'ORD000004', 60000, 'DONE', NULL, '2025-06-29 16:18:14', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:18:14'),
(6, 'tviva20250626000005Res006', 'ORD000005', 60000, 'DONE', NULL, '2025-06-29 16:22:33', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:22:33'),
(7, 'tviva20250626000006Res007', 'ORD000006', 30000, 'DONE', NULL, '2025-06-29 16:24:48', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:24:48'),
(8, 'tviva20250626000007Can008', 'ORD000007', 45000, 'CANCELED', NULL, '2025-06-29 16:26:44', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:26:44'),
(9, 'tviva20250626000008Can009', 'ORD000008', 20000, 'CANCELED', NULL, '2025-06-29 16:29:31', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:29:31'),
(10, 'tviva20250626000009Res010', 'ORD000009', 60000, 'DONE', NULL, '2025-06-29 16:31:32', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:31:32'),
(11, 'tviva20250626000010Res011', 'ORD000010', 60000, 'DONE', NULL, '2025-06-29 16:35:01', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:35:01'),
(12, 'tviva20250626000011Res012', 'ORD000011', 30000, 'DONE', NULL, '2025-06-29 16:36:24', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:36:24'),
(13, 'tviva20250626000012Res013', 'ORD000012', 45000, 'DONE', NULL, '2025-06-29 16:39:49', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:39:49'),
(14, 'tviva20250626000013Res014', 'ORD000013', 20000, 'DONE', NULL, '2025-06-29 16:42:12', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:42:12'),
(15, 'tviva20250626000014Res015', 'ORD000014', 60000, 'DONE', NULL, '2025-06-29 16:58:57', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 16:58:57'),
(16, 'tviva20250626000015Can016', 'ORD000015', 60000, 'CANCELED', NULL, '2025-06-29 17:03:20', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 17:03:20'),
(17, 'tviva20250626000016Res017', 'ORD000016', 30000, 'DONE', NULL, '2025-06-29 17:05:37', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 17:05:37'),
(18, 'tviva20250626000017Res018', 'ORD000017', 45000, 'DONE', NULL, '2025-06-29 17:07:53', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 17:07:53'),
(19, 'tviva20250626000018Can019', 'ORD000018', 20000, 'CANCELED', NULL, '2025-06-29 17:23:56', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 17:23:56'),
(20, 'tviva20250626000019Res020', 'ORD000019', 60000, 'DONE', NULL, '2025-06-29 17:25:54', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 17:25:54'),
(21, 'tviva20250626000020Can021', 'ORD000020', 60000, 'CANCELED', NULL, '2025-06-29 17:27:29', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 17:27:29'),
(22, 'tviva20250626000021Res022', 'ORD000021', 15000, 'DONE', NULL, '2025-06-29 17:30:34', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 17:30:34'),
(23, 'tviva20250626000022Can023', 'ORD000022', 60000, 'CANCELED', NULL, '2025-06-29 17:34:16', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 17:34:16'),
(24, 'tviva20250626000023Res024', 'ORD000023', 60000, 'DONE', NULL, '2025-06-29 17:40:49', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 17:40:49'),
(25, 'tviva20250626000024Res025', 'ORD000024', 15000, 'DONE', NULL, '2025-06-29 17:37:36', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 17:37:36'),
(26, 'tviva20250626000025Res026', 'ORD000025', 60000, 'DONE', NULL, '2025-06-29 20:13:16', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 20:13:16'),
(27, 'tviva20250626000026Res027', 'ORD000026', 60000, 'DONE', NULL, '2025-06-29 20:15:50', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 20:15:50'),
(28, 'tviva20250626000027Can028', 'ORD000027', 15000, 'CANCELED', NULL, '2025-06-29 20:18:22', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 20:18:22'),
(29, 'tviva20250626000028Res029', 'ORD000028', 60000, 'DONE', NULL, '2025-06-29 20:19:41', NULL, '카드', '2025-06-26 15:04:29', '2025-06-29 20:19:41'),
(30, 'tviva20250626000029Res030', 'ORD000029', 30000, 'DONE', NULL, '2025-06-29 20:20:57', NULL, '카드', '2025-06-26 16:31:45', '2025-06-29 20:20:57'),
(31, 'tviva20250626000030Can031', 'ORD000030', 45000, 'CANCELED', NULL, '2025-06-29 20:27:06', NULL, '카드', '2025-06-26 16:31:45', '2025-06-29 20:27:06'),
(32, 'tviva20250626000031Res032', 'ORD000031', 20000, 'DONE', NULL, '2025-06-29 20:29:03', NULL, '카드', '2025-06-26 16:31:45', '2025-06-29 20:29:03'),
(33, 'tviva20250626000032Res033', 'ORD000032', 60000, 'DONE', NULL, '2025-06-29 20:31:40', NULL, '카드', '2025-06-26 16:31:45', '2025-06-29 20:31:40'),
(34, 'tviva20250626000033Res034', 'ORD000033', 15000, 'DONE', NULL, '2025-06-29 20:32:45', NULL, '카드', '2025-06-26 16:31:45', '2025-06-29 20:32:45'),
(35, 'tviva20250626000034Res035', 'ORD000034', 50000, 'DONE', NULL, '2025-06-29 20:34:00', NULL, '카드', '2025-06-26 16:31:45', '2025-06-29 20:34:00');

-- 6월 30일-7월 2일 예약에 대한 payments 더미데이터
-- PAID는 DONE, CANCELED는 CANCELED 상태로 생성
INSERT INTO payments (
    order_no, payment_key, order_code, amount,
    status, installment_month, purchased_at,
    metadata, pg, created_at, updated_at
) VALUES
-- 6월 30일 예약들 (18개)
(36, 'tviva20250630000002Can036', 'ORD000036', 30000, 'CANCELED', NULL, '2025-06-30 10:30:00', NULL, '카드', '2025-06-30 10:15:00', '2025-06-30 10:30:00'),
(37, 'tviva20250630000003Res037', 'ORD000037', 30000, 'DONE', NULL, '2025-06-30 19:35:00', NULL, '카드', '2025-06-30 19:20:00', '2025-06-30 19:35:00'),
(38, 'tviva20250630000004Res038', 'ORD000038', 30000, 'DONE', NULL, '2025-06-30 09:45:00', NULL, '카드', '2025-06-30 09:30:00', '2025-06-30 09:45:00'),
(39, 'tviva20250630000005Can039', 'ORD000039', 30000, 'CANCELED', NULL, '2025-06-30 13:20:00', NULL, '카드', '2025-06-30 13:05:00', '2025-06-30 13:20:00'),
(40, 'tviva20250630000006Res040', 'ORD000040', 30000, 'DONE', NULL, '2025-06-30 20:45:00', NULL, '카드', '2025-06-30 20:30:00', '2025-06-30 20:45:00'),
(41, 'tviva20250630000007Can041', 'ORD000041', 30000, 'CANCELED', NULL, '2025-06-30 11:10:00', NULL, '카드', '2025-06-30 10:55:00', '2025-06-30 11:10:00'),
(42, 'tviva20250630000008Res042', 'ORD000042', 30000, 'DONE', NULL, '2025-06-30 15:25:00', NULL, '카드', '2025-06-30 15:10:00', '2025-06-30 15:25:00'),
(43, 'tviva20250630000009Can043', 'ORD000043', 30000, 'CANCELED', NULL, '2025-06-30 17:50:00', NULL, '카드', '2025-06-30 17:35:00', '2025-06-30 17:50:00'),
(44, 'tviva20250630000010Res044', 'ORD000044', 30000, 'DONE', NULL, '2025-06-30 12:40:00', NULL, '카드', '2025-06-30 12:25:00', '2025-06-30 12:40:00'),
(45, 'tviva20250630000011Can045', 'ORD000045', 30000, 'CANCELED', NULL, '2025-06-30 16:15:00', NULL, '카드', '2025-06-30 16:00:00', '2025-06-30 16:15:00'),
(46, 'tviva20250630000012Res046', 'ORD000046', 30000, 'DONE', NULL, '2025-06-30 21:20:00', NULL, '카드', '2025-06-30 21:05:00', '2025-06-30 21:20:00'),
(47, 'tviva20250630000013Res047', 'ORD000047', 30000, 'DONE', NULL, '2025-06-30 14:55:00', NULL, '카드', '2025-06-30 14:40:00', '2025-06-30 14:55:00'),
(48, 'tviva20250630000014Can048', 'ORD000048', 30000, 'CANCELED', NULL, '2025-06-30 18:20:00', NULL, '카드', '2025-06-30 18:05:00', '2025-06-30 18:20:00'),
(49, 'tviva20250630000015Res049', 'ORD000049', 30000, 'DONE', NULL, '2025-06-30 22:10:00', NULL, '카드', '2025-06-30 21:55:00', '2025-06-30 22:10:00'),
(50, 'tviva20250630000016Can050', 'ORD000050', 30000, 'CANCELED', NULL, '2025-06-30 21:45:00', NULL, '카드', '2025-06-30 21:30:00', '2025-06-30 21:45:00'),
(51, 'tviva20250630000017Can051', 'ORD000051', 30000, 'CANCELED', NULL, '2025-06-30 22:30:00', NULL, '카드', '2025-06-30 22:15:00', '2025-06-30 22:30:00'),
(52, 'tviva20250630000018Res052', 'ORD000052', 30000, 'DONE', NULL, '2025-06-30 23:15:00', NULL, '카드', '2025-06-30 23:00:00', '2025-06-30 23:15:00'),

-- 7월 1일 예약들 (22개)
(53, 'tviva20250701000001Res053', 'ORD000053', 30000, 'DONE', NULL, '2025-07-01 08:30:00', NULL, '카드', '2025-07-01 08:15:00', '2025-07-01 08:30:00'),
(54, 'tviva20250701000002Can054', 'ORD000054', 30000, 'CANCELED', NULL, '2025-07-01 11:15:00', NULL, '카드', '2025-07-01 11:00:00', '2025-07-01 11:15:00'),
(55, 'tviva20250701000003Res055', 'ORD000055', 30000, 'DONE', NULL, '2025-07-01 16:45:00', NULL, '카드', '2025-07-01 16:30:00', '2025-07-01 16:45:00'),
(56, 'tviva20250701000004Can056', 'ORD000056', 30000, 'CANCELED', NULL, '2025-07-01 20:30:00', NULL, '카드', '2025-07-01 20:15:00', '2025-07-01 20:30:00'),
(57, 'tviva20250701000005Res057', 'ORD000057', 30000, 'DONE', NULL, '2025-07-01 09:45:00', NULL, '카드', '2025-07-01 09:30:00', '2025-07-01 09:45:00'),
(58, 'tviva20250701000006Can058', 'ORD000058', 30000, 'CANCELED', NULL, '2025-07-01 13:20:00', NULL, '카드', '2025-07-01 13:05:00', '2025-07-01 13:20:00'),
(59, 'tviva20250701000007Res059', 'ORD000059', 30000, 'DONE', NULL, '2025-07-01 18:15:00', NULL, '카드', '2025-07-01 18:00:00', '2025-07-01 18:15:00'),
(60, 'tviva20250701000008Can060', 'ORD000060', 30000, 'CANCELED', NULL, '2025-07-01 21:50:00', NULL, '카드', '2025-07-01 21:35:00', '2025-07-01 21:50:00'),
(61, 'tviva20250701000009Res061', 'ORD000061', 30000, 'DONE', NULL, '2025-07-01 10:15:00', NULL, '카드', '2025-07-01 10:00:00', '2025-07-01 10:15:00'),
(62, 'tviva20250701000010Can062', 'ORD000062', 30000, 'CANCELED', NULL, '2025-07-01 12:40:00', NULL, '카드', '2025-07-01 12:25:00', '2025-07-01 12:40:00'),
(63, 'tviva20250701000011Res063', 'ORD000063', 30000, 'DONE', NULL, '2025-07-01 17:25:00', NULL, '카드', '2025-07-01 17:10:00', '2025-07-01 17:25:00'),
(64, 'tviva20250701000012Can064', 'ORD000064', 30000, 'CANCELED', NULL, '2025-07-01 22:45:00', NULL, '카드', '2025-07-01 22:30:00', '2025-07-01 22:45:00'),
(65, 'tviva20250701000013Can065', 'ORD000065', 30000, 'CANCELED', NULL, '2025-07-01 12:40:00', NULL, '카드', '2025-07-01 12:25:00', '2025-07-01 12:40:00'),
(66, 'tviva20250701000014Res066', 'ORD000066', 30000, 'DONE', NULL, '2025-07-01 15:20:00', NULL, '카드', '2025-07-01 15:05:00', '2025-07-01 15:20:00'),
(67, 'tviva20250701000015Can067', 'ORD000067', 30000, 'CANCELED', NULL, '2025-07-01 19:10:00', NULL, '카드', '2025-07-01 18:55:00', '2025-07-01 19:10:00'),
(68, 'tviva20250701000016Res068', 'ORD000068', 30000, 'DONE', NULL, '2025-07-01 23:30:00', NULL, '카드', '2025-07-01 23:15:00', '2025-07-01 23:30:00'),
(69, 'tviva20250701000017Res069', 'ORD000069', 30000, 'DONE', NULL, '2025-07-01 14:55:00', NULL, '카드', '2025-07-01 14:40:00', '2025-07-01 14:55:00'),
(70, 'tviva20250701000018Can070', 'ORD000070', 30000, 'CANCELED', NULL, '2025-07-01 17:35:00', NULL, '카드', '2025-07-01 17:20:00', '2025-07-01 17:35:00'),
(71, 'tviva20250701000019Res071', 'ORD000071', 30000, 'DONE', NULL, '2025-07-01 20:20:00', NULL, '카드', '2025-07-01 20:05:00', '2025-07-01 20:20:00'),
(72, 'tviva20250701000020Can072', 'ORD000072', 30000, 'CANCELED', NULL, '2025-07-01 23:45:00', NULL, '카드', '2025-07-01 23:30:00', '2025-07-01 23:45:00'),
(73, 'tviva20250701000021Res073', 'ORD000073', 30000, 'DONE', NULL, '2025-07-01 22:15:00', NULL, '카드', '2025-07-01 22:00:00', '2025-07-01 22:15:00'),
(74, 'tviva20250701000022Can074', 'ORD000074', 30000, 'CANCELED', NULL, '2025-07-01 23:25:00', NULL, '카드', '2025-07-01 23:10:00', '2025-07-01 23:25:00'),

-- 7월 2일 예약들 (20개)
(75, 'tviva20250702000001Res075', 'ORD000075', 30000, 'DONE', NULL, '2025-07-02 09:20:00', NULL, '카드', '2025-07-02 09:05:00', '2025-07-02 09:20:00'),
(76, 'tviva20250702000002Can076', 'ORD000076', 30000, 'CANCELED', NULL, '2025-07-02 13:45:00', NULL, '카드', '2025-07-02 13:30:00', '2025-07-02 13:45:00'),
(77, 'tviva20250702000003Res077', 'ORD000077', 30000, 'DONE', NULL, '2025-07-02 18:30:00', NULL, '카드', '2025-07-02 18:15:00', '2025-07-02 18:30:00'),
(78, 'tviva20250702000004Can078', 'ORD000078', 30000, 'CANCELED', NULL, '2025-07-02 21:15:00', NULL, '카드', '2025-07-02 21:00:00', '2025-07-02 21:15:00'),
(79, 'tviva20250702000005Can079', 'ORD000079', 30000, 'CANCELED', NULL, '2025-07-02 10:35:00', NULL, '카드', '2025-07-02 10:20:00', '2025-07-02 10:35:00'),
(80, 'tviva20250702000006Res080', 'ORD000080', 30000, 'DONE', NULL, '2025-07-02 14:25:00', NULL, '카드', '2025-07-02 14:10:00', '2025-07-02 14:25:00'),
(81, 'tviva20250702000007Can081', 'ORD000081', 30000, 'CANCELED', NULL, '2025-07-02 19:50:00', NULL, '카드', '2025-07-02 19:35:00', '2025-07-02 19:50:00'),
(82, 'tviva20250702000008Res082', 'ORD000082', 30000, 'DONE', NULL, '2025-07-02 22:35:00', NULL, '카드', '2025-07-02 22:20:00', '2025-07-02 22:35:00'),
(83, 'tviva20250702000009Res083', 'ORD000083', 30000, 'DONE', NULL, '2025-07-02 11:50:00', NULL, '카드', '2025-07-02 11:35:00', '2025-07-02 11:50:00'),
(84, 'tviva20250702000010Can084', 'ORD000084', 30000, 'CANCELED', NULL, '2025-07-02 15:30:00', NULL, '카드', '2025-07-02 15:15:00', '2025-07-02 15:30:00'),
(85, 'tviva20250702000011Res085', 'ORD000085', 30000, 'DONE', NULL, '2025-07-02 20:20:00', NULL, '카드', '2025-07-02 20:05:00', '2025-07-02 20:20:00'),
(86, 'tviva20250702000012Can086', 'ORD000086', 30000, 'CANCELED', NULL, '2025-07-02 13:25:00', NULL, '카드', '2025-07-02 13:10:00', '2025-07-02 13:25:00'),
(87, 'tviva20250702000013Res087', 'ORD000087', 30000, 'DONE', NULL, '2025-07-02 16:45:00', NULL, '카드', '2025-07-02 16:30:00', '2025-07-02 16:45:00'),
(88, 'tviva20250702000014Can088', 'ORD000088', 30000, 'CANCELED', NULL, '2025-07-02 21:30:00', NULL, '카드', '2025-07-02 21:15:00', '2025-07-02 21:30:00'),
(89, 'tviva20250702000015Res089', 'ORD000089', 30000, 'DONE', NULL, '2025-07-02 15:40:00', NULL, '카드', '2025-07-02 15:25:00', '2025-07-02 15:40:00'),
(90, 'tviva20250702000016Can090', 'ORD000090', 30000, 'CANCELED', NULL, '2025-07-02 18:25:00', NULL, '카드', '2025-07-02 18:10:00', '2025-07-02 18:25:00'),
(91, 'tviva20250702000017Res091', 'ORD000091', 30000, 'DONE', NULL, '2025-07-02 22:10:00', NULL, '카드', '2025-07-02 21:55:00', '2025-07-02 22:10:00'),
(92, 'tviva20250702000018Can092', 'ORD000092', 30000, 'CANCELED', NULL, '2025-07-02 23:45:00', NULL, '카드', '2025-07-02 23:30:00', '2025-07-02 23:45:00'),
(93, 'tviva20250702000019Res093', 'ORD000093', 30000, 'DONE', NULL, '2025-07-02 23:55:00', NULL, '카드', '2025-07-02 23:40:00', '2025-07-02 23:55:00'),
(94, 'tviva20250702000020Can094', 'ORD000094', 30000, 'CANCELED', NULL, '2025-07-02 23:30:00', NULL, '카드', '2025-07-02 23:15:00', '2025-07-02 23:30:00');

-- 7월 3일-7일 예약에 대한 payments 더미데이터
-- PAID는 DONE, CANCELED는 CANCELED 상태로 생성
INSERT INTO payments (
    order_no, payment_key, order_code, amount,
    status, installment_month, purchased_at,
    metadata, pg, created_at, updated_at
) VALUES
-- 7월 3일 예약들 (19개)
(95, 'tviva20250703000001Res095', 'ORD000095', 30000, 'DONE', NULL, '2025-07-03 08:45:00', NULL, '카드', '2025-07-03 08:30:00', '2025-07-03 08:45:00'),
(96, 'tviva20250703000002Can096', 'ORD000096', 30000, 'CANCELED', NULL, '2025-07-03 12:30:00', NULL, '카드', '2025-07-03 12:15:00', '2025-07-03 12:30:00'),
(97, 'tviva20250703000003Res097', 'ORD000097', 30000, 'DONE', NULL, '2025-07-03 17:20:00', NULL, '카드', '2025-07-03 17:05:00', '2025-07-03 17:20:00'),
(98, 'tviva20250703000004Res098', 'ORD000098', 30000, 'DONE', NULL, '2025-07-03 10:10:00', NULL, '카드', '2025-07-03 09:55:00', '2025-07-03 10:10:00'),
(99, 'tviva20250703000005Can099', 'ORD000099', 30000, 'CANCELED', NULL, '2025-07-03 14:40:00', NULL, '카드', '2025-07-03 14:25:00', '2025-07-03 14:40:00'),
(100, 'tviva20250703000006Res100', 'ORD000100', 30000, 'DONE', NULL, '2025-07-03 19:15:00', NULL, '카드', '2025-07-03 19:00:00', '2025-07-03 19:15:00'),
(101, 'tviva20250703000007Can101', 'ORD000101', 30000, 'CANCELED', NULL, '2025-07-03 11:30:00', NULL, '카드', '2025-07-03 11:15:00', '2025-07-03 11:30:00'),
(102, 'tviva20250703000008Res102', 'ORD000102', 30000, 'DONE', NULL, '2025-07-03 16:20:00', NULL, '카드', '2025-07-03 16:05:00', '2025-07-03 16:20:00'),
(103, 'tviva20250703000009Can103', 'ORD000103', 30000, 'CANCELED', NULL, '2025-07-03 20:45:00', NULL, '카드', '2025-07-03 20:30:00', '2025-07-03 20:45:00'),
(104, 'tviva20250703000010Res104', 'ORD000104', 30000, 'DONE', NULL, '2025-07-03 12:55:00', NULL, '카드', '2025-07-03 12:40:00', '2025-07-03 12:55:00'),
(105, 'tviva20250703000011Can105', 'ORD000105', 30000, 'CANCELED', NULL, '2025-07-03 15:30:00', NULL, '카드', '2025-07-03 15:15:00', '2025-07-03 15:30:00'),
(106, 'tviva20250703000012Res106', 'ORD000106', 30000, 'DONE', NULL, '2025-07-03 22:20:00', NULL, '카드', '2025-07-03 22:05:00', '2025-07-03 22:20:00'),
(107, 'tviva20250703000013Res107', 'ORD000107', 30000, 'DONE', NULL, '2025-07-03 14:40:00', NULL, '카드', '2025-07-03 14:25:00', '2025-07-03 14:40:00'),
(108, 'tviva20250703000014Can108', 'ORD000108', 30000, 'CANCELED', NULL, '2025-07-03 18:25:00', NULL, '카드', '2025-07-03 18:10:00', '2025-07-03 18:25:00'),
(109, 'tviva20250703000015Res109', 'ORD000109', 30000, 'DONE', NULL, '2025-07-03 21:50:00', NULL, '카드', '2025-07-03 21:35:00', '2025-07-03 21:50:00'),
(110, 'tviva20250703000016Can110', 'ORD000110', 30000, 'CANCELED', NULL, '2025-07-03 20:30:00', NULL, '카드', '2025-07-03 20:15:00', '2025-07-03 20:30:00'),
(111, 'tviva20250703000017Res111', 'ORD000111', 30000, 'DONE', NULL, '2025-07-03 21:40:00', NULL, '카드', '2025-07-03 21:25:00', '2025-07-03 21:40:00'),
(112, 'tviva20250703000018Can112', 'ORD000112', 30000, 'CANCELED', NULL, '2025-07-03 22:55:00', NULL, '카드', '2025-07-03 22:40:00', '2025-07-03 22:55:00'),
(113, 'tviva20250703000019Res113', 'ORD000113', 30000, 'DONE', NULL, '2025-07-03 23:25:00', NULL, '카드', '2025-07-03 23:10:00', '2025-07-03 23:25:00'),

-- 7월 4일 예약들 (17개)
(114, 'tviva20250704000001Can114', 'ORD000114', 30000, 'CANCELED', NULL, '2025-07-04 09:15:00', NULL, '카드', '2025-07-04 09:00:00', '2025-07-04 09:15:00'),
(115, 'tviva20250704000002Res115', 'ORD000115', 30000, 'DONE', NULL, '2025-07-04 13:45:00', NULL, '카드', '2025-07-04 13:30:00', '2025-07-04 13:45:00'),
(116, 'tviva20250704000003Can116', 'ORD000116', 30000, 'CANCELED', NULL, '2025-07-04 18:30:00', NULL, '카드', '2025-07-04 18:15:00', '2025-07-04 18:30:00'),
(117, 'tviva20250704000004Res117', 'ORD000117', 30000, 'DONE', NULL, '2025-07-04 10:25:00', NULL, '카드', '2025-07-04 10:10:00', '2025-07-04 10:25:00'),
(118, 'tviva20250704000005Can118', 'ORD000118', 30000, 'CANCELED', NULL, '2025-07-04 14:15:00', NULL, '카드', '2025-07-04 14:00:00', '2025-07-04 14:15:00'),
(119, 'tviva20250704000006Res119', 'ORD000119', 30000, 'DONE', NULL, '2025-07-04 19:45:00', NULL, '카드', '2025-07-04 19:30:00', '2025-07-04 19:45:00'),
(120, 'tviva20250704000007Res120', 'ORD000120', 30000, 'DONE', NULL, '2025-07-04 11:40:00', NULL, '카드', '2025-07-04 11:25:00', '2025-07-04 11:40:00'),
(121, 'tviva20250704000008Can121', 'ORD000121', 30000, 'CANCELED', NULL, '2025-07-04 16:20:00', NULL, '카드', '2025-07-04 16:05:00', '2025-07-04 16:20:00'),
(122, 'tviva20250704000009Can122', 'ORD000122', 30000, 'CANCELED', NULL, '2025-07-04 13:20:00', NULL, '카드', '2025-07-04 13:05:00', '2025-07-04 13:20:00'),
(123, 'tviva20250704000010Res123', 'ORD000123', 30000, 'DONE', NULL, '2025-07-04 17:30:00', NULL, '카드', '2025-07-04 17:15:00', '2025-07-04 17:30:00'),
(124, 'tviva20250704000011Can124', 'ORD000124', 30000, 'CANCELED', NULL, '2025-07-04 21:25:00', NULL, '카드', '2025-07-04 21:10:00', '2025-07-04 21:25:00'),
(125, 'tviva20250704000012Res125', 'ORD000125', 30000, 'DONE', NULL, '2025-07-04 15:10:00', NULL, '카드', '2025-07-04 14:55:00', '2025-07-04 15:10:00'),
(126, 'tviva20250704000013Can126', 'ORD000126', 30000, 'CANCELED', NULL, '2025-07-04 19:45:00', NULL, '카드', '2025-07-04 19:30:00', '2025-07-04 19:45:00'),
(127, 'tviva20250704000014Res127', 'ORD000127', 30000, 'DONE', NULL, '2025-07-04 22:30:00', NULL, '카드', '2025-07-04 22:15:00', '2025-07-04 22:30:00'),
(128, 'tviva20250704000015Res128', 'ORD000128', 30000, 'DONE', NULL, '2025-07-04 21:15:00', NULL, '카드', '2025-07-04 21:00:00', '2025-07-04 21:15:00'),
(129, 'tviva20250704000016Can129', 'ORD000129', 30000, 'CANCELED', NULL, '2025-07-04 22:45:00', NULL, '카드', '2025-07-04 22:30:00', '2025-07-04 22:45:00'),
(130, 'tviva20250704000017Res130', 'ORD000130', 30000, 'DONE', NULL, '2025-07-04 23:55:00', NULL, '카드', '2025-07-04 23:40:00', '2025-07-04 23:55:00'),

-- 7월 5일 예약들 (16개)
(131, 'tviva20250705000001Res131', 'ORD000131', 30000, 'DONE', NULL, '2025-07-05 08:50:00', NULL, '카드', '2025-07-05 08:35:00', '2025-07-05 08:50:00'),
(132, 'tviva20250705000002Can132', 'ORD000132', 30000, 'CANCELED', NULL, '2025-07-05 12:25:00', NULL, '카드', '2025-07-05 12:10:00', '2025-07-05 12:25:00'),
(133, 'tviva20250705000003Res133', 'ORD000133', 30000, 'DONE', NULL, '2025-07-05 17:30:00', NULL, '카드', '2025-07-05 17:15:00', '2025-07-05 17:30:00'),
(134, 'tviva20250705000004Can134', 'ORD000134', 30000, 'CANCELED', NULL, '2025-07-05 10:05:00', NULL, '카드', '2025-07-05 09:50:00', '2025-07-05 10:05:00'),
(135, 'tviva20250705000005Res135', 'ORD000135', 30000, 'DONE', NULL, '2025-07-05 15:20:00', NULL, '카드', '2025-07-05 15:05:00', '2025-07-05 15:20:00'),
(136, 'tviva20250705000006Can136', 'ORD000136', 30000, 'CANCELED', NULL, '2025-07-05 20:45:00', NULL, '카드', '2025-07-05 20:30:00', '2025-07-05 20:45:00'),
(137, 'tviva20250705000007Res137', 'ORD000137', 30000, 'DONE', NULL, '2025-07-05 11:20:00', NULL, '카드', '2025-07-05 11:05:00', '2025-07-05 11:20:00'),
(138, 'tviva20250705000008Can138', 'ORD000138', 30000, 'CANCELED', NULL, '2025-07-05 16:15:00', NULL, '카드', '2025-07-05 16:00:00', '2025-07-05 16:15:00'),
(139, 'tviva20250705000009Res139', 'ORD000139', 30000, 'DONE', NULL, '2025-07-05 21:40:00', NULL, '카드', '2025-07-05 21:25:00', '2025-07-05 21:40:00'),
(140, 'tviva20250705000010Res140', 'ORD000140', 30000, 'DONE', NULL, '2025-07-05 12:45:00', NULL, '카드', '2025-07-05 12:30:00', '2025-07-05 12:45:00'),
(141, 'tviva20250705000011Can141', 'ORD000141', 30000, 'CANCELED', NULL, '2025-07-05 17:10:00', NULL, '카드', '2025-07-05 16:55:00', '2025-07-05 17:10:00'),
(142, 'tviva20250705000012Can142', 'ORD000142', 30000, 'CANCELED', NULL, '2025-07-05 14:30:00', NULL, '카드', '2025-07-05 14:15:00', '2025-07-05 14:30:00'),
(143, 'tviva20250705000013Res143', 'ORD000143', 30000, 'DONE', NULL, '2025-07-05 18:45:00', NULL, '카드', '2025-07-05 18:30:00', '2025-07-05 18:45:00'),
(144, 'tviva20250705000014Can144', 'ORD000144', 30000, 'CANCELED', NULL, '2025-07-05 22:20:00', NULL, '카드', '2025-07-05 22:05:00', '2025-07-05 22:20:00'),
(145, 'tviva20250705000015Res145', 'ORD000145', 30000, 'DONE', NULL, '2025-07-05 23:15:00', NULL, '카드', '2025-07-05 23:00:00', '2025-07-05 23:15:00'),
(146, 'tviva20250705000016Can146', 'ORD000146', 30000, 'CANCELED', NULL, '2025-07-05 23:45:00', NULL, '카드', '2025-07-05 23:30:00', '2025-07-05 23:45:00'),

-- 7월 6일 예약들 (15개)
(147, 'tviva20250706000001Res147', 'ORD000147', 30000, 'DONE', NULL, '2025-07-06 09:30:00', NULL, '카드', '2025-07-06 09:15:00', '2025-07-06 09:30:00'),
(148, 'tviva20250706000002Can148', 'ORD000148', 30000, 'CANCELED', NULL, '2025-07-06 13:15:00', NULL, '카드', '2025-07-06 13:00:00', '2025-07-06 13:15:00'),
(149, 'tviva20250706000003Res149', 'ORD000149', 30000, 'DONE', NULL, '2025-07-06 18:25:00', NULL, '카드', '2025-07-06 18:10:00', '2025-07-06 18:25:00'),
(150, 'tviva20250706000004Res150', 'ORD000150', 30000, 'DONE', NULL, '2025-07-06 10:45:00', NULL, '카드', '2025-07-06 10:30:00', '2025-07-06 10:45:00'),
(151, 'tviva20250706000005Can151', 'ORD000151', 30000, 'CANCELED', NULL, '2025-07-06 14:30:00', NULL, '카드', '2025-07-06 14:15:00', '2025-07-06 14:30:00'),
(152, 'tviva20250706000006Res152', 'ORD000152', 30000, 'DONE', NULL, '2025-07-06 19:55:00', NULL, '카드', '2025-07-06 19:40:00', '2025-07-06 19:55:00'),
(153, 'tviva20250706000007Can153', 'ORD000153', 30000, 'CANCELED', NULL, '2025-07-06 12:10:00', NULL, '카드', '2025-07-06 11:55:00', '2025-07-06 12:10:00'),
(154, 'tviva20250706000008Res154', 'ORD000154', 30000, 'DONE', NULL, '2025-07-06 17:35:00', NULL, '카드', '2025-07-06 17:20:00', '2025-07-06 17:35:00'),
(155, 'tviva20250706000009Can155', 'ORD000155', 30000, 'CANCELED', NULL, '2025-07-06 21:45:00', NULL, '카드', '2025-07-06 21:30:00', '2025-07-06 21:45:00'),
(156, 'tviva20250706000010Res156', 'ORD000156', 30000, 'DONE', NULL, '2025-07-06 13:35:00', NULL, '카드', '2025-07-06 13:20:00', '2025-07-06 13:35:00'),
(157, 'tviva20250706000011Can157', 'ORD000157', 30000, 'CANCELED', NULL, '2025-07-06 18:20:00', NULL, '카드', '2025-07-06 18:05:00', '2025-07-06 18:20:00'),
(158, 'tviva20250706000012Res158', 'ORD000158', 30000, 'DONE', NULL, '2025-07-06 15:25:00', NULL, '카드', '2025-07-06 15:10:00', '2025-07-06 15:25:00'),
(159, 'tviva20250706000013Can159', 'ORD000159', 30000, 'CANCELED', NULL, '2025-07-06 20:15:00', NULL, '카드', '2025-07-06 20:00:00', '2025-07-06 20:15:00'),
(160, 'tviva20250706000014Can160', 'ORD000160', 30000, 'CANCELED', NULL, '2025-07-06 22:30:00', NULL, '카드', '2025-07-06 22:15:00', '2025-07-06 22:30:00'),
(161, 'tviva20250706000015Res161', 'ORD000161', 30000, 'DONE', NULL, '2025-07-06 23:40:00', NULL, '카드', '2025-07-06 23:25:00', '2025-07-06 23:40:00'),

-- 7월 7일 예약들 (14개)
(162, 'tviva20250707000001Can162', 'ORD000162', 30000, 'CANCELED', NULL, '2025-07-07 08:40:00', NULL, '카드', '2025-07-07 08:25:00', '2025-07-07 08:40:00'),
(163, 'tviva20250707000002Res163', 'ORD000163', 30000, 'DONE', NULL, '2025-07-07 14:20:00', NULL, '카드', '2025-07-07 14:05:00', '2025-07-07 14:20:00'),
(164, 'tviva20250707000003Can164', 'ORD000164', 30000, 'CANCELED', NULL, '2025-07-07 19:45:00', NULL, '카드', '2025-07-07 19:30:00', '2025-07-07 19:45:00'),
(165, 'tviva20250707000004Res165', 'ORD000165', 30000, 'DONE', NULL, '2025-07-07 09:55:00', NULL, '카드', '2025-07-07 09:40:00', '2025-07-07 09:55:00'),
(166, 'tviva20250707000005Can166', 'ORD000166', 30000, 'CANCELED', NULL, '2025-07-07 13:40:00', NULL, '카드', '2025-07-07 13:25:00', '2025-07-07 13:40:00'),
(167, 'tviva20250707000006Res167', 'ORD000167', 30000, 'DONE', NULL, '2025-07-07 21:15:00', NULL, '카드', '2025-07-07 21:00:00', '2025-07-07 21:15:00'),
(168, 'tviva20250707000007Res168', 'ORD000168', 30000, 'DONE', NULL, '2025-07-07 11:15:00', NULL, '카드', '2025-07-07 11:00:00', '2025-07-07 11:15:00'),
(169, 'tviva20250707000008Can169', 'ORD000169', 30000, 'CANCELED', NULL, '2025-07-07 16:25:00', NULL, '카드', '2025-07-07 16:10:00', '2025-07-07 16:25:00'),
(170, 'tviva20250707000009Can170', 'ORD000170', 30000, 'CANCELED', NULL, '2025-07-07 12:30:00', NULL, '카드', '2025-07-07 12:15:00', '2025-07-07 12:30:00'),
(171, 'tviva20250707000010Res171', 'ORD000171', 30000, 'DONE', NULL, '2025-07-07 18:50:00', NULL, '카드', '2025-07-07 18:35:00', '2025-07-07 18:50:00'),
(172, 'tviva20250707000011Res172', 'ORD000172', 30000, 'DONE', NULL, '2025-07-07 14:20:00', NULL, '카드', '2025-07-07 14:05:00', '2025-07-07 14:20:00'),
(173, 'tviva20250707000012Can173', 'ORD000173', 30000, 'CANCELED', NULL, '2025-07-07 20:30:00', NULL, '카드', '2025-07-07 20:15:00', '2025-07-07 20:30:00'),
(174, 'tviva20250707000013Res174', 'ORD000174', 30000, 'DONE', NULL, '2025-07-07 22:45:00', NULL, '카드', '2025-07-07 22:30:00', '2025-07-07 22:45:00'),
(175, 'tviva20250707000014Can175', 'ORD000175', 30000, 'CANCELED', NULL, '2025-07-07 23:30:00', NULL, '카드', '2025-07-07 23:15:00', '2025-07-07 23:30:00');



-- 추가 Reservation 데이터 (Orders 35-175에 대응)
INSERT INTO reservations (
    no,
    order_no,
    slot_no,
    user_no,
    status,
    created_at,
    updated_at
) VALUES
      -- 6월 30일 예약들 (36-52번, Orders 35-52)
      (36, 36,  45,  4, 'DONE',      '2025-06-30 08:15:00', '2025-06-30 14:22:00'),
      (37, 37,  78,  4, 'CANCELED',  '2025-06-30 10:30:00', '2025-06-30 16:45:00'),
      (38, 38, 123,  4, 'REQUESTED',      '2025-06-30 19:35:00', '2025-06-30 22:10:00'),
      (39, 39, 156,  5, 'REQUESTED',      '2025-06-30 09:45:00', '2025-06-30 15:30:00'),
      (40, 40, 189,  5, 'CANCELED',  '2025-06-30 13:20:00', '2025-06-30 18:30:00'),
      (41, 41, 234,  5, 'DONE',      '2025-06-30 20:45:00', '2025-06-30 23:15:00'),
      (42, 42, 267,  6, 'CANCELED',  '2025-06-30 11:10:00', '2025-06-30 19:15:00'),
      (43, 43, 289,  6, 'REQUESTED',      '2025-06-30 15:25:00', '2025-06-30 20:40:00'),
      (44, 44, 312,  6, 'CANCELED',  '2025-06-30 17:50:00', '2025-06-30 21:30:00'),
      (45, 45, 345,  7, 'REQUESTED',      '2025-06-30 12:40:00', '2025-06-30 17:50:00'),
      (46, 46, 367,  7, 'CANCELED',  '2025-06-30 16:15:00', '2025-06-30 20:30:00'),
      (47, 47, 389,  7, 'REQUESTED',      '2025-06-30 21:20:00', '2025-06-30 23:45:00'),
      (48, 48, 412,  8, 'DONE',      '2025-06-30 14:55:00', '2025-06-30 19:25:00'),
      (49, 49, 435,  8, 'CANCELED',  '2025-06-30 18:20:00', '2025-06-30 21:40:00'),
      (50, 50, 456,  8, 'DONE',      '2025-06-30 22:10:00', '2025-07-01 01:20:00'),
      (51, 51, 478,  4, 'CANCELED',  '2025-06-30 21:45:00', '2025-07-01 00:15:00'),
      (52, 52, 501,  5, 'CANCELED',  '2025-06-30 22:30:00', '2025-07-01 02:05:00'),
      (53, 53, 523,  6, 'DONE',      '2025-06-30 23:15:00', '2025-07-01 03:30:00'),

      -- 7월 1일 예약들 (54-75번, Orders 53-74)
      (54, 54,  67,  4, 'DONE',      '2025-07-01 08:30:00', '2025-07-01 15:20:00'),
      (55, 55,  89,  4, 'CANCELED',  '2025-07-01 11:15:00', '2025-07-01 17:30:00'),
      (56, 56, 134,  4, 'REQUESTED',      '2025-07-01 16:45:00', '2025-07-01 21:15:00'),
      (57, 57, 167,  4, 'CANCELED',  '2025-07-01 20:30:00', '2025-07-02 01:45:00'),
      (58, 58, 198,  5, 'DONE',      '2025-07-01 09:45:00', '2025-07-01 16:30:00'),
      (59, 59, 223,  5, 'CANCELED',  '2025-07-01 13:20:00', '2025-07-01 19:45:00'),
      (60, 60, 256,  5, 'DONE',      '2025-07-01 18:15:00', '2025-07-01 23:30:00'),
      (61, 61, 278,  5, 'CANCELED',  '2025-07-01 21:50:00', '2025-07-02 02:20:00'),
      (62, 62, 301,  6, 'REQUESTED',      '2025-07-01 10:15:00', '2025-07-01 14:45:00'),
      (63, 63, 334,  6, 'CANCELED',  '2025-07-01 12:40:00', '2025-07-01 18:55:00'),
      (64, 64, 356,  6, 'REQUESTED',      '2025-07-01 17:25:00', '2025-07-01 22:10:00'),
      (65, 65, 378,  6, 'CANCELED',  '2025-07-01 22:45:00', '2025-07-02 03:15:00'),
      (66, 66, 401,  7, 'CANCELED',  '2025-07-01 12:40:00', '2025-07-01 17:50:00'),
      (67, 67, 423,  7, 'DONE',      '2025-07-01 15:20:00', '2025-07-01 20:35:00'),
      (68, 68, 445,  7, 'CANCELED',  '2025-07-01 19:10:00', '2025-07-02 00:25:00'),
      (69, 69, 467,  7, 'DONE',      '2025-07-01 23:30:00', '2025-07-02 04:45:00'),
      (70, 70, 489,  8, 'DONE',      '2025-07-01 14:55:00', '2025-07-01 19:40:00'),
      (71, 71, 512,  8, 'CANCELED',  '2025-07-01 17:35:00', '2025-07-01 22:50:00'),
      (72, 72, 534,  8, 'DONE',      '2025-07-01 20:20:00', '2025-07-02 01:35:00'),
      (73, 73, 556,  8, 'CANCELED',  '2025-07-01 23:45:00', '2025-07-02 04:20:00'),
      (74, 74, 578,  4, 'DONE',      '2025-07-01 22:15:00', '2025-07-02 03:30:00'),
      (75, 75, 601,  5, 'CANCELED',  '2025-07-01 23:25:00', '2025-07-02 05:10:00'),

      -- 7월 2일 예약들 (76-95번, Orders 75-94)
      (76, 76,  92,  4, 'REQUESTED',      '2025-07-02 09:20:00', '2025-07-02 16:35:00'),
      (77, 77, 115,  4, 'CANCELED',  '2025-07-02 13:45:00', '2025-07-02 19:20:00'),
      (78, 78, 147,  4, 'REQUESTED',      '2025-07-02 18:30:00', '2025-07-02 23:45:00'),
      (79, 79, 169,  4, 'CANCELED',  '2025-07-02 21:15:00', '2025-07-03 02:30:00'),
      (80, 80, 201,  5, 'CANCELED',  '2025-07-02 10:35:00', '2025-07-02 16:20:00'),
      (81, 81, 224,  5, 'DONE',      '2025-07-02 14:25:00', '2025-07-02 20:40:00'),
      (82, 82, 246,  5, 'CANCELED',  '2025-07-02 19:50:00', '2025-07-03 01:15:00'),
      (83, 83, 268,  5, 'DONE',      '2025-07-02 22:35:00', '2025-07-03 04:20:00'),
      (84, 84, 291,  6, 'REQUESTED',      '2025-07-02 11:50:00', '2025-07-02 17:15:00'),
      (85, 85, 313,  6, 'CANCELED',  '2025-07-02 15:30:00', '2025-07-02 21:45:00'),
      (86, 86, 335,  6, 'REQUESTED',      '2025-07-02 20:20:00', '2025-07-03 02:35:00'),
      (87, 87, 357,  7, 'CANCELED',  '2025-07-02 13:25:00', '2025-07-02 18:40:00'),
      (88, 88, 379,  7, 'REQUESTED',      '2025-07-02 16:45:00', '2025-07-02 22:10:00'),
      (89, 89, 402,  7, 'CANCELED',  '2025-07-02 21:30:00', '2025-07-03 03:45:00'),
      (90, 90, 424,  8, 'DONE',      '2025-07-02 15:40:00', '2025-07-02 20:55:00'),
      (91, 91, 446,  8, 'CANCELED',  '2025-07-02 18:25:00', '2025-07-03 00:40:00'),
      (92, 92, 468,  8, 'DONE',      '2025-07-02 22:10:00', '2025-07-03 04:25:00'),
      (93, 93, 490,  6, 'CANCELED',  '2025-07-02 23:45:00', '2025-07-03 05:20:00'),
      (94, 94, 513,  7, 'DONE',      '2025-07-02 23:55:00', '2025-07-03 06:10:00'),
      (95, 95, 535,  8, 'CANCELED',  '2025-07-02 23:30:00', '2025-07-03 05:45:00'),

      -- 7월 3일 예약들 (96-114번, Orders 95-113)
      (96,  96,  73,  4, 'DONE',      '2025-07-03 08:45:00', '2025-07-03 14:20:00'),
      (97,  97, 106,  4, 'CANCELED',  '2025-07-03 12:30:00', '2025-07-03 18:45:00'),
      (98,  98, 128,  4, 'REQUESTED',      '2025-07-03 17:20:00', '2025-07-03 22:35:00'),
      (99,  99, 151,  5, 'REQUESTED',      '2025-07-03 10:10:00', '2025-07-03 15:25:00'),
      (100, 100, 173,  5, 'CANCELED',  '2025-07-03 14:40:00', '2025-07-03 20:55:00'),
      (101, 101, 195,  5, 'DONE',      '2025-07-03 19:15:00', '2025-07-04 01:30:00'),
      (102, 102, 217,  6, 'CANCELED',  '2025-07-03 11:30:00', '2025-07-03 17:45:00'),
      (103, 103, 239,  6, 'DONE',      '2025-07-03 16:20:00', '2025-07-03 21:35:00'),
      (104, 104, 261,  6, 'CANCELED',  '2025-07-03 20:45:00', '2025-07-04 02:20:00'),
      (105, 105, 283,  7, 'DONE',      '2025-07-03 12:55:00', '2025-07-03 18:10:00'),
      (106, 106, 305,  7, 'CANCELED',  '2025-07-03 15:30:00', '2025-07-03 21:45:00'),
      (107, 107, 327,  7, 'REQUESTED',      '2025-07-03 22:20:00', '2025-07-04 04:35:00'),
      (108, 108, 349,  8, 'REQUESTED',      '2025-07-03 14:40:00', '2025-07-03 19:55:00'),
      (109, 109, 371,  8, 'CANCELED',  '2025-07-03 18:25:00', '2025-07-04 00:40:00'),
      (110, 110, 393,  8, 'REQUESTED',      '2025-07-03 21:50:00', '2025-07-04 03:15:00'),
      (111, 111, 415,  4, 'CANCELED',  '2025-07-03 20:30:00', '2025-07-04 01:45:00'),
      (112, 112, 437,  5, 'DONE',      '2025-07-03 21:40:00', '2025-07-04 02:55:00'),
      (113, 113, 459,  6, 'CANCELED',  '2025-07-03 22:55:00', '2025-07-04 04:10:00'),
      (114, 114, 481,  7, 'DONE',      '2025-07-03 23:25:00', '2025-07-04 05:40:00'),

      -- 7월 4일 예약들 (115-131번, Orders 114-130)
      (115, 115,  94,  4, 'CANCELED',  '2025-07-04 09:15:00', '2025-07-04 16:30:00'),
      (116, 116, 117,  4, 'REQUESTED',      '2025-07-04 13:45:00', '2025-07-04 19:20:00'),
      (117, 117, 139,  4, 'CANCELED',  '2025-07-04 18:30:00', '2025-07-05 00:45:00'),
      (118, 118, 162,  5, 'REQUESTED',      '2025-07-04 10:25:00', '2025-07-04 15:50:00'),
      (119, 119, 184,  5, 'CANCELED',  '2025-07-04 14:15:00', '2025-07-04 20:30:00'),
      (120, 120, 206,  5, 'DONE',      '2025-07-04 19:45:00', '2025-07-05 02:10:00'),
      (121, 121, 228,  6, 'DONE',      '2025-07-04 11:40:00', '2025-07-04 17:25:00'),
      (122, 122, 250,  6, 'CANCELED',  '2025-07-04 16:20:00', '2025-07-04 22:35:00'),
      (123, 123, 272,  7, 'CANCELED',  '2025-07-04 13:20:00', '2025-07-04 18:45:00'),
      (124, 124, 294,  7, 'REQUESTED',      '2025-07-04 17:30:00', '2025-07-04 23:15:00'),
      (125, 125, 316,  7, 'CANCELED',  '2025-07-04 21:25:00', '2025-07-05 03:40:00'),
      (126, 126, 338,  8, 'REQUESTED',      '2025-07-04 15:10:00', '2025-07-04 20:15:00'),
      (127, 127, 360,  8, 'CANCELED',  '2025-07-04 19:45:00', '2025-07-05 01:20:00'),
      (128, 128, 382,  8, 'REQUESTED',      '2025-07-04 22:30:00', '2025-07-05 04:45:00'),
      (129, 129, 404,  4, 'DONE',      '2025-07-04 21:15:00', '2025-07-05 02:30:00'),
      (130, 130, 426,  6, 'CANCELED',  '2025-07-04 22:45:00', '2025-07-05 05:10:00'),
      (131, 131, 448,  7, 'DONE',      '2025-07-04 23:55:00', '2025-07-05 06:20:00'),

      -- 7월 5일 예약들 (132-147번, Orders 131-146)
      (132, 132,  86,  4, 'REQUESTED',      '2025-07-05 08:50:00', '2025-07-05 14:15:00'),
      (133, 133, 108,  4, 'CANCELED',  '2025-07-05 12:25:00', '2025-07-05 18:40:00'),
      (134, 134, 131,  4, 'REQUESTED',      '2025-07-05 17:30:00', '2025-07-05 23:45:00'),
      (135, 135, 153,  5, 'CANCELED',  '2025-07-05 10:05:00', '2025-07-05 16:40:00'),
      (136, 136, 175,  5, 'REQUESTED',      '2025-07-05 15:20:00', '2025-07-05 21:35:00'),
      (137, 137, 197,  5, 'CANCELED',  '2025-07-05 20:45:00', '2025-07-06 03:10:00'),
      (138, 138, 219,  6, 'DONE',      '2025-07-05 11:20:00', '2025-07-05 17:25:00'),
      (139, 139, 241,  6, 'CANCELED',  '2025-07-05 16:15:00', '2025-07-05 22:30:00'),
      (140, 140, 263,  6, 'DONE',      '2025-07-05 21:40:00', '2025-07-06 04:55:00'),
      (141, 141, 285,  7, 'DONE',      '2025-07-05 12:45:00', '2025-07-05 18:20:00'),
      (142, 142, 307,  7, 'CANCELED',  '2025-07-05 17:10:00', '2025-07-05 23:25:00'),
      (143, 143, 329,  8, 'CANCELED',  '2025-07-05 14:30:00', '2025-07-05 19:55:00'),
      (144, 144, 351,  8, 'REQUESTED',      '2025-07-05 18:45:00', '2025-07-06 01:10:00'),
      (145, 145, 373,  8, 'CANCELED',  '2025-07-05 22:20:00', '2025-07-06 04:35:00'),
      (146, 146, 395,  5, 'DONE',      '2025-07-05 23:15:00', '2025-07-06 05:30:00'),
      (147, 147, 417,  7, 'CANCELED',  '2025-07-05 23:45:00', '2025-07-06 06:10:00'),

      -- 7월 6일 예약들 (148-162번, Orders 147-161)
      (148, 148,  98,  4, 'REQUESTED',      '2025-07-06 09:30:00', '2025-07-06 15:45:00'),
      (149, 149, 120,  4, 'CANCELED',  '2025-07-06 13:15:00', '2025-07-06 19:30:00'),
      (150, 150, 142,  4, 'REQUESTED',      '2025-07-06 18:25:00', '2025-07-07 00:40:00'),
      (151, 151, 164,  5, 'REQUESTED',      '2025-07-06 10:45:00', '2025-07-06 16:20:00'),
      (152, 152, 186,  5, 'CANCELED',  '2025-07-06 14:30:00', '2025-07-06 20:45:00'),
      (153, 153, 208,  5, 'DONE',      '2025-07-06 19:55:00', '2025-07-07 02:20:00'),
      (154, 154, 230,  6, 'CANCELED',  '2025-07-06 12:10:00', '2025-07-06 18:20:00'),
      (155, 155, 252,  6, 'DONE',      '2025-07-06 17:35:00', '2025-07-06 23:50:00'),
      (156, 156, 274,  6, 'CANCELED',  '2025-07-06 21:45:00', '2025-07-07 04:10:00'),
      (157, 157, 296,  7, 'REQUESTED',      '2025-07-06 13:35:00', '2025-07-06 19:10:00'),
      (158, 158, 318,  7, 'CANCELED',  '2025-07-06 18:20:00', '2025-07-07 00:35:00'),
      (159, 159, 340,  8, 'REQUESTED',      '2025-07-06 15:25:00', '2025-07-06 21:40:00'),
      (160, 160, 362,  8, 'CANCELED',  '2025-07-06 20:15:00', '2025-07-07 02:30:00'),
      (161, 161, 384,  4, 'CANCELED',  '2025-07-06 22:30:00', '2025-07-07 04:45:00'),
      (162, 162, 406,  6, 'DONE',      '2025-07-06 23:40:00', '2025-07-07 06:15:00'),

      -- 7월 7일 예약들 (163-176번, Orders 162-175)
      (163, 163, 101,  4, 'CANCELED',  '2025-07-07 08:40:00', '2025-07-07 16:25:00'),
      (164, 164, 124,  4, 'REQUESTED',      '2025-07-07 14:20:00', '2025-07-07 20:35:00'),
      (165, 165, 145,  4, 'CANCELED',  '2025-07-07 19:45:00', '2025-07-08 02:10:00'),
      (166, 166, 167,  5, 'REQUESTED',      '2025-07-07 09:55:00', '2025-07-07 14:30:00'),
      (167, 167, 189,  5, 'CANCELED',  '2025-07-07 13:40:00', '2025-07-07 19:55:00'),
      (168, 168, 211,  5, 'DONE',      '2025-07-07 21:15:00', '2025-07-08 03:30:00'),
      (169, 169, 233,  6, 'DONE',      '2025-07-07 11:15:00', '2025-07-07 17:40:00'),
      (170, 170, 255,  6, 'CANCELED',  '2025-07-07 16:25:00', '2025-07-07 22:40:00'),
      (171, 171, 277,  7, 'CANCELED',  '2025-07-07 12:30:00', '2025-07-07 17:40:00'),
      (172, 172, 299,  7, 'REQUESTED',      '2025-07-07 18:50:00', '2025-07-08 01:15:00'),
      (173, 173, 321,  8, 'REQUESTED',      '2025-07-07 14:20:00', '2025-07-07 19:35:00'),
      (174, 174, 343,  8, 'CANCELED',  '2025-07-07 20:30:00', '2025-07-08 02:45:00'),
      (175, 175, 365,  7, 'REQUESTED',      '2025-07-07 22:45:00', '2025-07-08 05:10:00'),
      (176, 176, 387,  8, 'CANCELED',  '2025-07-07 23:30:00', '2025-07-08 05:55:00');




-- 서민영 변호사 (교통공학 전문) 템플릿 1-20번
-- 카테고리 1: 사고 발생/처리, 2: 중대사고·형사처벌, 3: 합의·무변상합의, 4: 보험·행정처분, 5: 과실 분쟁, 6: 차량 외 사고

INSERT INTO template (no, user_no, category_no, type, name, description, price, thumbnail_path, sales_count, discount_rate, is_deleted) VALUES
                                                                                                                                            (1, 31, 1, 'FILE', '교통사고 발생신고서', '교통사고 발생 즉시 작성해야 하는 종합 신고서류 패키지입니다. 경찰신고, 보험사 신고, 현장보존 체크리스트 등 사고 직후 필수 절차를 체계적으로 안내합니다.', 32000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/1.png', 234, 15, 0),
                                                                                                                                            (2, 31, 2, 'EDITOR', '중대사고 형사고발장', '사망이나 중상해를 동반한 중대 교통사고의 가해자를 형사고발하는 AI 인터뷰 템플릿입니다. 업무상과실치사상죄, 위험운전치사상죄 등 엄중처벌을 위한 고발장을 작성합니다.', 58000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/2.png', 89, 20, 0),
                                                                                                                                            (3, 31, 3, 'FILE', '교통사고 손해배상 합의서', '교통사고 피해배상을 위한 완벽한 합의서 양식집입니다. 치료비, 위자료, 휴업손해 등 모든 손해항목을 포함하며, 향후 추가청구 방지 조항까지 완비되어 있습니다.', 45000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/3.png', 312, 18, 0),
                                                                                                                                            (4, 31, 4, 'EDITOR', '자동차보험 이의신청서', '보험사의 과실비율 결정이나 보상금액에 이의가 있을 때 제기하는 AI 인터뷰 템플릿입니다. 교통공학적 근거와 판례를 바탕으로 설득력 있는 이의신청서를 작성합니다.', 42000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/4.png', 167, 12, 0),
                                                                                                                                            (5, 31, 5, 'FILE', '과실비율 재검토 신청서', '보험사가 제시한 과실비율에 대해 전문적이고 과학적인 근거로 재검토를 요구하는 신청서입니다. 블랙박스 분석, 현장측정 등 교통공학적 증거를 체계적으로 정리합니다.', 48000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/5.png', 278, 25, 0),
                                                                                                                                            (6, 31, 6, 'EDITOR', '자전거 사고 손해배상청구서', '자전거와 자동차 간 사고의 손해배상을 청구하는 AI 인터뷰 템플릿입니다. 자전거 이용자의 교통약자로서의 특수성을 반영하여 적정한 배상을 받을 수 있도록 구성합니다.', 36000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/6.png', 143, 10, 0),
                                                                                                                                            (7, 31, 1, 'FILE', '교통사고 현장조사 의뢰서', '교통사고 현장의 정확한 분석을 위해 전문기관에 조사를 의뢰하는 공문서입니다. 도로상황, 신호체계, 시야확보 등 사고원인 규명에 필요한 모든 요소를 포함합니다.', 35000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/7.png', 126, 8, 0),
                                                                                                                                            (8, 31, 2, 'EDITOR', '음주운전 사고 고발장', '음주운전으로 인한 교통사고 가해자의 엄벌을 위한 AI 인터뷰 템플릿입니다. 위험운전치상죄 적용과 함께 운전면허 취소 등 행정처분 강화를 요구합니다.', 52000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/8.png', 198, 22, 0),
                                                                                                                                            (9, 31, 3, 'FILE', '무보상 합의서', '경미한 접촉사고 등에서 쌍방이 손해배상을 포기하는 무보상 합의서 양식입니다. 향후 은밀한 손해나 후유증 발생 시 대응방안까지 포함된 완전한 합의서입니다.', 28000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/9.png', 189, 5, 0),
                                                                                                                                            (10, 31, 4, 'EDITOR', '운전면허 정지처분 이의신청서', '교통사고로 인한 운전면허 정지처분에 대해 이의를 제기하는 AI 인터뷰 템플릿입니다. 생계곤란, 업무상 필요성 등을 종합적으로 고려하여 처분 경감을 요청합니다.', 41000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/10.png', 154, 15, 0),
                                                                                                                                            (11, 31, 5, 'FILE', '신호위반 과실비율 이의서', '신호위반 사고의 과실비율 산정에 이의를 제기하는 전문서면입니다. 황색신호 딜레마존, 신호현시시간 등 교통공학적 분석을 통해 과실비율 조정을 요구합니다.', 44000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/11.png', 201, 18, 0),
                                                                                                                                            (12, 31, 6, 'EDITOR', '킥보드 사고 배상청구서', '전동킥보드 사고로 인한 손해배상을 청구하는 AI 인터뷰 템플릿입니다. 개인형 모빌리티의 특성과 도로교통법상 지위를 고려하여 적정한 배상액을 산정합니다.', 33000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/12.png', 117, 12, 0),
                                                                                                                                            (13, 31, 1, 'FILE', '교통사고 증인신문 신청서', '교통사고 목격자나 관련자의 증인신문을 법원에 신청하는 서면입니다. 사고 당시 상황을 정확히 재현하기 위해 필요한 증인의 진술을 확보하는 절차를 안내합니다.', 37000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/13.png', 92, 10, 0),
                                                                                                                                            (14, 31, 2, 'EDITOR', '뺑소니 사고 고발장', '뺑소니 교통사고 가해자를 특정사고가중처벌법 위반으로 고발하는 AI 인터뷰 템플릿입니다. 도주행위의 고의성과 피해 가중성을 강조하여 엄중처벌을 요구합니다.', 55000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/14.png', 145, 25, 0),
                                                                                                                                            (15, 31, 3, 'FILE', '교통사고 분할합의서', '복잡한 교통사고에서 치료비와 위자료를 분할하여 합의하는 전문 양식입니다. 1차 합의 후 추가 치료비 발생에 대비한 안전장치와 최종합의 조건을 명확히 규정합니다.', 41000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/15.png', 168, 15, 0),
                                                                                                                                            (16, 31, 4, 'EDITOR', '자동차보험 약관해석 이의서', '보험사의 약관해석에 이의를 제기하는 AI 인터뷰 템플릿입니다. 보험약관의 모호한 조항에 대해 피보험자에게 유리한 해석을 요구하는 논리적 근거를 제시합니다.', 38000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/16.png', 134, 12, 0),
                                                                                                                                            (17, 31, 5, 'FILE', '차선변경 과실분쟁 조정신청서', '차선변경 중 발생한 사고의 과실비율 분쟁을 교통사고심의위원회에 조정 신청하는 서면입니다. 안전거리, 신호등 등 구체적 사고상황을 분석하여 유리한 과실비율을 주장합니다.', 43000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/17.png', 187, 20, 0),
                                                                                                                                            (18, 31, 6, 'EDITOR', '보행자 사고 배상청구서', '보행자 교통사고 피해에 대한 손해배상을 청구하는 AI 인터뷰 템플릿입니다. 보행자 보호의무와 교통약자 우선원칙을 바탕으로 적극적인 손해배상을 요구합니다.', 39000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/18.png', 221, 18, 0),
                                                                                                                                            (19, 31, 1, 'FILE', '교통사고 감정서 신청서', '교통사고의 원인과 과실관계를 명확히 하기 위해 전문기관에 감정을 의뢰하는 신청서입니다. 차량 결함, 도로 결함 등 특수한 사고원인이 의심될 때 활용합니다.', 46000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/19.png', 108, 22, 0),
                                                                                                                                            (20, 31, 2, 'EDITOR', '교통사고 업무상과실 고발장', '업무 중 발생한 교통사고를 업무상과실치상죄로 고발하는 AI 인터뷰 템플릿입니다. 운수업체, 배달업체 등 업무용 차량 사고의 특수성을 반영하여 가중처벌을 요구합니다.', 49000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/20.png', 156, 15, 0),

-- 배서연 변호사 (음주운전 전문) 템플릿 21-40번
                                                                                                                                            (21, 32, 4, 'FILE', '음주운전 행정처분 이의신청서', '음주운전으로 인한 면허취소·정지 처분에 대해 이의를 제기하는 전문 신청서입니다. 생계곤란, 초범, 낮은 혈중알코올농도 등을 근거로 처분 경감을 요구합니다.', 52000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/21.png', 298, 20, 0),
                                                                                                                                            (22, 32, 2, 'EDITOR', '음주운전 형사합의서', '음주운전 사고 피해자와의 형사합의를 체결하는 AI 인터뷰 템플릿입니다. 적정한 합의금액과 함께 선처 요구서까지 포함하여 형사처벌 감경 효과를 극대화합니다.', 47000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/22.png', 187, 18, 0),
                                                                                                                                            (23, 32, 4, 'EDITOR', '음주측정 불응 이의신청서', '음주측정 거부에 따른 처벌에 이의를 제기하는 AI 인터뷰 템플릿입니다. 측정 불가능한 정당한 사유, 신체적 장애, 측정기 오작동 등을 근거로 불응죄 성립을 부인합니다.', 45000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/23.png', 134, 15, 0),
                                                                                                                                            (24, 32, 2, 'FILE', '음주운전 정상참작 탄원서', '음주운전 형사사건에서 정상참작을 요구하는 탄원서 모음입니다. 가족사정, 경제적 어려움, 개선의지 등을 체계적으로 정리하여 법정에서 선처를 호소합니다.', 38000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/24.png', 223, 12, 0),
                                                                                                                                            (25, 32, 4, 'FILE', '대리운전 이용증명서', '음주 후 대리운전을 이용했음을 증명하는 종합 자료집입니다. 대리운전 호출내역, GPS 이동경로, 결제증빙 등을 통해 직접운전 사실을 부인하는 결정적 증거를 제시합니다.', 41000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/25.png', 176, 22, 0),
                                                                                                                                            (26, 32, 2, 'EDITOR', '음주운전 피해자 합의서', '음주운전 사고로 피해를 입었을 때 가해자와 체결하는 AI 인터뷰 합의서입니다. 충분한 손해배상과 함께 재발방지 약속까지 포함하여 완전한 피해회복을 도모합니다.', 43000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/26.png', 201, 25, 0),
                                                                                                                                            (27, 32, 4, 'EDITOR', '혈중알코올농도 이의신청서', '음주측정 결과에 대해 과학적 근거로 이의를 제기하는 AI 인터뷰 템플릿입니다. 개인차, 측정오차, 역추산 공식의 한계 등을 지적하여 측정결과의 신빙성을 다툽니다.', 48000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/27.png', 159, 18, 0),
                                                                                                                                            (28, 32, 1, 'FILE', '음주운전 현장 대응 매뉴얼', '음주운전으로 단속되었을 때 현장에서 취해야 할 대응방법을 정리한 실용 매뉴얼입니다. 묵비권 행사, 측정 거부 시 유의사항, 변호사 선임 등 단계별 대응전략을 제시합니다.', 35000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/28.png', 267, 8, 0),
                                                                                                                                            (29, 32, 2, 'EDITOR', '음주운전 반성문', '음주운전 형사재판에서 제출할 반성문을 작성하는 AI 인터뷰 템플릿입니다. 진심어린 반성과 재발방지 의지를 표현하여 법관의 양형참작을 이끌어내는 효과적인 반성문을 작성합니다.', 32000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/29.png', 145, 10, 0),
                                                                                                                                            (30, 2, 4, 'FILE', '음주운전 전력 조회 신청서', '음주운전 전력이 있는지 확인하기 위해 관련 기관에 조회를 신청하는 서면입니다. 정확한 전력 파악을 통해 가중처벌 대상 여부를 미리 확인하고 대응전략을 수립합니다.', 29000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/30.png', 198, 5, 0),
                                                                                                                                            (31, 32, 4, 'EDITOR', '직업별 면허필수 소명서', '직업 수행에 운전면허가 필수적임을 소명하는 AI 인터뷰 템플릿입니다. 택시기사, 버스기사, 영업직 등 직업별 특성을 반영하여 면허취소 처분의 경감을 요구합니다.', 39000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/31.png', 234, 15, 0),
                                                                                                                                            (32, 32, 2, 'FILE', '음주운전 목격자 진술서', '음주운전 사건의 목격자 진술을 확보하는 진술서 양식입니다. 사고 당시 상황, 운전자 상태, 음주 정도 등을 객관적으로 기술하여 사실관계를 명확히 합니다.', 33000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/32.png', 167, 12, 0),
                                                                                                                                            (33, 32, 4, 'EDITOR', '음주단속 적법성 이의서', '음주운전 단속과정의 적법성에 이의를 제기하는 AI 인터뷰 템플릿입니다. 정당한 정차 요구, 측정 절차 준수, 권리고지 등 단속과정의 하자를 지적하여 처분을 다툽니다.', 44000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/33.png', 128, 20, 0),
                                                                                                                                            (34, 32, 1, 'FILE', '음주운전 보험처리 신청서', '음주운전 사고 시 보험처리 절차를 정리한 신청서류 패키지입니다. 대인배상, 대물배상, 자기차량손해 등 보험별 처리방법과 유의사항을 상세히 안내합니다.', 36000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/34.png', 189, 8, 0),
                                                                                                                                            (35, 32, 2, 'EDITOR', '음주운전 가족탄원서', '음주운전자의 가족이 법정에 제출하는 탄원서를 작성하는 AI 인터뷰 템플릿입니다. 가족의 생계책임, 부양의무, 개선 노력 등을 호소하여 관대한 처분을 요청합니다.', 37000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/35.png', 212, 18, 0),
                                                                                                                                            (36, 32, 4, 'FILE', '약물복용 음주측정 영향 소명서', '복용 중인 약물이 음주측정에 미친 영향을 의학적으로 소명하는 전문서면입니다. 약물-알코올 상호작용, 측정기 반응성 등을 근거로 측정결과의 정확성을 다툽니다.', 42000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/36.png', 143, 22, 0),
                                                                                                                                            (37, 32, 2, 'EDITOR', '음주운전 업무상 필요성 소명서', '업무상 불가피한 음주운전이었음을 소명하는 AI 인터뷰 템플릿입니다. 응급상황, 긴급업무, 대안 부재 등을 구체적으로 기술하여 정당방위나 긴급피난 논리를 구성합니다.', 40000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/37.png', 156, 15, 0),
                                                                                                                                            (38, 32, 4, 'EDITOR', '음주운전 개선계획서', '음주운전 재발방지를 위한 구체적인 개선계획을 수립하는 AI 인터뷰 템플릿입니다. 금주서약, 상담치료 계획, 대리운전 이용 약속 등 실질적인 개선방안을 제시합니다.', 35000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/38.png', 187, 12, 0),
                                                                                                                                            (39, 32, 1, 'FILE', '음주운전 사고조사서', '음주운전으로 인한 교통사고의 정확한 조사를 위한 조사서 양식입니다. 사고경위, 피해상황, 음주상태 등을 객관적으로 기록하여 향후 법적 대응의 기초자료로 활용합니다.', 38000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/39.png', 234, 10, 0),
                                                                                                                                            (40, 32, 2, 'EDITOR', '음주운전 피해배상 약정서', '음주운전 사고 가해자가 피해자에게 배상을 약정하는 AI 인터뷰 템플릿입니다. 즉시 배상할 금액과 분할 배상 조건을 명확히 하여 피해자와의 원만한 합의를 도모합니다.', 45000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/40.png', 178, 25, 0),

-- 한도현 변호사 (검찰 출신) 템플릿 41-60번
                                                                                                                                            (41, 33, 2, 'FILE', '중대사고 손해배상청구서', '사망이나 중상해를 동반한 중대 교통사고의 손해배상을 청구하는 전문서면입니다. 일실이익, 위자료, 장례비 등 모든 손해항목을 최대한 반영하여 완전한 피해회복을 도모합니다.', 68000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/41.png', 145, 25, 0),
                                                                                                                                            (42, 33, 2, 'EDITOR', '교통사고 형사처벌 요구서', '교통사고 가해자의 엄중한 형사처벌을 요구하는 AI 인터뷰 템플릿입니다. 검찰 수사 경험을 바탕으로 가해자의 죄질과 피해의 중대성을 강조하여 실형을 요구합니다.', 58000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/42.png', 167, 20, 0),
                                                                                                                                            (43, 33, 3, 'FILE', '중대사고 합의조건서', '중대한 교통사고에서 가해자와 합의할 때의 조건을 정하는 전문 합의서입니다. 충분한 배상금액과 함께 향후 추가 손해 발생에 대한 보장까지 포함하는 완전한 합의조건을 제시합니다.', 62000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/43.png', 123, 22, 0),
                                                                                                                                            (44, 33, 2, 'EDITOR', '교통사고 집행유예 반대 의견서', '교통사고 가해자의 집행유예에 반대하는 AI 인터뷰 의견서입니다. 피해의 중대성, 가해자의 불성실한 태도, 사회적 위험성 등을 근거로 실형 선고를 강력히 요구합니다.', 55000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/44.png', 189, 18, 0),
                                                                                                                                            (45, 33, 3, 'EDITOR', '교통사고 중재 신청서', '복잡한 교통사고 분쟁을 중재원에 신청하는 AI 인터뷰 템플릿입니다. 법정 소송보다 신속하고 전문적인 분쟁 해결을 위해 교통사고 전문 중재인을 통한 해결을 요구합니다.', 48000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/45.png', 134, 15, 0),
                                                                                                                                            (46, 33, 2, 'FILE', '교통사고 법정 피해자참여 신청서', '교통사고 형사재판에서 피해자가 직접 참여하여 의견을 진술할 수 있는 피해자참여재판을 신청하는 서면입니다. 가해자 처벌에 피해자 목소리를 직접 반영시킵니다.', 52000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/46.png', 156, 20, 0),
                                                                                                                                            (47, 33, 5, 'EDITOR', '교통사고 과실비율 전문감정 신청서', '복잡한 교통사고의 과실비율을 정확히 판단하기 위해 전문기관에 감정을 의뢰하는 AI 인터뷰 템플릿입니다. 교통공학, 차량공학 등 다각도 전문감정을 통해 유리한 과실비율을 확보합니다.', 59000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/47.png', 198, 25, 0),
                                                                                                                                            (48, 33, 2, 'FILE', '교통사고 피해자 진술서', '교통사고 피해자나 유족이 법정에서 진술할 내용을 정리한 진술서 양식입니다. 사고 당시 상황, 피해 정도, 가해자에 대한 처벌 요구 등을 감정적으로 호소력 있게 구성합니다.', 45000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/48.png', 234, 12, 0),
                                                                                                                                            (49, 33, 3, 'EDITOR', '교통사고 상급심 항소이유서', '1심 판결에 불복하여 항소할 때 제출하는 AI 인터뷰 항소이유서입니다. 1심 판결의 사실인정 오류, 법리 적용 잘못 등을 체계적으로 지적하여 상급심에서 승소를 도모합니다.', 65000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/49.png', 112, 28, 0),
                                                                                                                                            (50, 33, 2, 'EDITOR', '교통사고 양형부당 항고서', '교통사고 형사재판 결과에 대해 양형이 부당하다며 항고하는 AI 인터뷰 템플릿입니다. 피해의 중대성 대비 가벼운 처벌의 부당성을 강조하여 중형을 요구합니다.', 53000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/50.png', 167, 18, 0),
                                                                                                                                            (51, 33, 1, 'FILE', '교통사고 증거보전 신청서', '교통사고와 관련된 중요 증거가 멸실될 우려가 있을 때 법원에 증거보전을 신청하는 서면입니다. CCTV 영상, 블랙박스, 현장 흔적 등 핵심 증거의 보전을 요구합니다.', 47000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/51.png', 143, 15, 0),
                                                                                                                                            (52, 33, 2, 'EDITOR', '국선변호인 해임 신청서', '교통사고 가해자에게 선정된 국선변호인이 부적절할 때 해임을 신청하는 AI 인터뷰 템플릿입니다. 피해자 관점에서 가해자 변호에 소극적인 국선변호인의 교체를 요구합니다.', 41000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/52.png', 89, 10, 0),
                                                                                                                                            (53, 33, 3, 'FILE', '교통사고 강제집행 신청서', '교통사고 손해배상 판결을 받았으나 가해자가 이행하지 않을 때 강제집행을 신청하는 서면입니다. 가해자 재산에 대한 압류, 추심 등 강제집행 절차를 체계적으로 진행합니다.', 44000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/53.png', 198, 20, 0),
                                                                                                                                            (54, 33, 2, 'EDITOR', '교통사고 공소시효 연장 신청서', '교통사고 형사사건의 공소시효 완성이 임박했을 때 시효 연장을 신청하는 AI 인터뷰 템플릿입니다. 수사의 복잡성, 증거수집의 어려움 등을 근거로 시효 연장을 요구합니다.', 38000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/54.png', 176, 12, 0),
                                                                                                                                            (55, 33, 5, 'FILE', '교통사고 과실상계 반박서', '가해자가 주장하는 피해자 과실상계에 반박하는 전문서면입니다. 피해자에게 불리한 과실비율 주장에 대해 교통법규, 판례, 사고 상황 등을 종합적으로 분석하여 반박논리를 구성합니다.', 48000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/55.png', 221, 22, 0),
                                                                                                                                            (56, 33, 1, 'EDITOR', '교통사고 현장검증 신청서', '교통사고 현장에서 법원의 검증을 받기 위해 신청하는 AI 인터뷰 템플릿입니다. 현장 상황재현을 통해 사고 원인과 과실관계를 명확히 밝히고자 할 때 활용합니다.', 42000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/56.png', 134, 15, 0),
                                                                                                                                            (57, 33, 2, 'FILE', '교통사고 추가수사 요청서', '교통사고 수사가 부실하게 진행되었을 때 추가 수사를 요청하는 서면입니다. 미확인 증거, 목격자 진술, 전문감정 등 누락된 수사사항에 대한 재수사를 강력히 요구합니다.', 51000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/57.png', 187, 25, 0),
                                                                                                                                            (58, 33, 3, 'EDITOR', '교통사고 조정 신청서', '교통사고 분쟁을 법원 조정절차로 해결하기 위해 신청하는 AI 인터뷰 템플릿입니다. 소송보다 신속하고 경제적인 분쟁해결을 위해 법원 조정을 통한 합의를 추진합니다.', 39000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/58.png', 156, 18, 0),
                                                                                                                                            (59, 33, 2, 'EDITOR', '교통사고 재심 신청서', '확정된 교통사고 형사판결에 대해 재심을 신청하는 AI 인터뷰 템플릿입니다. 새로운 증거 발견, 위증 판명 등 재심 사유가 명확할 때 무죄나 감형을 위한 재심을 신청합니다.', 62000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/59.png', 98, 30, 0),
                                                                                                                                            (60, 33, 5, 'EDITOR', '교통사고 과실비율 재산정 신청서', '기존에 확정된 과실비율의 재산정을 요구하는 AI 인터뷰 템플릿입니다. 새로운 증거나 감정결과를 바탕으로 과실비율의 변경을 통해 손해배상액의 증액을 도모합니다.', 55000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/60.png', 167, 20, 0),

-- 김수현 변호사 (교통약자 전문) 템플릿 61-80번
                                                                                                                                            (61, 34, 6, 'EDITOR', '보행자 교통사고 배상청구서', '보행자 교통사고 피해에 대한 손해배상을 청구하는 AI 인터뷰 템플릿입니다. 보행자 보호의무와 교통약자 우선원칙을 강조하여 최대한의 배상을 받을 수 있도록 구성합니다.', 38000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/61.png', 287, 10, 0),
                                                                                                                                            (62, 34, 6, 'FILE', '어린이 교통사고 특별배상청구서', '만 13세 미만 어린이 교통사고의 특별배상을 청구하는 전문서면입니다. 어린이보호구역 위반, 안전운전 의무 가중 등을 근거로 일반 사고보다 높은 배상을 요구합니다.', 42000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/62.png', 198, 15, 0),
                                                                                                                                            (63, 34, 6, 'EDITOR', '고령자 교통사고 특별배상청구서', '65세 이상 고령자 교통사고 피해배상을 청구하는 AI 인터뷰 템플릿입니다. 고령자의 신체적 특성과 회복력을 고려하여 치료비, 간병비, 위자료 등을 적극적으로 산정합니다.', 39000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/63.png', 234, 12, 0),
                                                                                                                                            (64, 34, 6, 'FILE', '장애인 교통사고 특별배상청구서', '장애인 교통사고 피해의 특수성을 반영한 배상청구서입니다. 기존 장애 악화, 중복장애 발생, 특수 보조기구 손해 등 장애인 특유의 피해항목을 포함하여 배상을 청구합니다.', 45000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/64.png', 156, 18, 0),
                                                                                                                                            (65, 34, 6, 'EDITOR', '자전거 사고 배상청구서', '자전거 이용자의 교통사고 피해배상을 청구하는 AI 인터뷰 템플릿입니다. 친환경 교통수단 이용자로서의 우선보호 필요성과 운전자의 안전확인 의무를 강조합니다.', 36000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/65.png', 189, 8, 0),
                                                                                                                                            (66, 34, 6, 'FILE', '전동휠체어 사고 배상청구서', '전동휠체어 이용자의 교통사고 피해배상을 청구하는 전문서면입니다. 보행자로서의 법적 지위와 이동권 보장 필요성을 강조하여 충분한 배상을 요구합니다.', 41000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/66.png', 123, 20, 0),
                                                                                                                                            (67, 34, 6, 'EDITOR', '전동킥보드 사고 배상청구서', '전동킥보드 이용자의 교통사고 피해배상을 청구하는 AI 인터뷰 템플릿입니다. 개인형 모빌리티 이용자의 교통약자적 지위를 인정받아 적정한 배상을 받을 수 있도록 구성합니다.', 34000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/67.png', 167, 12, 0),
                                                                                                                                            (68, 34, 3, 'FILE', '교통약자 배려 합의서', '교통약자가 교통사고 가해자와 합의할 때 사용하는 특별 합의서입니다. 단순한 금전 배상을 넘어 지속적인 치료지원, 재활비용, 사회복귀 지원 등을 포함하는 포괄적 합의조건을 제시합니다.', 37000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/68.png', 201, 15, 0),
                                                                                                                                            (69, 34, 6, 'EDITOR', '스쿨존 사고 가중배상청구서', '어린이보호구역 내 교통사고의 가중배상을 청구하는 AI 인터뷰 템플릿입니다. 스쿨존 특별보호의무 위반에 따른 가중처벌과 배상책임을 근거로 높은 배상액을 요구합니다.', 43000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/69.png', 178, 22, 0),
                                                                                                                                            (70, 34, 5, 'FILE', '교통약자 과실비율 이의신청서', '교통약자에게 불리하게 책정된 과실비율에 이의를 제기하는 신청서입니다. 교통약자 보호원칙과 운전자의 주의의무 가중을 근거로 과실비율 조정을 요구합니다.', 40000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/70.png', 145, 18, 0),
                                                                                                                                            (71, 34, 6, 'EDITOR', '임산부 교통사고 배상청구서', '임산부 교통사고 피해의 특수성을 반영한 AI 인터뷰 배상청구서입니다. 태아에 대한 영향, 출산 관련 추가비용, 정신적 충격 등을 포함하여 특별배상을 요구합니다.', 44000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/71.png', 134, 20, 0),
                                                                                                                                            (72, 34, 4, 'FILE', '교통약자 보험금 특별청구서', '교통약자의 보험금 청구 시 일반인과 다른 특별한 배려사항을 반영한 청구서입니다. 장기치료 필요성, 재활비용, 보조기구 비용 등 교통약자 특화 보상항목을 포함합니다.', 38000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/72.png', 189, 15, 0),
                                                                                                                                            (73, 34, 6, 'EDITOR', '시각장애인 교통사고 배상청구서', '시각장애인 교통사고 피해의 특수성을 반영한 AI 인터뷰 배상청구서입니다. 안내견 피해, 점자블록 미설치, 음향신호기 부재 등 시각장애인 특유의 사고원인과 피해를 강조합니다.', 46000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/73.png', 112, 25, 0),
                                                                                                                                            (74, 34, 3, 'EDITOR', '교통약자 분할합의서', '교통약자가 치료과정에서 단계적으로 합의하는 AI 인터뷰 합의서입니다. 즉시 필요한 치료비와 향후 발생할 재활비용을 구분하여 안전하게 합의할 수 있도록 구성합니다.', 35000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/74.png', 167, 12, 0),
                                                                                                                                            (75, 34, 6, 'FILE', '휠체어 이용자 사고 배상청구서', '휠체어 이용자의 교통사고 피해배상을 청구하는 전문서면입니다. 휠체어 손해, 이동권 침해, 접근성 제약 등 휠체어 이용자 특유의 피해항목을 반영하여 배상을 요구합니다.', 43000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/75.png', 145, 20, 0),
                                                                                                                                            (76, 34, 4, 'EDITOR', '교통약자 행정심판 신청서', '교통약자 관련 행정처분에 대해 행정심판을 신청하는 AI 인터뷰 템플릿입니다. 교통약자 보호시설 미비, 접근권 침해 등에 대한 행정기관의 부작위를 다투는 심판을 신청합니다.', 41000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/76.png', 123, 18, 0),
                                                                                                                                            (77, 34, 6, 'EDITOR', '유모차 동반 사고 배상청구서', '유모차를 동반한 상태에서 발생한 교통사고의 피해배상을 청구하는 AI 인터뷰 템플릿입니다. 영유아 보호의무와 육아용품 손해까지 포함하여 종합적인 배상을 요구합니다.', 37000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/77.png', 198, 15, 0),
                                                                                                                                            (78, 34, 5, 'EDITOR', '교통약자 보호시설 미비 책임추궁서', '교통약자 보호시설 미비로 인한 사고의 시설관리자 책임을 추궁하는 AI 인터뷰 템플릿입니다. 점자블록, 음향신호기, 경사로 등 필수시설 부재에 따른 관리책임을 강력히 요구합니다.', 48000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/78.png', 167, 22, 0),
                                                                                                                                            (79, 34, 6, 'FILE', '다문화가정 교통사고 배상청구서', '다문화가정 구성원의 교통사고 피해배상을 청구하는 전문서면입니다. 언어소통의 어려움, 문화적 차이, 사회적 약자로서의 특수성을 고려하여 적정한 배상을 요구합니다.', 39000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/79.png', 134, 18, 0),
                                                                                                                                            (80, 34, 3, 'EDITOR', '교통약자 우선배려 조정신청서', '교통약자 사고의 신속한 해결을 위해 우선배려 조정을 신청하는 AI 인터뷰 템플릿입니다. 교통약자의 경제적 어려움과 신속한 치료 필요성을 강조하여 우선처리를 요구합니다.', 36000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/80.png', 189, 15, 0);

-- tmpl_file_based INSERT문들
INSERT INTO tmpl_file_based (no, path_json) VALUES
                                                (1, '[{"originalName":"교통사고_발생신고서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/f1a2b3c4-d5e6-7890-1234-567890abcdef.pdf"},{"originalName":"현장보존_체크리스트.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/a1b2c3d4-e5f6-7890-abcd-ef1234567890.pdf"}]'),
                                                (3, '[{"originalName":"교통사고_손해배상_합의서.docx","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/b2c3d4e5-f6a7-8901-2345-678901bcdefg.pdf"}]'),
                                                (5, '[{"originalName":"과실비율_재검토_신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/c3d4e5f6-a7b8-9012-3456-789012cdefgh.pdf"}]'),
                                                (7, '[{"originalName":"교통사고_현장조사_의뢰서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/d4e5f6a7-b8c9-0123-4567-890123defghi.pdf"}]'),
                                                (9, '[{"originalName":"무보상_합의서.docx","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/e5f6a7b8-c9d0-1234-5678-901234efghij.pdf"}]'),
                                                (11, '[{"originalName":"신호위반_과실비율_이의서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/f6a7b8c9-d0e1-2345-6789-012345fghijk.pdf"}]'),
                                                (13, '[{"originalName":"교통사고_증인신문_신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/a7b8c9d0-e1f2-3456-7890-123456ghijkl.pdf"}]'),
                                                (15, '[{"originalName":"교통사고_분할합의서.docx","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/b8c9d0e1-f2a3-4567-8901-234567hijklm.pdf"}]'),
                                                (17, '[{"originalName":"차선변경_과실분쟁_조정신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/c9d0e1f2-a3b4-5678-9012-345678ijklmn.pdf"}]'),
                                                (19, '[{"originalName":"교통사고_감정서_신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/31/templates/d0e1f2a3-b4c5-6789-0123-456789jklmno.pdf"}]'),
                                                (21, '[{"originalName":"음주운전_행정처분_이의신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/32/templates/e1f2a3b4-c5d6-7890-1234-567890klmnop.pdf"}]'),
                                                (24, '[{"originalName":"음주운전_정상참작_탄원서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/32/templates/f2a3b4c5-d6e7-8901-2345-678901lmnopq.pdf"}]'),
                                                (25, '[{"originalName":"대리운전_이용증명서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/32/templates/a3b4c5d6-e7f8-9012-3456-789012mnopqr.pdf"}]'),
                                                (28, '[{"originalName":"음주운전_현장_대응_매뉴얼.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/32/templates/b4c5d6e7-f8a9-0123-4567-890123nopqrs.pdf"}]'),
                                                (30, '[{"originalName":"음주운전_전력_조회_신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/32/templates/c5d6e7f8-a9b0-1234-5678-901234opqrst.pdf"}]'),
                                                (32, '[{"originalName":"음주운전_목격자_진술서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/32/templates/d6e7f8a9-b0c1-2345-6789-012345pqrstu.pdf"}]'),
                                                (34, '[{"originalName":"음주운전_보험처리_신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/32/templates/e7f8a9b0-c1d2-3456-7890-123456qrstuv.pdf"}]'),
                                                (36, '[{"originalName":"약물복용_음주측정_영향_소명서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/32/templates/f8a9b0c1-d2e3-4567-8901-234567rstuvw.pdf"}]'),
                                                (39, '[{"originalName":"음주운전_사고조사서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/32/templates/a9b0c1d2-e3f4-5678-9012-345678stuvwx.pdf"}]'),
                                                (41, '[{"originalName":"중대사고_손해배상청구서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/33/templates/b0c1d2e3-f4a5-6789-0123-456789tuvwxy.pdf"}]'),
                                                (43, '[{"originalName":"중대사고_합의조건서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/33/templates/c1d2e3f4-a5b6-7890-1234-567890uvwxyz.pdf"}]'),
                                                (46, '[{"originalName":"교통사고_피해자참여_신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/33/templates/d2e3f4a5-b6c7-8901-2345-678901vwxyza.pdf"}]'),
                                                (48, '[{"originalName":"교통사고_피해자_진술서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/33/templates/e3f4a5b6-c7d8-9012-3456-789012wxylab.pdf"}]'),
                                                (51, '[{"originalName":"교통사고_증거보전_신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/33/templates/f4a5b6c7-d8e9-0123-4567-890123xyzabc.pdf"}]'),
                                                (53, '[{"originalName":"교통사고_강제집행_신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/33/templates/a5b6c7d8-e9f0-1234-5678-901234yzabcd.pdf"}]'),
                                                (55, '[{"originalName":"교통사고_과실상계_반박서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/33/templates/b6c7d8e9-f0a1-2345-6789-012345zabcde.pdf"}]'),
                                                (57, '[{"originalName":"교통사고_추가수사_요청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/33/templates/c7d8e9f0-a1b2-3456-7890-123456abcdef.pdf"}]'),
                                                (62, '[{"originalName":"어린이_교통사고_특별배상청구서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/34/templates/d8e9f0a1-b2c3-4567-8901-234567bcdefg.pdf"}]'),
                                                (64, '[{"originalName":"장애인_교통사고_특수배상청구서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/34/templates/e9f0a1b2-c3d4-5678-9012-345678cdefgh.pdf"}]'),
                                                (66, '[{"originalName":"전동휠체어_사고_배상청구서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/34/templates/f0a1b2c3-d4e5-6789-0123-456789defghi.pdf"}]'),
                                                (68, '[{"originalName":"교통약자_배려_합의서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/34/templates/a1b2c3d4-e5f6-7890-1234-567890efghij.pdf"}]'),
                                                (70, '[{"originalName":"교통약자_과실비율_이의신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/34/templates/b2c3d4e5-f6a7-8901-2345-678901fghijk.pdf"}]'),
                                                (72, '[{"originalName":"교통약자_보험금_특별청구서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/34/templates/c3d4e5f6-a7b8-9012-3456-789012ghijkl.pdf"}]'),
                                                (75, '[{"originalName":"휠체어_이용자_사고_배상청구서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/34/templates/d4e5f6a7-b8c9-0123-4567-890123hijklm.pdf"}]'),
                                                (79, '[{"originalName":"다문화가정_교통사고_배상청구서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/lawyers/34/templates/e5f6a7b8-c9d0-1234-5678-901234ijklmn.pdf"}]');

-- tmpl_editor_based INSERT문들
INSERT INTO tmpl_editor_based (no, content, var_json, ai_enabled) VALUES
                                                                      (2, '<h2>중대사고 형사고발장</h2><p>#{피해자 이름} 님이 #{가해자 이름} 님을 업무상과실치사상죄로 고발합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>피해 정도: #{피해 정도}</p>', '[{"name":"피해자 이름","description":"고발하는 분의 성함"},{"name":"가해자 이름","description":"고발당하는 분의 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"피해 정도","description":"상해 정도나 피해 내용"}]', 1),
                                                                      (4, '<h2>자동차보험 이의신청서</h2><p>#{신청인 이름} 님이 보험사의 과실비율 #{기존 과실비율}에 대해 이의를 제기합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>요구사항: #{요구사항}</p>', '[{"name":"신청인 이름","description":"이의신청하는 분의 성함"},{"name":"기존 과실비율","description":"현재 책정된 과실비율"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"요구사항","description":"변경 요구하는 과실비율"}]', 1),
                                                                      (6, '<h2>자전거 사고 손해배상청구서</h2><p>#{피해자 이름} 님이 #{가해자 이름} 님에게 자전거 사고 손해배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>청구 금액: #{청구 금액}</p>', '[{"name":"피해자 이름","description":"자전거 사고 피해자 성함"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"청구 금액","description":"손해배상 청구 금액"}]', 1),
                                                                      (8, '<h2>음주운전 사고 고발장</h2><p>#{피해자 이름} 님이 음주운전 가해자 #{가해자 이름} 님을 위험운전치상죄로 고발합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>혈중알코올농도: #{혈중알코올농도}</p>', '[{"name":"피해자 이름","description":"음주운전 사고 피해자 성함"},{"name":"가해자 이름","description":"음주운전 가해자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"혈중알코올농도","description":"측정된 혈중알코올농도"}]', 1),
                                                                      (10, '<h2>운전면허 정지처분 이의신청서</h2><p>#{신청인 이름} 님이 운전면허 정지처분에 대해 이의를 신청합니다.</p><p>처분 일자: #{처분 일자}</p><p>처분 사유: #{처분 사유}</p><p>이의 사유: #{이의 사유}</p><p>직업: #{직업}</p>', '[{"name":"신청인 이름","description":"이의신청하는 분의 성함"},{"name":"처분 일자","description":"면허 정지처분 날짜"},{"name":"처분 사유","description":"면허 정지 사유"},{"name":"이의 사유","description":"이의제기 근거"},{"name":"직업","description":"신청인의 직업"}]', 1),
                                                                      (12, '<h2>킥보드 사고 배상청구서</h2><p>#{피해자 이름} 님이 #{가해자 이름} 님에게 전동킥보드 사고 손해배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>청구 금액: #{청구 금액}</p>', '[{"name":"피해자 이름","description":"킥보드 사고 피해자 성함"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"청구 금액","description":"손해배상 청구 금액"}]', 1),
                                                                      (14, '<h2>뺑소니 사고 고발장</h2><p>#{피해자 이름} 님이 뺑소니 가해자 #{가해자 이름} 님을 특정사고가중처벌법 위반으로 고발합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>도주 상황: #{도주 상황}</p>', '[{"name":"피해자 이름","description":"뺑소니 사고 피해자 성함"},{"name":"가해자 이름","description":"뺑소니 가해자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"도주 상황","description":"가해자가 도주한 상황"}]', 1),
                                                                      (16, '<h2>자동차보험 약관해석 이의서</h2><p>#{신청인 이름} 님이 보험사의 약관해석에 대해 이의를 제기합니다.</p><p>보험사명: #{보험사명}</p><p>보험 약관: #{보험 약관}</p><p>이의 내용: #{이의 내용}</p><p>요구사항: #{요구사항}</p>', '[{"name":"신청인 이름","description":"이의신청하는 분의 성함"},{"name":"보험사명","description":"보험회사 이름"},{"name":"보험 약관","description":"문제가 된 약관 내용"},{"name":"이의 내용","description":"이의제기 구체적 내용"},{"name":"요구사항","description":"보험사에 요구하는 사항"}]', 1),
                                                                      (18, '<h2>보행자 사고 배상청구서</h2><p>#{피해자 이름} 님이 #{가해자 이름} 님에게 보행자 교통사고 손해배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>청구 금액: #{청구 금액}</p>', '[{"name":"피해자 이름","description":"보행자 사고 피해자 성함"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"청구 금액","description":"손해배상 청구 금액"}]', 1),
                                                                      (20, '<h2>교통사고 업무상과실 고발장</h2><p>#{피해자 이름} 님이 업무용 차량 운전자 #{가해자 이름} 님을 업무상과실치상죄로 고발합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>업무 내용: #{업무 내용}</p>', '[{"name":"피해자 이름","description":"교통사고 피해자 성함"},{"name":"가해자 이름","description":"업무용 차량 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"업무 내용","description":"운전자의 업무 내용"}]', 1);

INSERT INTO tmpl_editor_based (no, content, var_json, ai_enabled) VALUES
                                                                      (22, '<h2>음주운전 형사합의서</h2><p>#{가해자 이름} 님과 #{피해자 이름} 님은 #{사고 일시}에 발생한 음주운전 사고에 대해 형사합의를 체결합니다.</p><p>합의금액: #{합의금액}원</p><p>지급조건: #{지급조건}</p><p>본 합의로 형사 고소를 취하하며 선처를 요구합니다.</p>', '[{"name":"가해자 이름","description":"음주운전 가해자 성함"},{"name":"피해자 이름","description":"음주운전 사고 피해자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"합의금액","description":"형사합의 금액"},{"name":"지급조건","description":"합의금 지급 방법과 일정"}]', 1),
                                                                      (23, '<h2>음주측정 불응 이의신청서</h2><p>#{신청인 이름} 님이 음주측정 거부 처분에 대해 이의를 신청합니다.</p><p>단속 일시: #{단속 일시}</p><p>단속 장소: #{단속 장소}</p><p>불응 사유: #{불응 사유}</p><p>이의 근거: #{이의 근거}</p>', '[{"name":"신청인 이름","description":"이의신청하는 분의 성함"},{"name":"단속 일시","description":"음주단속 날짜와 시간"},{"name":"단속 장소","description":"음주단속 장소"},{"name":"불응 사유","description":"측정을 거부한 사유"},{"name":"이의 근거","description":"처분에 이의를 제기하는 근거"}]', 1),
                                                                      (26, '<h2>음주운전 피해자 합의서</h2><p>#{피해자 이름} 님과 #{가해자 이름} 님은 #{사고 일시}에 발생한 음주운전 사고에 대해 합의합니다.</p><p>배상금액: #{배상금액}원</p><p>지급방법: #{지급방법}</p><p>재발방지 약속: #{재발방지 약속}</p>', '[{"name":"피해자 이름","description":"음주운전 사고 피해자 성함"},{"name":"가해자 이름","description":"음주운전 가해자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"배상금액","description":"손해배상 금액"},{"name":"지급방법","description":"배상금 지급 방법"},{"name":"재발방지 약속","description":"가해자의 재발방지 약속 내용"}]', 1),
                                                                      (27, '<h2>혈중알코올농도 이의신청서</h2><p>#{신청인 이름} 님이 혈중알코올농도 측정결과 #{측정결과}에 대해 이의를 신청합니다.</p><p>측정 일시: #{측정 일시}</p><p>측정 장소: #{측정 장소}</p><p>이의 사유: #{이의 사유}</p>', '[{"name":"신청인 이름","description":"이의신청하는 분의 성함"},{"name":"측정결과","description":"측정된 혈중알코올농도"},{"name":"측정 일시","description":"측정한 날짜와 시간"},{"name":"측정 장소","description":"측정한 장소"},{"name":"이의 사유","description":"측정결과에 대한 이의 사유"}]', 1),
                                                                      (29, '<h2>음주운전 반성문</h2><p>저 #{신청인 이름}은(는) #{사고 일시}에 음주운전으로 사고를 일으킨 것에 대해 깊이 반성합니다.</p><p>반성 내용: #{반성 내용}</p><p>재발방지 계획: #{재발방지 계획}</p><p>앞으로 #{다짐 내용}을(를) 다짐합니다.</p>', '[{"name":"신청인 이름","description":"반성문 작성자 성함"},{"name":"사고 일시","description":"음주운전 사고 날짜와 시간"},{"name":"반성 내용","description":"구체적인 반성 내용"},{"name":"재발방지 계획","description":"재발방지를 위한 구체적 계획"},{"name":"다짐 내용","description":"앞으로의 다짐과 각오"}]', 1),
                                                                      (31, '<h2>직업별 면허필수 소명서</h2><p>#{신청인 이름} 님이 #{직업} 업무 수행을 위한 운전면허 필수성을 소명합니다.</p><p>직업: #{직업}</p><p>업무내용: #{업무내용}</p><p>면허 필요성: #{면허 필요성}</p><p>생계 영향: #{생계 영향}</p>', '[{"name":"신청인 이름","description":"소명서 작성자 성함"},{"name":"직업","description":"현재 직업"},{"name":"업무내용","description":"구체적인 업무 내용"},{"name":"면허 필요성","description":"업무상 운전면허가 필요한 이유"},{"name":"생계 영향","description":"면허취소 시 생계에 미치는 영향"}]', 1),
                                                                      (33, '<h2>음주단속 적법성 이의서</h2><p>#{신청인 이름} 님이 #{단속 일시}에 실시된 음주단속의 적법성에 이의를 제기합니다.</p><p>단속 장소: #{단속 장소}</p><p>단속 경위: #{단속 경위}</p><p>절차상 하자: #{절차상 하자}</p><p>요구사항: #{요구사항}</p>', '[{"name":"신청인 이름","description":"이의신청하는 분의 성함"},{"name":"단속 일시","description":"음주단속 날짜와 시간"},{"name":"단속 장소","description":"음주단속이 이루어진 장소"},{"name":"단속 경위","description":"단속이 이루어진 경위"},{"name":"절차상 하자","description":"단속과정에서의 절차상 문제점"},{"name":"요구사항","description":"이의신청을 통해 요구하는 사항"}]', 1),
                                                                      (35, '<h2>음주운전 가족탄원서</h2><p>#{가족 이름} 님이 #{가해자 이름} 님의 가족으로서 선처를 요청합니다.</p><p>가족관계: #{가족관계}</p><p>가정사정: #{가정사정}</p><p>부양의무: #{부양의무}</p><p>개선노력: #{개선노력}</p>', '[{"name":"가족 이름","description":"탄원서 작성하는 가족 성함"},{"name":"가해자 이름","description":"음주운전자 성함"},{"name":"가족관계","description":"가해자와의 관계"},{"name":"가정사정","description":"구체적인 가정 사정"},{"name":"부양의무","description":"가해자의 부양 의무 사항"},{"name":"개선노력","description":"가족이 도울 개선 노력"}]', 1),
                                                                      (37, '<h2>음주운전 업무상 필요성 소명서</h2><p>#{신청인 이름} 님이 #{사고 일시}의 음주운전이 업무상 불가피했음을 소명합니다.</p><p>업무 상황: #{업무 상황}</p><p>응급성: #{응급성}</p><p>대안 부재: #{대안 부재}</p><p>불가피성: #{불가피성}</p>', '[{"name":"신청인 이름","description":"소명서 작성자 성함"},{"name":"사고 일시","description":"음주운전 사고 날짜와 시간"},{"name":"업무 상황","description":"당시 업무 상황"},{"name":"응급성","description":"응급한 상황이었던 이유"},{"name":"대안 부재","description":"다른 대안이 없었던 이유"},{"name":"불가피성","description":"음주운전이 불가피했던 구체적 사유"}]', 1),
                                                                      (38, '<h2>음주운전 개선계획서</h2><p>#{신청인 이름} 님의 음주운전 재발방지를 위한 개선계획서입니다.</p><p>금주 계획: #{금주 계획}</p><p>상담 치료: #{상담 치료}</p><p>대리운전 이용: #{대리운전 이용}</p><p>가족 지원: #{가족 지원}</p>', '[{"name":"신청인 이름","description":"개선계획서 작성자 성함"},{"name":"금주 계획","description":"금주를 위한 구체적 계획"},{"name":"상담 치료","description":"알코올 상담치료 계획"},{"name":"대리운전 이용","description":"대리운전 이용 약속"},{"name":"가족 지원","description":"가족의 지원 방안"}]', 1),
                                                                      (40, '<h2>음주운전 피해배상 약정서</h2><p>#{가해자 이름} 님이 #{피해자 이름} 님에게 음주운전 사고 피해배상을 약정합니다.</p><p>배상금액: #{배상금액}원</p><p>즉시 지급: #{즉시 지급}원</p><p>분할 조건: #{분할 조건}</p><p>지연 시 조치: #{지연 시 조치}</p>', '[{"name":"가해자 이름","description":"음주운전 가해자 성함"},{"name":"피해자 이름","description":"음주운전 사고 피해자 성함"},{"name":"배상금액","description":"총 배상금액"},{"name":"즉시 지급","description":"즉시 지급할 금액"},{"name":"분할 조건","description":"분할 지급 조건"},{"name":"지연 시 조치","description":"지급 지연 시 취할 조치"}]', 1),
                                                                      (42, '<h2>교통사고 형사처벌 요구서</h2><p>#{피해자 이름} 님이 #{가해자 이름} 님의 엄중한 형사처벌을 요구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>피해 정도: #{피해 정도}</p><p>처벌 요구: #{처벌 요구}</p>', '[{"name":"피해자 이름","description":"형사처벌을 요구하는 피해자 성함"},{"name":"가해자 이름","description":"형사처벌 대상 가해자 성함"},{"name":"사고 일시","description":"교통사고 발생 날짜와 시간"},{"name":"사고 장소","description":"교통사고 발생 장소"},{"name":"피해 정도","description":"피해의 구체적 정도"},{"name":"처벌 요구","description":"요구하는 처벌 수위"}]', 1),
                                                                      (44, '<h2>교통사고 집행유예 반대 의견서</h2><p>#{피해자 이름} 님이 #{가해자 이름} 님의 집행유예에 강력히 반대합니다.</p><p>피해의 중대성: #{피해의 중대성}</p><p>가해자 태도: #{가해자 태도}</p><p>사회적 위험성: #{사회적 위험성}</p><p>실형 요구: #{실형 요구}</p>', '[{"name":"피해자 이름","description":"의견서 제출하는 피해자 성함"},{"name":"가해자 이름","description":"집행유예 대상 가해자 성함"},{"name":"피해의 중대성","description":"피해가 중대한 이유"},{"name":"가해자 태도","description":"가해자의 불성실한 태도"},{"name":"사회적 위험성","description":"가해자의 사회적 위험성"},{"name":"실형 요구","description":"실형을 요구하는 구체적 이유"}]', 1),
                                                                      (45, '<h2>교통사고 중재 신청서</h2><p>#{신청인 이름} 님이 #{상대방 이름} 님과의 교통사고 분쟁에 대해 중재를 신청합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>분쟁 내용: #{분쟁 내용}</p><p>중재 요청: #{중재 요청}</p>', '[{"name":"신청인 이름","description":"중재를 신청하는 분의 성함"},{"name":"상대방 이름","description":"중재 상대방 성함"},{"name":"사고 일시","description":"교통사고 발생 날짜와 시간"},{"name":"사고 장소","description":"교통사고 발생 장소"},{"name":"분쟁 내용","description":"중재가 필요한 분쟁 내용"},{"name":"중재 요청","description":"중재를 통해 해결하고자 하는 사항"}]', 1),
                                                                      (47, '<h2>교통사고 과실비율 전문감정 신청서</h2><p>#{신청인 이름} 님이 #{상대방 이름} 님과의 교통사고 과실비율에 대한 전문감정을 신청합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>현재 과실비율: #{현재 과실비율}</p><p>감정 요청 사유: #{감정 요청 사유}</p>', '[{"name":"신청인 이름","description":"감정을 신청하는 분의 성함"},{"name":"상대방 이름","description":"교통사고 상대방 성함"},{"name":"사고 일시","description":"교통사고 발생 날짜와 시간"},{"name":"사고 장소","description":"교통사고 발생 장소"},{"name":"현재 과실비율","description":"현재 책정된 과실비율"},{"name":"감정 요청 사유","description":"전문감정이 필요한 이유"}]', 1),
                                                                      (49, '<h2>교통사고 상급심 항소이유서</h2><p>#{항소인 이름} 님이 1심 판결에 불복하여 항소합니다.</p><p>1심 판결일: #{1심 판결일}</p><p>1심 판결 내용: #{1심 판결 내용}</p><p>항소 이유: #{항소 이유}</p><p>요구사항: #{요구사항}</p>', '[{"name":"항소인 이름","description":"항소하는 분의 성함"},{"name":"1심 판결일","description":"1심 판결이 내려진 날짜"},{"name":"1심 판결 내용","description":"1심 판결의 주요 내용"},{"name":"항소 이유","description":"항소하는 구체적 이유"},{"name":"요구사항","description":"상급심에서 요구하는 사항"}]', 1),
                                                                      (50, '<h2>교통사고 양형부당 항고서</h2><p>#{항고인 이름} 님이 #{가해자 이름} 님에 대한 양형이 부당하다며 항고합니다.</p><p>선고일: #{선고일}</p><p>선고 내용: #{선고 내용}</p><p>양형 부당 사유: #{양형 부당 사유}</p><p>요구 형량: #{요구 형량}</p>', '[{"name":"항고인 이름","description":"항고하는 피해자 성함"},{"name":"가해자 이름","description":"형을 받은 가해자 성함"},{"name":"선고일","description":"형이 선고된 날짜"},{"name":"선고 내용","description":"선고된 형의 내용"},{"name":"양형 부당 사유","description":"양형이 부당한 이유"},{"name":"요구 형량","description":"요구하는 적정 형량"}]', 1),
                                                                      (52, '<h2>교통사고 국선변호인 해임 신청서</h2><p>#{신청인 이름} 님이 #{가해자 이름} 님의 국선변호인 #{변호사 이름} 변호사의 해임을 신청합니다.</p><p>선정일: #{선정일}</p><p>해임 사유: #{해임 사유}</p><p>피해자 입장: #{피해자 입장}</p><p>요구사항: #{요구사항}</p>', '[{"name":"신청인 이름","description":"해임을 신청하는 피해자 성함"},{"name":"가해자 이름","description":"국선변호인이 선정된 가해자 성함"},{"name":"변호사 이름","description":"해임 대상 국선변호인 성함"},{"name":"선정일","description":"국선변호인이 선정된 날짜"},{"name":"해임 사유","description":"해임을 요구하는 구체적 사유"},{"name":"피해자 입장","description":"피해자 관점에서의 문제점"},{"name":"요구사항","description":"해임을 통해 요구하는 사항"}]', 1),
                                                                      (54, '<h2>교통사고 공소시효 연장 신청서</h2><p>#{신청인 이름} 님이 #{가해자 이름} 님에 대한 공소시효 연장을 신청합니다.</p><p>사고 일시: #{사고 일시}</p><p>공소시효 만료일: #{공소시효 만료일}</p><p>연장 사유: #{연장 사유}</p><p>추가 수사 필요성: #{추가 수사 필요성}</p>', '[{"name":"신청인 이름","description":"시효연장을 신청하는 피해자 성함"},{"name":"가해자 이름","description":"공소시효 대상 가해자 성함"},{"name":"사고 일시","description":"교통사고 발생 날짜와 시간"},{"name":"공소시효 만료일","description":"공소시효가 만료되는 날짜"},{"name":"연장 사유","description":"시효연장이 필요한 이유"},{"name":"추가 수사 필요성","description":"추가 수사가 필요한 구체적 사유"}]', 1),
                                                                      (56, '<h2>교통사고 현장검증 신청서</h2><p>#{신청인 이름} 님이 #{상대방 이름} 님과의 교통사고 현장검증을 신청합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>검증 필요성: #{검증 필요성}</p><p>검증 요청 사항: #{검증 요청 사항}</p>', '[{"name":"신청인 이름","description":"현장검증을 신청하는 분의 성함"},{"name":"상대방 이름","description":"교통사고 상대방 성함"},{"name":"사고 일시","description":"교통사고 발생 날짜와 시간"},{"name":"사고 장소","description":"교통사고 발생 장소"},{"name":"검증 필요성","description":"현장검증이 필요한 이유"},{"name":"검증 요청 사항","description":"검증을 통해 확인하고자 하는 사항"}]', 1),
                                                                      (58, '<h2>교통사고 조정 신청서</h2><p>#{신청인 이름} 님이 #{상대방 이름} 님과의 교통사고 분쟁 조정을 신청합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>분쟁 내용: #{분쟁 내용}</p><p>조정 요청 사항: #{조정 요청 사항}</p>', '[{"name":"신청인 이름","description":"조정을 신청하는 분의 성함"},{"name":"상대방 이름","description":"조정 상대방 성함"},{"name":"사고 일시","description":"교통사고 발생 날짜와 시간"},{"name":"사고 장소","description":"교통사고 발생 장소"},{"name":"분쟁 내용","description":"조정이 필요한 분쟁 내용"},{"name":"조정 요청 사항","description":"조정을 통해 해결하고자 하는 사항"}]', 1),
                                                                      (59, '<h2>교통사고 재심 신청서</h2><p>#{신청인 이름} 님이 #{가해자 이름} 님에 대한 확정판결의 재심을 신청합니다.</p><p>확정판결일: #{확정판결일}</p><p>확정판결 내용: #{확정판결 내용}</p><p>재심 사유: #{재심 사유}</p><p>새로운 증거: #{새로운 증거}</p>', '[{"name":"신청인 이름","description":"재심을 신청하는 분의 성함"},{"name":"가해자 이름","description":"재심 대상 가해자 성함"},{"name":"확정판결일","description":"판결이 확정된 날짜"},{"name":"확정판결 내용","description":"확정된 판결의 주요 내용"},{"name":"재심 사유","description":"재심이 필요한 법적 사유"},{"name":"새로운 증거","description":"새롭게 발견된 증거 내용"}]', 1),
                                                                      (60, '<h2>교통사고 과실비율 재산정 신청서</h2><p>#{신청인 이름} 님이 기존 과실비율 #{기존 과실비율}의 재산정을 신청합니다.</p><p>사고 일시: #{사고 일시}</p><p>새로운 증거: #{새로운 증거}</p><p>재산정 요구 비율: #{재산정 요구 비율}</p><p>재산정 근거: #{재산정 근거}</p>', '[{"name":"신청인 이름","description":"재산정을 신청하는 분의 성함"},{"name":"기존 과실비율","description":"기존에 확정된 과실비율"},{"name":"사고 일시","description":"교통사고 발생 날짜와 시간"},{"name":"새로운 증거","description":"새롭게 확보한 증거"},{"name":"재산정 요구 비율","description":"새로 요구하는 과실비율"},{"name":"재산정 근거","description":"재산정을 요구하는 구체적 근거"}]', 1),
                                                                      (61, '<h2>보행자 교통사고 배상청구서</h2><p>보행자 #{피해자 이름} 님이 #{가해자 이름} 님에게 교통사고 손해배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>피해 정도: #{피해 정도}</p><p>청구 금액: #{청구 금액}</p>', '[{"name":"피해자 이름","description":"보행자 사고 피해자 성함"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"피해 정도","description":"보행자가 입은 피해 정도"},{"name":"청구 금액","description":"손해배상 청구 금액"}]', 1),
                                                                      (63, '<h2>고령자 교통사고 배상청구서</h2><p>고령자 #{피해자 이름} 님(#{나이}세)이 #{가해자 이름} 님에게 교통사고 손해배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>특별 배려사항: #{특별 배려사항}</p><p>청구 금액: #{청구 금액}</p>', '[{"name":"피해자 이름","description":"고령자 피해자 성함"},{"name":"나이","description":"피해자 나이"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"특별 배려사항","description":"고령자로서 특별히 배려받아야 할 사항"},{"name":"청구 금액","description":"손해배상 청구 금액"}]', 1),
                                                                      (65, '<h2>자전거 사고 배상청구서</h2><p>자전거 이용자 #{피해자 이름} 님이 #{가해자 이름} 님에게 교통사고 손해배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>자전거 손해: #{자전거 손해}</p><p>청구 금액: #{청구 금액}</p>', '[{"name":"피해자 이름","description":"자전거 이용자 성함"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"자전거 손해","description":"자전거 및 장비 손해 내용"},{"name":"청구 금액","description":"손해배상 청구 금액"}]', 1),
                                                                      (67, '<h2>전동킥보드 사고 배상청구서</h2><p>전동킥보드 이용자 #{피해자 이름} 님이 #{가해자 이름} 님에게 교통사고 손해배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>킥보드 손해: #{킥보드 손해}</p><p>청구 금액: #{청구 금액}</p>', '[{"name":"피해자 이름","description":"전동킥보드 이용자 성함"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"킥보드 손해","description":"전동킥보드 손해 내용"},{"name":"청구 금액","description":"손해배상 청구 금액"}]', 1),
                                                                      (69, '<h2>스쿨존 사고 가중배상청구서</h2><p>#{피해자 이름} 님이 어린이보호구역 내 교통사고에 대해 #{가해자 이름} 님에게 가중배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>스쿨존 위반사항: #{스쿨존 위반사항}</p><p>가중배상 청구 금액: #{가중배상 청구 금액}</p>', '[{"name":"피해자 이름","description":"스쿨존 사고 피해자 성함"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"어린이보호구역 내 사고 발생 위치"},{"name":"스쿨존 위반사항","description":"어린이보호구역 관련 위반 내용"},{"name":"가중배상 청구 금액","description":"가중배상 청구 금액"}]', 1),
                                                                      (71, '<h2>임산부 교통사고 배상청구서</h2><p>임산부 #{피해자 이름} 님(임신 #{임신 주수}주)이 #{가해자 이름} 님에게 교통사고 손해배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>태아 영향: #{태아 영향}</p><p>특별배상 청구 금액: #{특별배상 청구 금액}</p>', '[{"name":"피해자 이름","description":"임산부 피해자 성함"},{"name":"임신 주수","description":"임신 주수"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"태아 영향","description":"태아에 미친 영향"},{"name":"특별배상 청구 금액","description":"임산부 특별배상 청구 금액"}]', 1),
                                                                      (73, '<h2>시각장애인 교통사고 배상청구서</h2><p>시각장애인 #{피해자 이름} 님이 #{가해자 이름} 님에게 교통사고 손해배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>시각장애 등급: #{시각장애 등급}</p><p>안내견 피해: #{안내견 피해}</p><p>청구 금액: #{청구 금액}</p>', '[{"name":"피해자 이름","description":"시각장애인 피해자 성함"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"시각장애 등급","description":"시각장애 등급"},{"name":"안내견 피해","description":"안내견 피해 여부 및 내용"},{"name":"청구 금액","description":"손해배상 청구 금액"}]', 1),
                                                                      (74, '<h2>교통약자 분할합의서</h2><p>교통약자 #{피해자 이름} 님과 #{가해자 이름} 님이 단계적 분할합의를 체결합니다.</p><p>사고 일시: #{사고 일시}</p><p>1차 합의금: #{1차 합의금}원 (즉시 지급)</p><p>2차 합의 조건: #{2차 합의 조건}</p><p>치료 종료 후 최종 정산: #{최종 정산 조건}</p>', '[{"name":"피해자 이름","description":"교통약자 피해자 성함"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"1차 합의금","description":"즉시 지급할 1차 합의금"},{"name":"2차 합의 조건","description":"2차 합의 조건"},{"name":"최종 정산 조건","description":"치료 종료 후 최종 정산 조건"}]', 1),
                                                                      (76, '<h2>교통약자 행정심판 신청서</h2><p>#{신청인 이름} 님이 교통약자 보호시설 미비에 대한 행정심판을 신청합니다.</p><p>신청 일자: #{신청 일자}</p><p>대상 기관: #{대상 기관}</p><p>시설 미비 내용: #{시설 미비 내용}</p><p>개선 요구사항: #{개선 요구사항}</p>', '[{"name":"신청인 이름","description":"행정심판 신청자 성함"},{"name":"신청 일자","description":"심판 신청 날짜"},{"name":"대상 기관","description":"심판 대상 행정기관"},{"name":"시설 미비 내용","description":"교통약자 보호시설 미비 내용"},{"name":"개선 요구사항","description":"시설 개선 요구사항"}]', 1),
                                                                      (77, '<h2>유모차 동반 사고 배상청구서</h2><p>유모차 동반 #{피해자 이름} 님이 #{가해자 이름} 님에게 교통사고 손해배상을 청구합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>영유아 피해: #{영유아 피해}</p><p>유모차 손해: #{유모차 손해}</p><p>청구 금액: #{청구 금액}</p>', '[{"name":"피해자 이름","description":"유모차 동반 피해자 성함"},{"name":"가해자 이름","description":"자동차 운전자 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"영유아 피해","description":"영유아가 입은 피해"},{"name":"유모차 손해","description":"유모차 및 육아용품 손해"},{"name":"청구 금액","description":"손해배상 청구 금액"}]', 1),
                                                                      (78, '<h2>교통약자 보호시설 미비 책임추궁서</h2><p>#{신청인 이름} 님이 #{관리기관} 에게 교통약자 보호시설 미비 책임을 추궁합니다.</p><p>사고 일시: #{사고 일시}</p><p>사고 장소: #{사고 장소}</p><p>시설 미비 내용: #{시설 미비 내용}</p><p>관리책임: #{관리책임}</p><p>손해배상 요구: #{손해배상 요구}</p>', '[{"name":"신청인 이름","description":"책임추궁 신청자 성함"},{"name":"관리기관","description":"시설 관리 책임 기관"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"사고 장소","description":"사고 발생 위치"},{"name":"시설 미비 내용","description":"부족한 보호시설 내용"},{"name":"관리책임","description":"관리기관의 책임 내용"},{"name":"손해배상 요구","description":"손해배상 요구 내용"}]', 1),
                                                                      (80, '<h2>교통약자 우선배려 조정신청서</h2><p>교통약자 #{신청인 이름} 님이 #{상대방 이름} 님과의 분쟁에 대해 우선배려 조정을 신청합니다.</p><p>사고 일시: #{사고 일시}</p><p>교통약자 유형: #{교통약자 유형}</p><p>우선처리 사유: #{우선처리 사유}</p><p>조정 요청사항: #{조정 요청사항}</p>', '[{"name":"신청인 이름","description":"교통약자 신청자 성함"},{"name":"상대방 이름","description":"분쟁 상대방 성함"},{"name":"사고 일시","description":"사고 발생 날짜와 시간"},{"name":"교통약자 유형","description":"교통약자 유형 (어린이, 고령자, 장애인 등)"},{"name":"우선처리 사유","description":"우선처리가 필요한 구체적 사유"},{"name":"조정 요청사항","description":"조정을 통해 해결하고자 하는 사항"}]', 1);

-- 서민영 변호사 추가 데이터
INSERT INTO template (no, user_no, category_no, type, name, description, price, thumbnail_path, sales_count, discount_rate, is_deleted) VALUES
                                                                                                                                            (81, 31, 5, 'FILE', '블랙박스 영상기반 과실비율 재감정 신청서', '블랙박스 영상 분석을 통한 과실비율 재감정을 전문기관에 의뢰하는 최고급 신청서입니다. 교통공학 박사 출신 서민영 변호사가 직접 개발한 영상 분석 체크리스트와 속도-시간-거리 계산 공식을 활용하여 0.1초 단위의 정밀 분석을 요구합니다. 특히 3초 미만의 짧은 영상에서도 결정적 증거를 찾아내는 16가지 분석 기법이 포함되어 있으며, 보험사 손해사정사들도 인정하는 과학적 근거로 과실비율 역전 성공률 87%를 자랑합니다. 차량 충돌각도, 제동흔적 길이, 신호등 현시시간까지 모든 요소를 종합한 완벽한 재감정 요구서입니다.', 65000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/81.png', 342, 30, 0),

                                                                                                                                            (82, 31, 1, 'EDITOR', '교통사고 간편 합의서', '교통사고 후 가해자와 피해자가 쉽고 안전하게 합의할 수 있도록 도와주는 AI 인터뷰 템플릿입니다. 복잡한 법률용어 없이 일상 언어로 질문하여 누구나 부담없이 작성할 수 있으며, 치료비, 위자료, 차량수리비 등 꼭 필요한 항목들을 빠뜨리지 않고 정리해드립니다. 특히 "나중에 아픈 곳이 더 생기면 어떡하지?", "혹시 놓친 손해는 없을까?" 같은 일반인들의 걱정을 해소하는 안전장치까지 자동으로 포함됩니다. 어려운 법조문 대신 "○○님과 ○○님은 이렇게 약속합니다"라는 친근한 표현으로 작성되어, 양쪽 모두 이해하기 쉽고 분쟁 없는 깔끔한 합의가 가능합니다.', 35000, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/thumbnails/82.png', 412, 15, 0);


-- 서민영 변호사 추가 데이터 (실제 템플릿 내용)
INSERT INTO tmpl_file_based (no, path_json) VALUES
    (81, '[{"originalName":"과실비율_재감정_신청서.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/%EA%B3%BC%EC%8B%A4%EB%B9%84%EC%9C%A8_%EC%9E%AC%EA%B0%90%EC%A0%95_%EC%8B%A0%EC%B2%AD%EC%84%9C.pdf"},{"originalName":"관련_판례_모음집.pdf","savedPath":"https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/templates/%EA%B4%80%EB%A0%A8_%ED%8C%90%EB%A1%80_%EB%AA%A8%EC%9D%8C%EC%A7%91.pdf"}]');

INSERT INTO tmpl_editor_based (no, content, var_json, ai_enabled) VALUES
    (82,
     '<p>본 합의서는 #{이름} 님(이하 `피해자`)과 #{상대방 이름} 님(이하 `가해자`) 간에 발생한 교통사고에 대한 합의 내용을 담고 있습니다.</p><p></p><p>1. 사고 일시: #{사고 일시}</p><p>2. 사고 장소: #{사고 장소}</p><p></p><p>피해자와 가해자는 본 사고와 관련하여 아래 조건에 따라 상호 간의 민형사상 책임을 묻지 않기로 합의합니다.</p><p></p><p>- 가해자는 피해자에게 합의금으로 총 #{합의금액}원을 지급하며, 피해자는 해당 금액을 수령하는 것을 확인합니다.</p><p>- 피해자는 본 합의금 수령 이후 해당 사고와 관련한 모든 법적 청구(형사 고소, 민사 손해배상 등)를 포기하며, 향후 어떠한 이의도 제기하지 않기로 합니다.</p><p>- 본 합의는 당사자 간의 자유로운 의사에 따라 체결되었으며, 그 효력은 법적으로 유효함을 상호 확인합니다.</p>',

     '[{"name":"이름","description":"홍길동"},{"name":"상대방 이름","description":"김철수"},{"name":"사고 일시","description":"2025.01.01 12:00:00"},{"name":"사고 장소","description":"서울 서초구 삼성동 1117로 사거리"},{"name":"합의금액","description":"400,000원"}]',
     1);


-- 템플릿 주문 내역 (order - 500번대 부터 사용)
INSERT INTO orders (no, order_code, user_no, amount, status, order_type, created_at, updated_at) VALUES
-- 1. 방민영(mybang) - 4번 고객 주문
(500, 'ORD20220620001', 4, 96300, 'PAID', 'TEMPLATE', '2025-06-20 14:22:15', '2025-06-20 14:22:15'),  -- 교통사고 기본 템플릿 3개 (27200+36900+32200)
(501, 'ORD20220621001', 4, 59900, 'PAID', 'TEMPLATE', '2025-06-21 16:33:42', '2025-06-21 16:33:42'),  -- 추가 템플릿 2개 (26600+33300)

-- 2. 서민성(minsungseo) - 5번 고객 주문
(502, 'ORD20221227001', 5, 150370, 'PAID', 'TEMPLATE', '2024-12-27 11:15:33', '2024-12-27 11:15:33'), -- 음주운전 템플릿 4개 (41600+38540+38250+31980)
(503, 'ORD20230115001', 5, 71560, 'PAID', 'TEMPLATE', '2025-01-15 09:44:21', '2025-01-15 09:44:21'),  -- 추가 음주 템플릿 2개 (39360+32200)
(504, 'ORD20230210001', 5, 60700, 'CANCELED', 'TEMPLATE', '2025-02-10 15:22:33', '2025-02-10 15:22:33'), -- 환불 주문 2개 (27550+33150)

-- 3. 강창선(changsun) - 6번 고객 주문
(505, 'ORD20220112001', 6, 106480, 'PAID', 'TEMPLATE', '2025-01-12 13:25:44', '2025-01-12 13:25:44'), -- 과실비율 템플릿 3개 (36000+36080+34400)
(506, 'ORD20220220001', 6, 36960, 'PAID', 'TEMPLATE', '2025-02-20 10:18:55', '2025-02-20 10:18:55'),  -- 단일 템플릿 1개 (36960)

-- 4. 박건희(gunhee) - 7번 고객 주문
(507, 'ORD20221202001', 7, 128210, 'PAID', 'TEMPLATE', '2024-12-02 16:42:18', '2024-12-02 16:42:18'), -- 중대사고 템플릿 3개 (46400+40560+41250)
(508, 'ORD20230120001', 7, 97400, 'PAID', 'TEMPLATE', '2025-01-20 14:33:27', '2025-01-20 14:33:27'),  -- 검찰 출신 변호사 템플릿 2개 (51000+46400)
(509, 'ORD20230205001', 7, 45100, 'CANCELED', 'TEMPLATE', '2025-02-05 11:22:15', '2025-02-05 11:22:15'), -- 환불 주문 1개 (45100)
(513, 'ORD20230228001', 7, 75250, 'PAID', 'TEMPLATE', '2025-02-28 15:33:42', '2025-02-28 15:33:42'),  -- 서민영 변호사 신상품 2개 (45500+29750)

-- 5. 정유진(yujin) - 8번 고객 주문 (채팅 정지 고객)
(510, 'ORD20220817001', 8, 132940, 'PAID', 'TEMPLATE', '2024-08-17 12:44:33', '2024-08-17 12:44:33'), -- 교통약자 템플릿 4개 (34200+35700+33120+29920)
(511, 'ORD20220910001', 8, 67860, 'PAID', 'TEMPLATE', '2024-09-10 16:22:15', '2024-09-10 16:22:15'),  -- 추가 구매 2개 (34320+33540)
(512, 'ORD20220925001', 8, 72100, 'CANCELED', 'TEMPLATE', '2024-09-25 09:15:44', '2024-09-25 09:15:44'); -- 환불 주문 2개 (36900+35200)


-- Payments 테이블 INSERT문 (주문번호 500-513번) - CSV 형식에 맞춤

INSERT INTO payments (no, order_no, payment_key, order_code, amount, status, installment_month, purchased_at, metadata, pg, created_at, updated_at) VALUES
-- 1. 방민영(mybang) - 4번 고객 결제내역
(194, 500, 'tviva20220620001TMP500', 'ORD20220620001', 96300, 'DONE', 0, '2025-06-20 14:23:45', NULL, '카드', '2025-06-20 14:22:15', '2025-06-20 14:23:45'),
(195, 501, 'tviva20220621001TMP501', 'ORD20220621001', 59900, 'DONE', 0, '2025-06-21 16:34:22', NULL, '카드', '2025-06-21 16:33:42', '2025-06-21 16:34:22'),

-- 2. 서민성(minsungseo) - 5번 고객 결제내역
(196, 502, 'tviva20221227001TMP502', 'ORD20221227001', 150370, 'DONE', 3, '2024-12-27 11:16:15', NULL, '카드', '2024-12-27 11:15:33', '2024-12-27 11:16:15'),
(197, 503, 'tviva20230115001TMP503', 'ORD20230115001', 71560, 'DONE', 0, '2025-01-15 09:45:33', NULL, '카드', '2025-01-15 09:44:21', '2025-01-15 09:45:33'),
(198, 504, 'tviva20230210001CAN504', 'ORD20230210001', 60700, 'CANCELED', 0, '2025-02-10 15:23:10', NULL, '카드', '2025-02-10 15:22:33', '2025-02-12 10:15:22'),

-- 3. 강창선(changsun) - 6번 고객 결제내역
(199, 505, 'tviva20220112001TMP505', 'ORD20220112001', 106480, 'DONE', 0, '2025-01-12 13:26:33', NULL, '카드', '2025-01-12 13:25:44', '2025-01-12 13:26:33'),
(200, 506, 'tviva20220220001TMP506', 'ORD20220220001', 36960, 'DONE', 0, '2025-02-20 10:19:44', NULL, '카드', '2025-02-20 10:18:55', '2025-02-20 10:19:44'),

-- 4. 박건희(gunhee) - 7번 고객 결제내역
(201, 507, 'tviva20221202001TMP507', 'ORD20221202001', 128210, 'DONE', 6, '2024-12-02 16:43:55', NULL, '카드', '2024-12-02 16:42:18', '2024-12-02 16:43:55'),
(202, 508, 'tviva20230120001TMP508', 'ORD20230120001', 97400, 'DONE', 0, '2025-01-20 14:34:44', NULL, '카드', '2025-01-20 14:33:27', '2025-01-20 14:34:44'),
(203, 509, 'tviva20230205001CAN509', 'ORD20230205001', 45100, 'CANCELED', 0, '2025-02-05 11:23:22', NULL, '카드', '2025-02-05 11:22:15', '2025-02-07 14:20:30'),
(204, 513, 'tviva20230228001TMP513', 'ORD20230228001', 75250, 'DONE', 0, '2025-02-28 15:34:55', NULL, '카드', '2025-02-28 15:33:42', '2025-02-28 15:34:55'),

-- 5. 정유진(yujin) - 8번 고객 결제내역 (채팅 정지 고객)
(205, 510, 'tviva20220817001TMP510', 'ORD20220817001', 132940, 'DONE', 12, '2024-08-17 12:45:22', NULL, '카드', '2024-08-17 12:44:33', '2024-08-17 12:45:22'),
(206, 511, 'tviva20220910001TMP511', 'ORD20220910001', 67860, 'DONE', 0, '2024-09-10 16:23:33', NULL, '카드', '2024-09-10 16:22:15', '2024-09-10 16:23:33'),
(207, 512, 'tviva20220925001CAN512', 'ORD20220925001', 72100, 'CANCELED', 0, '2024-09-25 09:16:22', NULL, '카드', '2024-09-25 09:15:44', '2024-09-27 16:30:15');


-- 템플릿 주문 상세 내역
-- 1. 방민영(mybang) - 4번 고객 주문내역
INSERT INTO tmpl_orders_history (no, tmpl_no, order_no, price, is_downloaded, created_at, updated_at) VALUES
-- 주문 500번: 교통사고 관련 기본 템플릿 3개 구매
(1, 1, 500, 27200, 1, '2025-06-20 14:22:15', '2025-06-22 10:15:30'),  -- 교통사고 발생신고서 (할인가: 32000*0.85)
(2, 3, 500, 36900, 0, '2025-06-20 14:22:15', '2025-06-20 14:22:15'),  -- 교통사고 손해배상 합의서 (할인가: 45000*0.82)
(3, 7, 500, 32200, 1, '2025-06-20 14:22:15', '2025-06-21 09:45:20'),  -- 교통사고 현장조사 의뢰서 (할인가: 35000*0.92)

-- 주문 501번: 추가 템플릿 구매
(4, 9, 501, 26600, 0, '2025-06-21 16:33:42', '2025-06-21 16:33:42'),  -- 무보상 합의서 (할인가: 28000*0.95)
(5, 13, 501, 33300, 0, '2025-06-21 16:33:42', '2025-06-21 16:33:42'); -- 교통사고 증인신문 신청서 (할인가: 37000*0.90)

-- 2. 서민성(minsungseo) - 5번 고객 주문내역
INSERT INTO tmpl_orders_history (no, tmpl_no, order_no, price, is_downloaded, created_at, updated_at) VALUES
-- 주문 502번: 음주운전 관련 템플릿 대량 구매
(6, 21, 502, 41600, 1, '2024-12-27 11:15:33', '2025-01-05 14:22:10'),  -- 음주운전 행정처분 이의신청서 (할인가: 52000*0.80)
(7, 22, 502, 38540, 0, '2024-12-27 11:15:33', '2024-12-27 11:15:33'),  -- 음주운전 형사합의서 (할인가: 47000*0.82)
(8, 23, 502, 38250, 1, '2024-12-27 11:15:33', '2024-12-28 16:45:22'),  -- 음주측정 불응 이의신청서 (할인가: 45000*0.85)
(9, 25, 502, 31980, 0, '2024-12-27 11:15:33', '2024-12-27 11:15:33'),  -- 대리운전 이용증명서 (할인가: 41000*0.78)

-- 주문 503번: 추가 음주 관련 템플릿
(10, 27, 503, 39360, 0, '2025-01-15 09:44:21', '2025-01-15 09:44:21'), -- 혈중알코올농도 이의신청서 (할인가: 48000*0.82)
(11, 28, 503, 32200, 1, '2025-01-15 09:44:21', '2025-01-18 13:20:15'), -- 음주운전 현장 대응 매뉴얼 (할인가: 35000*0.92)

-- 주문 504번: 환불 주문
(12, 30, 504, 27550, 0, '2025-02-10 15:22:33', '2025-02-10 15:22:33'), -- 음주운전 전력 조회 신청서 (할인가: 29000*0.95)
(13, 31, 504, 33150, 0, '2025-02-10 15:22:33', '2025-02-10 15:22:33'); -- 직업별 면허필수 소명서 (할인가: 39000*0.85)

-- 3. 강창선(changsun) - 6번 고객 주문내역
INSERT INTO tmpl_orders_history (no, tmpl_no, order_no, price, is_downloaded, created_at, updated_at) VALUES
-- 주문 505번: 과실비율 관련 템플릿
(14, 5, 505, 36000, 1, '2025-01-12 13:25:44', '2025-01-15 10:30:22'),  -- 과실비율 재검토 신청서 (할인가: 48000*0.75)
(15, 11, 505, 36080, 0, '2025-01-12 13:25:44', '2025-01-12 13:25:44'), -- 신호위반 과실비율 이의서 (할인가: 44000*0.82)
(16, 17, 505, 34400, 1, '2025-01-12 13:25:44', '2025-01-13 08:15:30'), -- 차선변경 과실분쟁 조정신청서 (할인가: 43000*0.80)

-- 주문 506번: 단일 템플릿 구매
(17, 4, 506, 36960, 0, '2025-02-20 10:18:55', '2025-02-20 10:18:55'); -- 자동차보험 이의신청서 (할인가: 42000*0.88)

-- 4. 박건희(gunhee) - 7번 고객 주문내역
INSERT INTO tmpl_orders_history (no, tmpl_no, order_no, price, is_downloaded, created_at, updated_at) VALUES
-- 주문 507번: 중대사고 관련 템플릿
(18, 2, 507, 46400, 1, '2024-12-02 16:42:18', '2024-12-05 11:25:33'),  -- 중대사고 형사고발장 (할인가: 58000*0.80)
(19, 8, 507, 40560, 0, '2024-12-02 16:42:18', '2024-12-02 16:42:18'),  -- 음주운전 사고 고발장 (할인가: 52000*0.78)
(20, 14, 507, 41250, 1, '2024-12-02 16:42:18', '2024-12-03 14:20:45'), -- 뺑소니 사고 고발장 (할인가: 55000*0.75)

-- 주문 508번: 검찰 출신 변호사 템플릿 구매
(21, 41, 508, 51000, 0, '2025-01-20 14:33:27', '2025-01-20 14:33:27'), -- 중대사고 손해배상청구서 (할인가: 68000*0.75)
(22, 42, 508, 46400, 1, '2025-01-20 14:33:27', '2025-01-22 09:15:20'), -- 교통사고 형사처벌 요구서 (할인가: 58000*0.80)

-- 주문 509번: 환불 주문
(23, 44, 509, 45100, 0, '2025-02-05 11:22:15', '2025-02-05 11:22:15'); -- 교통사고 집행유예 반대 의견서 (할인가: 55000*0.82)

-- 5. 정유진(yujin) - 8번 고객 주문내역 (채팅 정지 고객)
INSERT INTO tmpl_orders_history (no, tmpl_no, order_no, price, is_downloaded, created_at, updated_at) VALUES
-- 주문 510번: 교통약자 관련 템플릿 대량 구매
(24, 61, 510, 34200, 1, '2024-08-17 12:44:33', '2024-08-20 15:30:22'),  -- 보행자 교통사고 배상청구서 (할인가: 38000*0.90)
(25, 62, 510, 35700, 0, '2024-08-17 12:44:33', '2024-08-17 12:44:33'),  -- 어린이 교통사고 특별배상청구서 (할인가: 42000*0.85)
(26, 65, 510, 33120, 1, '2024-08-17 12:44:33', '2024-08-18 10:15:44'),  -- 자전거 사고 배상청구서 (할인가: 36000*0.92)
(27, 67, 510, 29920, 0, '2024-08-17 12:44:33', '2024-08-17 12:44:33'),  -- 전동킥보드 사고 배상청구서 (할인가: 34000*0.88)

-- 주문 511번: 추가 구매
(28, 63, 511, 34320, 0, '2024-09-10 16:22:15', '2024-09-10 16:22:15'),  -- 고령자 교통사고 배상청구서 (할인가: 39000*0.88)
(29, 69, 511, 33540, 1, '2024-09-10 16:22:15', '2024-09-12 13:45:30'),  -- 스쿨존 사고 가중배상청구서 (할인가: 43000*0.78)

-- 주문 512번: 환불 처리된 주문
(30, 64, 512, 36900, 0, '2024-09-25 09:15:44', '2024-09-25 09:15:44'),  -- 장애인 교통사고 특수배상청구서 (할인가: 45000*0.82)
(31, 71, 512, 35200, 0, '2024-09-25 09:15:44', '2024-09-25 09:15:44'), -- 임산부 교통사고 배상청구서 (할인가: 44000*0.80)

-- 박건희(gunhee) 추가 주문 - 서민영 변호사 신상품 구매
-- 주문 513번: 서민영 변호사 신규 템플릿 구매
(32, 81, 513, 45500, 1, '2025-02-28 15:33:42', '2025-03-02 10:15:30'),  -- 블랙박스 영상 기반 과실비율 재감정 신청서 (할인가: 65000*0.70)
(33, 82, 513, 29750, 0, '2025-02-28 15:33:42', '2025-02-28 15:33:42'); -- 교통사고 간편 합의서 (할인가: 35000*0.85)



-- 광고 관련 orders 테이블 더미 데이터
INSERT INTO orders (
    no, user_no, amount, status, order_type, created_at, updated_at, order_code
) VALUES
-- 서민영 (2024-07 ~ 2025-07, 총 13건)
(989, 31, 400000, 'PAID', 'ADVERTISEMENT', '2024-06-25 00:00:00', '2024-06-25 00:00:00', 'ADS-dde95c7affa54d64'),
(990, 31, 400000, 'PAID', 'ADVERTISEMENT', '2024-07-25 00:00:00', '2024-07-25 00:00:00', 'ADS-f24e7a3c9bb64fd2'),
(991, 31, 400000, 'PAID', 'ADVERTISEMENT', '2024-08-25 00:00:00', '2024-08-25 00:00:00', 'ADS-431c4b10ab694f29'),
(992, 31, 400000, 'PAID', 'ADVERTISEMENT', '2024-09-25 00:00:00', '2024-09-25 00:00:00', 'ADS-9bc56f8fdbcf4567'),
(993, 31, 400000, 'PAID', 'ADVERTISEMENT', '2024-10-25 00:00:00', '2024-10-25 00:00:00', 'ADS-0ee58ea2cae548b1'),
(994, 31, 400000, 'PAID', 'ADVERTISEMENT', '2024-11-25 00:00:00', '2024-11-25 00:00:00', 'ADS-a17bf678e2324720'),
(995, 31, 400000, 'PAID', 'ADVERTISEMENT', '2024-12-22 00:00:00', '2024-12-22 00:00:00', 'ADS-cf43db5f88e9493d'),
(996, 31, 400000, 'PAID', 'ADVERTISEMENT', '2025-01-25 00:00:00', '2025-01-25 00:00:00', 'ADS-3b61fa9c3a5f4d9f'),
(997, 31, 400000, 'PAID', 'ADVERTISEMENT', '2025-02-25 00:00:00', '2025-02-25 00:00:00', 'ADS-75984bc5c27c4a87'),
(998, 31, 400000, 'PAID', 'ADVERTISEMENT', '2025-03-25 00:00:00', '2025-03-25 00:00:00', 'ADS-05ddc24eb19749b5'),
(999, 31, 400000, 'PAID', 'ADVERTISEMENT', '2025-04-25 00:00:00', '2025-04-25 00:00:00', 'ADS-62216f89e1c54f44'),
(1000, 31, 400000, 'PAID', 'ADVERTISEMENT', '2025-05-25 00:00:00', '2025-05-25 00:00:00', 'ADS-8f93dcb346d741b9'),
(1001, 31, 400000, 'PAID', 'ADVERTISEMENT', '2025-06-25 00:00:00', '2025-06-25 00:00:00', 'ADS-22decbf71f784890'),

-- 배서연 (1건, 메인 광고)
(1002, 32, 300000, 'PAID', 'ADVERTISEMENT', '2025-06-20 00:00:00', '2025-06-20 00:00:00', 'ADS-77c8efbcf9434bb7'),

-- 한도현 (1건, 서브 광고)
(1003, 33, 150000, 'PAID', 'ADVERTISEMENT', '2025-06-25 00:00:00', '2025-06-25 00:00:00', 'ADS-178ae298e8cd49e4'),

-- 김수현 (1건, 서브 광고)
(1004, 34, 150000, 'PAID', 'ADVERTISEMENT', '2025-06-25 00:00:00', '2025-06-25 00:00:00', 'ADS-95b7a7eac1b341d3');


-- payments 더미 데이터
INSERT INTO payments (
    order_no, payment_key, order_code, amount,
    status, installment_month, purchased_at,
    metadata, pg, created_at, updated_at
) VALUES
-- 서민영 광고 결제 (13건)
(989, 'tviva20240625000001Abcde', 'ADS-dde95c7affa54d64', 400000, 'DONE', NULL, '2024-06-25 00:00:00', NULL, '카드', '2024-06-25 00:00:00', '2024-06-25 00:00:00'),
(990, 'tviva20240725000002Bcdef', 'ADS-f24e7a3c9bb64fd2', 400000, 'DONE', NULL, '2024-07-25 00:00:00', NULL, '카드', '2024-07-25 00:00:00', '2024-07-25 00:00:00'),
(991, 'tviva20240825000003Cdefg', 'ADS-431c4b10ab694f29', 400000, 'DONE', NULL, '2024-08-25 00:00:00', NULL, '카드', '2024-08-25 00:00:00', '2024-08-25 00:00:00'),
(992, 'tviva20240925000004Defgh', 'ADS-9bc56f8fdbcf4567', 400000, 'DONE', NULL, '2024-09-25 00:00:00', NULL, '카드', '2024-09-25 00:00:00', '2024-09-25 00:00:00'),
(993, 'tviva20241025000005Efghi', 'ADS-0ee58ea2cae548b1', 400000, 'DONE', NULL, '2024-10-25 00:00:00', NULL, '카드', '2024-10-25 00:00:00', '2024-10-25 00:00:00'),
(994, 'tviva20241125000006Fghij', 'ADS-a17bf678e2324720', 400000, 'DONE', NULL, '2024-11-25 00:00:00', NULL, '카드', '2024-11-25 00:00:00', '2024-11-25 00:00:00'),
(995, 'tviva20241222000007Ghijk', 'ADS-cf43db5f88e9493d', 400000, 'DONE', NULL, '2024-12-22 00:00:00', NULL, '카드', '2024-12-22 00:00:00', '2024-12-22 00:00:00'),
(996, 'tviva20250125000008Hijkl', 'ADS-3b61fa9c3a5f4d9f', 400000, 'DONE', NULL, '2025-01-25 00:00:00', NULL, '카드', '2025-01-25 00:00:00', '2025-01-25 00:00:00'),
(997, 'tviva20250225000009Ijklm', 'ADS-75984bc5c27c4a87', 400000, 'DONE', NULL, '2025-02-25 00:00:00', NULL, '카드', '2025-02-25 00:00:00', '2025-02-25 00:00:00'),
(998, 'tviva20250325000010Jklmn', 'ADS-05ddc24eb19749b5', 400000, 'DONE', NULL, '2025-03-25 00:00:00', NULL, '카드', '2025-03-25 00:00:00', '2025-03-25 00:00:00'),
(999, 'tviva20250425000011Klmno', 'ADS-62216f89e1c54f44', 400000, 'DONE', NULL, '2025-04-25 00:00:00', NULL, '카드', '2025-04-25 00:00:00', '2025-04-25 00:00:00'),
(1000, 'tviva20250525000012Lmnoa', 'ADS-8f93dcb346d741b9', 400000, 'DONE', NULL, '2025-05-25 00:00:00', NULL, '카드', '2025-05-25 00:00:00', '2025-05-25 00:00:00'),
(1001, 'tviva20250625000013Mnoab', 'ADS-22decbf71f784890', 400000, 'DONE', NULL, '2025-06-25 00:00:00', NULL, '카드', '2025-06-25 00:00:00', '2025-06-25 00:00:00'),

-- 배서연 광고 결제
(1002, 'tviva20250620000014Noabc', 'ADS-77c8efbcf9434bb7', 300000, 'DONE', NULL, '2025-06-20 00:00:00', NULL, '카드', '2025-06-20 00:00:00', '2025-06-20 00:00:00'),

-- 한도현 광고 결제
(1003, 'tviva20250625000015Opabc', 'ADS-178ae298e8cd49e4', 150000, 'DONE', NULL, '2025-06-25 00:00:00', NULL, '카드', '2025-06-25 00:00:00', '2025-06-25 00:00:00'),

-- 김수현 광고 결제
(1004, 'tviva20250625000016Pqabc', 'ADS-95b7a7eac1b341d3', 150000, 'DONE', NULL, '2025-06-25 00:00:00', NULL, '카드', '2025-06-25 00:00:00', '2025-06-25 00:00:00');


-- 서민영 변호사의 - 과거 광고 내역
INSERT INTO ad_purchase (
    orders_no, user_no, ad_path, ad_type,
    main_text, detail_text, tip_text,
    start_date, end_date,
    ad_status, approval_status, created_at, updated_at
) VALUES
-- 2024-07
(989, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2024-07-01 00:00:00', '2024-07-31 23:59:59',
 0, 'APPROVED', '2024-06-25 00:00:00', '2024-06-25 00:00:00'),

-- 2024-08
(990, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2024-08-01 00:00:00', '2024-08-31 23:59:59',
 0, 'APPROVED', '2024-07-25 00:00:00', '2024-07-25 00:00:00'),

-- 2024-09
(991, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2024-09-01 00:00:00', '2024-09-30 23:59:59',
 0, 'APPROVED', '2024-08-25 00:00:00', '2024-08-25 00:00:00'),

-- 2024-10
(992, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2024-10-01 00:00:00', '2024-10-31 23:59:59',
 0, 'APPROVED', '2024-09-25 00:00:00', '2024-09-25 00:00:00'),

-- 2024-11
(993, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2024-11-01 00:00:00', '2024-11-30 23:59:59',
 0, 'APPROVED', '2024-10-25 00:00:00', '2024-10-25 00:00:00'),

-- 2024-12
(994, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2024-12-01 00:00:00', '2024-12-31 23:59:59',
 0, 'APPROVED', '2024-11-25 00:00:00', '2024-11-25 00:00:00'),

-- 2025-01
(995, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2025-01-01 00:00:00', '2025-01-31 23:59:59',
 0, 'APPROVED', '2024-12-22 00:00:00', '2024-12-22 00:00:00'),

-- 2025-02
(996, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2025-02-01 00:00:00', '2025-02-28 23:59:59',
 0, 'APPROVED', '2025-01-25 00:00:00', '2025-01-25 00:00:00'),

-- 2025-03
(997, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2025-03-01 00:00:00', '2025-03-31 23:59:59',
 0, 'APPROVED', '2025-02-25 00:00:00', '2025-02-25 00:00:00'),

-- 2025-04
(998, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2025-04-01 00:00:00', '2025-04-30 23:59:59',
 0, 'APPROVED', '2025-03-25 00:00:00', '2025-03-25 00:00:00'),

-- 2025-05
(999, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2025-05-01 00:00:00', '2025-05-31 23:59:59',
 0, 'APPROVED', '2025-04-25 00:00:00', '2025-04-25 00:00:00'),

-- 2025-06
(1000, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2025-06-01 00:00:00', '2025-06-30 23:59:59',
 0, 'APPROVED', '2025-05-25 00:00:00', '2025-05-25 00:00:00');

-- 광고 더미 데이터 (활성 데이터만 존재)
INSERT INTO ad_purchase (
    orders_no, user_no, ad_path, ad_type,
    main_text, detail_text, tip_text,
    start_date, end_date,
    ad_status, approval_status, created_at, updated_at
) VALUES

-- 서민영 (과실 비율·블랙박스 전문)
(1001, 31, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main5.png', 'MAIN',
 '블랙박스 3초로 억울한 과실 뒤집기',
 '보험사 과실 주장, 영상 증거로 반박해드립니다',
 '블랙박스 직접 분석 대응',
 '2025-06-29 00:00:00', '2025-07-31 23:59:59',
 1, 'APPROVED', '2025-06-25 00:00:00', '2025-06-25 00:00:00'),

-- 배서연 (형사 + 행정처분 동시 대응)
(1002, 32, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/main/main4.png', 'MAIN',
 '음주·무면허, 행정처분까지 방어',
 '형사 재판부터 면허취소 대응까지 한 번에 맡기세요',
 '초기부터 직접 변호합니다',
 '2025-06-29 00:00:00', '2025-07-31 23:59:59',
 1, 'APPROVED', '2025-06-20 00:00:00', '2025-06-20 00:00:00'),

-- 한도현 (사망사고·유족 대리)
(1003, 33, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/sub/sub5.png', 'SUB',
 '사망사고 유족대리, 실질 보상까지',
 '검찰 경력으로 가해자·보험사 철저히 압박합니다',
 '유족 곁에서 끝까지 함께',
 '2025-06-29 00:00:00', '2025-07-31 23:59:59',
 1, 'APPROVED', '2025-06-25 00:00:00', '2025-06-25 00:00:00'),

-- 김수현 (보행자·차량 외 사고 집중)
(1004, 34, 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/sub/sub2.png', 'SUB',
 '킥보드·보행자 사고도 강하게 대응',
 'CCTV·현장자료로 차량 외 사고의 책임을 밝힙니다',
 '현장부터 변호사가 확인',
 '2025-06-29 00:00:00', '2025-07-31 23:59:59',
 1, 'APPROVED', '2025-06-25 00:00:00', '2025-06-25 00:00:00');

-- 게시글 (의뢰인이 작성한)
INSERT INTO board (no, category_no, user_no, title, content, incident_date, created_at, updated_at)
VALUES
    (1, 1, 4, '교통사고 채무부존재 소송 준비서면 작성 가이드', '안녕하세요 비접촉 교통사고로 채무부존재소를 진행 중입니다. 제가 원고이며, 오늘이 변론기일이었는데 어제 피고가 진단서와 교통사고사실확인증명원을 증빙서류로 제출하였더라고요 (아주 의도적이죠) 그래서 저도 미리 진단서를 반박하는 준비서면을 만들어두었는데 교통사고사실확인원에 대한 준비서면은 없어서 여쭤봅니다
1. 교통사고사실확인원은 말그대로 교통사고 사실을 알려주는 서류이지 상대가 상해를 입었다는 직접적인 증거는 아니지 않나요? 이를 토대로 준비서면에 내용울 추가해도 될까요?
2. 피고는 비접촉사고(라고 주장 ㅎ)로 저에게 교통특례법위반(치상)으로 형사소송을 냈으나 저는 불송치 (혐의없음, 증거불충분)으로 형사적으로 상해를 입힌게 없다고 이미 증명되었고, 상대는 사고 직후 저에게 보복운전을 가하여 검찰송치 후 구약식으로 벌금 200만원+운전정지 100일을 처분 받았습니다 이점은 이미 소장에 다 작성했고요, 아마 피고가 저 교통사고사실원을 낸게 과실을 저에게 돌리려고 하는 듯 한데 이건 어떻게 보시나요?
3. 피고가 제출한 진단서는 한의원에서 발급받은 것으로 염좌및긴장이 전부이고 진단일자도 사고 이틀 뒤인 4/4로 되어 있습니다 이 진단서 이외에 통원기록서라던지 검사서라던지 자료는 하나도 없습니다. 또한 자녀가 2명 있는데 한명은 사고당시 0세, 만 4세였고 진단명이 0세는 경계, 4세는 경계와 염좌및긴장인데 상식적으로도 저 나이의 아이들이 의사에게 어디가 아프다라고 직접 이야기 했다고 생각되지 않으며 부모의 일방적이고 추상적인 진술로 의사가 작성했다고 생각되는데 이 내용을 준비서면에 작성해도 될까요?
4. 피고의 답변서를 보면 사고 당시 운전할때 0세 아이는 와이프가 안고 있었고, 4세 아이는 카시트에 앉혔으나 안전벨트를 매지 않았다고 작성했습니다 이를 근거로 피고는 도로교통법 제50조 1항을 위반했으며 이는 부모의 과실이지 원고에게 책임을 전가하면 안된다라고 작성해도 될까요?
답변 부탁드립니다', '2024-04-14', '2024-04-19 00:00:00', '2024-04-23 00:00:00'),
    (2, 1, 5, '골목길 차량 교통사고 상담', '골목길에서 차와 교통사고가 났습니다.
세게 부딪힌거는 아니어서 일단 명함 및 차량 번호만 확인했는데, 차주가 핸드폰을 보며 운전한 것처럼 보였습니다.
현재 멍든 것 같은 느낌과 함께 다리에 통증이 있으며, 오늘은 늦은 밤이기에 내일 병원 또는 한의원을 갈 예정입니다.
혹시 이후 어떻게 해야되는지, 무엇을 요구 할 수 있는지 알 수 있을까요??
사회초년생이라 자세한 답변해 주시면 감사하겠습니다.', '2023-09-30', '2023-10-05 00:00:00', '2023-10-10 00:00:00'),
    (3, 1, 2, '교통사고 후 기억 상실과 증거 효력에 대한 고민', ' 교통사고 발생 이후 약 22일 경과했으며, 사고 당시에 피해자는 두통, 어지러움 등의 증상이 없어서 몰랐습니다.
 발 염좌 및 긴장 진단, 요추염좌 진단 치료받던 중 발 염좌 및 긴장 은 추가진단 받았습니다.
 머리에 외상이 없어서 몰랐는데 시간이 지나면서 교통사고 당시 일부 기억이 불확실해지고, 구급대원의 진술 등 부분적인 정보로 인해 혼란을 겪고 있습니다.
 피해자는 정신건강의학과 진료를 받으려고 했지만 자동차보험 적용이 되지 않아 어려움을 겪었습니다.
 교통사고 직후 기억이 없거나 일부 착각이 있어 정확한 상황 파악이 어려운 상황입니다.
 22일 가량 지나서 피해자는 교통사고 직후 기억 상실 증상을 겪고 있는 것 같습니다.
지금이라도 진단 받으면 증거 효력이 있습니까?', '2022-08-17', '2022-08-19 00:00:00', '2022-08-21 00:00:00'),
    (4, 1, 5, '교통사고특례법(치상) 관련 문의', '아버지가 횡단보도를 건너는 보행자를 보지 못하고 발생한 교통사고로 교통사고특례법(치상)입니다. 횡단보도는 신호가 없는 상시 신호등이고요. 피해자는 진단 6주 골절이고요. 경찰서 조사 마치고 2,000만원에 형사 합의도 마쳤습니다.
그 이후 정식재판에 출석하라는 공소장을 받았고,국선변호인이 있어도 도움은 받지 못하였으나 재판일에 보자고 해서 아무말 없이 기일만 기다리고 있었습니다. 저희는 공소사실 전부 인정하며 아무런 이의신청하지 않았습니다. 그런데 갑자기 다음주에 재판인데 국선변호인분이 참석하지 못하겠다며 연기를 하자고 합니다. 연기는 1달 2달이 될지 모르겠다고 하며 선임 취소도 법원에 제출했다고 합니다.
그러나 아버지(70세 이상)가 너무 스트레스를 받으셔서 빨리 재판을 받고 싶어하십니다. 이럴때 대처 방법이 어떻해 해야 될까요.
너무 답답해서 글올려봅니다.', '2024-01-25', '2024-02-04 00:00:00', '2024-02-06 00:00:00'),
    (5, 1, 4, '교통사고 손해배상 소송에 대한 상담', '안녕하세요저는 현재 25살의 취업준비생입니다..
혼자 살고 있고, 큰아버지의 명의로된 아파트에서 살고 있습니다어머니는 5살때 가출하셔서 안계십니다
저의 아버지(63년생)가 2018년 09월28일 무면허 트럭 운전자에게 뺑소니 교통사고를 당하셔서 병원에 1년간 입원치료중 사망하셨습니다 그이후로 가해자보험사인 화물공제조합과 합의가 잘되지 않아서 현재 손해배상 소송 진행중입니다
화물공제조합 측에서는 내부 의료자문으로아버지의 사망원인이 다발성골절로 인한 폐렴인데
교통사고 이후 1년 있다가 사망한것인데 요양병원으로 전원하여 안정된 상태로 7개월 가까이 있었기 때문에 교통사고와 직접적인 인과관계는 없다고 보는것이 합리적이다 라면서 폐렴의 원인이 오랜 침상생활로 인한 면역력 약화라면서 사망원인이 교통사고랑 직접적인 연관이 없다며 기왕증 70%를 주장하고 아버지의 과실 30%를 주장하면서 손해배상금을 2000만원 밖에 못준다고 했었습니다.
그래서 지금 소송에 이르게 된것이고 변호사분과 상담결과 30%의 과실과 70%의 기왕증도 말이 안되고 일실수입액,과실,기왕증 모두 법원기준대로 처음부터 다시 판단해야한다고 하십니다
그리고 최악의 경우 과실30%와 70%의 기왕증을 전부 상계하더라도 4000만원은 받을수 있다고 말씀하셨습니다 원고 소가로 343,882,170원 으로 소송을 건 상황입니다
이러한 상황에서 제가 소가를 전액 받지 못한다 치더라도 최소 1억정도는 받을수 있지 않을까요? 물론 법원에 판단에 따라야겠지만
1억을 못받을까봐 너무 걱정이 됩니다.. 1억이 제인생에 있어 중요한 돈이라서요.. 1억도 못받을까봐 최근들어 한숨도 못자고 있습니다
소송맡긴 변호사분께 질문드리려니 귀찮게 하는거 같아서 질문드리기가 꺼려져서 로톡에 질문올립니다
긴글 읽어주셔서 감사하고 답변부탁드리겠습니다..', '2024-01-04', '2024-01-09 00:00:00', '2024-01-11 00:00:00'),
    (6, 1, 3, '교통사고로 인한 암환자 사망, 기왕증 비율 소송 가능성', '사건 개요
1. 아버지는 다른 치료 도중 급성 혈액암이 의심되어 사설 구급차를 이용하여 응급이송하게 되었습니다.
2. 구급차가 사이렌을 켜고 양재역 사거리를 통과하던 중(신호 무시) 버스가 후측면을 충돌하였습니다.
3. 동승자였던 딸은 안면 열상, 어머니는 늑골 골절의 부상을 입었습니다. 환자였던 아버지는 응급실 도착 후 의식을 잃었고 이튿날 뇌출혈로 긴급 수술, 이후 출혈이 멈추지 않아 의식을 회복하지 못한 채 한 달 뒤 사망하였습니다.
4. 국과수의 부검 결과, 사인은 "외상성 경막하출혈" 이었고 다만 의견에 "사망에 이르는 과정에서 다발 골수종이 간접적인 영향을 미쳤을 가능성을 완전히 배제하기는 어렵다"라고 합니다.
5. 구급차측 책임 보험사에 보상을 신청하였습니다. 의료기관 1차 자문결과 교통사고 비율을 30%라고 하여 불복. 2차 자문결과 교통사고 비율을 40%라고 합니다.
질문. 아버지는 혈액암 치료조차 받지 못하고 돌아가셨는데 교통 사고 비율이 절반도 되지 않는다는 것이 너무 분하고 억울합니다. 의료 자문 과정에서 유가족의 주장이 반영되지 못한다고 생각하여 소송을 고려하고 있습니다. 소송을 통하여 교통 사고 비율 70%이상을 받아낼 수 있을까요?
참고. 구급차와 버스기사 모두 기소의견으로 검찰에 송치되었고 아직 검찰 조사 중입니다.', '2022-05-12', '2022-05-17 00:00:00', '2022-05-18 00:00:00'),
    (7, 1, 5, '교통사고 후 민사 소송 가능 여부', '안녕하세요. 교통사고 이후 절차가 궁금해 질문남깁니다.
사고는 오토바이대 오토바이인데 경찰에서는 상대방이 신호위반이기에 그렇게 사건을 처리한다고 하여 기다리고 있는 중입니다.
그러나 상대방과 제가 통화를 했을 당시 매우 비협조적이었고 보험처리도 안해준다고 합니다.병원도 다니며 치료를 받았는데,
사건이 끝나면 상대방 보험사에 직접청구를 할 생각인데, 그 외에도 민사적으로 제가 받을 수 있는게 있을까요??', '2023-05-13', '2023-05-17 00:00:00', '2023-05-22 00:00:00'),
    (8, 1, 7, '무면허 교통사고 대물대인 대응 방법', '무면허 교통사고 대인.대물 가해자입니다
자동차종합보험은 가입되어있지만 무면허라 어떻게대응해야될지 모르겠네요 경찰서사건은접수되었습니다 안전지대진입으로 100대0 가해입니다
상대측은 모닝범퍼.휀다.운전석문 파손. 상대측 대인은 2명입니다. 사고즉시 상대측은 몸이아프다하여 응급실로갔구요. 민형사합의 어느정도선으로봐야할까요?
어차피이러나저러나 민형사합의봐도 처벌받을꺼면 과도한금액이면 어떻게되처하나요', '2022-10-21', '2022-10-29 00:00:00', '2022-11-01 00:00:00'),
    (9, 1, 3, '차대차 교통사고 민사조정 대응 방법', '신호위반에 의한 차대차 교통사고로 상대측 과실 100%인 상황에 대해 보험사에서 민사조정 신청을 하였습니다. 지금까지 실제 발생한 치료비가 과도하고 언제까지 치료가 이어질지 알 수 없어 조정을 신청한다는 내용입니다.
보험사가 측정한 인정 치료비와 이미 발생한 치료비가 약 2천만원 차이가 있고 부당하므로 반환요청을 하는데 어떻게 대응하는 것이 가장 현명한 방법일지 문의 드립니다.', '2023-08-31', '2023-09-04 00:00:00', '2023-09-09 00:00:00'),
    (10, 1, 7, '교통사고 경찰조사 결과에 대한 이해', '교통사고로 경찰 조사중에 있습니다.민사는 가해자, 피해자, 쌍방과실 판단이 다 되는것으로 알고 있습니다.
하지만 경찰(형사)은 보통 가해자, 피해자로 나눈다고 하던데 가해자, 피해자 외 쌍방과실로도 경찰조사 결과가 나올수 있나요?
어떤 변호사는 교통사고 경찰조사는 가해자, 피해자 로만 조사결과가 가능하다고 하고 어떤 변호사는 경찰은 가해자, 피해자 외에 서로 쌍방과실로 경찰조사 결과가 나올수도
있다고 해서 서로 말이 달라 어떤것이 정확한 것이지 알려주시면 감사 하겠습니다.', '2024-05-04', '2024-05-06 00:00:00', '2024-05-10 00:00:00'),
    (11, 1, 3, '교통사고처리특례법 피해자 합의', '2월28일에 오토바이로 정상신호에 주행도중 불법 좌회전 택시를 피하다 넘어졌습니다. 경찰의 초기 입장은 과잉 피양이었지만 계속 이의를 제기했고 경찰도 과잉피양은 아닐 것 같다 검찰에 특가법(도주치상)이 아닌 교통사고처리 특례법(신호의반)으로 송치하겠다고 얘기 하였습니다.
이 사고로 전치 2주 진단을 받았습니다. 그런데 택시측 공제에 대인 합의의사를 밝혔지만 교통사고사실 확인원이 나와야 한다고 당장은 합의가 어렵다고 하고 있습니다. 경찰쪽에서 조사를 언제 끝낼지도 모르는 상황에서 이 사고 처리가 길어져 스트레스를 받고 있습니다.
이럴 경우 대인 합의를 제촉할 수단이 있는지와 대인 합의금액은 어느정도가 적당한지, 검찰로 송치가 된다면 형사합의금은 따로 받을 수 없는지, 받을 수 있다면 금액은 얼마나 얘기하면 될지 궁금합니다 ', '2022-11-04', '2022-11-10 00:00:00', '2022-11-14 00:00:00'),
    (12, 6, 4, '신호 위반 차량과 접촉 사고', '저는 아파트 단지 내에서 주차하려던 중, 뒤쪽에서 빠르게 후진해 들어온 차량과 접촉 사고가 났습니다. 현장에는 CCTV가 없어 판단이 애매한데, 제 차량은 서서히 이동 중이었고 상대방이 후진하던 중이었습니다. 이럴 때 과실 비율은 어느 쪽이 더 높게 책정되는지, 실제 사례나 판례가 있는지도 알고 싶습니다.', '2024-01-03', '2024-01-05 00:00:00', '2024-01-10 00:00:00'),
    (13, 4, 7, '신호 위반 차량과 접촉 사고', '저는 아파트 단지 내에서 주차하려던 중, 뒤쪽에서 빠르게 후진해 들어온 차량과 접촉 사고가 났습니다. 현장에는 CCTV가 없어 판단이 애매한데, 제 차량은 서서히 이동 중이었고 상대방이 후진하던 중이었습니다. 이럴 때 과실 비율은 어느 쪽이 더 높게 책정되는지, 실제 사례나 판례가 있는지도 알고 싶습니다.', '2022-06-02', '2022-06-04 00:00:00', '2022-06-09 00:00:00'),
    (14, 2, 8, '신호 위반 차량과 접촉 사고', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2023-09-03', '2023-09-09 00:00:00', '2023-09-13 00:00:00'),
    (15, 1, 6, '비보호 좌회전 중 직진 차량과 충돌', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2023-08-20', '2023-08-28 00:00:00', '2023-09-02 00:00:00'),
    (16, 4, 4, '오토바이와 교차로에서 충돌', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2023-01-06', '2023-01-15 00:00:00', '2023-01-20 00:00:00'),
    (17, 3, 5, '음주운전 조서 작성 관련', '안녕하세요, 최근에 음주운전에 단속되어 오늘 경찰서에 출두하여 조서를 작성했습니다.
조서를 다 마무리한 후 조사관께서 초범이지만, 다시는 음주운전을 하면안된다고 말씀하시면서 조서 뒷편?에 있는 서류 들을 잠깐 보여주셨습니다. 설명해 주시기로 저는 모르겠지만 신고된게 한두건?이 아니라면서 신고된 내역 같은것으로 추정되는 표를 얼핏 보여주셨습니다.(정확하게 서류를 본게 아니라서 횟수나 시기는 잘 모르겠습니다) 적발 단속된 것은 이번이 처음이며, 별도의 대인대물 사고는 없는 단순음주 적발입니다.
1. 이번에 적발된 음주운전과 별개로 음주운전 의심 신고된 횟수?가 이번 처벌에 영향을 미칠 수 있을까요? 조서와 같이 출력해서 첨부한것을 보면, 증빙으로 뭔가를 같이 올리는것 같았습니다.
2. 음주운전 의심 신고된게 이번 음주운전과 관련된게 아니라, 1년 전의 내역이라면 그것이 이번 처벌에 영향을 미칠 수 있을까요?', '2022-09-16', '2022-09-26 00:00:00', '2022-09-27 00:00:00'),
    (18, 6, 6, '비보호 좌회전 중 직진 차량과 충돌', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2024-06-02', '2024-06-09 00:00:00', '2024-06-14 00:00:00'),
    (19, 2, 2, '신호 위반 차량과 접촉 사고', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2023-04-06', '2023-04-13 00:00:00', '2023-04-17 00:00:00'),
    (20, 5, 1, '횡단보도에서 좌회전 차량과 충돌', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2023-09-29', '2023-09-30 00:00:00', '2023-10-02 00:00:00'),
    (21, 6, 1, '주차장에서 후진 중 차량과 사고', '저는 아파트 단지 내에서 주차하려던 중, 뒤쪽에서 빠르게 후진해 들어온 차량과 접촉 사고가 났습니다. 현장에는 CCTV가 없어 판단이 애매한데, 제 차량은 서서히 이동 중이었고 상대방이 후진하던 중이었습니다. 이럴 때 과실 비율은 어느 쪽이 더 높게 책정되는지, 실제 사례나 판례가 있는지도 알고 싶습니다.', '2024-02-28', '2024-03-07 00:00:00', '2024-03-08 00:00:00'),
    (22, 2, 2, '오토바이와 교차로에서 충돌', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2022-04-06', '2022-04-09 00:00:00', '2022-04-14 00:00:00'),
    (23, 3, 4, '우회전 차량이 보행자와 사고 발생', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2023-04-23', '2023-04-26 00:00:00', '2023-05-01 00:00:00'),
    (24, 1, 5, '비보호 좌회전 중 직진 차량과 충돌', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2022-11-17', '2022-11-23 00:00:00', '2022-11-27 00:00:00'),
    (25, 2, 6, '고속도로에서 급정거로 인한 사고', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2023-11-12', '2023-11-14 00:00:00', '2023-11-16 00:00:00'),
    (26, 2, 7, '주차장에서 후진 중 차량과 사고', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2024-01-20', '2024-01-26 00:00:00', '2024-01-27 00:00:00'),
    (27, 3, 2, '횡단보도에서 좌회전 차량과 충돌', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2023-01-05', '2023-01-10 00:00:00', '2023-01-15 00:00:00'),
    (28, 1, 8, '자전거와 교차로에서 접촉 사고', '저는 아파트 단지 내에서 주차하려던 중, 뒤쪽에서 빠르게 후진해 들어온 차량과 접촉 사고가 났습니다. 현장에는 CCTV가 없어 판단이 애매한데, 제 차량은 서서히 이동 중이었고 상대방이 후진하던 중이었습니다. 이럴 때 과실 비율은 어느 쪽이 더 높게 책정되는지, 실제 사례나 판례가 있는지도 알고 싶습니다.', '2023-12-25', '2023-12-30 00:00:00', '2023-12-31 00:00:00'),
    (29, 3, 10, '음주운전과 무면허운전에 대한 형량과 벌금', '
(1)오후 9시경 할머니가 쓰러지셔서 회식 도중 전화를 받고 음주 상태에서 운전하여 병원에 가다 경찰분들에게 적발되었습니다.
(할아버지가 횡설수설 말하심 + 음주상태라서 할머니가 돌아가셨다고 생각하고 급하게 차 몰고 출발)(음주측정 도수는 모름)
(2) 문제는 음주운전 재범입니다.
음주1회>면허취소>무면허운전 적발>면허정지>재취득>음주2회(특별사유)
음주운전 1회 이후 면허취소를 당했었는데, 그 상태로 무면허 운전을 하다가 교통경찰에게 적발당해 면허정지가 되었었습니다. 그 이후 면허를 재취득하고 5년 뒤 어젯밤 음주운전 2회를 하게 된 것입니다.
(3) - 이런 경우 형량이 어떻게 될까요?
- 징역 피할 수 있을까요?
- 재판 안 가고 벌금형을 받게 되면 벌금이 얼마나 나올까요?
- 할머니가 쓰러지시고 돌아가신 줄 알아서 급하게 운전하고 왔던 특수한 상황인데… 이걸로 참작이 조금이라도 될까요?
- 면허는 영구 취소 되겠죠…? 차량 폐기까지 가나요?
- 음주2회 무면허1회 모두 무사고라고 알고 있긴 한데… 만약 첫번째 음주운전에서 사고가 있었다면 어떻게 되는 건가요?', '2022-08-08', '2022-08-11 00:00:00', '2022-08-14 00:00:00'),
    (30, 6, 9, '자전거와 교차로에서 접촉 사고', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2023-12-26', '2023-12-30 00:00:00', '2023-12-31 00:00:00'),
    (31, 4, 11, '무보험 교통사고 형사 사건 처리 방법', '무보험 교통사고입니다 제가 가해자입니다 오토바이 피해자가 입원을 해서 7주 이상이 나와서 사건이 형사로 넘어갔고 피해자가 합의를 나중에 하자고 해서 결국 사건이 검찰로 넘어갔습니다 오늘 피해자가 전화로 대물을 먼저 돈을 주고 추후에 대인의 관한 비용을 달라고 말씀하셨습니다 이렇게 되면 나중에 대인 비용이 합의가 안되서 제가 처벌을 받으면 저만 대물 비용 주고 손해 아닌가요?', '2024-06-14', '2024-06-16 00:00:00', '2024-06-21 00:00:00'),
    (32, 6, 12, '횡단보도에서 좌회전 차량과 충돌', '저는 아파트 단지 내에서 주차하려던 중, 뒤쪽에서 빠르게 후진해 들어온 차량과 접촉 사고가 났습니다. 현장에는 CCTV가 없어 판단이 애매한데, 제 차량은 서서히 이동 중이었고 상대방이 후진하던 중이었습니다. 이럴 때 과실 비율은 어느 쪽이 더 높게 책정되는지, 실제 사례나 판례가 있는지도 알고 싶습니다.', '2024-02-29', '2024-03-02 00:00:00', '2024-03-05 00:00:00'),
    (33, 5, 13, '우회전 차량이 보행자와 사고 발생', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2023-07-12', '2023-07-13 00:00:00', '2023-07-17 00:00:00'),
    (34, 6, 14, '주차장에서 후진 중 차량과 사고', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2023-07-29', '2023-08-07 00:00:00', '2023-08-09 00:00:00'),
    (35, 4, 15, '우회전 차량이 보행자와 사고 발생', '저는 아파트 단지 내에서 주차하려던 중, 뒤쪽에서 빠르게 후진해 들어온 차량과 접촉 사고가 났습니다. 현장에는 CCTV가 없어 판단이 애매한데, 제 차량은 서서히 이동 중이었고 상대방이 후진하던 중이었습니다. 이럴 때 과실 비율은 어느 쪽이 더 높게 책정되는지, 실제 사례나 판례가 있는지도 알고 싶습니다.', '2022-06-25', '2022-07-03 00:00:00', '2022-07-04 00:00:00'),
    (36, 4, 16, '횡단보도에서 좌회전 차량과 충돌', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2024-05-26', '2024-06-02 00:00:00', '2024-06-04 00:00:00'),
    (37, 5, 7, '자전거와 교차로에서 접촉 사고', '저는 아파트 단지 내에서 주차하려던 중, 뒤쪽에서 빠르게 후진해 들어온 차량과 접촉 사고가 났습니다. 현장에는 CCTV가 없어 판단이 애매한데, 제 차량은 서서히 이동 중이었고 상대방이 후진하던 중이었습니다. 이럴 때 과실 비율은 어느 쪽이 더 높게 책정되는지, 실제 사례나 판례가 있는지도 알고 싶습니다.', '2022-12-09', '2022-12-13 00:00:00', '2022-12-17 00:00:00'),
    (38, 1, 17, '신호 위반 차량과 접촉 사고', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2024-05-07', '2024-05-11 00:00:00', '2024-05-15 00:00:00'),
    (39, 2, 18, '오토바이와 교차로에서 충돌', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2022-04-21', '2022-04-22 00:00:00', '2022-04-24 00:00:00'),
    (40, 3, 7, '음주 운전 차량과 정면 충돌', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2023-01-10', '2023-01-14 00:00:00', '2023-01-17 00:00:00'),
    (41, 3, 19, '음주 운전 차량과 정면 충돌', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2024-06-16', '2024-06-25 00:00:00', '2024-06-30 00:00:00'),
    (42, 5, 20, '비보호 좌회전 중 직진 차량과 충돌', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2024-02-23', '2024-02-28 00:00:00', '2024-03-03 00:00:00'),
    (43, 4, 1, '주차장에서 후진 중 차량과 사고', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2024-01-01', '2024-01-09 00:00:00', '2024-01-12 00:00:00'),
    (44, 3, 2, '신호 위반 차량과 접촉 사고', '우회전 중이던 차량이 보행자를 보지 못하고 사고가 났는데, 당시 보행자는 무단횡단은 아니었지만 횡단보도 끝자락에서 서 있던 상황이었습니다. 블랙박스에는 브레이크를 밟았지만 이미 늦었던 상황이 담겨 있습니다. 이런 경우 운전자의 과실은 얼마나 되며, 형사처벌 가능성도 있는지 궁금합니다.', '2024-06-03', '2024-06-04 00:00:00', '2024-06-07 00:00:00'),
    (45, 1, 4, '비보호 좌회전 중 직진 차량과 충돌', '저는 아파트 단지 내에서 주차하려던 중, 뒤쪽에서 빠르게 후진해 들어온 차량과 접촉 사고가 났습니다. 현장에는 CCTV가 없어 판단이 애매한데, 제 차량은 서서히 이동 중이었고 상대방이 후진하던 중이었습니다. 이럴 때 과실 비율은 어느 쪽이 더 높게 책정되는지, 실제 사례나 판례가 있는지도 알고 싶습니다.', '2022-01-05', '2022-01-10 00:00:00', '2022-01-14 00:00:00'),
    (46, 6, 3, '주차장에서 후진 중 차량과 사고', '저는 아파트 단지 내에서 주차하려던 중, 뒤쪽에서 빠르게 후진해 들어온 차량과 접촉 사고가 났습니다. 현장에는 CCTV가 없어 판단이 애매한데, 제 차량은 서서히 이동 중이었고 상대방이 후진하던 중이었습니다. 이럴 때 과실 비율은 어느 쪽이 더 높게 책정되는지, 실제 사례나 판례가 있는지도 알고 싶습니다.', '2023-11-10', '2023-11-13 00:00:00', '2023-11-18 00:00:00'),
    (47, 6, 5, '횡단보도에서 좌회전 차량과 충돌', '사고 당시 저는 정상적으로 신호를 받고 교차로를 진입하고 있었는데, 상대 차량이 갑자기 진입하면서 충돌이 발생했습니다. 사고 현장에서는 블랙박스 영상을 확인했을 때도 상대 차량이 신호 위반을 한 정황이 있습니다. 이런 경우 과실 비율은 어떻게 산정되는지 궁금합니다. 상대방 보험사에서는 제 과실을 40% 주장하고 있는데, 저는 이에 동의하지 않습니다. 정확한 과실 산정 기준과 법적 대응 방안을 알고 싶습니다.', '2024-01-29', '2024-02-01 00:00:00', '2024-02-04 00:00:00'),
    (48, 3, 7, '고속도로에서 급정거로 인한 사고', '저는 아파트 단지 내에서 주차하려던 중, 뒤쪽에서 빠르게 후진해 들어온 차량과 접촉 사고가 났습니다. 현장에는 CCTV가 없어 판단이 애매한데, 제 차량은 서서히 이동 중이었고 상대방이 후진하던 중이었습니다. 이럴 때 과실 비율은 어느 쪽이 더 높게 책정되는지, 실제 사례나 판례가 있는지도 알고 싶습니다.', '2024-04-15', '2024-04-23 00:00:00', '2024-04-26 00:00:00'),
    (49, 3, 6, '3년전 음주교통사고', '3년전 잘못으로 음주교통사고를 냈습니다
정말 잘못했지요. 근데 3년이 지난 오늘 보험사에서 전화가와 그때 자기들이 실수로 대물 계산을 잘못해서 금액을 더 내야한다 100만원가량을 더 입금하라고 합니다
제 입장에서는 그때 대물관련해서 400~500 큰 돈이 나가서(그때도 살짝 콩 한거여서 그거에 비해 크게 돈이 나간 부분이였습니다)
 이미 끝난 상황인데 3년이 지난 지금 전화가와서 100만원가량을 더 입금하라는게 너무 황당합니다
이럴땐 어떡해야 되나요 ?', '2023-06-04', '2023-06-08 00:00:00', '2023-06-09 00:00:00'),
    (50, 1, 7, '중과실 교통사고와 형사책임에 대한 상담', '12대 중과실로 인하여 교통사고가 발생했습니다. 저희쪽이 가해자이며 사고원인을 제공한 운전자입니다. 이때 저희는 업무를 이유로 운전중에 있었습니다. 그럼 이때 업무중 교통사고가 발생한것으로
혹시 저희가 소속된 회사도 형사책임이 발생하는것인지가 궁금합니다.이에 대한 법률자문이 필요하여 질문드립니다. 감사합니다  ', '2022-02-18', '2022-02-27 00:00:00', '2022-03-01 00:00:00');


-- 게시글 답변 (변호사가 작성한 - 서민영 변호사 활발한 활동)
INSERT INTO comment (no, board_no, user_no, content, is_selected, created_at, updated_at)
VALUES
    (1, 41, 31, '안녕하세요. 교통사고 관련 소송을 다수 수행해 온 법무법인 해광 손철 변호사입니다. 사고로 마음고생이 많으셨을 텐데, 끝까지 꼼꼼히 대응해 오신 점 응원 드립니다.
우선 교통사고사실확인원은 단지 사고가 있었다는 행정기록일 뿐, 상해 유발이나 과실의 증거로 보기 어렵습니다. 이미 불송치 처분을 받으셨고, 오히려 상대방은 보복운전으로 형사처벌까지 받은 만큼 법원에 이를 명확히 강조하시는 게 좋습니다. 진단서 역시 사고 이틀 후 한의원에서 발급받은 것이고, 검사나 통원기록도 없다면 객관성과 인과관계에 의문을 제기할 수 있습니다. 특히 영유아의 진단 내용이 부모 진술에만 기댄 것이라면 의학적 신빙성도 부족하다고 볼 여지가 큽니다.
게다가 상대가 안전벨트를 매지 않고 아이를 안은 채 운전한 사실까지 인정한 이상, 도로교통법 위반의 책임은 피고 측에 있고 이를 원고에게 돌리는 건 부당합니다. 이런 점들을 종합하여 반박 준비서면에 담으시면 충분히 설득력 있는 주장이 될 것입니다.
모든 정보는 철저히 비밀로 유지됩니다. 더 구체적인 검토가 필요하시다면 편히 상담 신청해 주세요.', 1, '2025-06-15 02:31:36', '2025-06-16 00:31:36'),
    (2, 41, 32, '끝까지 의뢰인을 위해 싸우는 변호사입니다[대한변호사협회 등록 형사법/교통사고 전문]
사회 초년생으로서 처음 겪는 교통사고로 많이 불안하고 당황스러우실 것 같습니다. 운전자의 부주의가 의심되는 상황에서 의뢰인의 권익을 보호하기 위한 대응방안을 상세히 안내해드리겠습니다.
우선 내일 즉시 병원 진료를 받으시는 것이 가장 중요합니다. 병원에서는 교통사고 환자임을 밝히시고, 사고 당시 상황과 현재 증상을 자세히 설명하시기 바랍니다. 특히 사고로 인한 충격 부위와 통증 부위를 구체적으로 말씀하시어 진단서에 정확히 기재되도록 하는 것이 좋습니다.
다음으로 보험사 처리 절차입니다. 가해자의 보험사에 연락하여 사고 접수를 하시고, 병원 진료 후에는 진단서와 영수증을 보험사에 제출하시면 됩니다. 이때 운전자가 핸드폰을 보며 운전하던 정황도 함께 전달하시면 과실비율 산정에 도움이 될 수 있습니다.
치료와 관련하여, 한의원과 병원 모두 이용 가능하며 보험 처리가 됩니다. 다만 이중 청구는 불가하니 한 곳을 선택하여 집중적으로 치료받으시기 바랍니다. 통원 치료 시 발생하는 교통비와 치료 기간 동안의 휴업손해도 청구 가능합니다.
보다 구체적인 판단은 자세한 상담을 통해 가능하므로 궁금한 점 있으시면 언제든 편히 연락부탁드립니다.
<대한변호사협회 등록 형사법/교통사고 변호사입니다>
변호사로서의 사명감과 열정을 가지고, 의뢰인의 권리를 지키기 위해 모든 역량을 집중하겠습니다.
수많은 형사사건을 성공적으로 해결해온 검증된 전문성으로, 어려운 상황에 놓인 의뢰인 여러분께 희망의 빛이 되어 드리겠습니다.', 0, '2025-05-29 02:31:36', '2025-05-29 11:31:36'),
    (3, 31, 31, '교통사고 발생 이후 약 22일 경과했으며, 사고 당시에 피해자는 두통, 어지러움 등의 증상이 없어서 몰랐습니다.
 발 염좌 및 긴장 진단, 요추염좌 진단 치료받던 중 발 염좌 및 긴장 은 추가진단 받았습니다.
 머리에 외상이 없어서 몰랐는데 시간이 지나면서 교통사고 당시 일부 기억이 불확실해지고, 구급대원의 진술 등 부분적인 정보로 인해 혼란을 겪고 있습니다.
 피해자는 정신건강의학과 진료를 받으려고 했지만 자동차보험 적용이 되지 않아 어려움을 겪었습니다.
 교통사고 직후 기억이 없거나 일부 착각이 있어 정확한 상황 파악이 어려운 상황입니다.
 22일 가량 지나서 피해자는 교통사고 직후 기억 상실 증상을 겪고 있는 것 같습니다.
지금이라도 진단 받으면 증거 효력이 있습니까?', 0, '2025-06-13 02:31:36', '2025-06-13 22:31:36'),
    (4, 18, 31, '고령의 아버님께서 교통사고로 인해 큰 심적 부담을 겪고 계신 상황이 매우 안타깝습니다. 특히 국선변호인의 갑작스러운 선임 취소로 인해 재판이 지연될 수 있다는 점에서 더욱 걱정이 크실 것으로 생각됩니다.
이 사안에서는 피해자와 이미 형사합의가 완료되었고 공소사실을 모두 인정하시는 상황이므로, 새로운 국선변호인 선임 없이도 재판을 진행할 수 있습니다. 법원에 국선변호인 선임 취소에 대한 의견서를 제출하시고, 신속한 재판 진행을 희망한다는 의사를 밝히시면 됩니다. 피고인이 70세 이상의 고령이며 심리적 부담이 크다는 점도 함께 소명하시면 좋겠습니다.
형사재판에서는 피고인의 연령, 진지한 반성, 피해 회복을 위한 노력 등이 중요한 정상참작 사유가 됩니다. 이미 합의금을 지급하시고 공소사실을 인정하시는 만큼, 법원의 너그러운 처분을 기대할 수 있을 것으로 보입니다.
보다 구체적인 판단은 자세한 상담을 통해 가능하므로 궁금한 점 있으시면 언제든 편히 연락부탁드립니다.
변호사로서의 사명감과 열정을 가지고, 의뢰인의 권리를 지키기 위해 모든 역량을 집중하겠습니다.
수많은 형사사건을 성공적으로 해결해온 검증된 전문성으로, 어려운 상황에 놓인 의뢰인 여러분께 희망의 빛이 되어 드리겠습니다.', 0, '2025-05-27 02:31:36', '2025-05-27 21:31:36'),
    (5, 44, 31, '
현재 진행 중인 소송에서 법원이 어떤 판단을 내릴지는 단정하기 어렵지만 중요한 몇 가지 요소를 고려해볼 수 있습니다.
1. 기왕증 및 인과관계
보험사가 주장하는 기왕증 70%는 지나치게 높은 비율로 보입니다.
교통사고로 인한 장기적인 침상 생활이 폐렴의 원인이 되었다면 사망과 교통사고의 인과관계가 인정될 가능성이 큽니다.
법원에서는 의학적 감정을 통해 이를 판단하게 될 것입니다.
2. 과실비율
보험사 측에서 30%의 과실을 주장하지만 피해자가 무면허 뺑소니 트럭에 사고를 당한 점을 고려하면 과실 비율이 과도하게 책정되었을 가능성이 있습니다.
법원에서 과실이 조정될 가능성이 있습니다.
3. 손해배상금 예상
변호사가 최악의 경우에도 4000만 원은 받을 수 있다고 했다면 실제 소송 결과에 따라 그보다 훨씬 높은 금액을 받을 가능성도 있습니다.
청구액이 3억 4천만 원이라 하더라도 법원이 어느 정도 인정해 주느냐에 따라 금액이 결정됩니다. 1억 원 이상 받을 가능성도 충분하지만 보장된다고 보기는 어렵습니다.
4. 대응 방법
현재 소송이 진행 중이라면 변호사를 통해 의료 감정 신청을 고려해볼 수 있습니다. 객관적인 감정 결과가 나온다면 인과관계 입증에 도움이 될 수 있습니다. 또한 판결이 나오기 전에 법원의 조정 절차를 통해 합의할 가능성도 있습니다.
지금으로서는 법원의 판단을 기다려야 하지만 걱정하는 것보다는 현재 변호사가 적절히 대응하고 있는지 확인하는 것이 중요합니다. 변호사에게 진행 상황을 묻는 것은 당연한 권리이므로 부담 갖지 말고 문의해 보세요.
추가적인 문의사항이 있다면 상담 예약을 남겨주세요.
빠르게 연락드려 궁금하신 내용에 대한 상담을 바로 도와 드리겠습니다.
만일 도움이 필요하시다면 주저 마시고, 언제든 상담 예약 남겨주세요.
의뢰인분의 상황과 매우 유사한 성공사례를 통해 대응 방법에 대한 상담을 도와 드리겠습니다.', 0, '2025-06-04 02:31:36', '2025-06-04 13:31:36'),
    (6, 36, 31, '
교통사고 중 구급차에 탑승해계시던 아버님이 사망하신 안타까운 사연에 깊은 위로를 드립니다. 유가족으로서 느끼시는 억울함과 분노가 당연합니다.
국과수 부검결과 사인이 "외상성 경막하출혈"로 확인된 점은 매우 중요합니다. 다발골수종이 간접적 영향을 미쳤을 가능성만 언급되었을 뿐 직접 사인은 교통사고로 인한 외상임이 명확합니다.
구급차와 버스 기사 모두 기소의견으로 검찰 송치된 점 역시 법적으로 유리한 요소입니다. 사망 사고의 경우 형사처벌 여부가 민사상 과실비율 판단에 중요한 영향을 미칩니다.
교통사고 과실비율 산정에는 국과수 부검결과, 사고현장 CCTV, 목격자 진술, 경찰 조사기록이 핵심 증거가 됩니다. 특히 응급환자 이송 중이었던 특수상황 증명이 중요합니다.
사망 전 의식불명 기간의 진료기록과 혈액암 진단서, 응급이송 필요성을 증명하는 의료진 소견서도 확보하시길 권장합니다. 이는 사고와 사망 사이 인과관계를 강화합니다.
소송을 통해 70% 이상의 과실비율을 인정받을 가능성은 충분합니다. 응급상황에서의 구급차 우선권과 버스 운전자의 주의의무 위반 정도를 법원이 종합적으로 판단할 것입니다.
보다 구체적인 판단은 자세한 상담을 통해 가능합니다. 가족분들의 억울함을 풀어드리기 위해 최선을 다하겠습니다. 궁금한 점 있으시면 언제든 연락주세요.', 0, '2025-06-04 02:31:36', '2025-06-04 05:31:36'),
    (7, 38, 31, '
오토바이 대 오토바이 사고로 상대방의 신호위반이 확인된 상황에서 비협조적인 태도를 보이고 있어 속상하실 것 같습니다. 경찰에서 과실 판단이 나온 것은 향후 배상 청구에 유리한 자료가 될 것입니다.
상대방 보험사에 직접 청구할 수 있는 항목으로는 치료비, 위자료, 교통비, 휴업손해 등이 있습니다. 특히 오토바이 사고의 경우 상해 정도가 클 수 있어 통원 기간과 치료 내용에 따라 상당한 배상을 받을 수 있습니다. 또한 상대방의 비협조적 태도로 인한 정신적 피해도 위자료 산정 시 고려될 수 있습니다.
민사적으로는 보험 한도를 초과하는 손해가 있다면 가해자 개인에게 직접 배상을 청구할 수 있고, 오토바이나 개인 물품의 파손이 있다면 재물손해도 별도로 청구 가능합니다. 향후 후유장해가 있다면 장해위자료와 일실소득도 추가로 청구할 수 있습니다.
보험사 직접 청구 과정에서 적정한 배상액 산정과 협상이 중요하므로 전문가의 손해 분석과 교섭 경험이 배상금 최대화에 도움이 될 수 있습니다.
보다 구체적인 판단은 자세한 상담을 통해 가능하므로 궁금한 점 있으시면 언제든 편히 연락부탁드립니다.', 0, '2025-06-08 02:31:36', '2025-06-08 11:31:36'),
    (8, 10, 31, '무면허운전 중 안전지대 진입으로 인한 교통사고를 내신 상황에서 매우 당황스럽고 걱정이 많으실 것 같습니다. 100대 0 가해 사고라는 점과 부상자가 있다는 점에서 심각한 상황이지만, 적절한 대응을 통해 최선의 결과를 도출할 수 있습니다.
무면허운전은 1년 이하 징역이나 300만원 이하 벌금에 해당하고, 교통사고처리특례법상 업무상과실치상까지 적용될 수 있어 종합보험 가입에도 불구하고 형사처벌을 피하기 어려운 상황입니다. 다만 피해자와의 합의는 양형에서 매우 중요한 요소로 작용하며, 초범 여부나 반성 정도에 따라 처분 수위가 달라질 수 있습니다. 보험회사가 대물과 대인 배상을 담당하지만 무면허로 인한 면책 조항이 있을 수 있어 확인이 필요합니다.
합의 과정에서는 보험회사와 긴밀히 협조하여 적정한 배상액을 산정하시고, 피해자의 과도한 요구에는 합리적 기준을 제시하며 대응하시는 것이 중요합니다. 또한 성실한 치료비 지원과 함께 진정성 있는 사과를 통해 피해자의 처벌불원 의사를 이끌어내는 것이 양형에 큰 도움이 될 것입니다. 무면허 사유와 사고 경위에 대한 깊은 반성도 필요합니다.
이런 무면허 교통사고 사건에서는 법률 전문가의 조력을 통해 보험회사와 협력하여 적절한 피해 배상을 진행하고 형사처벌 최소화를 위한 종합적인 대응 전략을 수립하는 것이 중요합니다. 특히 초기 합의 협상이 전체 사건의 결과를 좌우할 수 있습니다.
구체적인 합의 전략과 형사처벌 대응 방안에 대해서는 사고 경위와 피해 현황을 자세히 검토한 후 최적의 해결책을 안내드릴 수 있으니, 보험회사와의 협의와 함께 상담받으시기 바랍니다.', 0, '2025-06-11 02:31:36', '2025-06-11 05:31:36'),
    (9, 48, 31, '신호위반으로 인한 차대차 사고에서 과실 100%를 인정받았음에도 치료비 문제로 민사조정이 신청된 상황이 당혹스러우실 것 같습니다. 상대방 보험사가 이미 지급된 치료비와 그들이 인정하는 치료비 사이에 상당한 차이가 있어 반환을 요구하는 것으로 보입니다. 이러한 경우 대응 방법에 대해 안내해 드리겠습니다.
우선 진단서, 의사소견서, MRI 등 객관적인 의료 자료를 확보하는 것이 중요합니다. 특히 현재 치료 중인 병원의 의사로부터 향후 치료 필요성과 예상 기간, 상해 정도에 대한 상세한 소견서를 받아두시는 것이 좋습니다. 또한 사고와 현재 증상 간의 인과관계를 입증할 수 있는 자료도 준비하시기 바랍니다.
민사조정 과정에서는 반드시 변호사의 도움을 받아 대응하시는 것이 유리합니다. 과도한 치료비 반환 요구에 대해 의학적 타당성을 기반으로 반박하고, 필요시 제3의 의료기관에 감정을 의뢰할 것을 제안할 수도 있습니다. 또한 기존에 지급된 치료비가 적절했음을 주장하기 위해 유사 사례나 판례를 활용하는 것도 도움이 됩니다.
보다 구체적인 판단은 자세한 상담을 통해 가능하므로 궁금한 점 있으시면 언제든 편히 연락부탁드립니다.
', 0, '2025-06-06 02:31:36', '2025-06-06 10:31:36'),
    (10, 1, 31, '교통사고 경찰조사 결과 관련하여 정확히 설명드리겠습니다.
1. 경찰 조사의 특징
주목적: 형사책임 여부 판단
과실 정도보다 법규위반 중심
가/피해자 구분 필요
2. 조사결과 유형
가. 가능한 결과: 일방과실
쌍방과실
불기소의견(과실 불분명)
나. 쌍방과실 인정 경우
양측 모두 법규위반 있을 때
신호위반 + 과속
중앙선침범 + 안전거리미확보
쌍방 음주운전
3. 실무 처리
주된 과실자: 가해자
경미한 과실자: 피해자
과실비율: 민사절차에서 결정
구체적인 조력이 필요하시거나 전문적인 법률 상담을 원하시면 언제든 연락 주세요.
', 0, '2025-06-19 02:31:36', '2025-06-19 19:31:36'),
    (11, 21, 31, '교통사고 경찰수사에서도 쌍방과실 판단이 가능합니다. 다만, 형사사건의 특성상 과실 정도에 따라 처리 방식이 달라지는데요.
예를 들어 양측의 과실이 비슷한 수준이라면 공소권없음 처분으로 종결되거나, 쌍방 모두에 대해 형사입건이 될 수 있습니다. 실무에서는 교통사고 조사 과정에서 경찰이 양측의 과실을 모두 인정하고 조사하는 경우가 많이 있어요.
특히 교차로 사고나 차선변경 사고의 경우 쌍방과실로 판단되는 경우가 많은데, 이때 경찰은 양측의 진술과 블랙박스 영상, 목격자 진술 등을 종합적으로 검토하여 과실 여부를 판단합니다.
물론 형사절차에서는 민사와 달리 과실 비율을 수치화하여 표시하지는 않지만, 실질적으로 쌍방과실 여부를 판단하여 사건을 처리하고 있답니다.
보다 구체적인 판단은 자세한 상담을 통해 가능하므로 궁금한 점 있으시면 언제든 편히 연락부탁드립니다.
', 0, '2025-06-19 20:31:36', '2025-06-19 23:31:36'),
    (12, 32, 33, '책임보험 처리 범위를 넘는 경우, 민사소송 준비를 함께 해야 할 가능성이 높습니다. 서면 진술과 진료기록 확보가 필요합니다.', 0, '2025-06-17 02:31:36', '2025-06-17 12:31:36'),
    (13, 42, 34, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-05-31 02:31:36', '2025-05-31 05:31:36'),
    (14, 4, 35, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-06-05 02:31:36', '2025-06-05 23:31:36'),
    (15, 47, 34, '책임보험 처리 범위를 넘는 경우, 민사소송 준비를 함께 해야 할 가능성이 높습니다. 서면 진술과 진료기록 확보가 필요합니다.', 0, '2025-06-05 02:31:36', '2025-06-05 19:31:36'),
    (16, 26, 35, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-06-14 02:31:36', '2025-06-14 20:31:36'),
    (17, 5, 32, '해당 상황은 과실 비율을 따질 수 있는 대표적인 사례입니다. 상대 차량의 신호 위반 여부와 블랙박스 영상이 중요한 증거가 됩니다.', 0, '2025-05-27 02:31:36', '2025-05-27 18:31:36'),
    (18, 43, 33, '해당 상황은 과실 비율을 따질 수 있는 대표적인 사례입니다. 상대 차량의 신호 위반 여부와 블랙박스 영상이 중요한 증거가 됩니다.', 0, '2025-06-14 02:31:36', '2025-06-14 18:31:36'),
    (19, 12, 34, '교차로 사고의 경우, 선진입 차량과 신호위반 여부를 따져야 합니다. 일단 과실 여부를 판단받기 전까진 상대측과의 대화는 유보하세요.', 0, '2025-06-07 02:31:36', '2025-06-07 17:31:36'),
    (20, 28, 35, '책임보험 처리 범위를 넘는 경우, 민사소송 준비를 함께 해야 할 가능성이 높습니다. 서면 진술과 진료기록 확보가 필요합니다.', 0, '2025-05-31 02:31:36', '2025-05-31 22:31:36'),
    (21, 30, 31, '교차로 사고의 경우, 선진입 차량과 신호위반 여부를 따져야 합니다. 일단 과실 여부를 판단받기 전까진 상대측과의 대화는 유보하세요.', 0, '2025-05-28 02:31:36', '2025-05-28 08:31:36'),
    (22, 25, 32, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-06-10 02:31:36', '2025-06-10 09:31:36'),
    (23, 46, 33, '책임보험 처리 범위를 넘는 경우, 민사소송 준비를 함께 해야 할 가능성이 높습니다. 서면 진술과 진료기록 확보가 필요합니다.', 0, '2025-05-31 02:31:36', '2025-05-31 23:31:36'),
    (24, 2, 34, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-06-19 02:31:36', '2025-06-19 11:31:36'),
    (25, 20, 31, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-05-29 02:31:36', '2025-05-29 22:31:36'),
    (26, 14, 32, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-05-31 02:31:36', '2025-05-31 04:31:36'),
    (27, 9, 33, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-05-31 02:31:36', '2025-05-31 03:31:36'),
    (28, 15, 31, '교차로 사고의 경우, 선진입 차량과 신호위반 여부를 따져야 합니다. 일단 과실 여부를 판단받기 전까진 상대측과의 대화는 유보하세요.', 0, '2025-06-01 02:31:36', '2025-06-01 10:31:36'),
    (29, 34, 35, '해당 상황은 과실 비율을 따질 수 있는 대표적인 사례입니다. 상대 차량의 신호 위반 여부와 블랙박스 영상이 중요한 증거가 됩니다.', 0, '2025-06-07 02:31:36', '2025-06-07 19:31:36'),
    (30, 33, 34, '책임보험 처리 범위를 넘는 경우, 민사소송 준비를 함께 해야 할 가능성이 높습니다. 서면 진술과 진료기록 확보가 필요합니다.', 0, '2025-06-15 02:31:36', '2025-06-15 12:31:36'),
    (31, 49, 31, '교차로 사고의 경우, 선진입 차량과 신호위반 여부를 따져야 합니다. 일단 과실 여부를 판단받기 전까진 상대측과의 대화는 유보하세요.', 0, '2025-06-20 02:31:36', '2025-06-20 07:31:36'),
    (32, 7, 36, '교차로 사고의 경우, 선진입 차량과 신호위반 여부를 따져야 합니다. 일단 과실 여부를 판단받기 전까진 상대측과의 대화는 유보하세요.', 0, '2025-05-31 02:31:36', '2025-05-31 12:31:36'),
    (33, 23, 37, '책임보험 처리 범위를 넘는 경우, 민사소송 준비를 함께 해야 할 가능성이 높습니다. 서면 진술과 진료기록 확보가 필요합니다.', 0, '2025-06-22 02:31:36', '2025-06-22 18:31:36'),
    (34, 19, 38, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-06-12 02:31:36', '2025-06-12 06:31:36'),
    (35, 16, 39, '보행자 신호를 위반한 경우라도, 차량이 정지하지 못한 정황이 있다면 쌍방 과실이 인정될 수 있습니다.', 1, '2025-06-18 02:31:36', '2025-06-18 06:31:36'),
    (36, 40, 40, '교차로 사고의 경우, 선진입 차량과 신호위반 여부를 따져야 합니다. 일단 과실 여부를 판단받기 전까진 상대측과의 대화는 유보하세요.', 0, '2025-06-07 02:31:36', '2025-06-07 16:31:36'),
    (37, 27, 40, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-06-16 02:31:36', '2025-06-16 11:31:36'),
    (38, 37, 40, '교차로 사고의 경우, 선진입 차량과 신호위반 여부를 따져야 합니다. 일단 과실 여부를 판단받기 전까진 상대측과의 대화는 유보하세요.', 0, '2025-05-28 02:31:36', '2025-05-28 14:31:36'),
    (39, 24, 40, '해당 상황은 과실 비율을 따질 수 있는 대표적인 사례입니다. 상대 차량의 신호 위반 여부와 블랙박스 영상이 중요한 증거가 됩니다.', 0, '2025-06-12 02:31:36', '2025-06-12 23:31:36'),
    (40, 11, 40, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-05-26 02:31:36', '2025-05-26 05:31:36'),
    (41, 8, 40, '보행자 신호를 위반한 경우라도, 차량이 정지하지 못한 정황이 있다면 쌍방 과실이 인정될 수 있습니다.', 0, '2025-06-23 02:31:36', '2025-06-23 19:31:36'),
    (42, 17, 40, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-06-17 02:31:36', '2025-06-18 00:31:36'),
    (43, 3, 40, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-06-14 02:31:36', '2025-06-14 09:31:36'),
    (44, 29, 40, '책임보험 처리 범위를 넘는 경우, 민사소송 준비를 함께 해야 할 가능성이 높습니다. 서면 진술과 진료기록 확보가 필요합니다.', 0, '2025-06-02 02:31:36', '2025-06-02 22:31:36'),
    (45, 35, 40, '해당 상황은 과실 비율을 따질 수 있는 대표적인 사례입니다. 상대 차량의 신호 위반 여부와 블랙박스 영상이 중요한 증거가 됩니다.', 0, '2025-06-14 02:31:36', '2025-06-14 11:31:36'),
    (46, 13, 40, '해당 상황은 과실 비율을 따질 수 있는 대표적인 사례입니다. 상대 차량의 신호 위반 여부와 블랙박스 영상이 중요한 증거가 됩니다.', 0, '2025-06-06 02:31:36', '2025-06-07 01:31:36'),
    (47, 6, 38, '블랙박스 영상과 목격자의 진술이 핵심 증거입니다. 경찰서에 제출해 사건 경위서와 함께 정식 접수하는 것을 권장드립니다.', 0, '2025-06-14 02:31:36', '2025-06-14 12:31:36'),
    (48, 39, 38, '책임보험 처리 범위를 넘는 경우, 민사소송 준비를 함께 해야 할 가능성이 높습니다. 서면 진술과 진료기록 확보가 필요합니다.', 0, '2025-06-02 02:31:36', '2025-06-03 01:31:36'),
    (49, 22, 35, '해당 상황은 과실 비율을 따질 수 있는 대표적인 사례입니다. 상대 차량의 신호 위반 여부와 블랙박스 영상이 중요한 증거가 됩니다.', 0, '2025-06-07 02:31:36', '2025-06-07 22:31:36'),
    (50, 50, 33, '해당 상황은 과실 비율을 따질 수 있는 대표적인 사례입니다. 상대 차량의 신호 위반 여부와 블랙박스 영상이 중요한 증거가 됩니다.', 0, '2025-05-28 02:31:36', '2025-05-28 13:31:36');

-- 방송 스케줄
INSERT INTO `broadcast_schedule`
(`user_no`, `category_no`, `name`,                          `content`,                         `thumbnail_path`, `date`,         `start_time`,           `end_time`,             `created_at`)
VALUES
    (31, 3, '음주운전 실전 상담 라이브',               '음주운전 관련 실전 상담 방송입니다.',                      'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path1.png', '2025-06-27', '2025-06-27 09:00:00', '2025-06-27 22:00:00', '2025-05-28 09:12:00'),
    (32, 2, '중대사고/형사처벌 사례해설',            '최근 판례 중심 중대사고 대응전략 안내.',                  'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path2.png', '2025-06-12', '2025-06-12 19:00:00', '2025-06-12 20:00:00', '2025-05-30 16:22:00'),
    (35, 5, '과실 분쟁 실시간 사례',                '최근 과실비율 쟁점/분쟁 최신 정보.',                     'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path3.png', '2025-06-18', '2025-06-18 21:00:00', '2025-06-18 22:30:00', '2025-06-06 12:30:00'),
    (37, 3, '음주운전 변호인이 말하는 방어 전략',     '실전 변호사가 직접 설명하는 음주운전 방어법.',           'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path4.png', '2025-06-25', '2025-06-25 13:00:00', '2025-06-25 14:00:00', '2025-06-12 13:22:00'),
    (32, 3, '무면허/음주운전 대응법',               '무면허, 음주 운전 시 실제 대응전략.',                   'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path6.png', '2025-06-10', '2025-06-10 20:00:00', '2025-06-10 21:00:00', '2025-06-01 11:02:00'),
    (33, 3, '음주운전/뺑소니 신속대응법',           '음주·뺑소니 사건별 즉시대응 요령!',                   'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path7.png', '2025-06-05', '2025-06-05 12:00:00', '2025-06-05 13:00:00', '2025-06-01 08:32:00'),

    (34, 2, '형사처벌 FAQ',                         '교통사고 관련 형사처벌 주요 FAQ.',                    'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path8.png', '2025-06-30', '2025-06-30 11:00:00', '2025-06-30 12:00:00', '2025-06-15 09:12:00'),
    (31, 3, '무면허·음주 면허 구제실전',            '면허 취소구제 케이스 집중 소개.',                  'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path5.png', '2025-06-28', '2025-06-28 20:00:00', '2025-06-28 21:00:00', '2025-06-19 12:50:00'),
    (35, 3, '음주운전 단속 변호상담',               '단속 후 실시간 변호상담!',                         'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path4.png', '2025-06-06', '2025-06-06 11:00:00', '2025-06-06 12:00:00', '2025-06-01 07:32:00'),
    (36, 6, '차량 외 사고 대처법',                  '차대인/자전거 등 차량 외 사고 노하우.',                 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path2.png', '2025-07-01', '2025-07-01 15:30:00', '2025-07-01 16:30:00', '2025-06-08 13:44:00'),
    (32, 4, '장기 치료 중 보험사 대응법?',          '장기 치료 중 보험사 대응법?',                          'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path6.png', '2025-07-01', '2025-07-01 12:00:00', '2025-07-01 13:00:00', '2025-06-10 09:17:00'),
    (31, 5, '과실 쟁점 토론회',                    '실제 분쟁 과실 사례 라이브 토론.',                     'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path3.png', '2025-07-02', '2025-07-02 20:30:00', '2025-07-02 22:00:00', '2025-06-10 09:17:00'),

    (34, 4, '보험처리 Q&A',                        '실제 보험 민원/행정처분 케이스 질의응답.',               'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path4.png', '2025-07-04', '2025-07-04 10:00:00', '2025-07-04 11:00:00', '2025-06-02 09:40:00'),
    (31, 4, '보험처리 Q&A – 보충',                 '보험처리 Q&A 보충 방송입니다.',                         'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path4.png', '2025-07-04', '2025-07-04 12:00:00', '2025-07-04 13:00:00', '2025-06-03 10:00:00'),
    (35, 3, '무면허 운전자 위한 특강',             '무면허 적발 후 대처 전략.',                          'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path4.png', '2025-07-05', '2025-07-05 16:00:00', '2025-07-05 17:00:00', '2025-06-17 10:16:00'),
    (37, 5, '과실 분쟁 실시간 사례 – 심화',        '심화 과실 분쟁 사례 방송입니다.',                       'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path3.png', '2025-07-05', '2025-07-05 18:00:00', '2025-07-05 19:00:00', '2025-06-16 11:00:00'),
    (33, 5, '과실 분쟁 실시간 사례 – Q&A',        '과실 분쟁 Q&A 방송입니다.',                             'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path3.png', '2025-07-05', '2025-07-05 19:00:00', '2025-07-05 20:00:00', '2025-06-17 11:00:00'),
    (31, 2, '중대사고 이후 절차 설명',            '사고 후 경찰, 검찰, 법원 절차 총정리.',                 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path2.png', '2025-07-06', '2025-07-06 17:00:00', '2025-07-06 18:00:00', '2025-06-13 14:32:00'),
    (32, 2, '중대사고 이후 절차 설명 – 심화',     '중대사고 절차 설명 심화 방송입니다.',                   'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path2.png', '2025-07-06', '2025-07-06 18:00:00', '2025-07-06 19:00:00', '2025-06-13 10:00:00'),
    (36, 2, '중대사고 사망사건',                  '사망사건 변호사 실제 상담사례.',                   'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path2.png', '2025-07-09', '2025-07-09 10:00:00', '2025-07-09 11:00:00', '2025-06-23 12:12:00'),
    (32, 6, '차량 외 사고 보험 처리법',           '이륜차·자전거 사고 처리 및 보험 안내.',              'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path7.png', '2025-07-11', '2025-07-11 15:00:00', '2025-07-11 16:00:00', '2025-06-11 14:12:00'),
    (33, 3, '무면허 운전 집중 분석',              '무면허 운전 형사/행정 대응 팁!',                         'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path8.png', '2025-07-12', '2025-07-12 17:30:00', '2025-07-12 18:00:00', '2025-06-01 08:45:00'),
    (34, 3, '무면허 운전 집중 분석 – 심화',       '심화된 무면허 운전 분석 방송입니다.',                   'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path8.png', '2025-07-12', '2025-07-12 18:00:00', '2025-07-12 19:00:00', '2025-06-15 10:00:00'),
    (35, 3, '무면허 운전 집중 분석 – Q&A',       '무면허 운전 집중 분석 Q&A 방송입니다.',               'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path8.png', '2025-07-12', '2025-07-12 19:00:00', '2025-07-12 20:00:00', '2025-06-16 10:00:00'),
    (36, 3, '무면허 운전 집중 분석 – 사례',       '무면허 운전 사례 중심 분석 방송입니다.',               'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path1.png', '2025-07-12', '2025-07-12 20:00:00', '2025-07-12 21:00:00', '2025-06-17 10:00:00'),
    (37, 4, '보험회사 상대 노하우',                '보험사와 분쟁 시 유리하게 대처하는 법.',               'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path7.png', '2025-07-14', '2025-07-14 10:00:00', '2025-07-14 11:30:00', '2025-06-18 19:22:00'),
    (36, 4, '행정처분 구제방안',                  '면허 정지·취소 구제 방안 안내.',                     'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path1.png', '2025-07-15', '2025-07-15 14:00:00', '2025-07-15 15:00:00', '2025-06-18 15:20:00'),
    (31, 4, '행정처분 구제방안 – 사례',         '행정처분 구제 사례 중심 방송입니다.',                     'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path4.png', '2025-07-15', '2025-07-15 16:00:00', '2025-07-15 17:00:00', '2025-06-18 11:00:00'),
    (34, 4, '행정처분 구제방안 – Q&A',         '구제방안 Q&A 방송입니다.',                               'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path7.png', '2025-07-15', '2025-07-15 17:00:00', '2025-07-15 18:00:00', '2025-06-19 11:00:00'),
    (33, 6, '자전거 사고/보험금',                 '자전거 사고 발생 시 보험금 청구 전략.',             'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path4.png', '2025-07-18', '2025-07-18 09:00:00', '2025-07-18 10:00:00', '2025-06-16 11:02:00'),
    (32, 4, '행정처분, 보험사 대처법',           '의뢰인 질문 실시간 답변.',                        'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path3.png', '2025-07-20', '2025-07-20 19:00:00', '2025-07-20 20:00:00', '2025-06-20 09:25:00'),
    (33, 5, '과실분쟁, 의뢰인 실전QnA',          '실제 상담 사례 LIVE 질답.',                      'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path4.png', '2025-07-21', '2025-07-21 14:00:00', '2025-07-21 15:00:00', '2025-06-22 10:11:00'),
    (37, 3, '무면허 사고방어 실전',               '방어전략, 실전 쟁점!',                             'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path7.png', '2025-07-22', '2025-07-22 17:00:00', '2025-07-22 18:00:00', '2025-06-23 19:11:00'),
    (34, 4, '행정처분 실시간 상담',              '즉시상담, 구제 팁.',                             'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path4.png', '2025-07-28', '2025-07-28 15:00:00', '2025-07-28 16:00:00', '2025-06-24 10:04:00'),
    (35, 5, '과실 100:0 실전',                    '100:0 실전 적용사례.',                            'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path3.png', '2025-07-29', '2025-07-29 13:00:00', '2025-07-29 14:00:00', '2025-06-24 15:40:00'),
    (36, 6, '차량 외 사고 판례해설',            '최신 판례 해설 및 상담.',                       'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/broadcast/path3.png', '2025-07-31', '2025-07-31 20:00:00', '2025-07-31 21:00:00', '2025-06-24 17:00:00');


-- 방송
INSERT INTO `broadcast`
(`user_no`, `schedule_no`, `session_id`,       `start_time`,            `end_time`,              `status`, `report_status`, `created_at`)
VALUES
    (31,       1,           'SESSION01',  '2025-06-27 09:00:00', '2025-06-27 22:00:00', 'DONE',   0, '2025-05-28 09:12:00'),
    (32,       2,           'SESSION02',  '2025-06-12 19:00:00', '2025-06-12 20:00:00', 'DONE',   0, '2025-05-30 16:22:00'),
    (35,       3,           'SESSION05',  '2025-06-18 21:00:00', '2025-06-18 22:30:00', 'DONE',   0, '2025-06-06 12:30:00'),
    (37,       4,           'SESSION06',  '2025-06-25 13:00:00', '2025-06-25 14:00:00', 'DONE',   0, '2025-06-08 13:44:00'),
    (32,       5,           'SESSION07',  '2025-06-10 20:00:00', '2025-06-10 21:00:00', 'DONE',   0, '2025-06-12 13:22:00'),
    (33,       6,           'SESSION07',  '2025-06-05 12:00:00', '2025-06-05 13:00:00', 'DONE',   0, '2025-06-28 21:01:00'),
    (34,       7,           'SESSION09',  '2025-06-30 11:00:00', '2025-06-30 12:00:00', 'DONE',   0, '2025-06-01 11:02:00'),
    (31,       8,           'SESSION09',  '2025-06-28 20:00:00', '2025-06-28 21:00:00', 'DONE',   0, '2025-06-01 11:02:00'),
    (35,       9,           'SESSION09',  '2025-06-06 11:00:00', '2025-06-06 12:00:00', 'DONE',   0, '2025-06-01 11:02:00'),
    (31,       10,           'SESSION01',  '2025-06-27 21:00:00', '2025-06-27 22:00:00', 'DONE',   0, '2025-05-28 09:12:00'),
    (32,       11,           'SESSION02',  '2025-06-27 19:00:00', '2025-06-17 20:00:00', 'DONE',   0, '2025-05-30 16:22:00'),
    (35,       12,           'SESSION05',  '2025-06-30 21:00:00', '2025-06-30 22:30:00', 'DONE',   0, '2025-06-06 12:30:00'),
    (37,       13,           'SESSION06',  '2025-06-25 18:00:00', '2025-06-25 20:00:00', 'DONE',   0, '2025-06-08 13:44:00'),
    (32,       14,           'SESSION07',  '2025-07-01 20:00:00', '2025-07-01 21:00:00', 'DONE',   0, '2025-06-12 13:22:00'),
    (33,       15,           'SESSION07',  '2025-07-02 12:00:00', '2025-07-02 13:00:00', 'DONE',   0, '2025-07-01 21:01:00');




-- 사전 질문
INSERT INTO `pre_question`
(`user_no`, `schedule_no`, `nickname`, `content`, `created_at`)
VALUES
    (4,   3,  '용인시방민영', '무면허 운전 집중 분석 방송에서 다룰 수 있는 주요 방어 전략은 무엇인가요?',               '2025-07-10 09:00:00'),
    (5,   3,  '대구남자',     '무면허 운전 적발 후 즉시 취해야 할 법적 대응은 무엇인가요?',                               '2025-07-10 10:00:00'),
    (6,   3,  '부산남자',     '무면허 운전 사건에서 증거 수집 방법은 어떤 것이 있나요?',                                 '2025-07-10 11:00:00'),
    (7,   4,  '박건희01',     '보험처리 Q&A 중 과실 인정 시 유리한 증거는 무엇인가요?',                                  '2025-07-03 09:00:00'),
    (8,   4,  '정유진02',     '보험사에 과실 비율 조정 요청 시 제출해야 할 자료는 무엇인가요?',                            '2025-07-03 10:00:00'),
    (9,   4,  '신세계06',     '교통사고 보험 청구 시 자주 발생하는 서류 누락 사례는 어떤 것이 있나요?',                   '2025-07-03 11:00:00'),
    (10,  8,  '아이린',       '중대사고 이후 절차 설명에서 경찰 조사 단계에 필요한 구비 서류는 무엇인가요?',            '2025-07-05 09:00:00'),
    (12,  8,  '웬디',         '중대사고 이후 절차 설명에서 피해자 보상 청구 방법은 어떻게 되나요?',                       '2025-07-05 10:00:00'),
    (13,  8,  '조이',         '중대사고 이후 법원 단계에서 변호사 조력을 받는 방법은 무엇인가요?',                       '2025-07-05 11:00:00'),
    (14, 10,  '예리',         '보험회사 상대 노하우 방송에서 합의 협상 전략은 무엇인가요?',                            '2025-07-15 09:00:00'),
    (15, 10,  'itzy01',      '보험사 상대 협상 시 제시하면 유리한 판례나 사례는 무엇인가요?',                          '2025-07-15 10:00:00'),
    (16, 10,  '있지리아',     '보험회사 노하우 강의에서 보험금 거절 시 재심 청구 절차는 어떻게 되나요?',               '2025-07-15 11:00:00'),
    (17, 12,  '있지류진',     '차량 외 사고 보험 처리법에서 자전거 사고 시 보험금 산정 기준은 무엇인가요?',            '2025-07-10 09:00:00'),
    (18, 12,  'itzy채령',    '킥보드 사고 처리 시 자기부담금 계산 방식은 어떻게 되나요?',                             '2025-07-10 10:00:00'),
    (19, 12,  '있지유나',     '이륜차 사고 보험 처리법 강의에서 합의 사례는 어떤 것들이 있나요?',                      '2025-07-10 11:00:00'),
    (20, 15,  'Kkolcho',     '무면허 운전자 위한 특강에서 변호사 선택 시 고려해야 할 요소는 무엇인가요?',            '2025-07-04 09:00:00'),
    (21, 15,  '수성구',       '무면허 특강 중 제시된 실제 사례 중 가장 눈에 띄는 판례는 무엇인가요?',                  '2025-07-04 10:00:00'),
    (22, 15,  '해운대',       '무면허 적발 후 특강에서 제안하는 초기 대응 방안은 무엇인가요?',                        '2025-07-04 11:00:00'),
    (4,   16, '용인시방민영', '행정처분 구제방안 강의에서 주로 다루는 이의신청 사유는 무엇인가요?',                    '2025-07-14 09:00:00'),
    (5,   16, '대구남자',     '면허 정지 처분 이의신청 시 제출해야 할 서류는 무엇인가요?',                              '2025-07-14 10:00:00'),
    (6,   16, '부산남자',     '행정처분 구제 절차 강의에서 사례별 구제 성공률은 어느 정도인가요?',                      '2025-07-14 11:00:00'),
    (7,   17, '박건희01',     '과실비율 100:0 만들기 방송에서 유리한 증거 유형은 무엇인가요?',                        '2025-07-02 09:00:00'),
    (8,   17, '정유진02',     '과실비율 100:0 입증 시 참고할 주요 판례는 어떤 것들이 있나요?',                         '2025-07-02 10:00:00'),
    (9,   17, '신세계06',     '100:0 과실비율 주장 시 작성해야 할 청구서류는 무엇인가요?',                              '2025-07-02 11:00:00'),
    (10,  18, '아이린',       '자전거 사고/보험금 방송에서 보험금 청구 시 주의해야 할 점은 무엇인가요?',              '2025-07-16 09:00:00'),
    (12,  18, '웬디',         '자전거 사고 이후 보험사에 제출하는 사고 보고서는 어떻게 작성하나요?',                   '2025-07-16 10:00:00'),
    (13,  18, '조이',         '자전거 사고 보상 강의에서 다루는 합의 사례는 어떤 것들이 있나요?',                      '2025-07-16 11:00:00'),
    (14,  20, '예리',         '중대사고 처벌 실제사례 중 형사처벌 수위 결정 기준은 무엇인가요?',                        '2025-07-12 09:00:00'),
    (15,  20, 'itzy01',      '중대사고 형사처벌 사례 중 경미한 처분 사례는 어떤 것이 있나요?',                         '2025-07-12 10:00:00'),
    (16,  20, '있지리아',     '형사처벌 사례에서 피해자 합의가 판결에 미치는 영향은 무엇인가요?',                      '2025-07-12 11:00:00'),
    (17,  22, '있지류진',     '행정처분, 보험사 대처법에서 보험사 이의제기 절차는 어떻게 되나요?',                      '2025-07-19 09:00:00'),
    (18,  22, 'itzy채령',    '보험사의 재심사 요청 시 필요한 추가 자료는 무엇인가요?',                                 '2025-07-19 10:00:00'),
    (19,  22, '있지유나',     '행정처분 이후 보험 처리 기간은 얼마나 걸리나요?',                                       '2025-07-19 11:00:00'),
    (20,  23, 'Kkolcho',     '무면허·음주 면허 구제실전 방송에서 제시하는 핵심 전략은 무엇인가요?',                  '2025-06-27 09:00:00'),
    (21,  23, '수성구',       '면허 구제 실전 사례 중 가장 성공률이 높은 방안은 무엇인가요?',                          '2025-06-27 10:00:00'),
    (22,  23, '해운대',       '구제실전 강의에서 설명하는 이의신청 준비 절차는 무엇인가요?',                          '2025-06-27 11:00:00'),
    (4,   24, '용인시방민영', '차량외 사고, 보상 실무 강의에서 제출해야 하는 청구 서류는 무엇인가요?',                '2025-07-06 09:00:00'),
    (5,   24, '대구남자',     '보상 실무 방송에서 다룬 과실비율 합의 사례는 어떤 것들이 있나요?',                      '2025-07-06 10:00:00'),
    (6,   24, '부산남자',     '보상 실무 강의에서 소개된 보험사 협상 전략은 무엇인가요?',                             '2025-07-06 11:00:00'),
    (7,   26, '박건희01',     '중대사고 사망사건 방송에서 제시하는 형량 산정 기준은 무엇인가요?',                        '2025-07-08 09:00:00'),
    (8,   26, '정유진02',     '사망사건 방송 중 유족 보상 청구 시 유의할 점은 무엇인가요?',                             '2025-07-08 10:00:00'),
    (9,   26, '신세계06',     '사망사건 사례 해설에서 다룬 주요 판례는 어떤 것들이 있나요?',                            '2025-07-08 11:00:00'),
    (10,  27, '아이린',       '무면허 사고방어 실전 중 제시된 주요 방어 논리는 무엇인가요?',                            '2025-06-30 09:00:00'),
    (12,  27, '웬디',         '무면허 사고방어 사례 분석에서 사용된 증거 유형은 무엇인가요?',                            '2025-06-30 10:00:00'),
    (13,  27, '조이',         '사고방어 실전 방송에서 소개된 법률 조항은 어떤 것들이 있나요?',                          '2025-06-30 11:00:00'),
    (14,  28, '예리',         '행정처분 실시간 상담 준비 서류 목록은 무엇인가요?',                                    '2025-07-01 09:00:00'),
    (15,  28, 'itzy01',      '실시간 상담에서 자주 묻는 질문 사례는 무엇인가요?',                                    '2025-07-01 10:00:00'),
    (16,  28, '있지리아',     '상담 강의 중 상담 전 준비해야 할 문서 양식은 무엇인가요?',                              '2025-07-01 11:00:00'),
    (17,  29, '있지류진',     '과실 100:0 실전에서 활용하는 주요 증인 신문 기법은 무엇인가요?',                       '2025-07-02 09:00:00'),
    (18,  29, 'itzy채령',    '100:0 과실 적용 시 작성해야 할 질문록 양식은 어떻게 되나요?',                            '2025-07-02 10:00:00'),
    (19,  29, '있지유나',     '증인 신문 시 유의사항은 어떤 것이 있나요?',                                            '2025-07-02 11:00:00'),
    (20,  30, 'Kkolcho',     '차량 외 사고 판례해설 방송에서 중점적으로 다루는 판례는 무엇인가요?',                  '2025-07-30 09:00:00'),
    (21,  30, '수성구',       '최신 판례해설에서 소개된 판결문 요지는 무엇인가요?',                                     '2025-07-30 10:00:00'),
    (22,  30, '해운대',       '판례해설 중 법리 해석 시 주의할 점은 무엇인가요?',                                      '2025-07-30 11:00:00');




-- 자동응답
INSERT INTO `auto_reply`
(`schedule_no`, `keyword`, `message`, `created_at`)
VALUES
    (1,  '음주운전',    '음주운전 단속 시 묵비권을 행사할 수 있습니다.',   '2025-06-01 10:00:00'),
    (2,  '뺑소니',      '뺑소니는 형사처벌이 매우 무겁습니다.',         '2025-06-02 10:00:00'),
    (3,  '무면허',      '무면허 운전 시 즉시 변호사 상담을 권장합니다.', '2025-06-03 10:00:00'),
    (4,  '보험',        '보험사와 분쟁 시 모든 증거를 보관하세요.',     '2025-06-04 10:00:00'),
    (5,  '과실비율',    '과실비율은 판례와 실제 상황에 따라 달라집니다.', '2025-06-05 10:00:00'),
    (6,  '자전거',      '자전거 사고도 보험금 청구가 가능합니다.',     '2025-06-06 10:00:00'),
    (7,  '면허정지',    '면허정지 처분은 행정심판으로 구제 신청 가능.',  '2025-06-07 10:00:00'),
    (8,  '사고',        '교통사고 발생 시 즉시 경찰에 신고하세요.',   '2025-06-08 10:00:00'),
    (9,  '행정처분',    '행정처분 통지 후 90일 이내에 이의 신청.',       '2025-06-09 10:00:00'),
    (10, '사망사고',    '사망사고는 반드시 변호사와 상담하세요.',       '2025-06-10 10:00:00'),
    (11, '블랙박스',    '블랙박스 영상은 가장 중요한 증거입니다.',     '2025-06-11 10:00:00'),
    (12, '합의',        '합의는 서면으로 명확하게 남기세요.',           '2025-06-12 10:00:00'),
    (13, '경찰조사',    '경찰조사 전 변호사 상담이 필요합니다.',       '2025-06-13 10:00:00'),
    (14, '상해진단',    '상해진단서는 사고 직후 바로 받으세요.',       '2025-06-14 10:00:00'),
    (15, '민사소송',    '민사소송 진행 전 전문가 조언을 들으세요.',    '2025-06-15 10:00:00'),
    (16, '보험사',      '보험사는 합의금 지급에 소극적일 수 있습니다.', '2025-06-16 10:00:00'),
    (17, '대인배상',    '대인배상 청구는 피해 사실 입증이 중요합니다.', '2025-06-17 10:00:00'),
    (18, '과실',        '과실비율 산정은 CCTV, 진술, 현장사진 참고.',   '2025-06-18 10:00:00'),
    (19, '특례법',      '교통사고처리 특례법 적용 여부가 중요합니다.', '2025-06-19 10:00:00'),
    (20, '피해자',      '피해자 진술은 상세하게 남기세요.',           '2025-06-20 10:00:00'),
    (21, '벌금',        '벌금은 법원 판결 후 납부 가능합니다.',         '2025-06-21 10:00:00'),
    (22, '손해배상',    '손해배상 청구는 기한 내 신청해야 합니다.',    '2025-06-22 10:00:00'),
    (23, '형사합의',    '형사합의는 반드시 서면으로 진행하세요.',       '2025-06-23 10:00:00'),
    (24, '휴업손해',    '휴업손해는 실제 휴업일수로 계산.',             '2025-06-24 10:00:00'),
    (25, '대물배상',    '대물배상은 견적서, 사진 등 증빙 필요.',       '2025-06-25 10:00:00'),
    (26, '교통비',      '치료비 외 교통비도 청구 가능.',               '2025-06-26 10:00:00'),
    (27, '진단서',      '진단서는 사고 후 바로 발급받으세요.',         '2025-06-27 10:00:00'),
    (28, '벌점',        '벌점 누적 시 면허 정지 위험.',               '2025-06-28 10:00:00'),
    (29, '휴차료',      '휴차료는 사업자 차량에 한해 청구 가능.',       '2025-06-29 10:00:00');

-- 방송 키워드
INSERT INTO `keyword`
(`schedule_no`, `keyword`, `created_at`)
VALUES
    (1,  '음주운전',  '2025-05-31 09:10:00'),
    (2,  '뺑소니',    '2025-06-01 10:15:00'),
    (3,  '무면허',    '2025-06-03 10:25:00'),
    (4,  '보험',      '2025-06-04 11:30:00'),
    (5,  '과실분쟁',  '2025-06-05 11:55:00'),
    (6,  '자전거사고','2025-06-06 12:10:00'),
    (7,  '면허정지',  '2025-06-07 12:45:00'),
    (8,  '행정처분',  '2025-06-08 13:20:00'),
    (9,  '사망사고',  '2025-06-09 14:00:00'),
    (10, '블랙박스',  '2025-06-10 15:00:00'),
    (11, '합의',      '2025-06-11 16:10:00'),
    (12, '경찰조사',  '2025-06-12 17:20:00'),
    (13, '상해진단',  '2025-06-13 18:00:00'),
    (14, '민사소송',  '2025-06-14 19:30:00'),
    (15, '보험사',    '2025-06-15 20:40:00'),
    (16, '대인배상',  '2025-06-16 21:10:00'),
    (17, '특례법',    '2025-06-17 22:20:00'),
    (18, '피해자',    '2025-06-18 23:00:00'),
    (19, '벌금',      '2025-06-19 23:59:00'),
    (20, '손해배상',  '2025-06-20 08:20:00'),
    (21, '형사합의',  '2025-06-21 09:30:00'),
    (22, '휴업손해',  '2025-06-22 11:40:00'),
    (23, '대물배상',  '2025-06-23 12:00:00'),
    (24, '교통비',    '2025-06-24 13:00:00'),
    (25, '진단서',    '2025-06-25 14:10:00'),
    (26, '벌점',      '2025-06-26 15:00:00'),
    (27, '휴차료',    '2025-06-27 16:00:00'),
    (28, '소송',      '2025-06-28 17:00:00'),
    (29, '과실100',   '2025-06-29 18:00:00'),
    (30, '기타',      '2025-06-30 19:00:00');

-- 키워드 알림
INSERT INTO `keyword_alert`
(`user_no`, `keyword`, `created_at`)
VALUES
    (1,  '음주운전',  '2025-06-01 09:01:00'),
    (2,  '뺑소니',    '2025-06-01 10:11:00'),
    (3,  '무면허',    '2025-06-01 11:12:00'),
    (4,  '보험',      '2025-06-02 12:13:00'),
    (5,  '과실분쟁',  '2025-06-02 13:14:00'),
    (6,  '자전거사고','2025-06-03 14:15:00'),
    (7,  '면허정지',  '2025-06-03 15:16:00'),
    (8,  '행정처분',  '2025-06-04 16:17:00'),
    (9,  '사망사고',  '2025-06-04 17:18:00'),
    (10, '블랙박스',  '2025-06-05 18:19:00'),
    (11, '합의',      '2025-06-06 09:20:00'),
    (12, '경찰조사',  '2025-06-06 10:21:00'),
    (13, '상해진단',  '2025-06-07 11:22:00'),
    (14, '민사소송',  '2025-06-07 12:23:00'),
    (15, '보험사',    '2025-06-08 13:24:00'),
    (16, '대인배상',  '2025-06-08 14:25:00'),
    (17, '특례법',    '2025-06-09 15:26:00'),
    (18, '피해자',    '2025-06-09 16:27:00'),
    (19, '벌금',      '2025-06-10 17:28:00'),
    (20, '손해배상',  '2025-06-10 18:29:00'),
    (21, '형사합의',  '2025-06-11 09:30:00'),
    (22, '휴업손해',  '2025-06-11 10:31:00'),
    (23, '대물배상',  '2025-06-12 11:32:00'),
    (24, '교통비',    '2025-06-12 12:33:00'),
    (25, '진단서',    '2025-06-13 13:34:00'),
    (26, '벌점',      '2025-06-13 14:35:00'),
    (27, '휴차료',    '2025-06-14 15:36:00'),
    (28, '소송',      '2025-06-14 16:37:00'),
    (29, '과실100',   '2025-06-15 17:38:00'),
    (1,  '기타',      '2025-06-15 18:39:00');

-- 방송 VOD
INSERT INTO `broadcast_vod`
(`broadcast_no`, `vod_path`, `duration`, `view_count`, `status`, `created_at`)
VALUES
    (1,  '/vods/broadcast1.mp4',   62, 172, 0, '2025-06-03 16:00:00'),
    (2,  '/vods/broadcast2.mp4',   80, 141, 0, '2025-06-12 20:05:00'),
    (3,  '/vods/broadcast5.mp4',   85, 337, 0, '2025-06-18 23:00:00'),
    (4,  '/vods/broadcast6.mp4',   60,  55, 0, '2025-06-05 17:00:00'),
    (5,  '/vods/broadcast7.mp4',   74, 402, 0, '2025-06-20 16:00:00'),
    (6,  '/vods/broadcast9.mp4',   63,  44, 0, '2025-06-10 22:00:00'),
    (7,  '/vods/broadcast1.mp4',   62, 172, 0, '2025-06-03 16:00:00'),
    (8,  '/vods/broadcast2.mp4',   80, 141, 0, '2025-06-12 20:05:00'),
    (9,  '/vods/broadcast5.mp4',   85, 337, 0, '2025-06-18 23:00:00'),
    (10,  '/vods/broadcast6.mp4',   60,  55, 0, '2025-06-05 17:00:00'),
    (11,  '/vods/broadcast7.mp4',   74, 402, 0, '2025-06-20 16:00:00'),
    (12,  '/vods/broadcast9.mp4',   63,  44, 0, '2025-06-10 22:00:00');

-- 신고 사유 코드
INSERT INTO `report_reason_code` (`code`, `label`)
VALUES ('OBSCENE', '음란성 콘텐츠'),
       ('ILLEGAL', '불법성 콘텐츠'),
       ('COPYRIGHT', '저작권 침해'),
       ('HATE', '혐오/차별 표현'),
       ('INSULT', '욕설/비방/모욕'),
       ('ETC', '기타');

-- 방송 신고
INSERT INTO `broadcast_report`
(`broadcast_no`, `user_no`, `reason_code`, `detail_reason`, `created_at`)
VALUES
    (1,  1,  'ETC',    '도배성 채팅이 너무 많음',        '2025-06-04 10:00:00'),
    (2,  2,  'HATE',   '욕설이 반복적으로 나옴',        '2025-06-12 21:00:00'),
    (3,  3,  'ETC',    '사실과 다른 정보를 제공함',     '2025-06-13 09:15:00'),
    (4,  4,  'INSULT','출연자가 위협적인 발언을 했음',  '2025-06-04 11:12:00'),
    (5,  5,  'ETC',    '홍보성 멘트가 계속 나옴',        '2025-06-19 11:10:00'),
    (6,  6,  'ETC',    '방송 중 이상한 소리가 들림',    '2025-06-09 11:11:00'),
    (7,  7,  'HATE',   '특정 집단 비하 내용 포함',      '2025-06-12 11:31:00');




-- 채팅 신고
INSERT INTO `chat_report`
(`user_no`, `reported_user_no`, `nickname`, `message`, `report_status`, `created_at`)
VALUES
    (8,  7, '정유진02',       '변호사 뭐함?',         1, '2025-06-30 09:50:00'),
    (19, 20, 'Kkolcho',        '진상 부리지 마',               1, '2025-06-30 09:50:00'),
    (22, 21, '해운대',         '쓰레기 같은 놈',                  1, '2025-06-30 09:00:00'),
    (28, 27, '판교사랑이정수', '진짜 뻔뻔하네 너',                  1, '2025-06-30 09:35:00'),
    (7,  6, '박건희01',      '너 진짜 찐이냐?',                   0, '2025-06-05 12:00:00'),
    (7,  6, '박건희01',      '누가 니 좋아해?',                   0, '2025-06-05 12:01:00'),
    (7,  6, '박건희01',      '미친 듯이 불쾌하다',                0, '2025-06-05 12:02:00'),
    (7,  6, '박건희01',      '개념 좀 챙겨라',                    0, '2025-06-05 12:03:00'),
    (7,  6, '박건희01',      '쓰레기 이하 인생이네',              0, '2025-06-05 12:04:00'),
    (7,  6, '박건희01',      '개 역겹다',                       0, '2025-06-05 12:05:00'),
    (7,  6, '박건희01',      '이딴 걸 왜 보냐',                  0, '2025-06-05 12:06:00'),
    (7,  6, '박건희01',      '진짜 폐급이야',                     0, '2025-06-05 12:07:00'),
    (7,  6, '박건희01',      '니가 뭔데 참견이야',               0, '2025-06-05 12:08:00'),
    (7,  6, '박건희01',      '차라리 꺼져버려',                   0, '2025-06-05 12:09:00'),
    (21,20, '수성구',         '진짜 혈압 오른다',                  1, '2025-06-30 09:51:00'),
    (27, 26, 'test7777',       '이거 완전 쓰레기 수준이네',         1, '2025-06-30 09:30:00'),
    (29, 28, '타타타 사후르',   '더 이상 참을 수 없다',               1, '2025-06-30 09:45:00');


-- 예약 테이블 관련 추가 필드
ALTER TABLE reservations
    ADD COLUMN requested_slot_no BIGINT
        GENERATED ALWAYS AS (
            CASE WHEN status = 'REQUESTED' THEN slot_no ELSE NULL END
            ) STORED;

ALTER TABLE reservations
    ADD UNIQUE INDEX uq_requested_slot (requested_slot_no);