<template>
  <ClientFrame>
    <div class="container mx-auto py-6">
      <h2 class="text-3xl font-bold mb-6">
        {{ props.lawyerName }} 변호사 상담 예약
      </h2>

      <!-- 로딩 스피너 -->
      <div v-if="loading" class="text-center py-10">로딩 중…</div>

      <!-- 슬롯 리스트 -->
      <div v-else>
        <div
            v-for="day in weeklySlots"
            :key="day.date"
            class="mb-6 bg-white rounded-lg shadow p-4"
        >
          <h3 class="text-xl font-semibold mb-3">
            {{ formatDate(day.date) }}
          </h3>

          <!-- 오전 -->
          <div class="mb-4">
            <p class="text-sm font-medium text-gray-700 mb-2">
              오전 (08:00 ~ 11:00)
            </p>
            <div class="grid grid-cols-4 gap-2">
              <button
                  v-for="slot in day.slots.filter(s => +s.slotTime.slice(0,2) < 12)"
                  :key="slot.no"
                  :disabled="slot.status !== 1 || isPast(slot)"
                  @click="select(slot)"
                  :class="[
                  'px-3 py-2 rounded border',
                  slot.status !== 1 || isPast(slot)
                    ? 'bg-gray-200 cursor-not-allowed'
                    : selectedSlot && selectedSlot.no === slot.no
                      ? 'bg-green-200 border-green-500'
                      : 'hover:bg-green-50'
                ]"
              >
                {{ slot.slotTime.slice(0, 5) }}
              </button>
            </div>
          </div>

          <!-- 오후 -->
          <div>
            <p class="text-sm font-medium text-gray-700 mb-2">
              오후 (12:00 ~ 22:00)
            </p>
            <div class="grid grid-cols-6 gap-2">
              <button
                  v-for="slot in day.slots.filter(s => +s.slotTime.slice(0,2) >= 12)"
                  :key="slot.no"
                  :disabled="slot.status !== 1 || isPast(slot)"
                  @click="select(slot)"
                  :class="[
                  'px-3 py-2 rounded border',
                  slot.status !== 1 || isPast(slot)
                    ? 'bg-gray-200 cursor-not-allowed'
                    : selectedSlot && selectedSlot.no === slot.no
                      ? 'bg-green-200 border-green-500'
                      : 'hover:bg-green-50'
                ]"
              >
                {{ slot.slotTime.slice(0, 5) }}
              </button>
            </div>
          </div>
        </div>

        <!-- 예약 신청 버튼 -->
        <div class="text-right">
          <button
              class="px-5 py-2 bg-blue-600 text-white disabled:opacity-50"
              :disabled="!selectedSlot"
              @click="apply"
          >
            결제 페이지로 이동
          </button>
        </div>
      </div>
    </div>
  </ClientFrame>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import ClientFrame from '@/components/layout/client/ClientFrame.vue'
import { getValidToken } from '@/libs/axios-auth.js'

// props
const props = defineProps({
  lawyerNo:   { type: Number, required: true },
  lawyerName: { type: String, required: true }
})

const router      = useRouter()
const loading     = ref(true)
const slotsFlat   = ref([])
const selectedSlot = ref(null)
const now         = ref(new Date())

// 현재 시각을 1분마다 갱신
setInterval(() => { now.value = new Date() }, 60_000)

// 과거 슬롯 판정
function isPast(slot) {
  const slotDateTime = new Date(`${slot.slotDate}T${slot.slotTime}`)
  return slotDateTime < now.value
}

// 슬롯 조회(변경 없음)
onMounted(async () => {
  const token = await getValidToken()
  if (!token) {
    alert('로그인이 필요합니다.')
    loading.value = false
    return
  }
  try {
    const today = new Date().toISOString().slice(0, 10)
    const res = await axios.get(
        `/api/lawyer/${props.lawyerNo}/slots`,
        {
          headers: { Authorization: `Bearer ${token}` },
          params:  { startDate: today }
        }
    )
    slotsFlat.value = res.data
  } catch (err) {
    console.error(err)
    alert('슬롯 조회에 실패했습니다.')
  } finally {
    loading.value = false
  }
})

// 그룹핑 함수(변경 없음)
function groupByDate(list) {
  const map = {}
  list.forEach(s => {
    if (!map[s.slotDate]) map[s.slotDate] = []
    map[s.slotDate].push(s)
  })
  return Object.entries(map)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([date, daySlots]) => ({
        date,
        slots: daySlots.sort((a, b) => a.slotTime.localeCompare(b.slotTime))
      }))
}

const weeklySlots = computed(() => groupByDate(slotsFlat.value).slice(0, 7))

// 날짜 포맷(변경 없음)
function formatDate(str) {
  const d = new Date(str + 'T00:00:00')
  return d.toLocaleDateString('ko', { month: 'long', day: 'numeric', weekday: 'short' })
}

// 슬롯 선택(변경 없음)
function select(slot) {
  if (slot.status !== 1 || isPast(slot)) return
  selectedSlot.value = slot
}

// apply: 예약+주문 API 호출 부분 제거, 결제 페이지 이동만 수행
function apply() {
  const slot = selectedSlot.value
  router.push({
    name: 'ClientReservationsPayment',
    query: {
      slotNo:     slot.no,
      slotDate:   slot.slotDate,
      slotTime:   slot.slotTime,
      amount:     slot.amount ?? 0,
      lawyerName: props.lawyerName
    }
  })
}
</script>

<style scoped>
.container {
  max-width: 800px;
}
</style>
