<!-- NaverLoginHandler.vue (또는 SocialLoginRedirect.vue 등) -->
<script setup>
import { useRoute, useRouter } from 'vue-router'
import { onMounted } from 'vue'
import axios from 'axios'

const route = useRoute()
const router = useRouter()

onMounted(() => {

  const { token, refresh, nickname,no } = route.query

  if (token && refresh) {
    // ✅ 로컬스토리지 저장
    localStorage.setItem('token', token)
    //localStorage.setItem('refreshToken', refresh)
    localStorage.setItem('nickname', nickname || '')
    localStorage.setItem('accountType', 'client') // 필요 시 계정유형도 저장
    localStorage.setItem('no',no)


    // ✅ axios Authorization 헤더 설정
    axios.defaults.headers.common['Authorization'] = `Bearer ${token}`

    console.log('✅ 소셜 로그인 토큰 저장 완료:', {
      token,

      nickname,
      no

    })

    // ✅ 원하는 경로로 이동 (예: 마이페이지)
    router.replace('/')
  } else {
    console.warn('🔴 소셜 로그인 토큰 누락 → 로그인 페이지로 이동')
    router.replace('/login')
  }
})
</script>

<template>
  <p>소셜 로그인 처리 중입니다...</p>
</template>
