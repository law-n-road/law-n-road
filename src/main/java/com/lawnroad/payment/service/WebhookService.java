package com.lawnroad.payment.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lawnroad.payment.mapper.PaymentMapper;
import com.lawnroad.payment.mapper.WebhookMapper;
import com.lawnroad.payment.model.WebhookVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WebhookService {

    private final WebhookMapper webhookMapper;
    private final PaymentMapper paymentMapper;
    private final ObjectMapper objectMapper;

    public WebhookService(WebhookMapper webhookMapper,
                          PaymentMapper paymentMapper,
                          ObjectMapper objectMapper) {
        this.webhookMapper = webhookMapper;
        this.paymentMapper = paymentMapper;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public void saveWebhook(JsonNode json) {
        try {
            String eventType = json.get("type").asText("UNKNOWN");
            JsonNode data = json.get("data");
            String paymentKey = data.get("paymentKey").asText();

            Long paymentNo = paymentMapper.findPaymentNoByPaymentKey(paymentKey);

            WebhookVO log = new WebhookVO();
            log.setEventType(eventType);
            log.setPaymentNo(paymentNo);
            log.setPayload(objectMapper.writeValueAsString(json));
            log.setProcessed(true);
            log.setErrorMessage(null);

            webhookMapper.insert(log);

        } catch (Exception e) {
            e.printStackTrace();
            try {
                WebhookVO log = new WebhookVO();
                log.setEventType(json.has("type") ? json.get("type").asText() : "UNKNOWN");
                log.setPaymentNo(null);
                log.setPayload(json.toString());
                log.setProcessed(false);
                log.setErrorMessage(e.getMessage().length() > 255
                        ? e.getMessage().substring(0, 255)
                        : e.getMessage());

                webhookMapper.insert(log);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

}
