<script setup>
import {ref, onMounted, computed, nextTick} from 'vue'
import { useRouter } from 'vue-router'
import ClientFrame from '@/components/layout/client/ClientFrame.vue'
import {
  sendBroadcastStartAlimtalk,
  sendVerificationCodeAlimtalk,
  sendClientReservationStartedAlimtalk,
  sendLawyerReservationStartedAlimtalk,
  sendClientReservationCreatedAlimtalk,
  sendLawyerReservationCreatedAlimtalk,
  sendLawyerReservationCanceledAlimtalk,
  sendBroadcastCreateAlimtalk
} from "@/service/notification.js"
import HttpRequester from '@/libs/HttpRequester'
import { fetchMyQnaBoards } from '@/service/boardService'
import { getUserNo } from '@/service/authService.js'
import BasicTable from '@/components/table/BasicTable.vue'


// 라우터
const router = useRouter()
function goToProfileEdit() {
  router.push({ name: 'ClientProfileEdit' })
}

// 테스트용 임시 하드 코딩
const userNo = getUserNo()
const notifyKeywordEnabled = ref(true)
const notifyConsultEnabled = ref(true)
const nickname = ref('회원')
const requestedCount = ref(0)
const doneCount = ref(0)

const myQnaBoards = ref([]) //추가

onMounted(async () => {
  const storedNickname = localStorage.getItem('nickname')
  if (storedNickname && storedNickname !== 'null') {
    nickname.value = storedNickname
  }

  // 예약
  try {
    const res = await HttpRequester.get(`/api/client/reservations/counts`)
    requestedCount.value = res.data.requestedCount
    doneCount.value = res.data.doneCount
  } catch (e) {
    console.error('예약 건수 조회 실패', e)
  }

  // 최근 주문내역
  const res = await HttpRequester.get('/api/client/templates/orders/recent') // 최근 주문 5개
  console.log(res.data)
  orders_rows.value = res.data.orders || []

  // QnA 조회 및 정렬 → 상위 5개만 보여줌
  try {
    const res = await fetchMyQnaBoards(userNo)

    const sorted = res.data.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    myQnaBoards.value = sorted.slice(0, 5)
  } catch (e) {
    console.error('QnA 조회 실패', e)
  }

  // 현재 알림 설정 조회
  try {
    const alertRes = await HttpRequester.get(`/api/client/alert-settings/${userNo}`)
    console.log('알림 설정 조회 결과:', alertRes.data)

    if (alertRes.data) {
      notifyConsultEnabled.value = alertRes.data.isConsultAlert
      notifyKeywordEnabled.value = alertRes.data.isKeywordAlert
    }
  } catch (e) {
    console.error('알림 설정 조회 실패', e)
    // 조회 실패 시 기본값 설정
    notifyConsultEnabled.value = true
    notifyKeywordEnabled.value = true
  }

  // 키워드
  const keyRes = await HttpRequester.get('/api/client/keywords')
  keywords.value = keyRes.data
})

