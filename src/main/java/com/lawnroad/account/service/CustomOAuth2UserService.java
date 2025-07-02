package com.lawnroad.account.service;

import com.lawnroad.account.entity.ClientEntity;
import com.lawnroad.account.entity.UserEntity;
import com.lawnroad.account.mapper.ClientMapper;
import com.lawnroad.account.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {
    private final UserMapper userMapper;
    private final ClientMapper clientMapper;



    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest)
            throws OAuth2AuthenticationException {

        OAuth2User oAuth2User = super.loadUser(userRequest);
        Map<String, Object> response = (Map<String, Object>) oAuth2User.getAttributes().get("response");

        String email = (String) response.get("email");
        String name = (String) response.get("name");
        String naverId = (String) response.get("id");
        String nickname = (String) response.get("nickname");
        String phone = (String) response.get("mobile");



        if (clientMapper.findBySocialId(naverId) == null) {
            // 1. user 테이블 삽입
            UserEntity user = new UserEntity();
            user.setType("CLIENT");
            userMapper.insertUser(user);
            // 2. client 테이블 삽입
            ClientEntity client = new ClientEntity();
            client.setNo(user.getNo());
            client.setClientId(email);
            client.setPwHash("");
            client.setEmail(email);
            client.setName(name);
            client.setNickname(nickname);
            client.setPhone(phone);
            client.setContent(1);
            client.setAlert_content(1);
            client.setIs_consult_alert(1);
            client.setSocial_id(naverId); // 소셜 ID 저장

            clientMapper.insertClientBySocial(client);
        }

        return new DefaultOAuth2User(
                Collections.singleton(new SimpleGrantedAuthority("ROLE_CLIENT")),
                response,
                "email"
        );
    }
}
