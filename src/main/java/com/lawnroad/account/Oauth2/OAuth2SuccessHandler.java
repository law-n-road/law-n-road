package com.lawnroad.account.Oauth2;


import com.lawnroad.account.entity.ClientEntity;
import com.lawnroad.account.mapper.ClientMapper;
import com.lawnroad.account.service.RefreshTokenService;
import com.lawnroad.common.util.JwtTokenUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class  OAuth2SuccessHandler implements AuthenticationSuccessHandler {

    // 개발인지 배포인지 검사
    @Value("${spring.profiles.active:}")
    private String activeProfile;

    private final JwtTokenUtil jwtTokenUtil;
    private final ClientMapper clientMapper;
    private final RefreshTokenService refreshTokenService;


//    public void onAuthenticationSuccess(HttpServletRequest request,
//                                        HttpServletResponse response,
//                                        Authentication authentication) throws IOException {
//
//        // OAuth2User에서 이메일 추출
//        String email = (String) ((org.springframework.security.oauth2.core.user.DefaultOAuth2User)
//                authentication.getPrincipal()).getAttributes().get("email");
//
//        ClientEntity client = clientMapper.findByClientId(email);
//        if (client == null) {
//            response.sendRedirect("/login?error=missing_user");
//            return;
//        }
//
//        String accessToken = jwtTokenUtil.generateAccessToken(client.getClientId(), client.getNo(), "CLIENT", client.getNickname());
//        String refreshToken = jwtTokenUtil.generateRefreshToken(client.getClientId());
//        System.out.println("✅ 소셜 로그인 성공 핸들러 진입 완료");
//        String redirectUri = "http://localhost:5173/naver-login"
//                + "?token=" + accessToken
//                + "&refresh=" + refreshToken
//                + "&nickname=" + client.getNickname();
//
//        System.out.println("🔁 리디렉션 주소: " + redirectUri);  // << 이 줄을 추가하세요
//        response.sendRedirect(redirectUri);                    // << 이 줄은 이미 있으실 것
//
//
//        // 프론트엔드로 리다이렉트 (쿼리 파라미터로 토큰 전달)
//        response.sendRedirect("http://localhost:5173/naver-login?token=" + accessToken + "&refresh=" + refreshToken + "&nickname=" + client.getNickname());
//    }

@Override
public void onAuthenticationSuccess(HttpServletRequest request,
                                    HttpServletResponse response,
                                    Authentication authentication) throws IOException {



    String email = (String) ((DefaultOAuth2User) authentication.getPrincipal())
            .getAttributes().get("email");
    System.out.println(email);

    ClientEntity client = clientMapper.findByClientId(email);
    if (client == null) {
        response.sendRedirect("/login?error=missing_user");
        return;
    }

    String accessToken = jwtTokenUtil.generateAccessToken(
            client.getClientId(), client.getNo(), "CLIENT", client.getNickname(),client.getPhone());
    String refreshToken = jwtTokenUtil.generateRefreshToken(client.getClientId());

    // ✅ DB에 RefreshToken 저장
    refreshTokenService.save(client.getNo(), refreshToken);

    // ✅ 한글 nickname 인코딩
    String encodedNickname = URLEncoder.encode(client.getNickname(), StandardCharsets.UTF_8);

    // 프로필에 따라 redirect URI 분기
//    String baseUrl = "dev".equals(activeProfile)
//        ? "http://localhost:5173/naver-login"
//        : "https://lawnroad.kr/naver-login";
    String baseUrl = "http://localhost:5173/naver-login";
//    String baseUrl = "prod".equals(activeProfile)
//            ? "https://lawnroad.kr/#/naver-login"
//            : "http://localhost:5173/#/naver-login";
    // ✅ 추가 정보 포함한 URI 조합
    String redirectUri = baseUrl
            + "?token=" + accessToken
            + "&refresh=" + refreshToken
            + "&nickname=" + encodedNickname
            + "&no=" + client.getNo()
            + "&accountType=CLIENT";  // 또는 client.getRole() 등으로 변경 가능

    System.out.println("🔁 리디렉션 주소: " + redirectUri);


    response.sendRedirect(redirectUri);
}




}