// 각 알림톡 테스트 함수
async function testBroadcastStart() {
  try {
    await sendBroadcastStartAlimtalk({
      to: "01038578216",
      name: "방민영",
      title: "음주운전 뺑소니 사고",
      start: "22:00"
    });
    alert(":흰색_확인_표시: 방송 시작 알림톡 발송 완료");
  } catch (e) {
    alert(":x: 방송 시작 알림 실패");
  }
}
async function testBroadcastCreate() {
  try {
    await sendBroadcastCreateAlimtalk({
      to: "01081272572",
      name: "박건희",
      lawyer: "김변",
      title: "음주운전 뺑소니 사고",
      start: "22:00"
    });
    alert(":흰색_확인_표시: 방송 등록 알림톡 발송 완료");
  } catch (e) {
    alert(":x: 방송 등록 알림 실패");
  }
}
async function testVerificationCode() {
  try {
    await sendVerificationCodeAlimtalk({
      to: "01081272572",
      code: "928374"
    });
    alert(":흰색_확인_표시: 인증번호 발송 완료");
  } catch (e) {
    alert(":x: 인증번호 발송 실패");
  }
}
async function testClientReservationStarted() {
  try {
    await sendClientReservationStartedAlimtalk({
      to: "01081272572",
      client: "홍길동",
      lawyer: "박건희",
      datetime: "2025-06-05 15:00"
    });
    alert(":흰색_확인_표시: 상담 임박(의뢰인) 발송 완료");
  } catch (e) {
    alert(":x: 상담 임박(의뢰인) 실패");
  }
}
async function testLawyerReservationStarted() {
  try {
    await sendLawyerReservationStartedAlimtalk({
      to: "01081272572",
      lawyer: "박건희",
      client: "홍길동",
      datetime: "2025-06-05 15:00",
      summary: "음주운전 관련 문의"
    });
    alert(":흰색_확인_표시: 상담 임박(변호사) 발송 완료");
  } catch (e) {
    alert(":x: 상담 임박(변호사) 실패");
  }
}
async function testClientReservationCreated() {
  try {
    await sendClientReservationCreatedAlimtalk({
      to: "01081272572",
      client: "홍길동",
      lawyer: "박건희",
      datetime: "2025-06-05 15:00",
      summary: "음주운전 벌금 문의"
    });
    alert(":흰색_확인_표시: 상담 신청 완료(의뢰인) 발송 완료");
  } catch (e) {
    alert(":x: 상담 신청(의뢰인) 실패");
  }
}
async function testLawyerReservationCreated() {
  try {
    await sendLawyerReservationCreatedAlimtalk({
      to: "01081272572",
      lawyer: "박건희",
      client: "홍길동",
      datetime: "2025-06-05 15:00",
      summary: "음주운전 벌금 문의"
    });
    alert(":흰색_확인_표시: 상담 신청 완료(변호사) 발송 완료");
  } catch (e) {
    alert(":x: 상담 신청(변호사) 실패");
  }
}
async function testLawyerReservationCanceled() {
  try {
    await sendLawyerReservationCanceledAlimtalk({
      to: "01081272572",
      lawyer: "박건희",
      client: "홍길동",
      datetime: "2025-06-05 15:00"
    });
    alert(":흰색_확인_표시: 상담 취소(변호사) 발송 완료");
  } catch (e) {
    alert(":x: 상담 취소(변호사) 실패");
  }
}

/* --------------------------- */
/*      최근 5개 구매내역      */
/* --------------------------- */

// 최근 5개 구매내역 데이터
const orders_rows = ref([])

// 주문 내역 컬럼 정의
const orderColumns = [
  { label: '주문번호', key: 'orderNo' },
  { label: '주문일자', key: 'orderDate' },
  { label: '주문상품', key: 'firstTemplateName' },
  { label: '총금액', key: 'amount' },
  { label: '주문상태', key: 'status' }
]

function formatProductLabel(name, count) {
  return count > 1 ? `${name} 외 ${count - 1}건` : name
}

const statusLabel = {
  ORDERED: '결제대기',
  PAID: '결제완료',
  CANCELED: '환불'
}

const statusClass = {
  ORDERED: 'bg-warning text-dark', // 결제대기 (노랑)
  PAID: 'bg-primary', // 결제완료 (파랑)
  CANCELED: 'bg-danger',  // 환불 (빨강)
}

function handleOrderRowClick(row) {
  if (row.status === 'CANCELED') return
  router.push(`/client/template/orders/${row.orderNo}`)
}

/* --------------------------- */
/*      키워드 관련 처리       */
/* --------------------------- */

// 키워드 관련 변수들 추가
const keywords = ref([]) // 기본값 또는 서버에서 가져온 데이터
const newKeyword = ref('')
const keywordInput = ref(null)

// 계산된 속성
const canAddKeyword = computed(() => {
  const trimmed = newKeyword.value.trim()
  return trimmed.length > 0 &&
      !keywords.value.includes(trimmed)
})

