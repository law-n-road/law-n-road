<script setup>
import { useRoute, useRouter } from 'vue-router'
import { ref, watch } from 'vue'

const router = useRouter()
const route = useRoute()
const emit = defineEmits(['update:title'])

const lawyer = {
  name: '김수영',
}

const menuItems = [
  // { label: '홈 대시보드', icon: 'bi-house-door', path: '/admin' },
  { label: '의뢰인관리', icon: 'bi-people', path: '/admin' },
  { label: '변호사관리', icon: 'bi-person-badge', path: '/admin/lawyer' },
  { label: '변호사신고관리', icon: 'bi-exclamation-circle', path: '/admin/report_lawyer' },
  { label: '의뢰인신고관리', icon: 'bi-person-x', path: '/admin/report_client' },
  { label: '광고관리', icon: 'bi-megaphone', path: '/admin/ads' },
]

function go(path, label) {
  emit('update:title', label)
  router.push(path)
}

function logout() {
  // ✅ 1. 로컬스토리지 항목 삭제
  localStorage.removeItem('token')

  localStorage.removeItem('accountType')
  localStorage.removeItem('name')
  localStorage.removeItem('no')

  // ✅ 2. Axios 인증 헤더 제거
  //delete axios.defaults.headers.common['Authorization']
  console.log('로그아웃')

  router.push('/')
  // setTimeout(() => location.reload(), 100)
}

watch(
    () => route.path,
    () => {
      const current = menuItems.find(item => item.path === route.path)
      if (current) emit('update:title', current.label)
    },
    { immediate: true }
)
</script>

<template>
  <aside class="sidebar d-flex flex-column justify-content-between align-items-center">
    <div class="w-100">
      <!-- 로고 -->
      <div class="logo-box mb-5 text-center">
        <img src="@/assets/images/logo/logo-dark.png" alt="로앤로드 로고" class="logo-img" />
      </div>

      <!-- 프로필 -->
      <div class="profile-box text-center mb-5 mt-3">
        <i class="bi bi-person-lock fs-1"></i>
        <div class="profile-name mt-0 fw-semibold">{{ lawyer.name }} 관리자</div>
        <div class="small text-white-50">접속을 환영합니다</div>
      </div>

      <!-- 메뉴 -->
      <ul class="nav-list w-100 px-3">
        <li v-for="item in menuItems" :key="item.path"
            :class="{ active: route.path === item.path }"
            @click="go(item.path, item.label)">
          <i :class="`bi ${item.icon} me-2`"></i> {{ item.label }}
        </li>
      </ul>
    </div>

    <!-- 하단 로그아웃 버튼 -->
    <div class="logout-box w-100 text-start px-3 pb-20">
      <small class="logout-link" @click="logout">로그아웃</small>
    </div>
  </aside>
</template>

<style scoped>
.sidebar {
  width: 240px;
  min-height: 100vh;
  background-color: #2e3b4e;
  color: white;
  padding: 24px 12px;
}
.logo-img {
  width: 160px;
}
.profile-img {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid white;
}
.nav-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.nav-list li {
  padding: 10px;
  border-radius: 6px;
  font-size: 0.95rem;
  cursor: pointer;
  transition: background-color 0.2s;
}
.nav-list li:hover {
  background-color: #3c4c60;
}
.nav-list li.active {
  background-color: #445b7c;
  font-weight: bold;
}
.logout-box {
  width: 100%;
}
.logout-link {
  color: #767779;
  font-size: 0.75rem;
  cursor: pointer !important;
  transition: opacity 0.2s;
}
.logout-link:hover {
  opacity: 0.6;
  text-decoration: underline;
}
</style>
