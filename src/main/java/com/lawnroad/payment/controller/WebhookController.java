package com.lawnroad.payment.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lawnroad.payment.service.WebhookService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/webhook/toss")
public class WebhookController {
    private static final org.slf4j.Logger log =
            org.slf4j.LoggerFactory.getLogger(WebhookController.class);

    private final WebhookService webhookService;
    private final ObjectMapper objectMapper;

    public WebhookController(
            WebhookService webhookService,
            ObjectMapper objectMapper
    ) {
        this.webhookService = webhookService;
        this.objectMapper = objectMapper;
    }

    @PostMapping
    public ResponseEntity<String> receiveWebhook(
            @RequestBody String payload
    ) {
        log.info("▶ Webhook received: {}", payload);

        JsonNode json;
        try {
            json = objectMapper.readTree(payload);
        } catch (JsonProcessingException e) {
            // 잘못된 JSON → 400 Bad Request
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body("Malformed JSON payload");
        }

        webhookService.saveWebhook(json);
        return ResponseEntity.ok("OK");
    }
}