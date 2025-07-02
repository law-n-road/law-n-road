package com.lawnroad.account.security;


import com.lawnroad.account.service.CustomUserDetailsService;
import com.lawnroad.common.util.JwtTokenUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

//@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenUtil jwtTokenUtil;

//
//
//
//    @Override
//    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
//            throws ServletException, IOException {
//        String header = request.getHeader("Authorization");
//
//        if (header != null && header.startsWith("Bearer ")) {
//            String token = header.substring(7);
//            if (jwtTokenUtil.validateToken(token)) {
//                String email = jwtTokenUtil.getClientIdFromToken(token);
//                UsernamePasswordAuthenticationToken authentication =
//                        new UsernamePasswordAuthenticationToken(email, null, List.of());
//                SecurityContextHolder.getContext().setAuthentication(authentication);
//            }
//        }
//        filterChain.doFilter(request, response);
//    }

//    @Override
//    protected void doFilterInternal(HttpServletRequest request,
//                                    HttpServletResponse response,
//                                    FilterChain filterChain)
//            throws ServletException, IOException {
//
//        String authHeader = request.getHeader("Authorization");
//
//        if (authHeader != null && authHeader.startsWith("Bearer ")) {
//            String token = authHeader.substring(7);
//
//            if (jwtTokenUtil.validateToken(token)) {
//                String clientId = jwtTokenUtil.getClientIdFromToken(token);
//                String role = jwtTokenUtil.getRoleFromToken(token); // "CLIENT", "LAWYER"
//
//                // ROLE_ 접두어 붙이기 (Spring Security는 ROLE_XXX 형태 필요)
//
//                System.out.println("🟢 필터 진입");
//                System.out.println("🔐 토큰: " + token);
//                System.out.println("👤 clientId: " + clientId);
//                System.out.println("🎭 role: " + role);
//                System.out.println("✅ 권한 등록: ROLE_" + role);
//
//                SimpleGrantedAuthority authority = new SimpleGrantedAuthority("ROLE_" + role);
//
//                UsernamePasswordAuthenticationToken authentication =
//                        new UsernamePasswordAuthenticationToken(clientId, null, Collections.singletonList(authority));
//
//                SecurityContextHolder.getContext().setAuthentication(authentication);
//            }
//        }
//
//        filterChain.doFilter(request, response);
//    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);

            if (jwtTokenUtil.validateToken(token)) {
                String clientId = jwtTokenUtil.getClientIdFromToken(token);
                String role = jwtTokenUtil.getRoleFromToken(token); // "CLIENT", "LAWYER"

                System.out.println("🟢 필터 진입");
                System.out.println("🔐 토큰: " + token);
                System.out.println("👤 clientId: " + clientId);
                System.out.println("🎭 role: " + role);
                System.out.println("✅ 권한 등록: ROLE_" + role);

                // ✅ UserDetails 객체로 만들어 넣어주기
                UserDetails userDetails = org.springframework.security.core.userdetails.User
                        .withUsername(clientId)
                        .password("")
                        .authorities("ROLE_" + role)
                        .build();

                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authentication);
                System.out.println(SecurityContextHolder.getContext().getAuthentication());
                System.out.println("여기까지 옴");


            }
        }

        filterChain.doFilter(request, response);
    }

}