// 키워드 관련 함수들
async function startAddingKeyword() {
  await nextTick()
  keywordInput.value?.focus()
}

async function addKeyword() {
  const trimmed = newKeyword.value.trim()

  if (!trimmed) return
  if (keywords.value.includes(trimmed)) {
    alert('이미 등록된 키워드입니다.')
    return
  }

  keywords.value.push(trimmed)
  newKeyword.value = ''

  await HttpRequester.post('/api/client/keywords', {
    keyword: trimmed
  })
}

async function removeKeyword(index) {
  const keyword = keywords.value[index]
  try {
    await HttpRequester.delete(`/api/client/keywords/${encodeURIComponent(keyword)}`)
    keywords.value.splice(index, 1)
  } catch (e) {
    console.error('키워드 삭제 실패:', e)
    alert('키워드 삭제에 실패했습니다.')
  }
}

function cancelAddingKeyword() {
  newKeyword.value = '';
}

function handleKeyDown(event) {
  if (event.key === 'Enter' && canAddKeyword.value) {
    event.preventDefault();
    addKeyword();
  } else if (event.key === 'Escape') {
    cancelAddingKeyword();
  }
}

// 토글 핸들러들 - 이벤트에서 값을 받아서 업데이트
function handleKeywordToggle(event) {
  console.log('=== 키워드 토글 시작 ===')
  console.log('이벤트 체크 상태:', event.target.checked)
  console.log('토글 전 notifyKeywordEnabled:', notifyKeywordEnabled.value)
  console.log('토글 전 notifyConsultEnabled:', notifyConsultEnabled.value)

  // 먼저 값을 업데이트
  notifyKeywordEnabled.value = event.target.checked

  console.log('토글 후 notifyKeywordEnabled:', notifyKeywordEnabled.value)

  // 그 다음 서버에 전송
  toggleKeyword()
}

function handleConsultToggle(event) {
  console.log('=== 상담 토글 시작 ===')
  console.log('이벤트 체크 상태:', event.target.checked)
  console.log('토글 전 notifyConsultEnabled:', notifyConsultEnabled.value)

  // 먼저 값을 업데이트
  notifyConsultEnabled.value = event.target.checked

  console.log('토글 후 notifyConsultEnabled:', notifyConsultEnabled.value)

  // 그 다음 서버에 전송
  toggleConsultation()
}

// 토글 1: 키워드 알림
async function toggleKeyword() {
  console.log(
      '방송 키워드 알림 수신 여부:',
      notifyKeywordEnabled.value ? '수신함' : '수신 안 함'
  )

  const requestData = {
    clientNo: userNo,
    isConsultAlert: notifyConsultEnabled.value,
    isKeywordAlert: notifyKeywordEnabled.value
  }

  console.log('서버로 보낼 데이터:', requestData)

  try {
    await HttpRequester.post('/api/client/update-alerts', requestData)
    console.log('키워드 알림 설정 저장 완료')
  } catch (e) {
    console.error('키워드 알림 설정 업데이트 실패:', e)
    alert('키워드 알림 설정 저장 실패')
    notifyKeywordEnabled.value = !notifyKeywordEnabled.value
  }
}

// 토글 2: 상담 알림
async function toggleConsultation() {
  console.log(
      '상담 관련 알림 수신 여부:',
      notifyConsultEnabled.value ? '수신함' : '수신 안 함'
  )

  try {
    await HttpRequester.post('/api/client/update-alerts', {
      clientNo: userNo,
      isConsultAlert: notifyConsultEnabled.value,
      isKeywordAlert: notifyKeywordEnabled.value
    })
  } catch (e) {
    console.error('알림 설정 업데이트 실패:', e)
    alert('알림 설정 저장 실패')
    // 실패 시 원래 상태로 되돌리기
    notifyConsultEnabled.value = !notifyConsultEnabled.value
  }
}

</script>

