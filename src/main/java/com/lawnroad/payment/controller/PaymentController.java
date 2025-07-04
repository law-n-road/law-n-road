package com.lawnroad.payment.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.lawnroad.payment.dto.PaymentConfirmRequestDTO;
import com.lawnroad.payment.dto.RefundRequestDTO;
import com.lawnroad.payment.dto.OrdersStatusUpdateDTO;
import com.lawnroad.payment.model.OrdersVO;
import com.lawnroad.payment.service.OrdersService;
import com.lawnroad.payment.service.PaymentService;
import com.lawnroad.payment.service.RefundService;
import com.lawnroad.reservation.mapper.ReservationsMapper;
import com.lawnroad.payment.mapper.PaymentMapper;
import com.lawnroad.reservation.mapper.TimeSlotMapper;
import org.springframework.http.*;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;

import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Base64;
import java.util.Map;

@RestController
@RequestMapping("/api/confirm")
public class PaymentController {

    private static final String SECRET_KEY       = "test_sk_4yKeq5bgrpoROnDY0L4XVGX0lzW6";
    private static final String TOSS_CONFIRM_URL = "https://api.tosspayments.com/v1/payments/confirm";

    private final OrdersService      ordersService;
    private final PaymentService     paymentService;
    private final RefundService      refundService;
    private final ReservationsMapper reservationsMapper;
    private final PaymentMapper      paymentMapper;
    private final TimeSlotMapper     timeSlotMapper;

    public PaymentController(
            OrdersService ordersService,
            PaymentService paymentService,
            RefundService refundService,
            ReservationsMapper reservationsMapper,
            PaymentMapper paymentMapper,
            TimeSlotMapper timeSlotMapper
    ) {
        this.ordersService      = ordersService;
        this.paymentService     = paymentService;
        this.refundService      = refundService;
        this.reservationsMapper = reservationsMapper;
        this.paymentMapper      = paymentMapper;
        this.timeSlotMapper     = timeSlotMapper;
    }

