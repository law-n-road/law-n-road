<script setup>
//1. Vue & 외부 라이브러리 임포트
import { ref,computed, onMounted, onUnmounted } from 'vue'
import { useLawyerStore } from '@/stores/lawyer'
import LawyerFrame from "@/components/layout/lawyer/LawyerFrame.vue";
import { fetchTodaySchedule, fetchTomorrowConsultationRequests, fetchMonthlySalesRevenue, fetchTomorrowBroadcasts, fetchWeeklyConsultations , fetchWeeklyBroadcasts , fetchMonthlyRevenue , fetchMonthlyTemplateSales   } from '@/service/dashboardService.js'
import { Chart, CategoryScale, LinearScale, BarElement, LineElement, PointElement, Title, Tooltip,
  Legend, Filler, BarController, LineController} from 'chart.js'
// Chart.js 플러그인 등록
Chart.register(CategoryScale, LinearScale, BarElement, LineElement, PointElement, Title, Tooltip, Legend,
    Filler, BarController, LineController)
import {getUserNo} from "@/service/authService.js";

//2.Pinia 스토어 & 사용자 정보
const store = useLawyerStore()
const userNo = ref( getUserNo() )
const lawyerName = computed(() => store.lawyerInfo?.name || '')

// 반응형 데이터
const currentTime = ref('')
// 시간 업데이트 타이머
let timeInterval = null

const loading = ref(false)
const lawyerInfo = ref({
  name: lawyerName,
  id: userNo
})

//주요 지표 카드
const dashboardStats = ref([
  {
    title: '내일 상담신청',
    value: '0건',
    icon: '👥',
    color: '#3b82f6',
    trend: false,
    trendValue: null,
    loading: false
  },
  {
    title: '내일 예정된 방송',
    value: '방송 없음',
    icon: '📺',
    color: '#10b981',
    trend: false,
    trendValue: null,
    loading: false
  },
  {
    title: '이달의 수익',
    value: '0원',
    icon: '💰',
    color: '#f59e0b',
    trend: false,
    trendValue: null,
    loading: false
  },
  {
    title: '이달의 템플릿 판매 수',
    value: '0건',
    icon: '📄',
    color: '#8b5cf6',
    trend: false,
    trendValue: null,
    loading: false
  }
])

//오늘 일정
const todaySchedule = ref([])
const scheduleLoading = ref(false)

const tomorrowConsultationRequests = ref([])
const consultationLoading = ref(false)

//내일 예정된 방송 데이터
const tomorrowBroadcasts = ref([])
const broadcastLoading = ref(false)

// 차트 참조
const weeklyChart = ref(null)
const revenueChart = ref(null)
let weeklyChartInstance = null
let revenueChartInstance = null