<template>
  <ClientFrame>
    <div class="mypage-home p-4">
      <h3 class="mb-3 text-muted d-flex justify-content-between align-items-center">
        마이페이지 홈
        <button class="btn btn-outline-primary btn-sm" @click="goToProfileEdit">
          정보 수정
        </button>
      </h3>
      <p class="text-muted">환영합니다! {{ nickname }}님 마이페이지 홈입니다.</p>

      <!-- 상담내역 카드 -->
      <div class="card mb-4 border-light">
        <div class="card-header title-bg-primary text-white">1:1 상담내역</div>
        <div class="card-body p-0">
          <ul class="list-group list-group-flush">
            <li class="list-group-item d-flex justify-content-between align-items-center">
              &nbsp;&nbsp;상담 대기
              <span class="badge bg-warning text-dark me-5">{{ requestedCount }}건</span>
            </li>
            <li class="list-group-item d-flex justify-content-between align-items-center">
              &nbsp;&nbsp;상담 완료
              <span class="badge bg-success text-white me-5">{{ doneCount }}건</span>
            </li>
            <li class="list-group-item text-center bg-white">
              <router-link
                  :to="{ name: 'ClientReservationsList', params: { clientNo: userNo } }"
                  class="text-decoration-none btn small"
              >
                자세히 보기
              </router-link>
            </li>
          </ul>
        </div>
      </div>

      <!-- 템플릿 구매 내역 카드 -->
      <div class="card mb-4 border-light">
        <div class="card-header title-bg-primary text-white">템플릿 구매 내역</div>
        <div class="card-body">

          <!-- BasicTable 사용 -->
          <BasicTable
              :columns="orderColumns"
              :fullData="orders_rows"
              :pageSize="5"
              @row-click="handleOrderRowClick"
          >
            <template #cell-firstTemplateName="{ row, value }">
              {{ formatProductLabel(value, row.templateCount) }}
            </template>
            <template #cell-amount="{ value }">
              {{ value.toLocaleString() }}원
            </template>
            <template #cell-status="{ value }">
              <span class="badge" :class="statusClass[value]">
                {{ statusLabel[value] }}
              </span>
            </template>
          </BasicTable>


<!--          <table class="table table-hover align-middle">-->
<!--            <thead class="table">-->
<!--            <tr>-->
<!--              <th scope="col">주문번호</th>-->
<!--              <th scope="col">주문일자</th>-->
<!--              <th scope="col">주문상품</th>-->
<!--              <th scope="col">총금액</th>-->
<!--              <th scope="col">주문상태</th>-->
<!--            </tr>-->
<!--            </thead>-->
<!--            <tbody>-->
<!--            <tr-->
<!--                v-for="row in orders_rows"-->
<!--                :key="row.orderNo"-->
<!--                style="cursor: pointer"-->
<!--                @click="handleRowClick(row)"-->
<!--            >-->
<!--              <td>{{ row.orderNo }}</td>-->
<!--              <td>{{ row.orderDate }}</td>-->
<!--              <td>{{ formatProductLabel(row.firstTemplateName, row.templateCount) }}</td>-->
<!--              <td>{{ row.amount.toLocaleString() }}원</td>-->
<!--              <td>-->
<!--            <span class="badge"-->
<!--                  :class="statusClass[row.status] || 'bg-secondary'">-->
<!--              {{ statusLabel[row.status] || row.status }}-->
<!--            </span>-->
<!--              </td>-->
<!--            </tr>-->
<!--            <tr v-if="orders_rows.length === 0">-->
<!--              <td colspan="5" class="text-muted text-center">최근 주문 내역이 없습니다.</td>-->
<!--            </tr>-->
<!--            </tbody>-->
<!--          </table>-->

