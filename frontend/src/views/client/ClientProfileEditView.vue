<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { makeApiRequest } from '@/libs/axios-auth.js'

const router = useRouter()

const originalNickname = localStorage.getItem('nickname') || ''
const originalEmail = localStorage.getItem('email') || ''
const originalPhone = localStorage.getItem('phone') || ''

const nickname = ref(originalNickname)
const phone = ref(originalPhone)

const isNicknameAvailable = ref(true)
const isEmailVerified = ref(true)

const emailId = ref(originalEmail.split('@')[0] || '')
const domainList = ['gmail.com', 'naver.com', 'daum.net', 'custom']
const savedDomain = originalEmail.split('@')[1] || 'gmail.com'
const emailDomainSelect = ref(domainList.includes(savedDomain) ? savedDomain : 'custom')
const emailDomainCustom = ref(emailDomainSelect.value === 'custom' ? savedDomain : '')

const email = computed(() => {
  return (
      emailId.value + '@' +
      (emailDomainSelect.value === 'custom' ? emailDomainCustom.value : emailDomainSelect.value)
  )
})

const authCode = ref('')

// ✅ 이메일 변경 시 인증 상태 초기화
watch(email, (newVal) => {
  if (newVal !== originalEmail) {
    isEmailVerified.value = false
  } else {
    isEmailVerified.value = true
  }
})

onMounted(async () => {
  try {
    const res = await makeApiRequest({ method: 'get', url: '/api/client/profile' })
    if (res?.data) {
      nickname.value = res.data.nickname
      phone.value = res.data.phone
      const [id, domain] = res.data.email.split('@')
      emailId.value = id
      if (domainList.includes(domain)) {
        emailDomainSelect.value = domain
        emailDomainCustom.value = ''
      } else {
        emailDomainSelect.value = 'custom'
        emailDomainCustom.value = domain
      }
    }
  } catch (err) {
    console.error('프로필 조회 실패:', err)
  }
})

async function checkNicknameDuplicate() {
  if (!nickname.value.trim()) {
    alert('닉네임을 입력해주세요.')
    return
  }

  try {
    const res = await makeApiRequest({
      method: 'get',
      url: `/api/auth/check-nickname`,
      params: { nickname: nickname.value }
    })

    if (res.data.available || nickname.value === originalNickname) {
      alert('✅ 사용 가능한 닉네임입니다.')
      isNicknameAvailable.value = true
    } else {
      alert('❌ 이미 사용 중인 닉네임입니다.')
      isNicknameAvailable.value = false
    }
  } catch (err) {
    console.error(err)
    alert('닉네임 중복 확인 중 오류 발생')
  }
}

async function requestEmailCode() {
  if (!email.value.trim()) {
    alert('이메일을 입력해주세요.')
    return
  }

  try {
    const res = await makeApiRequest({
      method: 'get',
      url: '/api/auth/check-email',
      params: { email: email.value }
    })

    if (!res.data.available && email.value !== originalEmail) {
      alert('❌ 이미 가입된 이메일입니다.')
      return
    }

    await makeApiRequest({
      method: 'post',
      url: '/mail/send',
      params: { email: email.value }
    })

    isEmailVerified.value = false
    alert('✅ 인증번호가 전송되었습니다.')
  } catch (err) {
    console.error('이메일 인증 요청 실패:', err)
    alert('이메일 인증 요청 중 오류 발생')
  }
}

async function verifyEmailCode() {
  if (!email.value.trim() || !authCode.value.trim()) {
    alert('이메일과 인증번호를 입력해주세요.')
    return
  }

  try {
    const res = await makeApiRequest({
      method: 'post',
      url: '/mail/verify',
      params: {
        email: email.value,
        code: authCode.value
      }
    })

    if (res.data === '인증 성공') {
      isEmailVerified.value = true
      alert('✅ 이메일 인증이 완료되었습니다.')
    } else {
      alert('❌ 인증번호가 일치하지 않습니다.')
    }
  } catch (err) {
    console.error('이메일 인증 실패:', err)
    alert('이메일 인증 중 오류 발생')
  }
}

const updateProfile = async () => {
  if (!nickname.value.trim() || !email.value.trim() || !phone.value.trim()) {
    alert('모든 정보를 입력해주세요.')
    return
  }

  if (!isNicknameAvailable.value && nickname.value !== originalNickname) {
    alert('❌ 닉네임 중복 확인을 먼저 해주세요.')
    return
  }

  if (!isEmailVerified.value && email.value !== originalEmail) {
    alert('❌ 이메일 인증을 완료해주세요.')
    return
  }

  try {
    const res = await makeApiRequest({
      method: 'put',
      url: '/api/client/profile',
      data: {
        nickname: nickname.value,
        email: email.value,
        phone: phone.value
      }
    })

    localStorage.setItem('nickname', nickname.value)
    localStorage.setItem('email', email.value)
    localStorage.setItem('phone', phone.value)

    alert('✅ 프로필이 성공적으로 수정되었습니다.')
    router.push('/client/mypage')
  } catch (err) {
    console.error('❌ 프로필 수정 실패:', err)
    alert('서버 오류 또는 권한 문제가 발생했습니다.')
  }
}

