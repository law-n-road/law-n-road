<script setup>
import {ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import http from '@/libs/HttpRequester'
import ClientFrame from '@/components/layout/client/ClientFrame.vue'
import { useRouter } from 'vue-router'
import ProductCard from "@/components/common/ProductCard.vue";

const router = useRouter()

// 상태
const route = useRoute()
const template = ref(null)
const productList = ref(null)

// 템플릿 + 변호사 상품 정보 요청 함수
const fetchTemplateAndProducts = async () => {
  const templateNo = route.params.no
  try {
    const res = await http.get(`/api/public/templates/${templateNo}`)
    template.value = res.data

    const res2 = await http.get(`/api/public/homepage/${template.value.lawyerNo}`)
    productList.value = res2.data
  } catch (err) {
    console.error('템플릿 조회 실패:', err)
  }
}

// 최초 mount 시 호출
onMounted(fetchTemplateAndProducts)

// 장바구니 함수
const handleAddToCart = async () => {
  const accountType = localStorage.getItem('accountType')

  if (!accountType) {
    alert('로그인이 필요합니다.')
    return;
    // return router.push(`/login?redirect=${encodeURIComponent(route.fullPath)}`)
  }

  if (accountType !== 'client') {
    alert('접근 권한이 없습니다.')
    return;
    // return router.push('/')
  }

  try {
    await http.post('/api/client/cart', {
      tmplNo: template.value.no
    })

    const goToCart = confirm('장바구니에 상품이 추가되었습니다.\n장바구니로 이동하시겠습니까?')
    if (goToCart) {
      await router.push('/client/cart')
    }
  } catch (err) {
    if (err.response?.status === 409) {
      alert('이미 장바구니에 담긴 상품입니다.')
    } else {
      console.error('장바구니 추가 실패:', err)
      alert('장바구니 추가 중 오류가 발생했습니다.')
    }
  }
}

// 구매하기 함수 (alert 창 없이 바로 장바구니로)
const handleAddToCart2 = async () => {
  const accountType = localStorage.getItem('accountType')

  if (!accountType) {
    alert('로그인이 필요합니다.')
    return;
    // return router.push(`/login?redirect=${encodeURIComponent(route.fullPath)}`)
  }

  if (accountType !== 'client') {
    alert('접근 권한이 없습니다.')
    return;
    // return router.push('/')
  }

  try {
    await http.post('/api/client/cart', {
      tmplNo: template.value.no
    })

    await router.push('/client/cart')
  } catch (err) {
    if (err.response?.status === 409) {
      await router.push('/client/cart')
    } else {
      console.error('장바구니 추가 실패:', err)
      alert('구매 중 오류가 발생했습니다.')
    }
  }
}

watch(() => route.params.no, fetchTemplateAndProducts)
</script>
<template>
  <ClientFrame>
    <div class="container py-5" v-if="template">
      <!-- 상단: 썸네일 + 템플릿 정보 -->
      <div class="row g-4 mb-4">
        <!-- 썸네일 -->
        <div class="col-md-5">
          <div class="card shadow-sm h-100">
            <img :src="template.thumbnailPath" class="card-img-top" alt="썸네일" style="object-fit: cover; height: 100%; max-height: 400px;">
          </div>
        </div>

        <!-- 오른쪽 카드 -->
        <div class="col-md-7">
          <div class="card shadow-sm h-100 p-4 d-flex flex-column">

            <!-- 🔹 누적 판매수 (상단 작게) -->
            <div class="text-muted text-end small mb-2">

            </div>

            <!-- 🔹 변호사 정보 -->
            <div class="d-flex align-items-start mb-3 position-relative" style="min-height: 55px;">
              <!-- 프로필 이미지 -->
              <img
                  v-if="template.profile"
                  :src="template.profile"
                  alt="프로필"
                  class="rounded-circle me-3"
                  style="width: 50px; height: 50px; object-fit: cover;"
              />

              <!-- 변호사 이름 + 설명 -->
              <div>
                <strong class="fw-semibold">
                  {{ template.lawyerName }} 변호사 | {{ template.shortIntro }}
                </strong><br />
                <small class="text-muted">
                  {{ template.type === 'EDITOR' ? 'AI 생성형 템플릿' : '문서 기반 템플릿' }} |
                  {{ template.categoryName }}
                </small>
              </div>

              <!-- 오른쪽 하단에 고정된 링크 -->
              <a
                  :href="`/homepage/${template.lawyerNo}`"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-muted small text-decoration-underline me-2"
                  style="position: absolute; bottom: 0; right: 0;"
              >
                프로필 보러가기
              </a>
            </div>

            <hr>

            <!-- 🔹 상품명 -->
            <h2 class="fw-bold mb-2 mt-6">{{ template.name }}</h2>

            <!-- 🔹 가격 -->
            <div class="d-flex align-items-baseline mb-0 mt-auto">
              <span class="text-danger fw-bold fs-1">{{ template.discountRate }}%</span>
              <div class="d-flex align-items-baseline ms-auto">
                <del class="text-muted me-2 fs-5">
                  {{ template.price.toLocaleString() }}원
                </del>
                <span class="text-danger fw-bold fs-1">
                  {{ (template.price * (1 - template.discountRate / 100)).toLocaleString() }}원
                </span>
              </div>
            </div>

            <!-- 🔹 CTA -->
            <div class="mt-5 d-flex gap-2">
              <button class="btn btn-primary flex-fill" @click="handleAddToCart2">구매하기</button>
              <button class="btn btn-outline-secondary flex-fill" @click="handleAddToCart">장바구니</button>
            </div>

          </div>
        </div>
      </div>

      <!-- 상품 설명 -->
      <div class="card shadow-sm mb-4 p-4">
        <h5 class="fw-bold">상품 설명</h5>
        <pre class="mb-0 mt-4"
             style="white-space: pre-wrap;
                         word-break: break-word;
                         font-family: inherit;
                         min-height: 160px;">{{ template.description }}</pre>
      </div>


      <!-- 변호사 상세 설명 -->
      <div class="card shadow-sm mb-4 p-4">
        <h5 class="fw-bold">{{ productList.name }} 변호사 경력</h5>
        <p class="mb-0"><strong>사무실 주소 :</strong> {{ template.fullAddress }}</p>
        <p class="mb-0"><strong>사무실 번호 :</strong> {{ template.officeNumber }}</p>
        <pre class="mb-0 mt-4"
             style="white-space: pre-wrap;
                         word-break: break-word;
                         font-family: inherit;
                         min-height: 160px;">{{ template.longIntro }}</pre>
      </div>


      <div class="card shadow-sm mb-4 p-4">
        <h5 class="fw-bold">{{ productList.name }} 변호사의 다른 법률 템플릿</h5>
        <p class="mb-0">{{  }}</p>

        <div v-if="productList.recentTemplates.length > 0" class="row g-4 row-cols-lg-5 row-cols-2 row-cols-md-3">
          <div class="col-md-3 mb-4" v-for="product in productList.recentTemplates" :key="product.no">
            <ProductCard
                :no="product.no"
                :imageUrl="product.thumbnailPath"
                :title="product.name"
                :originalPrice="product.price.toLocaleString() + '원'"
                :discountPercent="product.discountRate"
                :discountedPrice="Math.floor(product.price * (1 - product.discountRate / 100)).toLocaleString() + '원'"
            />
          </div>
        </div>

        <div v-else class="text-center text-muted py-5">
          등록된 상품이 없습니다.
        </div>
      </div>
    </div>
  </ClientFrame>
</template>