    @PostMapping("/payment")
    @Transactional
    public ResponseEntity<?> confirmPayment(@RequestBody PaymentConfirmRequestDTO req) {
        RestTemplate rt = new RestTemplate();
        String basic = Base64.getEncoder()
                .encodeToString((SECRET_KEY + ":").getBytes(StandardCharsets.UTF_8));
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Basic " + basic);

        Map<String,Object> payload = Map.of(
                "paymentKey", req.getPaymentKey(),
                "orderId",    req.getOrderId(),
                "amount",     req.getAmount()
        );
        HttpEntity<Map<String,Object>> ent = new HttpEntity<>(payload, headers);

        JsonNode root;
        try {
            ResponseEntity<JsonNode> tossResp =
                    rt.postForEntity(TOSS_CONFIRM_URL, ent, JsonNode.class);
            root = tossResp.getBody();
            if (root == null) throw new IllegalStateException("Empty Toss response");
        } catch (HttpClientErrorException | HttpServerErrorException ex) {
            String msg = extractErrorMessage(ex.getResponseBodyAsString());
            handleCompensation(req.getOrderId());
            return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .body(Map.of("message", msg));
        }

        // 결제 승인 성공 처리
        String orderCode = root.path("orderId").asText();
        OrdersVO order = ordersService.getOrderByCode(orderCode);
        if (order == null) {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "해당 주문이 없습니다."));
        }
        Long orderNo = order.getNo();

        paymentService.savePaymentFromToss(root, orderNo);
        if ("CANCELED".equals(root.path("status").asText())) {
            refundService.saveRefundFromToss(root);
        }
        OrdersStatusUpdateDTO st = new OrdersStatusUpdateDTO();
        st.setOrderNo(orderNo);
        st.setStatus("DONE".equals(root.path("status").asText()) ? "PAID" : "FAILED");
        ordersService.changeStatus(st);

        return ResponseEntity.ok(root);
    }

    @PostMapping("/cancel")
    public ResponseEntity<?> cancelPayment(@RequestBody RefundRequestDTO req) {
        try {
            if (req.getReservationNo() != null) {
                Long reservationNo = req.getReservationNo();
                var res = reservationsMapper.selectReservationByNo(reservationNo);
                if (res == null) {
                    return ResponseEntity
                            .status(HttpStatus.NOT_FOUND)
                            .body(Map.of("message", "해당 예약이 없습니다."));
                }
                Long orderNo = res.getOrderNo();
                String paymentKey = paymentMapper.findPaymentKeyByOrderNo(orderNo);
                Long amount = res.getAmount();
                req.setOrderNo(orderNo);
                req.setPaymentKey(paymentKey);
                req.setAmount(amount);
                req.setCancelReason("사용자 예약 취소 요청");
                refundService.processRefund(req);
                reservationsMapper.updateReservationStatus(reservationNo, "CANCELED");
                timeSlotMapper.resetSlotStatusByResNo(reservationNo);
                return ResponseEntity.ok(Map.of("message", "예약 환불 처리 완료"));
            } else if (req.getOrderNo() != null) {
                Long orderNo = req.getOrderNo();
                OrdersVO order = ordersService.getOrder(orderNo);
                if (order == null) {
                    return ResponseEntity
                            .status(HttpStatus.NOT_FOUND)
                            .body(Map.of("message", "해당 주문이 없습니다."));
                }
                String type = order.getOrderType();
                if (!"TEMPLATE".equals(type) && !"ADVERTISEMENT".equals(type)) {
                    return ResponseEntity
                            .badRequest()
                            .body(Map.of("message", "해당 주문은 존재하지 않습니다."));
                }
                String paymentKey = paymentMapper.findPaymentKeyByOrderNo(orderNo);
                Long amount = order.getAmount();
                req.setPaymentKey(paymentKey);
                req.setAmount(amount);
                req.setCancelReason("사용자 " + type.toLowerCase() + " 환불 요청");
                refundService.processRefund(req);
                return ResponseEntity.ok(Map.of("message", type + " 환불 처리 완료"));
            } else {
                return ResponseEntity
                        .badRequest()
                        .body(Map.of("message", "reservationNo 또는 orderNo 중 하나를 전달해야 합니다."));
            }
        } catch (IllegalArgumentException ie) {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", ie.getMessage()));
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "환불 처리 중 오류가 발생했습니다.", "error", e.getMessage()));
        }
    }

    // 에러 메시지 추출 헬퍼
    private String extractErrorMessage(String body) {
        String msg = "결제 승인 실패";
        int idx = body.indexOf("\"message\"");
        if (idx >= 0) {
            int start = body.indexOf('"', idx + 9) + 1;
            int end = body.indexOf('"', start);
            if (start > 0 && end > start) {
                msg = body.substring(start, end);
            }
        }
        return msg;
    }

    // 보상 처리 헬퍼
    private void handleCompensation(String orderCode) {
        OrdersVO order = ordersService.getOrderByCode(orderCode);
        if (order == null) return;

        Long orderNo = order.getNo();
        // orders 상태 CANCELED
        OrdersStatusUpdateDTO st = new OrdersStatusUpdateDTO();
        st.setOrderNo(orderNo);
        st.setStatus("CANCELED");
        ordersService.changeStatus(st);

        if ("RESERVATION".equals(order.getOrderType())) {
            var res = reservationsMapper.selectReservationByOrderNo(orderNo);
            if (res != null) {
                Long reservationNo = res.getNo();
                reservationsMapper.updateReservationStatus(reservationNo, "CANCELED");
                timeSlotMapper.resetSlotStatusByResNo(reservationNo);
            }
        }
    }

    @PostMapping("/cancel-reservation")
    @Transactional
    public ResponseEntity<Map<String,String>> cancelReservationOnly(
            @RequestBody Map<String, Long> req  // { "reservationNo": 123 }
    ) {
        Long reservationNo = req.get("reservationNo");
        if (reservationNo == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "reservationNo가 필요합니다."));
        }
        // 1) 예약 레코드 상태만 CANCELED
        reservationsMapper.updateReservationStatus(reservationNo, "CANCELED");
        // 2) 슬롯도 원복
        timeSlotMapper.resetSlotStatusByResNo(reservationNo);
        var res = reservationsMapper.selectReservationByNo(reservationNo);
        if (res != null && res.getOrderNo() != null) {
            OrdersStatusUpdateDTO upd = new OrdersStatusUpdateDTO();
            upd.setOrderNo(res.getOrderNo());
            upd.setStatus("CANCELED");
            ordersService.changeStatus(upd);
        }

        return ResponseEntity.ok(Map.of("message", "예약 및 주문이 취소되었습니다."));
    }
}