const withdrawAccount = async () => {
  if (!confirm('정말로 회원 탈퇴하시겠습니까?')) return
  try {
    await makeApiRequest({ method: 'delete', url: '/api/client/withdraw' })
    localStorage.clear()
    alert('회원 탈퇴가 완료되었습니다.')
    router.push('/')
  } catch (err) {
    console.error('회원 탈퇴 실패:', err)
    alert('탈퇴 중 오류가 발생했습니다.')
  }
}
</script>


<template>
  <div class="mypage-wrapper">
    <h2 class="page-title">프로필 관리</h2>
    <p class="welcome-msg">안녕하세요, {{ nickname }}님! 회원정보를 수정하실 수 있습니다.</p>

    <div class="info-card">
      <h5 class="section-title">기본 정보 수정</h5>

      <!-- 닉네임 입력 -->
      <div class="form-group">
        <label for="nickname">닉네임</label>
        <div class="input-with-button">
          <input id="nickname" v-model="nickname" class="form-control" placeholder="새 닉네임 입력" />
          <button class="btn btn-outline-secondary" @click="checkNicknameDuplicate">중복 확인</button>
        </div>
      </div>

      <!-- 이메일 입력 -->
      <div class="form-group">
        <label>이메일</label>
        <div class="email-input-group">
          <input v-model="emailId" class="form-control email-id" placeholder="아이디" />
          <span class="at-symbol">@</span>
          <select v-model="emailDomainSelect" class="form-control domain-select">
            <option value="gmail.com">gmail.com</option>
            <option value="naver.com">naver.com</option>
            <option value="daum.net">daum.net</option>
            <option value="custom">직접입력</option>
          </select>
          <input
              v-if="emailDomainSelect === 'custom'"
              v-model="emailDomainCustom"
              class="form-control custom-domain"
              placeholder="도메인"
          />
          <button class="btn btn-outline-secondary" @click="requestEmailCode">인증요청</button>
        </div>
        <p class="current-email">현재 이메일: {{ email }}</p>

        <!-- 이메일 인증번호 확인 -->
        <div class="verification-group">
          <input
              class="form-control auth-code"
              v-model="authCode"
              placeholder="인증번호 입력"
          />
          <button class="btn btn-outline-secondary" @click="verifyEmailCode">인증확인</button>
        </div>
      </div>

      <!-- 전화번호 입력 -->
      <div class="form-group">
        <label for="phone">전화번호</label>
        <input id="phone" v-model="phone" class="form-control" placeholder="전화번호 입력" />
      </div>

      <!-- 버튼 그룹 -->
      <div class="btn-group">
        <button class="btn btn-primary" @click="updateProfile">수정 완료</button>
        <button class="btn btn-primary" @click="withdrawAccount">회원 탈퇴</button>
        <button class="btn btn-primary" @click="router.push('/')">
          홈으로
        </button>

      </div>
    </div>
  </div>
</template>

<style scoped>
.mypage-wrapper {
  max-width: 720px;
  margin: 0 auto;
  padding: 40px 16px;
}

.page-title {
  font-size: 24px;
  font-weight: bold;
  color: #2E4065;
  margin-bottom: 8px;
}

.welcome-msg {
  font-size: 16px;
  margin-bottom: 32px;
}

.info-card {
  background: #f9f9f9;
  border: 1px solid #dcdcdc;
  border-radius: 12px;
  padding: 24px;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 20px;
  border-bottom: 1px solid #ccc;
  padding-bottom: 8px;
}

.form-group {
  margin-bottom: 24px;
}

label {
  display: block;
  font-weight: 500;
  margin-bottom: 8px;
  color: #333;
}

.form-control {
  padding: 10px 12px;
  font-size: 14px;
  border: 1px solid #ccc;
  border-radius: 6px;
  transition: border-color 0.2s;
}

.form-control:focus {
  outline: none;
  border-color: #2E4065;
}

/* 닉네임 입력 그룹 */
.input-with-button {
  display: flex;
  gap: 8px;
}

.input-with-button .form-control {
  flex: 1;
}

/* 이메일 입력 그룹 */
.email-input-group {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}

.email-id {
  flex: 2;
  min-width: 120px;
}

.at-symbol {
  font-weight: bold;
  color: #444;
  padding: 0 4px;
}

.domain-select {
  flex: 2;
  min-width: 140px;
}

.custom-domain {
  flex: 2;
  min-width: 120px;
}

.current-email {
  font-size: 12px;
  color: #888;
  margin: 4px 0 12px 0;
}

/* 인증 그룹 */
.verification-group {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
}

.auth-code {
  flex: 1;
  min-width: 140px;
}

/* 버튼 스타일 */
.btn {
  padding: 10px 16px;
  font-size: 14px;
  font-weight: 600;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
}

.btn-outline-secondary {
  background-color: white;
  color: #6c757d;
  border: 1px solid #6c757d;
}

.btn-outline-secondary:hover {
  background-color: #6c757d;
  color: white;
}

.btn-primary {
  background-color: #2E4065;
  color: white;
}

.btn-primary:hover {
  background-color: #1f2d4c;
}

.btn-group {
  display: flex;
  gap: 12px;
  margin-top: 32px;
}

.btn-group .btn {
  flex: 1;
}

/* 반응형 */
@media (max-width: 480px) {
  .email-input-group {
    flex-direction: column;
    align-items: stretch;
  }

  .email-id, .domain-select, .custom-domain {
    flex: none;
  }

  .verification-group {
    flex-direction: column;
    align-items: stretch;
  }

  .btn-group {
    flex-direction: column;
  }
}
</style>