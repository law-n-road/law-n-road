<script setup>
import ClientFrame from '@/components/layout/client/ClientFrame.vue'
import CustomTable from '@/components/table/CustomTable.vue'
import { ref, onMounted } from 'vue'
import http from '@/libs/HttpRequester'
import { useRouter } from 'vue-router'

// 라우터
const router = useRouter()
// 상태
const rows = ref([])
const currentPage = ref(1)
const totalPages = ref(1)
const filters = ref([
  {
    label: '주문상태',
    key: 'status',
    options: ['전체', 'ORDERED', 'CANCELED', 'REFUNDED']
  }
])
// status + 검색어(keyword) 가 이 오브젝트에 담겨서 넘어옴
const currentFilters = ref({})
const isDownloaded = ref(false)

// 템플릿 목록 불러오기
async function fetchOrders(filtersObj, pageNo) {
  const params = {
    no: Number(localStorage.getItem('no')),
    page: pageNo,
    limit: 10,
    ...normalizeFilters(filtersObj)
  }

  console.log('fetchOrders', params)
  const res = await http.get('/api/client/templates/orders', params)

  console.log(res)

  // 상태 한글 변환 맵
  const statusLabelMap = {
    ORDERED: '결제대기',
    PAID: '결제완료',
    CANCELED: '환불'
  }

  // rows에 한글 상태 필드 추가
  rows.value = res.data.orders.map((o) => ({
    ...o,
    status: statusLabelMap[o.status] || o.status
  }))

  // rows.value = res.data.orders
  totalPages.value = res.data.totalPages
  currentPage.value = pageNo
  isDownloaded.value = res.data.isDownloaded
}

// 서버에 보낼 쿼리 정리
function normalizeFilters(f) {
  return {
    status: f.status && f.status !== '전체' ? f.status : undefined,
    keyword: f.keyword?.trim() || undefined
  }
}

// 필터(주문상태 + 검색어) 변경 시
function handleFilterChange(newFilters) {
  currentFilters.value = { ...newFilters }
  currentPage.value = 1
  fetchOrders(currentFilters.value, 1)
}

// 페이지 변경 시
function handlePageChange(newPage) {
  fetchOrders(currentFilters.value, newPage)
}

// 행 클릭
function handleRowClick(row) {
  if (!row || row.status === '환불') return
  router.push(`/client/template/orders/${row.orderNo}`)
}

// 초기 로딩
onMounted(() => fetchOrders(currentFilters.value, currentPage.value))
</script>

<template>
  <ClientFrame>
    <div class="container py-5">
      <h4 class="mb-4 fw-bold">템플릿 주문 내역</h4>
      <CustomTable
          :rows="rows"
          :columns="[
            { label: '주문번호', key: 'orderNo' },
            { label: '주문일자', key: 'orderDate' },
            {
              label: '주문상품',
              key: 'firstTemplateName',
              formatter: (v, row) => {
                const count = row.templateCount || 0
                return count > 1 ? `${v} 외 ${count - 1}건` : v
              }
            },
            {
              label: '총금액',
              key: 'amount',
              formatter: (v) => `${v.toLocaleString()}원`
            },
            {
              label: '주문상태',
              key: 'status'  // fetchOrders 내부에서 매핑 진행
            },
          ]"
          :show-search-input="true"
          :filters="filters"
          :current-page="currentPage"
          :total-pages="totalPages"
          @update:filters="handleFilterChange"
          @page-change="handlePageChange"
          @row-click="handleRowClick"
      />
    </div>
  </ClientFrame>
</template>
