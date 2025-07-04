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
        <p>원하시는 상담 시간을 선택해주세요</p>

        <!-- 날짜별 카드 -->
        <div
            v-for="day in weeklySlots"
            :key="day.date"
            class="schedule-card"
        >
          <h3 class="text-lg font-medium mb-2">
            {{ formatDate(day.date) }}
          </h3>

          <!-- 오전 -->
          <div class="mb-4">
            <div class="text-sm font-medium text-gray-700 mb-1 time-label">
              오전 (08:00 ~ 11:00)
            </div>
            <div class="slots-grid slots-grid-afternoon">
              <button
                  v-for="slot in day.slots.filter(s => +s.slotTime.slice(0,2) < 12)"
                  :key="slot.no"
                  :disabled="slot.status !== 1 || isPast(slot)"
                  @click="select(slot)"
                  :class="getSlotClass(slot)"
              >
                {{ slot.slotTime.slice(0, 5) }}
              </button>
            </div>
          </div>

          <!-- 오후 -->
          <div>
            <div class="text-sm font-medium text-gray-700 mb-1">
              오후 (12:00 ~ 22:00)
            </div>
            <div class="slots-grid slots-grid-afternoon">
              <button
                  v-for="slot in day.slots.filter(s => +s.slotTime.slice(0,2) >= 12)"
                  :key="slot.no"
                  :disabled="slot.status !== 1 || isPast(slot)"
                  @click="select(slot)"
                  :class="getSlotClass(slot)"
              >
                {{ slot.slotTime.slice(0, 5) }}
              </button>
            </div>
          </div>
        </div>

        <!-- 예약 신청 버튼 -->
        <div class="d-flex justify-content-end mt-4 w-100">
          <button
              class="btn btn-primary px-4 py-2 rounded"
              :disabled="!selectedSlot"
              @click="apply"
          >
            예약 신청
          </button>
        </div>
      </div>
    </div>
  </ClientFrame>
</template>

<script setup>
import {ref, onMounted, computed} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import axios from 'axios'
import ClientFrame from '@/components/layout/client/ClientFrame.vue'
import {getValidToken} from '@/libs/axios-auth.js'

// props
const props = defineProps({
  lawyerNo: {type: Number, required: true},
  lawyerName: {type: String, required: true}
})

const route = useRoute()
const router = useRouter()
const loading = ref(true)
const slotsFlat = ref([])
const selectedSlot = ref(null)
const now = ref(new Date())

// 현재 시각을 1분마다 갱신
setInterval(() => {
  now.value = new Date()
}, 60_000)

// 과거 슬롯 판정
function isPast(slot) {
  const slotDateTime = new Date(`${slot.slotDate}T${slot.slotTime}`)
  return slotDateTime < now.value
}

// 슬롯 조회
onMounted(async () => {
  const token = await getValidToken()
  if (!token) {
    alert('로그인이 필요합니다.')
    return
  }
  try {
    const token = localStorage.getItem('token')
    const today = new Date().toISOString().slice(0, 10)
    const res = await axios.get(
        `/api/lawyer/${props.lawyerNo}/slots`,
        {
          headers: {Authorization: `Bearer ${token}`},
          params: {startDate: today}
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

// 그룹핑 함수
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

// 날짜 포맷
function formatDate(str) {
  const d = new Date(str + 'T00:00:00')
  return d.toLocaleDateString('ko', {month: 'long', day: 'numeric', weekday: 'short'})
}

// 슬롯 클래스 결정
function getSlotClass(slot) {
  const baseClass = 'slot-button'

  if (slot.status !== 1 || isPast(slot)) {
    return `${baseClass} disabled-slot`
  } else if (selectedSlot.value?.no === slot.no) {
    return `${baseClass} selected-slot`
  } else {
    return `${baseClass} available-slot`
  }
}

// 슬롯 선택
function select(slot) {
  if (slot.status !== 1 || isPast(slot)) return
  selectedSlot.value = slot
}

// 예약 신청
async function apply() {
  const token = await getValidToken()
  if (!token) {
    alert('로그인이 필요합니다.')
    return
  }
  const slot = selectedSlot.value
  await router.push({
    name: 'ClientReservationsPayment',
    query: {
      lawyerNo: props.lawyerNo,
      lawyerName: props.lawyerName,
      slotNo: slot.no,
      slotDate: slot.slotDate,
      slotTime: slot.slotTime,
    }
  })

}
</script>

<style scoped>
/* 카드 컨테이너 */
.schedule-card {
  background-color: #ffffff; /* 흰 배경 */
  padding: 1rem; /* 안쪽 여백 */
  border-radius: 0.75rem; /* 둥근 모서리 */
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 부드러운 그림자 */
  margin-bottom: 1rem; /* 카드 사이 간격 */
}

/* 날짜 제목 */
.schedule-card h3 {
  margin: 0 0 0.75rem; /* 아래 여백 */
  font-size: 1.125rem; /* 글자 크기 */
  font-weight: 600; /* 글자 굵기 */
  color: #2d3748; /* 진한 회색 */
}

/* 오전/오후 레이블 */
.schedule-card .time-label {
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: #4a5568;
}

/* 슬롯 버튼 그리드 */
.schedule-card .slots-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 0.5rem;
}

/* 오후 슬롯은 6개 컬럼 */
.schedule-card .slots-grid-afternoon {
  grid-template-columns: repeat(6, 1fr);
}

/* 기본 슬롯 버튼 */
.schedule-card .slots-grid button {
  display: block;
  width: 100%;
  padding: 0.5rem;
  font-size: 0.875rem;
  font-weight: 500;
  border-radius: 0.5rem;
  border: 1px solid #e2e8f0;
  background-color: #ffffff;
  color: #a0aec0;
  transition: transform 0.2s ease, background-color 0.2s ease;
  cursor: pointer;
}

/* 호버 애니메이션 */
.schedule-card .slots-grid button:hover:not(:disabled) {
  transform: scale(1.05);
}

/* 상태별 스타일 */
.slot-button.available-slot {
  background-color: #ffffff !important; /* gray-200 → gray-300 */
  color: #4a5568 !important; /* gray-700 */
  border-color: #c3ced9 !important; /* gray-600 */
}

.slot-button.available-slot:hover {
  background-color: #edf2f7;
  border-color: #718096;
  color: #2d3748;
}

.slot-button.selected-slot {
  background-color: #445b7c !important;
  color: #ffffff !important;
  border-color: #3a4d66 !important;
}

.slot-button.disabled-slot {
  background-color: #f7fafc;
  color: #a0aec0;
  border-color: #e2e8f0;
  opacity: 0.5;
  cursor: not-allowed;
}

</style>