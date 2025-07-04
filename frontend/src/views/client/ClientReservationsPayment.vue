<template>
  <ClientFrame>
    <div class="container mx-auto py-6">
      <h2 class="text-2xl font-bold mb-4">상담 결제</h2>

      <div class="bg-white shadow rounded-lg p-6">
        <p class="mb-2"><strong>예약번호:</strong> {{ reservationNo || '생성 중...' }}</p>
        <p class="mb-2"><strong>주문코드:</strong> {{ orderCode   || '생성 중...' }}</p>
        <p class="mb-2"><strong>예약 시간:</strong> {{ formattedTime }}</p>
        <p class="mb-2"><strong>담당 변호사:</strong> {{ props.lawyerName }}</p>

        <button
            class="btn btn-primary w-full"
            @click="handlePayFlow"
            :disabled="isProcessing"
        >
          결제 진행하기
        </button>
      </div>
    </div>
  </ClientFrame>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter }       from 'vue-router'
import axios                from '@/libs/HttpRequester'
import ClientFrame          from '@/components/layout/client/ClientFrame.vue'
import { getValidToken }    from '@/libs/axios-auth.js'

const props = defineProps({
  lawyerNo:   { type: Number, required: true },
  lawyerName: { type: String, required: true },
  slotNo:     { type: Number, required: true },
  slotDate:   { type: String, required: true },
  slotTime:   { type: String, required: true }
})

const router        = useRouter()
const isProcessing  = ref(false)
const reservationNo = ref(null)
const orderCode     = ref(null)
const amount        = ref(0)

// 예약 시간 포맷
const formattedTime = computed(() => {
  const { slotDate, slotTime } = props
  if (!slotDate || !slotTime) return '시간 정보 없음'
  const dt = new Date(`${slotDate}T${slotTime}`)
  return isNaN(dt)
      ? '유효하지 않은 시간'
      : dt.toLocaleString('ko-KR', {
        year: 'numeric', month: 'long', day: 'numeric',
        hour: '2-digit', minute: '2-digit'
      })
})

async function handlePayFlow() {
  if (isProcessing.value) return
  isProcessing.value = true

  const token = await getValidToken()
  if (!token) {
    alert('로그인이 필요합니다.')
    isProcessing.value = false
    return
  }

  try {
    // 1) 예약 + 주문 생성: props.slotNo 사용
    const resp = await axios.post(
        '/api/client/reservations',
        { slotNo: props.slotNo, content: '' },
        { headers: { Authorization: `Bearer ${token}` } }
    )
    const dto = resp.data
    reservationNo.value = dto.no
    orderCode.value     = dto.orderCode
    amount.value        = dto.amount

    // 2) TossPayments 결제 팝업
    const tossPayments = window.TossPayments('test_ck_d46qopOB89dkZvqg40zOrZmM75y0')
    await tossPayments.requestPayment('카드', {
      amount:    amount.value,
      orderId:   orderCode.value,
      orderName: `${props.lawyerName} 상담 예약`,
      successUrl: `${location.origin}/payment/success?reservationNo=${reservationNo.value}&orderCode=${orderCode.value}`,
      failUrl:    `${location.origin}/payment/fail?reservationNo=${reservationNo.value}&orderCode=${orderCode.value}`
    })

  } catch (err) {
    // 팝업 닫힘 등 사용자 취소
    const isUserCancel = err.name === 'AbortError'
        || err.code === 'USER_CANCEL'
        || err.message?.includes('closed')

    if (isUserCancel && reservationNo.value) {
      try {
        await axios.post(
            '/api/confirm/cancel-reservation',
            { reservationNo: reservationNo.value },
            { headers: { Authorization: `Bearer ${token}` } }
        )
        alert('결제를 취소하여 예약이 취소되었습니다.')
        // 루트('/')로 리다이렉트
        router.replace({ path: '/' })
      } catch (cancelErr) {
        console.error('사전 취소 실패', cancelErr)
        alert('예약 취소 중 오류가 발생했습니다.')
      }
    } else {
      alert('결제 진행 중 오류가 발생했습니다.')
    }
  } finally {
    isProcessing.value = false
  }
}

onMounted(() => {
  if (!window.TossPayments) {
    alert('결제 기능을 사용할 수 없습니다.')
  }
})
</script>

<style scoped>
.container { max-width: 600px; }
</style>
