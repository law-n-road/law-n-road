<script setup>
import { ref, watchEffect, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import AccountFrame from '@/components/layout/account/AccountFrame.vue'
import { useLawyerStore } from '@/stores/lawyer'

const token = localStorage.getItem('token')
if (token) {
  axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
}

const router = useRouter()
const route = useRoute()
const lawyerStore = useLawyerStore()

const tab = ref('client')

watchEffect(() => {
  const queryType = route.query.type
  if (queryType === 'lawyer' || queryType === 'client') {
    tab.value = queryType
  }
})

const clientId = ref('')
const password = ref('')


const naverLogin = () => {
  // console.log("네이버 소셜 로그인 진입 중 ..")
  // alert("naverLogin 호출됨")
  const redirectUri = encodeURIComponent('http://localhost:5173/login')
  // alert(redirectUri)

  window.location.href = 'http://localhost:8080/oauth2/authorization/naver'
  // const API_BASE = import.meta.env.VITE_API_BASE || 'https://lawnroad.kr'
  // window.location.href = 'https://lawnroad.kr/oauth2/authorization/naver'



  // window.location.origin은 현재 웹사이트의 프로토콜 + 도메인 + 포트를 의미
  // 로컬 상황 : http://localhost:5173 + '/login'
  // 배포 상황 : https://lawnroad.kr  + '/login'
  // const redirectUri = encodeURIComponent(window.location.origin + '/login')
  // window.location.href = `${__API_BASE__}/oauth2/authorization/naver?redirect_uri=${redirectUri}`
}

const submitLogin = async () => {
  try {
    console.log('📨 로그인 요청 데이터:', {
      clientId: clientId.value,
      password: password.value,
      type: tab.value
    })

    const res = await axios.post('/api/auth/login', {
      clientId: clientId.value,
      password: password.value,
      type: tab.value
    })

    console.log('✅ 로그인 성공 응답:', res.data)

    const { accessToken, refreshToken, name, nickname, no ,phone} = res.data

    localStorage.setItem('token', accessToken)
    localStorage.setItem('refreshToken', refreshToken)
    localStorage.setItem('accountType', tab.value)
    localStorage.setItem('name', name)
    localStorage.setItem('nickname', nickname)
    localStorage.setItem('no', no)
    localStorage.setItem('phone', phone)

    console.log('🚨🚨🚨 localStorage 저장 완료! 🚨🚨🚨')
    console.log('💾 localStorage 저장된 데이터:', {
      token: localStorage.getItem('token'),
      refreshToken: localStorage.getItem('refreshToken'),
      accountType: localStorage.getItem('accountType'),
      name: localStorage.getItem('name'),
      nickname: localStorage.getItem('nickname'),
      phone: localStorage.getItem('phone')
    })

    axios.defaults.headers.common["Authorization"] = `Bearer ${accessToken}`

    if (tab.value === 'lawyer') {
      try {
        console.log('🔍 lawyerNo:', no)
        setTimeout(async () => {
          await lawyerStore.fetchLawyerInfo(no)
        }, 100)
        console.log('✅ fetchLawyerInfo 성공')
      } catch (e) {
        console.error('❌ fetchLawyerInfo 실패:', e)
        alert('변호사 정보 불러오기 실패')
        return
      }
    }

    const redirect = route.query.redirect || (tab.value === 'lawyer' ? '/lawyer' : '/')
    router.push(redirect)

  } catch (err) {
    console.error('❌ 로그인 실패:', err)
    if (err.response) {
      alert(`로그인 실패: ${err.response.data}`)
    } else {
      alert('로그인 정보가 일치하지 않습니다.')
    }
  }
}

function parseJwt(token) {
  try {
    let base64 = token.split('.')[1]
    base64 = base64.replace(/-/g, '+').replace(/_/g, '/')
    while (base64.length % 4 !== 0) base64 += '='
    return JSON.parse(atob(base64))
  } catch (e) {
    console.error('❌ JWT 파싱 실패:', e)
    return null
  }
}

watchEffect(async () => {
  const queryToken = route.query.token
  if (queryToken) {
    try {
      const decoded = parseJwt(queryToken)
      const { no, nickname, role } = decoded

      localStorage.setItem('token', queryToken)
      localStorage.setItem('nickname', nickname)
      localStorage.setItem('no', no)
      localStorage.setItem('accountType', role.toLowerCase())

      axios.defaults.headers.common['Authorization'] = `Bearer ${queryToken}`

      if (role === 'LAWYER') {
        await lawyerStore.fetchLawyerInfo(no)
        router.replace('/lawyer')
      } else {
        router.replace('/')
      }
    } catch (e) {
      console.error('소셜 로그인 JWT 처리 실패:', e)
      alert('소셜 로그인 실패')
    }
  }
})
</script>

<template>
  <AccountFrame>
    <section class="w-100" style="max-width: 420px;">
      <div class="btn-group w-100 mb-4">
        <button
            class="btn"
            :class="tab === 'client' ? 'btn-primary' : 'btn-outline-secondary'"
            @click="tab = 'client'"
        >
          의뢰인 로그인
        </button>
        <button
            class="btn"
            :class="tab === 'lawyer' ? 'btn-primary' : 'btn-outline-secondary'"
            @click="tab = 'lawyer'"
        >
          변호사 로그인
        </button>
      </div>

      <form @submit.prevent="submitLogin">
        <div class="mb-3">
          <input v-model="clientId" type="text" class="form-control" placeholder="아이디" required />
        </div>

        <div class="mb-3">
          <input v-model="password" type="password" class="form-control" placeholder="비밀번호" required />
        </div>

        <div class="d-flex justify-content-between align-items-center mb-3">

          <router-link to="/forgot-password" class="small">아이디/비밀번호 찾기</router-link>
        </div>

        <button type="submit" class="btn btn-primary w-100">로그인</button>
      </form>

      <div class="text-center mt-3">
        <span class="small text-muted">
          {{ tab === 'client' ? '아직 계정이 없으신가요?' : '변호사 계정이 없으신가요?' }}
        </span>
        <router-link
            :to="tab === 'client' ? '/signup/client' : '/signup/lawyer'"
            class="ms-1 small"
        >
          {{ tab === 'client' ? '회원가입' : '변호사 회원가입' }}
        </router-link>
      </div>

      <!-- ✅ 소셜 로그인 버튼: 의뢰인 탭일 때만 보이게 -->
      <div v-if="tab === 'client'" class="text-center mt-4">
        <button class="btn btn-outline-success w-100" @click="naverLogin">
          네이버로 로그인
        </button>
      </div>
    </section>
  </AccountFrame>
</template>

<style scoped>
.btn-group .btn {
  flex: 1 1 0;
}
</style>