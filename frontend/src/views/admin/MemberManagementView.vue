<script setup>
import AdminFrame from "@/components/layout/admin/AdminFrame.vue";
import CustomTable from "@/components/table/CustomTable.vue";
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

const router = useRouter()
const rows = ref([])
const isLoading = ref(false)
const hasMore = ref(true)
const offset = ref(0)
const limit = 20

const currentFilters = ref({})
const filters = ref([
  { label: '회원유형', key: 'type', options: ['전체', '의뢰인'] },
  { label: '계정 상태', key: 'status', options: ['전체', '회원', '가입대기', '탈퇴', '패널티 중'] }
])

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
    ...currentFilters.value
  }

  try {
    const res = await axios.get('/api/admin/client', { params })

    const list = (res.data.list || []).map(item => ({
      ...item,
      accountStatus: item.status
    }))

    if (list.length < limit) {
      hasMore.value = false
    }

    rows.value.push(...list)
    offset.value += list.length
  } catch (e) {
    console.error('조회 실패:', e)
  } finally {
    isLoading.value = false
  }
}

function handleFilterChange(newFilters) {
  const mapped = { ...newFilters }
  if (mapped.type === '전체') delete mapped.type
  if (mapped.status === '전체') delete mapped.status

  rows.value = []
  offset.value = 0
  hasMore.value = true
  currentFilters.value = mapped

  fetchItems()
}

function handleRowClick(row) {
  if (!row) return
  router.push(`/admin/client/detail/${row.no}`)
}

function handleEdit(row) {
  router.push(`/admin/client/edit/${row.no}`)
}

async function handleDelete(row) {
  if (!confirm(`'${row?.name}' 회원을 삭제하시겠습니까?`)) return
  try {
    await axios.delete(`/api/admin/member/client/${row.no}`)
    rows.value = rows.value.filter(r => r.no !== row.no)
    alert('삭제되었습니다.')
  } catch (e) {
    console.error('삭제 실패:', e)
    alert(e?.response?.data?.message || '삭제 중 오류가 발생했습니다.')
  }
}

onMounted(() => {
  fetchItems()
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<template>
  <AdminFrame>
    <div class="container py-5">
      <CustomTable
          :rows="rows"
          :columns="[
            { label: '회원번호',     key: 'no' },
            { label: '회원유형',     key: 'type' },
            { label: '회원명',       key: 'name' },
            { label: '아이디',       key: 'id' },
            { label: '전화번호',     key: 'phone' },
            { label: '이메일',       key: 'email' },
            { label: '회원 가입일',  key: 'createdAt' },
            { label: '계정상태',     key: 'accountStatus' }
          ]"
          :action-buttons="{ edit: true, delete: true }"
          :filters="filters"
          @edit-action="handleEdit"
          @delete-action="handleDelete"
          @update:filters="handleFilterChange"
      >
        <!-- status 셀에 조건부 스타일 적용 -->
        <template #cell-status="{ row }">
          <span :style="{ color: row.accountStatus === '회원' ? '#003366' : 'inherit' }">
            {{ row.accountStatus }}
          </span>
        </template>
      </CustomTable>

      <div v-if="isLoading" class="text-center my-4">불러오는 중...</div>
      <div v-if="!hasMore" class="text-center my-4 text-muted">모든 회원을 불러왔습니다.</div>
    </div>
  </AdminFrame>
</template>


<style scoped>
img {
  object-fit: cover;
}

.bg-navy {
  background-color: #003366 !important;
  color: white !important;
}
</style>