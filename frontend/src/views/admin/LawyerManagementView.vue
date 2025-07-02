<script setup>
import AdminFrame from "@/components/layout/admin/AdminFrame.vue";
import CustomTable from "@/components/table/CustomTable.vue";
import { ref, onMounted, onUnmounted, computed } from 'vue'
import axios from 'axios'

const rows = ref([])
const isLoading = ref(false)
const hasMore = ref(true)
const offset = ref(0)
const limit = 20

const searchKeyword = ref('')
const currentFilters = ref({})
const filters = ref([
  { label: '계정 상태', key: 'accountStatus', options: ['전체', 'APPROVED_JOIN', 'REJECTED_JOIN', 'PENDING_LEAVE', 'APPROVED_LEAVE'] }
])

const accountStatusMap = {
  APPROVED_JOIN: 'APPROVED_JOIN',
  REJECTED_JOIN: 'REJECTED_JOIN',
  PENDING_LEAVE: 'PENDING_LEAVE',
  APPROVED_LEAVE: 'APPROVED_LEAVE'
}

function handleScroll() {
  const scrollBottom = window.innerHeight + window.scrollY >= document.body.offsetHeight - 50
  if (scrollBottom && !isLoading.value && hasMore.value) {
    fetchItems()
  }
}

async function fetchItems() {
  isLoading.value = true
  const params = {
    offset: offset.value,
    limit,
    ...currentFilters.value,
    keyword: searchKeyword.value
  }

  try {
    const res = await axios.get('/api/admin/lawyer', { params })
    const list = (res.data.list || []).map(item => ({
      ...item,
      accountStatus: item.status  // 여기서 반드시 status 를 accountStatus 로 복사
    }))

    console.log('res:', res.data)
    console.log('list:', list)

    if (list.length < limit) hasMore.value = false
    rows.value.push(...list)
    offset.value += list.length
  } catch (e) {
    console.error('조회 실패:', e)
  } finally {
    isLoading.value = false
  }
}

function handleFilterChange(newFilters) {
  const reverseStatusMap = Object.fromEntries(Object.entries(accountStatusMap).map(([k, v]) => [v, k]))
  const mapped = {}
  if (newFilters.accountStatus && newFilters.accountStatus !== '전체') {
    mapped.accountStatus = reverseStatusMap[newFilters.accountStatus]
  }

  searchKeyword.value = ''
  rows.value = []
  offset.value = 0
  hasMore.value = true
  currentFilters.value = mapped

  fetchItems()
}

const showModal = ref(false)
const selectedLawyer = ref(null)

function handleRowClick(row) {
  if (row.accountStatus !== 'REJECTED_JOIN') return
  selectedLawyer.value = row
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedLawyer.value = null
}

const profileUrl = computed(() =>
    selectedLawyer.value?.profile?.startsWith('http')
        ? selectedLawyer.value.profile
        : `https://kr.object.ncloudstorage.com/law-n-road/${selectedLawyer.value?.profile || ''}`
)

const cardFrontUrl = computed(() =>
    selectedLawyer.value?.cardFront?.startsWith('http')
        ? selectedLawyer.value.cardFront
        : `https://kr.object.ncloudstorage.com/law-n-road/${selectedLawyer.value?.cardFront || ''}`
)

const cardBackUrl = computed(() =>
    selectedLawyer.value?.cardBack?.startsWith('http')
        ? selectedLawyer.value.cardBack
        : `https://kr.object.ncloudstorage.com/law-n-road/${selectedLawyer.value?.cardBack || ''}`
)

onMounted(() => {
  fetchItems()
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

async function approveLawyer() {
  if (!selectedLawyer.value) return

  try {
    const res = await axios.post('/api/admin/lawyer/approve', {
      no: selectedLawyer.value.no
    })

    alert('승인 처리 완료')
    selectedLawyer.value.accountStatus = 'APPROVED_JOIN'

    // rows 갱신
    const idx = rows.value.findIndex(l => l.no === selectedLawyer.value.no)
    if (idx !== -1) rows.value[idx].accountStatus = 'APPROVED_JOIN'

    closeModal()
  } catch (e) {
    console.error('승인 실패:', e)
    alert('승인 처리 중 오류 발생')
  }
}



</script>


<template>
  <AdminFrame>
    <div class="container py-5">
      <CustomTable
          :rows="rows"
          :columns="[
            { label: '번호',       key: 'no' },
            { label: '이름',       key: 'name' },
            { label: '아이디',     key: 'lawyerId' },
            { label: '전화번호',   key: 'phone' },
            { label: '이메일',     key: 'email' },
            { label: '가입일',     key: 'createdAt' },
            { label: '계정 상태',  key: 'accountStatus' }
          ]"
          :filters="filters"
          :show-search-input="true"
          @update:filters="handleFilterChange"
          @row-click="handleRowClick"
      >
        <template #cell-accountStatus="{ row }">
          <span :style="{ color: row.accountStatus === 'APPROVED_JOIN' ? '#003366' : 'inherit' }">
            {{ accountStatusMap[row.accountStatus] || row.accountStatus }}
          </span>
        </template>
      </CustomTable>

      <div v-if="isLoading" class="text-center my-4">불러오는 중...</div>
      <div v-if="!hasMore" class="text-center my-4 text-muted">모든 변호사를 불러왔습니다.</div>
    </div>

    <!-- ✅ 사진 모달 -->
    <div v-if="showModal" class="modal-overlay">
      <div class="modal-container">
        <button class="modal-close-btn" @click="closeModal">✕</button>
        <h3 class="modal-title">변호사 사진 (#{{ selectedLawyer?.no }})</h3>
        <div class="mt-4 text-right">
        </div>
        <div class="image-section">
          <div>
            <p>프로필 사진</p>
            <img :src="profileUrl" alt="프로필" @error="e => e.target.style.display='none'" />
          </div>
          <div>
            <p>신분증 앞면</p>
            <img :src="cardFrontUrl" alt="신분증 앞" @error="e => e.target.style.display='none'" />
          </div>
          <div>
            <p>신분증 뒷면</p>
            <img :src="cardBackUrl" alt="신분증 뒤" @error="e => e.target.style.display='none'" />
          </div>


        </div>
        <button v-if="selectedLawyer?.accountStatus !== 'APPROVED_JOIN'" class="approve-btn btn btn-primary mt-4" @click="approveLawyer">
          승인하기
        </button>
      </div>
    </div>
  </AdminFrame>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}
.modal-container {
  background: white;
  padding: 24px;
  border-radius: 8px;
  width: 700px;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
}
.modal-close-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
}
.modal-title {
  font-size: 1.2rem;
  font-weight: bold;
  margin-bottom: 16px;
}
.image-section {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.image-section img {
  width: 100%;
  max-height: 200px;
  object-fit: contain;
  border: 1px solid #ddd;
  border-radius: 4px;
}
</style>
