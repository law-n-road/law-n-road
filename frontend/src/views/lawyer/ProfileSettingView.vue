<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import LawyerFrame from '@/components/layout/lawyer/LawyerFrame.vue'
import { makeApiRequest } from '@/libs/axios-auth.js'

const router = useRouter()

const token = localStorage.getItem('token')
const userNo = localStorage.getItem('no')

const officeNumber = ref('')
const phone = ref('')
const detailAddress = ref('')

// ✅ 주소 관련 필드
const zipcode = ref('')
const roadAddress = ref('')
const landAddress = ref('')

// 로딩 상태 관리
const isLoading = ref(false)
const isWithdrawing = ref(false)

// ✅ Daum 주소 검색 API 로드
onMounted(() => {
  const script = document.createElement('script')
  script.src = 'https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js'
  script.async = true
  document.head.appendChild(script)

  console.log('=== Lawyer Profile Edit Debug ===')
  console.log('Token:', token)
  console.log('User No:', userNo)
  console.log('================================')
})

// ✅ 주소 검색 팝업 실행 함수
function openPostcodePopup() {
  if (!window.daum || !window.daum.Postcode) {
    alert('주소 검색 API 로드 실패')
    return
  }

  new window.daum.Postcode({
    oncomplete(data) {
      zipcode.value = data.zonecode
      roadAddress.value = data.roadAddress
      landAddress.value = data.jibunAddress
    }
  }).open()
}

const updateLawyerInfo = async () => {
  if (!token || !userNo) {
    alert('로그인이 필요합니다.')
    router.push('/login')
    return
  }

  if (!officeNumber.value.trim() || !phone.value.trim() || !detailAddress.value.trim()) {
    alert('모든 필드를 입력해주세요.')
    return
  }

  isLoading.value = true

  try {
    const response = await makeApiRequest({
      method: 'put',
      url: '/api/lawyer/info',
      data: {
        officeNumber: officeNumber.value,
        phone: phone.value,
        detailAddress: detailAddress.value,
        zipcode: zipcode.value,
        roadAddress: roadAddress.value,
        landAddress: landAddress.value
      }
    })

    if (response && response.status === 200) {
      alert('✅ 정보가 성공적으로 수정되었습니다.')
      router.push('/lawyer')
    } else {
      alert('❌ 수정 요청에 실패했습니다. 다시 시도해주세요.')
    }
  } catch (error) {
    console.error('❌ 정보 수정 실패:', error)
    alert('❌ 정보 수정 중 오류가 발생했습니다.')
  } finally {
    isLoading.value = false
  }
}

const withdrawLawyerAccount = async () => {
  if (!token || !userNo) {
    alert('로그인이 필요합니다.')
    router.push('/login')
    return
  }

  const confirmResult = confirm('정말 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다.')
  if (!confirmResult) return

  isWithdrawing.value = true

  try {
    const response = await makeApiRequest({
      method: 'delete',
      url: `/api/lawyer/withdraw/${userNo}`
    })

    if (response && response.status === 200) {
      alert('계정이 탈퇴 처리되었습니다.')
      localStorage.clear()
      router.push('/')
    } else {
      alert('탈퇴 처리에 실패했습니다. 다시 시도해주세요.')
    }
  } catch (error) {
    console.error('❌ 탈퇴 오류:', error)
    alert('❌ 계정 탈퇴 중 문제가 발생했습니다.')
  } finally {
    isWithdrawing.value = false
  }
}
</script>

