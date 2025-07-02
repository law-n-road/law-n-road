<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import AccountFrame from '@/components/layout/account/AccountFrame.vue'

const router = useRouter()

const adminId = ref('')
const password = ref('')

const submitAdminLogin = async () => {
  try {
    const res = await axios.post('/api/auth/admin/login', {
      adminId: adminId.value,
      password: password.value,
    })

    const { accessToken, refreshToken, name } = res.data

    localStorage.setItem('token', accessToken)
    localStorage.setItem('refreshToken', refreshToken)
    localStorage.setItem('accountType', 'admin')
    localStorage.setItem('name', name)

    console.log(localStorage.getItem('token'))
    console.log(localStorage.getItem('accountType'))
    console.log(localStorage.getItem('name'))



    axios.defaults.headers.common['Authorization'] = `Bearer ${accessToken}`

    router.push('/admin')
  } catch (err) {
    console.error('관리자 로그인 실패:', err)
    if (err.response) {
      alert(`로그인 실패: ${err.response.data}`)
    } else {
      alert('네트워크 오류 또는 서버 응답 없음')
    }
  }
}
</script>

<template>
  <AccountFrame>
    <section class="w-100" style="max-width: 420px;">
      <h3 class="text-center mb-4">관리자 로그인</h3>

      <form @submit.prevent="submitAdminLogin">
        <div class="mb-3">
          <input
              v-model="adminId"
              type="text"
              class="form-control"
              placeholder="관리자 아이디"
              required
          />
        </div>

        <div class="mb-3">
          <input
              v-model="password"
              type="password"
              class="form-control"
              placeholder="비밀번호"
              required
          />
        </div>

        <button type="submit" class="btn btn-primary w-100">로그인</button>
      </form>

      <div class="text-center mt-3">
        <router-link to="/" class="small">← 메인페이지로 돌아가기</router-link>
      </div>
    </section>
  </AccountFrame>
</template>

<style scoped>
.btn-group .btn {
  flex: 1 1 0;
}
</style>
