package com.lawnroad.account.controller;


import com.lawnroad.account.service.MailService;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
//@CrossOrigin(origins = "https://example.com")
@RestController
@RequestMapping("/mail")
public class MailController {

    private final MailService mailService;
    private final Map<String, String> authStorage = new ConcurrentHashMap<>();

    public MailController(MailService mailService) {
        this.mailService = mailService;
    }

    @PostMapping("/send")
    public String sendCode(@RequestParam String email) {
        String code = mailService.sendAuthCode(email);
        authStorage.put(email, code);
        return "인증번호 전송 완료";
    }

    @PostMapping("/verify")
    public String verifyCode(@RequestParam String email, @RequestParam String code) {
        String stored = authStorage.get(email);
        return code.equals(stored) ? "인증 성공" : "인증 실패";
    }


}