<!--          <div class="text-center">-->
<!--            <router-link-->
<!--                :to="{ name: 'TmplHistoryListView' }"-->
<!--                class="btn small text-decoration-none"-->
<!--            >-->
<!--              구매 내역 더보기-->
<!--            </router-link>-->
<!--          </div>-->
        </div>
      </div>

      <!-- Q&A 카드 -->
      <div class="card mb-4 border-light">
        <div class="card-header title-bg-primary text-white">Q&A 작성한 글 보러가기</div>
        <div class="card-body">
          <table class="table table-hover align-middle">
            <thead class="table">
            <tr>
              <th scope="col">글번호</th>
              <th scope="col">카테고리</th>
              <th scope="col">제목</th>
              <th scope="col">사건발생일</th>
            </tr>
            </thead>
            <tbody>
            <tr
                v-for="row in myQnaBoards"
                :key="row.boardNo"
                style="cursor: pointer"
                @click="$router.push(`/qna/${row.boardNo}`)"
            >
              <td>{{ row.boardNo }}</td>
              <td>{{ row.categoryName }}</td>
              <td>{{ row.title }}</td>
              <td>{{ row.incidentDate }}</td>
            </tr>
            <tr v-if="myQnaBoards.length === 0">
              <td colspan="4" class="text-muted text-center">최근 상담글이 없습니다.</td>
            </tr>
            </tbody>
          </table>

          <div class="text-center"><router-link :to="{ name: 'ClientQaMyList' }" class="btn small text-decoration-none">
            내 상담글 더보기
          </router-link></div>
        </div>
      </div>

      <!-- 알림 수신 여부 및 테스트 -->
      <div class="card mb-4 border-light">
        <div class="card-header title-bg-primary text-white">알림 수신 여부 체크하기</div>
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <span class="text-muted small">카카오톡 상담 관련 알림</span>
            <div class="form-check form-switch m-0">
              <input class="form-check-input" type="checkbox" id="consultationSwitch"
                     :checked="notifyConsultEnabled"
                     @input="handleConsultToggle" />
            </div>
          </div>
          <div class="d-flex justify-content-between align-items-center mb-3">
            <span class="text-muted small">카카오톡 방송 키워드 알림</span>
            <div class="form-check form-switch m-0">
              <input class="form-check-input" type="checkbox" id="keywordSwitch"
                     :checked="notifyKeywordEnabled"
                     @input="handleKeywordToggle"/>
            </div>
          </div>

          <hr v-if="notifyKeywordEnabled" class="my-4">
          <!-- 키워드 등록 섹션 -->
          <div v-if="notifyKeywordEnabled" class="mb-3">
            <div class="d-flex justify-content-between align-items-center mb-3">
              <span class="text-muted small fw-bold">키워드 알림 설정</span>
              <small class="text-muted">{{ keywords.length }}개 등록됨</small>
            </div>


            <!-- 키워드 추가 영역 -->
            <div class="mb-3">
              <div class="input-group mb-2">
                <input
                    type="text"
                    class="form-control"
                    v-model="newKeyword"
                    @keydown="handleKeyDown"
                    placeholder="키워드를 입력하세요 (예: 교통사고, 음주운전, 과실비율)"
                    maxlength="20"
                    ref="keywordInput"
                />
                <button
                    type="button"
                    class="btn btn-primary"
                    @click="addKeyword"
                    :disabled="!canAddKeyword"
                >
                  추가
                </button>
              </div>
            </div>

            <!-- 등록된 키워드 표시 -->
            <div class="keywords-container" :class="{ empty: keywords.length === 0 }">
              <div v-if="keywords.length === 0" class="text-center">
                <small>등록된 키워드가 없습니다. 관심 키워드를 추가해보세요!</small>
              </div>
              <div v-else>
                            <span v-for="(keyword, index) in keywords" :key="index" class="keyword-tag">
                                {{ keyword }}
                                <button type="button" class="remove-btn" @click="removeKeyword(index)" title="키워드 삭제">
                                    ×
                                </button>
                            </span>
              </div>
            </div>

            <!-- 도움말 -->
            <div class="card p-3 mb-3 bg-light-subtle">
              <div class="d-flex justify-content-between align-items-center mb-2">
                <strong>키워드 알림이란?</strong>
              </div>
              <p class="mb-2 text-muted small">
                관심 있는 <b>키워드를 등록</b>하면 관련 방송이 시작될 때 카카오톡 알림톡으로 알려드립니다.
                <br>구체적인 키워드일수록 <u><b>정확한 알림</b></u>을 받을 수 있습니다.
              </p>
              <p class="mb-0 text-muted small">
                <strong>안내:</strong> <u>중복된 키워드는 등록할 수 없습니다</u>. 언제든지 수정하거나 삭제할 수 있어요.
              </p>
            </div>

          </div>