<template>
  <LawyerFrame>
    <div class="lawyer-container">
      <!-- 헤더 섹션 -->
      <div class="header-section">
        <div class="header-content">
          <div class="header-icon">
            <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 12C14.7614 12 17 9.76142 17 7C17 4.23858 14.7614 2 12 2C9.23858 2 7 4.23858 7 7C7 9.76142 9.23858 12 12 12Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M20.5899 22C20.5899 18.13 16.7399 15 11.9999 15C7.25991 15 3.40991 18.13 3.40991 22" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
          <div>
            <h1 class="page-title">계정 설정</h1>
            <p class="page-subtitle">사무실 정보와 연락처를 관리하세요</p>
          </div>
        </div>
      </div>

      <!-- 메인 폼 카드 -->
      <div class="form-card">
        <div class="card-header">
          <h2 class="card-title">기본 정보</h2>
          <p class="card-description">변호사 사무실 관련 정보를 입력해주세요</p>
        </div>

        <div class="form-content">
          <!-- 사무실 정보 섹션 -->
          <div class="form-section">
            <h3 class="section-title">사무실 정보</h3>

            <div class="form-group">
              <label for="officeNumber" class="form-label">
                <span class="label-text">전화번호</span>
                <span class="required">*</span>
              </label>
              <div class="input-wrapper">
                <input
                    id="officeNumber"
                    type="text"
                    class="form-input"
                    v-model="officeNumber"
                    placeholder="예: 02-1234-5678"
                />
              </div>
            </div>


            <div class="form-group">
              <label for="phone" class="form-label">
                <span class="label-text">전화번호</span>
                <span class="required">*</span>
              </label>
              <div class="input-wrapper">
                <input
                    id="phone"
                    type="tel"
                    class="form-input"
                    v-model="phone"
                    placeholder="예: 02-1234-5678"
                />
              </div>
            </div>
          </div>



          <!-- 주소 정보 섹션 -->
          <div class="form-section">
            <h3 class="section-title">주소 정보</h3>

            <div class="form-group">
              <label for="zipcode" class="form-label">
                <span class="label-text">우편번호</span>
                <span class="required">*</span>
              </label>
              <div class="address-search-group">
                <input
                    id="zipcode"
                    type="text"
                    class="form-input"
                    v-model="zipcode"
                    readonly
                    placeholder="주소 검색을 눌러주세요"
                />
                <button
                    type="button"
                    class="search-btn"
                    @click="openPostcodePopup"
                >
                  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M21 21L16.5 16.5M19 11C19 15.4183 15.4183 19 11 19C6.58172 19 3 15.4183 3 11C3 6.58172 6.58172 3 11 3C15.4183 3 19 6.58172 19 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  주소 검색
                </button>
              </div>
            </div>

            <div class="form-group">
              <label for="roadAddress" class="form-label">
                <span class="label-text">도로명 주소</span>
              </label>
              <div class="input-wrapper">
                <input
                    id="roadAddress"
                    type="text"
                    class="form-input"
                    v-model="roadAddress"
                    readonly
                    placeholder="주소 검색 후 자동 입력됩니다"
                />
              </div>
            </div>

            <div class="form-group">
              <label for="landAddress" class="form-label">
                <span class="label-text">지번 주소</span>
              </label>
              <div class="input-wrapper">
                <input
                    id="landAddress"
                    type="text"
                    class="form-input"
                    v-model="landAddress"
                    readonly
                    placeholder="주소 검색 후 자동 입력됩니다"
                />
              </div>
            </div>

            <div class="form-group">
              <label for="detailAddress" class="form-label">
                <span class="label-text">상세 주소</span>
                <span class="required">*</span>
              </label>
              <div class="input-wrapper">
                <input
                    id="detailAddress"
                    type="text"
                    class="form-input"
                    v-model="detailAddress"
                    placeholder="예: 101동 502호, 3층 등"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- 액션 버튼들 -->
        <div class="action-section">
          <button
              class="btn btn-primary"
              @click="updateLawyerInfo"
              :disabled="isLoading"
          >
            <div v-if="isLoading" class="loading-spinner"></div>
            <span v-if="!isLoading">정보 수정</span>
            <span v-else>저장 중...</span>
          </button>
        </div>
      </div>

      <!-- 위험 구역 -->
      <div class="danger-zone">
        <div class="danger-header">
          <div class="danger-icon">
            <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 9V13M12 17H12.01M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
          <div>
            <h3 class="danger-title">계정 탈퇴</h3>
            <p class="danger-description">계정을 삭제하면 모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.</p>
          </div>
        </div>

        <button
            class="btn btn-danger"
            @click="withdrawLawyerAccount"
            :disabled="isWithdrawing"
        >
          <div v-if="isWithdrawing" class="loading-spinner"></div>
          <span v-if="!isWithdrawing">계정 탈퇴</span>
          <span v-else>처리 중...</span>
        </button>
      </div>
    </div>
  </LawyerFrame>
</template>

<style scoped>
.lawyer-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px 16px;
  min-height: 100vh;
}

/* 헤더 섹션 */
.header-section {
  margin-bottom: 32px;
}

.header-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.header-icon svg {
  width: 24px;
  height: 24px;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: #1a202c;
  margin: 0 0 4px 0;
  letter-spacing: -0.025em;
}