//4.유틸 함수
// 화면 시계 갱신
const updateTime = () => {
  const now = new Date()
  currentTime.value = now.toLocaleTimeString('ko-KR', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// 날짜 문자열 → "HH:MM" 포맷(시간 포맷팅 함수)
const formatTime = (dateTimeString) => {
  if (!dateTimeString) return ''
  const date = new Date(dateTimeString)
  return date.toLocaleTimeString('ko-KR', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getScheduleIcon = (type) => {
  switch(type) {
    case 'consultation': return '👤'
    case 'broadcast': return '📺'
    case 'qa': return '💬'
    default: return '📅'
  }
}

const getScheduleColor = (type) => {
  switch(type) {
    case 'consultation': return 'bg-blue-100 border-blue-300'
    case 'broadcast': return 'bg-red-100 border-red-300'
    case 'qa': return 'bg-green-100 border-green-300'
    default: return 'bg-gray-100 border-gray-300'
  }
}


// 차트 초기화/업데이트 함수
const createWeeklyChart = (data = null) => {
  if (!weeklyChart.value) return

  const ctx = weeklyChart.value.getContext('2d')

  const chartData = data || {
    consultations: [0, 0, 0, 0, 0, 0, 0],
    broadcasts: [0, 0, 0, 0, 0, 0, 0]
  }

  console.log('차트 생성 데이터:', chartData)

  // 기존 차트가 있으면 제거
  if (weeklyChartInstance) {
    weeklyChartInstance.destroy()
  }

  weeklyChartInstance = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
      datasets: [
        {
          label: '상담',
          data: chartData.consultations,
          backgroundColor: '#3b82f6',
          borderRadius: 6,
          borderSkipped: false,
        },
        {
          label: '방송',
          data: chartData.broadcasts,
          backgroundColor: '#ef4444',
          borderRadius: 6,
          borderSkipped: false,
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top',
          labels: {
            boxWidth: 20,
            padding: 20,
            font: {
              size: 14
            }
          }
        },
        tooltip: {
          backgroundColor: 'rgba(0, 0, 0, 0.8)',
          titleColor: 'white',
          bodyColor: 'white',
          borderColor: '#e5e7eb',
          borderWidth: 1
        }
      },
      scales: {
        x: {
          grid: {
            display: false
          },
          ticks: {
            font: {
              size: 12
            }
          }
        },
        y: {
          beginAtZero: true,
          grid: {
            color: '#f3f4f6'
          },
          ticks: {
            font: {
              size: 12
            }
          }
        }
      }
    }
  })
}

const createRevenueChart = (data = null) => {
  if (!revenueChart.value) return

  const ctx = revenueChart.value.getContext('2d')

  const chartData = data || {
    months: ['1월', '2월', '3월', '4월', '5월', '6월'],
    revenues: [0, 0, 0, 0, 0, 0]
  }

  revenueChartInstance = new Chart(ctx, {
    type: 'line',
    data: {
      labels: chartData.months,
      datasets: [{
        label: '수익 (만원)',
        data: chartData.revenues,
        borderColor: '#f59e0b',
        backgroundColor: 'rgba(245, 158, 11, 0.1)',
        borderWidth: 3,
        fill: true,
        tension: 0.4,
        pointBackgroundColor: '#f59e0b',
        pointBorderColor: '#ffffff',
        pointBorderWidth: 2,
        pointRadius: 6,
        pointHoverRadius: 8
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top',
          labels: {
            boxWidth: 20,
            padding: 20,
            font: {
              size: 14
            }
          }
        },
        tooltip: {
          backgroundColor: 'rgba(0, 0, 0, 0.8)',
          titleColor: 'white',
          bodyColor: 'white',
          borderColor: '#e5e7eb',
          borderWidth: 1
        }
      },
      scales: {
        x: {
          grid: {
            display: false
          },
          ticks: {
            font: {
              size: 12
            }
          }
        },
        y: {
          beginAtZero: true,
          grid: {
            color: '#f3f4f6'
          },
          ticks: {
            font: {
              size: 12
            },
            callback: function(value) {
              return value + '만원'
            }
          }
        }
      }
    }
  })
}

const loadTodaySchedule = async () => {
  scheduleLoading.value = true
  try {
    console.log('오늘 일정 로드 시작')

    const response = await fetchTodaySchedule()
    console.log('오늘 일정 API 응답:', response)

    // 응답 구조에 맞게 수정
    if (response && response.data && Array.isArray(response.data)) {
      todaySchedule.value = response.data
    } else if (response && Array.isArray(response)) {
      // 직접 배열로 반환되는 경우
      todaySchedule.value = response
    } else {
      console.warn('예상과 다른 응답 구조:', response)
      todaySchedule.value = []
    }

    console.log('최종 일정 데이터:', todaySchedule.value)
    // 추가: 각 요소도 개별적으로 출력
    todaySchedule.value.forEach((item, idx) => {
      console.log(`todaySchedule[${idx}]:`, item)
    })

  } catch (error) {
    console.error('오늘 일정 로딩 에러:', error)
    todaySchedule.value = []
  } finally {
    scheduleLoading.value = false
  }
}

const loadTomorrowConsultationRequests = async () => {
  consultationLoading.value = true
  try {
    // console.log('내일 상담신청 로드 시작')

    const response = await fetchTomorrowConsultationRequests()
    // console.log('내일 상담신청 API 응답:', response)

    if (response && response.data && Array.isArray(response.data) && response.data.length > 0) {
      tomorrowConsultationRequests.value = response.data

      dashboardStats.value[0].value = response.data.length + '건'
      dashboardStats.value[0].loading = false

      // console.log('내일 상담신청 데이터 매핑 완료:', tomorrowConsultationRequests.value)
    } else {
      // console.log('내일 상담신청 데이터 없음')
      tomorrowConsultationRequests.value = []
      dashboardStats.value[0].value = '0건'
      dashboardStats.value[0].loading = false
    }
  } catch (error) {
    // console.error('내일 상담신청 로딩 실패:', error)
    tomorrowConsultationRequests.value = []
    dashboardStats.value[0].value = '데이터 없음'
    dashboardStats.value[0].loading = false
  } finally {
    consultationLoading.value = false
  }
}
//내일 방송 로드 함수
const loadTomorrowBroadcasts = async () => {
  broadcastLoading.value = true
  try {
    // console.log('내일 방송 로드 시작')

    const response = await fetchTomorrowBroadcasts()
    // console.log('내일 방송 API 응답:', response)

    if (response && response.data && Array.isArray(response.data) && response.data.length > 0) {
      tomorrowBroadcasts.value = response.data

      // 방송의 시간과 제목을 카드에 표시
      const firstBroadcast = response.data[0]
      const broadcastTime = formatTime(firstBroadcast.startTime)
      const broadcastTitle = firstBroadcast.name

      dashboardStats.value[1].value = `${broadcastTime} ${broadcastTitle}`
      dashboardStats.value[1].loading = false

      // console.log('내일 방송 데이터 매핑 완료:', tomorrowBroadcasts.value)
    } else {
      // console.log('내일 방송 데이터 없음')
      tomorrowBroadcasts.value = []
      dashboardStats.value[1].value = '방송 없음'
      dashboardStats.value[1].loading = false
    }
  } catch (error) {
    // console.error('내일 방송 로딩 실패:', error)
    tomorrowBroadcasts.value = []
    dashboardStats.value[1].value = '방송 없음'
    dashboardStats.value[1].loading = false
  } finally {
    broadcastLoading.value = false
  }
}


const updateWeeklyChart = ({ consultations, broadcasts }) => {
  if (weeklyChartInstance) {
    weeklyChartInstance.data.datasets[0].data = consultations
    weeklyChartInstance.data.datasets[1].data = broadcasts
    weeklyChartInstance.update('active')
  } else {
    createWeeklyChart({ consultations, broadcasts })
  }
}

//주간 차트
const loadWeeklyChartData = async () => {
  try {
    console.log('주간 차트 데이터 로드 시작')

    // ① 주간 상담/방송 각각 API 호출
    const [consultResponse, broadcastResponse] = await Promise.all([
      fetchWeeklyConsultations(),
      fetchWeeklyBroadcasts()
    ])

    console.log('상담 API 응답:', consultResponse)
    console.log('방송 API 응답:', broadcastResponse)

    // ② 배열 초기화 (월~일: 0~6 인덱스)
    const consultations = [0, 0, 0, 0, 0, 0, 0]
    const broadcasts = [0, 0, 0, 0, 0, 0, 0]

    // ③ 상담 데이터 매핑
    if (Array.isArray(consultResponse)) {
      consultResponse.forEach(item => {
        console.log('상담 데이터:', item)

        // LocalDate를 JavaScript Date로 변환
        const date = new Date(item.date)
        const dayOfWeek = date.getDay() // 0=일요일, 1=월요일, ..., 6=토요일

        // 배열 인덱스 변환: 월요일(0) ~ 일요일(6)
        const arrayIndex = dayOfWeek === 0 ? 6 : dayOfWeek - 1

        if (arrayIndex >= 0 && arrayIndex < 7) {
          consultations[arrayIndex] = item.count
        }
      })
    }

    // ④ 방송 데이터 매핑
    if (Array.isArray(broadcastResponse)) {
      broadcastResponse.forEach(item => {
        console.log('방송 데이터:', item)

        const date = new Date(item.date)
        const dayOfWeek = date.getDay() // 0=일요일, 1=월요일, ..., 6=토요일

        // 배열 인덱스 변환: 월요일(0) ~ 일요일(6)
        const arrayIndex = dayOfWeek === 0 ? 6 : dayOfWeek - 1

        if (arrayIndex >= 0 && arrayIndex < 7) {
          broadcasts[arrayIndex] = item.count
        }
      })
    }

    console.log('최종 상담 배열:', consultations)
    console.log('최종 방송 배열:', broadcasts)

    // ⑤ 차트에 데이터 반영
    updateWeeklyChart({ consultations, broadcasts })

  } catch (error) {
    console.error('주간 차트 로드 실패:', error)
    console.error('에러 상세:', error.message)

    // 에러 시 더미 데이터
    updateWeeklyChart({
      consultations: [1, 2, 3, 4, 5, 2, 1],
      broadcasts: [2, 1, 4, 3, 2, 3, 2]
    })
  }
}

// 이달의 수익 로드 함수
const loadMonthlyRevenue = async () => {
  try {
    console.log('이달의 수익 로드 시작')

    const response = await fetchMonthlyRevenue()
    console.log('이달의 수익 API 응답:', response)

    if (response && response.data) {
      const revenue = response.data

      // 총 수익을 원 단위로 포맷팅
      const totalRevenueInWon = revenue.totalRevenue || 0
      const formattedRevenue = totalRevenueInWon.toLocaleString('ko-KR') + '원'

      dashboardStats.value[2].value = formattedRevenue
      dashboardStats.value[2].loading = false

      console.log('이달의 수익 데이터 매핑 완료:', formattedRevenue)
    } else {
      console.log('이달의 수익 데이터 없음')
      dashboardStats.value[2].value = '0원'
      dashboardStats.value[2].loading = false
    }
  } catch (error) {
    console.error('이달의 수익 로딩 실패:', error)

    // 더 자세한 에러 정보 출력
    if (error.response) {
      // 서버가 응답을 했지만 에러 상태 코드
      console.error('응답 에러:', {
        status: error.response.status,
        statusText: error.response.statusText,
        data: error.response.data,
        headers: error.response.headers
      })
    } else if (error.request) {
      // 요청이 만들어졌지만 응답을 받지 못함
      console.error('요청 에러:', error.request)
    } else {
      // 요청 설정에서 에러 발생
      console.error('설정 에러:', error.message)
    }

    dashboardStats.value[2].value = '0원'
    dashboardStats.value[2].loading = false
  }
}

// 이달의 템플릿 판매 건수 로드 함수
const loadMonthlyTemplateSales = async () => {
  try {
    console.log('이달의 템플릿 판매 건수 로드 시작')
    console.log('요청 URL:', '/api/lawyer/dashboard/monthly-template-sales')

    const response = await fetchMonthlyTemplateSales()
    console.log('이달의 템플릿 판매 건수 API 응답:', response)

    if (response && response.data) {
      const sales = response.data
      const monthlySalesCount = sales.monthlySalesCount || 0
      dashboardStats.value[3].value = `${monthlySalesCount}건`
      dashboardStats.value[3].loading = false
      console.log('이달의 템플릿 판매 건수 데이터 매핑 완료:', `${monthlySalesCount}건`)
    } else {
      console.log('이달의 템플릿 판매 건수 데이터 없음')
      dashboardStats.value[3].value = '0건'
      dashboardStats.value[3].loading = false
    }
  } catch (error) {
    console.error('이달의 템플릿 판매 건수 로딩 실패:', error)
    console.error('에러 상세:', error.message)
    console.error('에러 코드:', error.code)
    console.error('요청 정보:', error.config)

    dashboardStats.value[3].value = '0건'
    dashboardStats.value[3].loading = false
  }
}

const loadMonthlySalesRevenue = async () => {
  dashboardStats.value[2].loading = true  // “이달의 수익” 카드 인덱스가 2번이라 가정
  try {
    console.log('월별 판매 수익 로드 시작')

    const response = await fetchMonthlySalesRevenue()
    console.log('월별 판매 수익 API 응답:', response)

    if (response && response.data && Array.isArray(response.data) && response.data.length > 0) {
      // 1) 차트 데이터 준비
      const months   = response.data.map(d => d.month)
      const revenues = response.data.map(d => Math.round(d.totalAmount / 10000))

      // 2) 차트 그리기
      createRevenueChart({ months, revenues })

      // 3) “이달의 수익” 카드 업데이트
      const currentMonth = new Date().toISOString().slice(0,7) // 'YYYY-MM'
      const thisMonthData = response.data.find(d => d.month === currentMonth)
      dashboardStats.value[2].value = thisMonthData
          ? `${Math.round(thisMonthData.totalAmount/10000)}만원`
          : '0만원'

      console.log('월별 판매 수익 데이터 매핑 완료')
    } else {
      console.log('월별 판매 수익 데이터 없음')
      // 차트 클리어 혹은 빈 데이터 처리
      createRevenueChart({ months: [], revenues: [] })
      dashboardStats.value[2].value = '0만원'
    }
  } catch (error) {
    console.error('월별 판매 수익 로딩 실패:', error)
    // 실패 시에도 빈 차트
    createRevenueChart({ months: [], revenues: [] })
    dashboardStats.value[2].value = '데이터 없음'
  } finally {
    dashboardStats.value[2].loading = false
  }
}

onMounted(() => {
  //시계 시작
  updateTime()
  timeInterval = setInterval(updateTime, 1000)

  // 1) 빈 차트 먼저 그리기
  // setTimeout(() => {
  //   createWeeklyChart()
  // }, 100)

  // 2) 실제 데이터로 업데이트
  loadWeeklyChartData()
  loadTodaySchedule()
  loadTomorrowConsultationRequests()
  loadTomorrowBroadcasts()
  // loadMonthlyRevenue() // 이달의 수익 (월별 수익 트렌드 차트에서 값을 구해오는 중)
  loadMonthlyTemplateSales()  // 이달의 템플릿
  loadMonthlySalesRevenue()

})


onUnmounted(() => {
  if (timeInterval) {
    clearInterval(timeInterval)
  }
  if (weeklyChartInstance) {
    weeklyChartInstance.destroy()
  }
  if (revenueChartInstance) {
    revenueChartInstance.destroy()
  }
})

</script>

<template>
  <LawyerFrame>

      <div class="bg-[#f7f8fa] rounded-2xl px-4 py-1">

      <!-- 헤더 -->
      <div class="card mb-4">
        <div class="card-body d-flex justify-content-between align-items-center">
          <h5 class="card-title mb-0">안녕하세요, {{ lawyerName }} 변호사님</h5>
          <div class="text-end">
            <small class="text-muted">현재 시간은</small>
            <div class="h5 mb-0">{{ currentTime }}</div>
          </div>
        </div>
      </div>

      <!-- 오늘 일정 -->
      <div class="card mb-4">
        <div class="card-header d-flex align-items-center">
          <i class="bi bi-calendar3 me-2"></i>
          <strong>오늘 일정</strong>
        </div>
        <div class="card-body p-3">
          <div class="row row-cols-1 gy-1">
            <div
                v-for="(s, i) in todaySchedule"
                :key="i"
                class="col"
            >
              <!-- border-0 으로 모든 테두리 제거 후 border-bottom 만 적용 -->
              <div class="d-flex align-items-center py-1 px-2 border-0 border-bottom">
                <i class="bi bi-person-fill text-primary fs-5 me-2"></i>
                <div>
                  <div class="small text-secondary">{{ s.time }}</div>
                  <div>
                    {{ s.event }}
                    <span v-if="s.clientPhone"> ({{ s.clientPhone }})</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 주요 지표 카드 -->
      <div class="row row-cols-2 row-cols-md-4 g-3 mb-4">
        <div
            v-for="stat in dashboardStats"
            :key="stat.title"
            class="col d-flex"
        >
          <!-- border-start 제거, 대신 border 로 사방 테두리 -->
          <div
              class="card flex-fill border"
              :style="{ borderColor: stat.color }"
          >
            <div class="card-body">
              <h6 class="card-subtitle mb-2 text-muted">{{ stat.title }}</h6>
              <div class="d-flex align-items-center">
                <span class="fs-4 me-2">{{ stat.icon }}</span>
                <h5
                    class="mb-0"
                    :class="stat.value === '데이터 없음' ? 'text-secondary' : ''"
                    :style="stat.value !== '데이터 없음' ? { color: stat.color } : {}"
                >
                  {{ stat.value }}
                </h5>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 차트 영역 -->
      <div class="row gy-4">
        <div class="col-lg-6">
          <div class="card h-100">
            <div class="card-header d-flex align-items-center">
              <i class="bi bi-bar-chart me-2"></i>
              <strong>주간 상담 & 방송 현황</strong>
            </div>
            <div class="card-body">
              <canvas ref="weeklyChart" class="w-100" style="height:300px;"></canvas>
            </div>
          </div>
        </div>
        <div class="col-lg-6">
          <div class="card h-100">
            <div class="card-header d-flex align-items-center">
              <i class="bi bi-graph-up me-2"></i>
              <strong>월별 수익 트렌드</strong>
            </div>
            <div class="card-body">
              <canvas ref="revenueChart" class="w-100" style="height:300px;"></canvas>
            </div>
          </div>
        </div>
      </div>

    </div>
  </LawyerFrame>
</template>


<style scoped>
.bg-gradient-custom {
  background: #f9f9f9;
}

.transition-all {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.font-mono {
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
}

/* 애니메이션 */
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

/* 커스텀 스크롤바 */
::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 10px;
}

::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 10px;
}

