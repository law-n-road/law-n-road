<!-- src/views/client/TemplatePaymentSuccessView.vue -->
<template>
  <ClientFrame>
    <div class="container py-5 text-center">
      <h5 class="mb-4">결제 처리 중…</h5>
      <div v-if="error" class="alert alert-danger">
        {{ error }}
      </div>
      <div v-else>
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
        <p class="mt-3">잠시만 기다려주세요.</p>
      </div>
    </div>
  </ClientFrame>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import http from '@/libs/HttpRequester'   // axios 인스턴스
import ClientFrame from "@/components/layout/client/ClientFrame.vue";

const error  = ref('')
const router = useRouter()

onMounted(async () => {
  const params     = new URLSearchParams(window.location.search)
  const paymentKey = params.get('paymentKey')
  const orderId    = params.get('orderId')
  const amountStr  = params.get('amount')

  if (!paymentKey || !orderId || !amountStr) {
    error.value = '결제 승인에 필요한 정보가 누락되었습니다.'
    return
  }

  try {
    await http.post('/api/confirm/payment', {
      paymentKey,
      orderId,
      amount: Number(amountStr)
    })

    // 결제 관련 사후 처리
    await http.post('/api/client/cart/complete', {
      orderId
    })

    alert("결제가 완료되었습니다. 마이페이지로 넘어갑니다.")
    return window.location.href = `/client/mypage`
  } catch (e) {
    error.value =
        e.response?.data?.message ||
        '결제 승인 처리에 실패했습니다. 고객센터에 문의해주세요.'
  }
})
</script>

<style scoped>
.container { max-width: 600px; margin: auto; }
</style>