<!--          알림톡 관련 테스트 버튼-->
<!--          pr시 반드시 주석 처리 후 올릴 것-->
<!--          <hr class="my-4">-->

<!--          <p><a href="#" @click.prevent="testBroadcastStart">🟡 방송 시작 알림톡 테스트</a></p>-->
<!--          <p><a href="#" @click.prevent="testBroadcastCreate">🟡 방송 등록 알림톡 테스트</a></p>-->
<!--          <p><a href="#" @click.prevent="testVerificationCode">🔵 인증번호 발송 테스트</a></p>-->
<!--          <p><a href="#" @click.prevent="testClientReservationStarted">🟢 상담 임박 (의뢰인)</a></p>-->
<!--          <p><a href="#" @click.prevent="testLawyerReservationStarted">🟠 상담 임박 (변호사)</a></p>-->
<!--          <p><a href="#" @click.prevent="testClientReservationCreated">🟤 신규 상담 (의뢰인)</a></p>-->
<!--          <p><a href="#" @click.prevent="testLawyerReservationCreated">⚪ 신규 상담 (변호사)</a></p>-->
<!--          <p><a href="#" @click.prevent="testLawyerReservationCanceled">🔴 상담 취소 (변호사)</a></p>-->
        </div>
      </div>
    </div>
  </ClientFrame>
</template>

<style scoped>
.mypage-home {
  background-color: #f8f9fa;
  min-height: 100%;
  font-size: 1.1rem;
  line-height: 1.6;
}

.title-bg-primary {
  background-color: #435879;
}

.card {
  background-color: #ffffff;
}

.card-header {
  font-size: 1rem;
  font-weight: 600;
}

.border-light {
  border-color: #e9ecef !important;
}

.text-muted {
  color: #6c757d !important;
}

.small {
  font-size: 0.85rem;
}

.form-check-input {
  width: 2rem;
  height: 1rem;
}

.keyword-tag {
  display: inline-flex;
  align-items: center;
  background-color: #e3f2fd;
  border: 1px solid #90caf9;
  color: #1976d2;
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
  font-size: 0.85rem;
  margin: 0.25rem;
  transition: all 0.2s;
}

.keyword-tag:hover {
  background-color: #bbdefb;
}

.keyword-tag .remove-btn {
  background: none;
  border: none;
  color: #1976d2;
  font-size: 0.75rem;
  margin-left: 0.5rem;
  cursor: pointer;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.keyword-tag .remove-btn:hover {
  background-color: #1976d2;
  color: white;
}

.keywords-container {
  min-height: 60px;
  border: 1px dashed #dee2e6;
  border-radius: 0.375rem;
  padding: 0.75rem;
  margin-bottom: 1rem;
  background-color: #fafafa;
}

.keywords-container.empty {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #6c757d;
  font-style: italic;
}

.keyword-input-group {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.keyword-help {
  background-color: #e3f2fd;
  border-left: 4px solid #2196f3;
  padding: 0.75rem;
  margin-top: 1rem;
  border-radius: 0.25rem;
}

.alert-light-primary {
  background-color: #e3f2fd;
  border-color: #90caf9;
  color: #1565c0;
}

.add-keyword-btn {
  color: #435879;
  text-decoration: none;
  font-weight: 500;
  cursor: pointer;
  font-size: 0.9rem;
}

.add-keyword-btn:hover {
  color: #2c3e50;
  text-decoration: underline;
}


h3 {
  font-size: 1.25rem;
  font-weight: 500;
}

.btn-outline-primary.btn-sm {
  padding: 0.25rem 0.75rem;
}
</style>