.page-subtitle {
  font-size: 16px;
  color: #718096;
  margin: 0;
}

/* 폼 카드 */
.form-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  border: 1px solid #e2e8f0;
  margin-bottom: 24px;
  overflow: hidden;
}

.card-header {
  padding: 24px 24px 0 24px;
  border-bottom: 1px solid #e2e8f0;
  margin-bottom: 24px;
}

.card-title {
  font-size: 20px;
  font-weight: 600;
  color: #2d3748;
  margin: 0 0 8px 0;
}

.card-description {
  font-size: 14px;
  color: #718096;
  margin: 0 0 24px 0;
}

.form-content {
  padding: 0 24px;
}

/* 폼 섹션 */
.form-section {
  margin-bottom: 32px;
}

.form-section:last-child {
  margin-bottom: 0;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: #2d3748;
  margin: 0 0 20px 0;
  padding-bottom: 8px;
  border-bottom: 2px solid #e2e8f0;
}

/* 폼 그룹 */
.form-group {
  margin-bottom: 20px;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-bottom: 8px;
  font-weight: 500;
  color: #374151;
  font-size: 14px;
}

.label-text {
  display: flex;
  align-items: center;
}

.required {
  color: #ef4444;
  font-size: 16px;
}

/* 입력 필드 */
.input-wrapper {
  position: relative;
}

.form-input {
  width: 100%;
  padding: 12px 16px;
  font-size: 16px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  background-color: #ffffff;
  transition: all 0.2s ease-in-out;
  box-sizing: border-box;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input:read-only {
  background-color: #f7fafc;
  color: #718096;
}

.form-input::placeholder {
  color: #a0aec0;
}

/* 주소 검색 그룹 */
.address-search-group {
  display: flex;
  gap: 12px;
}

.address-search-group .form-input {
  flex: 1;
}

.search-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s ease-in-out;
  white-space: nowrap;
}

.search-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.search-btn:active {
  transform: translateY(0);
}

.search-btn svg {
  width: 16px;
  height: 16px;
}

/* 액션 섹션 */
.action-section {
  padding: 24px;
  background-color: #f8fafc;
  border-top: 1px solid #e2e8f0;
}

/* 버튼 스타일 */
.btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px 24px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease-in-out;
  text-decoration: none;
  min-height: 48px;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none !important;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  width: 100%;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.btn-danger {
  background: linear-gradient(135deg, #fc8181 0%, #f56565 100%);
  color: white;
}

.btn-danger:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(245, 101, 101, 0.4);
}

/* 위험 구역 */
.danger-zone {
  background: white;
  border: 2px solid #fed7d7;
  border-radius: 12px;
  padding: 24px;
  margin-top: 24px;
}

.danger-header {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 20px;
}

.danger-icon {
  width: 40px;
  height: 40px;
  background-color: #fed7d7;
  color: #e53e3e;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.danger-icon svg {
  width: 20px;
  height: 20px;
}

.danger-title {
  font-size: 18px;
  font-weight: 600;
  color: #2d3748;
  margin: 0 0 4px 0;
}

.danger-description {
  font-size: 14px;
  color: #718096;
  margin: 0;
  line-height: 1.5;
}

/* 로딩 스피너 */
.loading-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid transparent;
  border-top: 2px solid currentColor;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 반응형 디자인 */
@media (max-width: 640px) {
  .lawyer-container {
    padding: 16px 12px;
  }

  .header-content {
    gap: 12px;
  }

  .header-icon {
    width: 40px;
    height: 40px;
  }

  .page-title {
    font-size: 24px;
  }

  .form-card {
    border-radius: 12px;
  }

  .card-header, .form-content, .action-section {
    padding: 20px 16px;
  }

  .address-search-group {
    flex-direction: column;
  }

  .search-btn {
    width: 100%;
    justify-content: center;
  }

  .danger-zone {
    padding: 20px 16px;
  }

  .danger-header {
    gap: 12px;
  }
}

/* 다크 모드 지원 준비 */
@media (prefers-color-scheme: dark) {
  .lawyer-container {
    color: #f7fafc;
  }
}

/* 접근성 개선 */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* 포커스 링 개선 */
.btn:focus-visible,
.form-input:focus-visible {
  outline: 2px solid #667eea;
  outline-offset: 2px;
}
</style>