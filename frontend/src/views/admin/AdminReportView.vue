<template>
  <AdminFrame>
    <div class="container py-5">
      <h2 class="mb-4">미처리 신고 목록</h2>

      <!-- 방송번호 검색창 -->
      <div class="row mb-3">
        <div class="col-md-4">
          <input
              v-model="searchKeyword"
              type="text"
              class="form-control"
              placeholder="방송번호로 검색"
          />
        </div>
      </div>

      <!-- 테이블 -->
      <CustomTable
          :rows="filteredRows"
          :columns="[
          { label: '신고번호',      key: 'no' },
          { label: '신고자 번호',   key: 'userNo' },
          { label: '방송번호',      key: 'broadcastNo' },
          { label: '신고 사유 코드', key: 'reason' },
          { label: '상세 사유',     key: 'detailReason' },
          { label: '신고일시',      key: 'createdAt' },
          { label: '관리',         key: 'actions' }
        ]"
          :show-search-input="false"
          :action-buttons="{ edit: false, delete: true }"
          @delete-action="handlePenalty"
      />

      <div v-if="isLoading" class="text-center my-4">불러오는 중...</div>
      <div
          v-else-if="!isLoading && filteredRows.length === 0"
          class="text-center my-4 text-muted"
      >
        조건에 맞는 신고가 없습니다.
      </div>
    </div>
  </AdminFrame>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import AdminFrame from '@/components/layout/admin/AdminFrame.vue'
import CustomTable from '@/components/table/CustomTable.vue'

const rows = ref([])
const isLoading = ref(false)
const searchKeyword = ref('')

// 전체 목록 조회
async function fetchReports() {
  isLoading.value = true
  try {
    const res = await axios.get('/api/admin/report/unpenalized')
    rows.value = res.data
  } catch (err) {
    console.error('신고 목록 조회 실패:', err)
  } finally {
    isLoading.value = false
  }
}

// 페널티 부여
function handlePenalty(row) {
  if (!confirm(`방송번호 ${row.broadcastNo}에 대해 패널티를 부여하시겠습니까?`)) return

  axios.post('/api/admin/report/penalty', { broadcastNo: row.broadcastNo })
      .then(() => {
        alert('패널티 부여 완료')
        fetchReports()
      })
      .catch(err => {
        console.error('패널티 부여 실패:', err)
        alert(err.response?.data?.message || '패널티 처리 중 오류가 발생했습니다.')
      })
}

// 마운트 시 데이터 로드
onMounted(fetchReports)

// 검색어 기반 필터링
const filteredRows = computed(() => {
  const kw = searchKeyword.value.trim()
  if (!kw) return rows.value
  return rows.value.filter(r =>
      String(r.broadcastNo).includes(kw)
  )
})
</script>
<style scoped>
/* 검색창과 테이블 사이 여백 */
.row.mb-3 {
  margin-bottom: 1.5rem !important;
}
</style>