::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

/* 반응형 개선 */
@media (max-width: 480px) {
  /* 아주 작은 화면에서 추가 조정 */
  .text-lg {
    font-size: 1rem;
  }

  .text-xl {
    font-size: 1.125rem;
  }
}

.dashboard-stats-row {
  display: flex;
  flex-direction: row;
  gap: 1rem;
}
.dashboard-stats-card {
  flex: 1;
  background: white;
  border-radius: 0.75rem;
  /* box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); */
  padding: 1rem;
  border-left-width: 4px;
  border-left-style: solid;
  min-width: 0;
}
.dashboard-stats-card-inner {
  display: flex;
  flex-direction: column;
}
.dashboard-stats-title {
  color: #6b7280;
  font-size: 0.875rem;
  font-weight: 500;
}
.dashboard-stats-value-row {
  margin-top: 0.25rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  white-space: nowrap;
}
.dashboard-stats-icon {
  font-size: 1.25rem;
}
.dashboard-stats-value {
  font-size: 1.25rem;
  font-weight: 700;
}
.text-blue { color: #3b82f6; }
.text-green { color: #10b981; }
.text-yellow { color: #f59e0b; }
.text-purple { color: #8b5cf6; }
.border-blue { border-left-color: #3b82f6; }
.border-green { border-left-color: #10b981; }
.border-yellow { border-left-color: #f59e0b; }
.border-purple { border-left-color: #8b5cf6; }
.no-shadow {
  box-shadow: none !important;
}

@media (max-width: 768px) {
  .dashboard-stats-row {
    flex-direction: column !important;
    gap: 0.75rem !important;
  }
  .dashboard-stats-card {
    width: 100% !important;
    min-width: 0 !important;
  }
  .max-w-7xl {
    padding-left: 0.5rem !important;
    padding-right: 0.5rem !important;
  }
}

.dashboard-bg {
  background: #f7f8fa;
  border-radius: 1.25rem;
  padding: 1rem 1.5rem 1rem 1.5rem; /* 위 1rem, 좌우 1.5rem, 아래 1rem */
  /* min-height: 100vh;  // 제거 */
}
</style>