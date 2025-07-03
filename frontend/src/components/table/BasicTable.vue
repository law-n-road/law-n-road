<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  columns: Array,
  fullData: Array,
  pageSize: {
    type: Number,
    default: 10
  }
})

const currentPage = ref(1)
const sortKey = ref(null)
const sortOrder = ref('asc')

// 정렬
const sortedData = computed(() => {
  if (!sortKey.value) return props.fullData

  return [...props.fullData].sort((a, b) => {
    if (a[sortKey.value] < b[sortKey.value]) return sortOrder.value === 'asc' ? -1 : 1
    if (a[sortKey.value] > b[sortKey.value]) return sortOrder.value === 'asc' ? 1 : -1
    return 0
  })
})

// 페이징
const totalPages = computed(() => Math.ceil(sortedData.value.length / props.pageSize))
const pagedData = computed(() => {
  const start = (currentPage.value - 1) * props.pageSize
  return sortedData.value.slice(start, start + props.pageSize)
})

// 페이지 그룹 (5개 단위)
const pageGroup = computed(() => {
  const groupSize = 5
  const groupIndex = Math.floor((currentPage.value - 1) / groupSize)
  const start = groupIndex * groupSize + 1
  const end = Math.min(start + groupSize - 1, totalPages.value)
  const pages = Array.from({ length: end - start + 1 }, (_, i) => start + i)
  return {
    groupIndex,
    pages,
    hasPrev: start > 1,
    hasNext: end < totalPages.value
  }
})

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const toggleSort = (key) => {
  if (sortKey.value === key) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortKey.value = key
    sortOrder.value = 'asc'
  }
}
</script>

<template>
  <div class="table-wrapper">
    <table class="table table-hover align-middle mb-0">
      <thead>
        <tr>
          <th
            v-for="col in columns"
            :key="col.key"
            @click="toggleSort(col.key)"
            style="cursor: pointer;"
          >
            {{ col.label }}
            <span v-if="sortKey === col.key">
              {{ sortOrder === 'asc' ? '▲' : '▼' }}
            </span>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-if="pagedData.length === 0">
          <td :colspan="columns.length" class="text-center">데이터가 없습니다.</td>
        </tr>
        <tr v-for="row in pagedData" :key="row.no" @click="$emit('row-click', row)">
          <td
              v-for="col in columns"
              :key="col.key"
          >
            <!-- 슬롯이 있으면 슬롯으로 출력 -->
            <slot
                :name="`cell-${col.key}`"
                :row="row"
                :value="row[col.key]"
            >
              {{ row[col.key] }}
            </slot>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 페이지네이션 -->
    <nav v-if="totalPages > 1">
      <ul class="pagination justify-content-center">
        <!-- 이전 그룹 -->
        <li class="page-item" :class="{ disabled: !pageGroup.hasPrev }">
          <button class="page-link" @click="changePage(pageGroup.pages[0] - 1)">‹</button>
        </li>

        <!-- 그룹 내 페이지 -->
        <li
          v-for="p in pageGroup.pages"
          :key="p"
          class="page-item"
          :class="{ active: p === currentPage }"
        >
          <button class="page-link" @click="changePage(p)">{{ p }}</button>
        </li>

        <!-- 다음 그룹 -->
        <li class="page-item" :class="{ disabled: !pageGroup.hasNext }">
          <button class="page-link" @click="changePage(pageGroup.pages.at(-1) + 1)">›</button>
        </li>
      </ul>
    </nav>
  </div>
</template>

<style scoped>

</style>
