<script setup>
import HomepageFrame from "@/components/layout/homepage/HomepageFrame.vue"
import { ref, onMounted, computed, watch} from 'vue'
import { useRoute, useRouter } from 'vue-router'
import http from '@/libs/HttpRequester'
import ProductCard from "@/components/common/ProductCard.vue";
import CardTable from "@/components/table/CardTable.vue";
import basicThumbnail from '@/assets/images/thumbnail/basic_thumbnail.png';
import { getUserNo } from '@/service/authService.js'

const route = useRoute()
const router = useRouter()
const data = ref({
  name: '',
  shortIntro: '',
  longIntro: '',
  email: '',
  officePhone: '',
  officeAddress: '',
  officeName: '',
  consultPrice: 0,
  profileImagePath: '',
  recentTemplates: [],
  recentBoards: [],
  lawyerNo: null
})
// vod
const vods = ref([]);
const currentPage = ref(1);
const totalPages = ref(0);
const pageSize = 4;
const sort = ref('recent')

const productList = computed(() => {
  return (data.value.recentTemplates || []).map(tmpl => {
    const price = tmpl.price || 0
    const discountRate = tmpl.discountRate || 0
    const discountedPrice = Math.floor(price * (1 - discountRate / 100))

    return {
      no: tmpl.no,
      title: tmpl.name,
      imageUrl: tmpl.thumbnailPath || 'https://kr.object.ncloudstorage.com/law-n-road/uploads/defaults/template-thumbnail.png',
      originalPrice: `${price.toLocaleString()}원`,
      discountPercent: `${discountRate}`,
      discountedPrice: `${discountedPrice.toLocaleString()}원`,
    }
  })
})

async function fetchLawyerHomepage(lawyerNo) {
  try {
    console.log(lawyerNo)
    const res = await http.get(`/api/public/homepage/${lawyerNo}`)
    console.log(res.data) // 또는 return response.data;
    data.value = res.data
  } catch (error) {
    console.error('❌ 변호사 홈화면 불러오기 실패:', error)
  }
}

// VOD 가져오는 함수
async function fetchVodPreview(page = 1) {
  try {
    const res = await http.get(
        `/api/public/vod/lawyer/${route.params.lawyerNo}`,
        { page, size: pageSize, sort: sort.value }
    )
    vods.value = res.data.vods
    totalPages.value = res.data.totalPages
    currentPage.value = res.data.page
  } catch (err) {
    console.error('❌ VOD 불러오기 실패:', err)
  }
}

// duration 포맷터
const formatDuration = (seconds) => {
  const m = String(Math.floor(seconds / 60)).padStart(2, "0")
  const s = String(seconds % 60).padStart(2, "0")
  return `${m}:${s}`
}

// **페이지 그룹 계산** (5개씩 묶음)
const pageGroup = computed(() => {
  const groupSize = 5
  const gIndex = Math.floor((currentPage.value - 1) / groupSize)
  const start = gIndex * groupSize + 1
  const end = Math.min(start + groupSize - 1, totalPages.value)
  const pages = Array.from({ length: end - start + 1 }, (_, i) => start + i)
  return {
    pages,
    hasPrevGroup: start > 1,
    hasNextGroup: end < totalPages.value,
    prevPage: start - 1,
    nextPage: end + 1
  }
})

// **페이지 이동 핸들러**
function changePage(page) {
  if (page >= 1 && page <= totalPages.value && page !== currentPage.value) {
    currentPage.value = page
  }
}

// 정렬 변경 핸들러
function setSort(order) {
  if (sort.value !== order) {
    sort.value = order
    currentPage.value = 1
    fetchVodPreview(1)
  }
}

function goToVod(vod) {
  try {
    http.put(`/api/public/vod/${vod.vodNo}`) // 조회수 증가
  } catch (err) {
    console.error("❌ 조회수 증가 실패:", err)
  }

  router.push(`/vod/${vod.broadcastNo}`) // broadcastNo 기준으로 이동
}

// currentPage가 바뀔 때마다 데이터 재요청
watch(currentPage, (newPage) => {
  fetchVodPreview(newPage)
})

onMounted(async () => {
  fetchLawyerHomepage(route.params.lawyerNo);
  fetchVodPreview(currentPage.value);
})

</script>

<template>
  <HomepageFrame>
    <div class="container py-5">
      <div class="row g-4 mb-4">
        <!-- 썸네일 -->
        <div class="col-md-4">
          <div class="card shadow-sm h-100">
            <img :src="data.profileImagePath" class="card-img-top" alt="프로필" style="object-fit: cover; height: 100%; max-height: 400px;">
          </div>
        </div>

        <!-- 오른쪽 카드 -->
        <div class="col-md-8">
          <div class="card shadow-sm" style="min-height: 400px; max-height: 400px;">

            <!-- 변호사 정보 -->
            <div class="d-flex align-items-start pb-5 position-relative bg-light-primary" style="min-height: 55px;">
              <div class=" mb-2 mt-5 me-4 ms-4">
                <strong class="fw-semibold fs-1" style="color: #5a5a78;"> {{ data.shortIntro }} </strong>
                <br />
                <strong class="fw-semibold fs-5 ms-3"> {{ data.name }} 변호사 </strong>
              </div>
            </div>

            <!--pre 태그 엔터, 띄어쓰기 그대로 반영, 쓸데없이 엔터 금지-->
            <div class="d-flex align-items-start justify-content-between gap-4 mb-5 mt-5 me-4 ms-4">
              <!-- 왼쪽 -->
              <div class="ms-3 small w-100 w-md-50">
                <div><strong>이메일</strong> {{ data.email }}</div>
                <div><strong>전화</strong> {{ data.officePhone }}</div>
                <br>
                <div><strong>{{ data.officeName }}</strong><br>
                  {{ data.officeAddress }}
                </div>
                <br>
                <div><strong>상담비용</strong> {{ data.consultPrice }} 원</div>
              </div>

              <!-- 오른쪽 -->
              <pre class="w-100 w-md-50 mb-0"
                   style="white-space: pre-wrap;
                         word-break: break-word;
                         font-family: inherit;
                         min-height: 160px;
                         max-height: 160px;
                         overflow-y: auto;">{{ data.longIntro }}</pre>
            </div>


            <router-link
                v-if="data.lawyerNo"
                :to="{ name: 'ClientReservations', params: { lawyerNo: data.lawyerNo, lawyerName: data.name } }"
                class="btn btn-primary w-auto text-center ms-4 me-4 mb-3"
            >
              전화상담 예약하러 가기
            </router-link>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-12">
          <div class="card shadow-sm mb-0 p-4 d-flex mb-4">
            <h5 class="fw-bold">{{ data.name }} 변호사의 방송 다시보기</h5>
            <p class="mb-0">{{  }}</p>
            <!-- 정렬 버튼 (극소형) -->
            <div class="d-flex gap-2 my-3 mt-0 mb-0 ps-1">
              <button
                  class="btn btn-sm px-2 py-1 text-sm-center"
                  :class="sort === 'recent' ? 'btn-primary' : 'btn-outline-primary'"
                  @click="setSort('recent')"
              >최신순</button>
              <button
                  class="btn btn-sm px-2 py-1"
                  :class="sort === 'popular' ? 'btn-primary' : 'btn-outline-primary'"
                  @click="setSort('popular')"
              >인기순</button>
            </div>
            <!-- VOD 목록 -->
            <div v-if="vods.length > 0" class="row row-cols-md-4 row-cols-2 g-4 my-3 mt-0">
              <template v-for="vod in vods" :key="vod.vodNo">
                <div class="col">
                  <div
                      class="card h-100 shadow-sm border-0 cursor-pointer"
                      @click="goToVod(vod)"
                  >
                    <div class="position-relative">
                      <img
                          :src="vod.thumbnailPath || basicThumbnail"
                          class="card-img-top"
                          alt="방송 썸네일"
                          style="height: 180px; object-fit: cover;"
                      />
                      <!-- 다시보기 + 카테고리 뱃지 -->
                      <div class="position-absolute top-0 start-0 m-2 d-flex gap-2">
                        <span
                            class="badge bg-primary"
                            style="font-size: 0.7rem; padding: 0.35em 0.6em;"
                        >다시보기</span>
                        <span
                            v-if="vod.categoryName"
                            class="badge bg-secondary"
                            style="font-size: 0.7rem; padding: 0.35em 0.6em;"
                        >{{ vod.categoryName }}</span>
                      </div>
                      <!-- 영상 길이 -->
                      <span
                          class="position-absolute bottom-0 end-0 m-2 px-2 py-1 bg-dark bg-opacity-50 text-white rounded small"
                          style="font-size: 0.75rem;"
                      >
                      {{ formatDuration(vod.duration) }}
                      </span>
                    </div>
                    <div class="card-body p-2">
                      <h6 class="card-title fs-6 fw-bold text-dark-gray mb-1">
                        {{ vod.title }}
                      </h6>
                      <p class="mt-0 mb-0 fs-7 text-muted">
                        조회수 {{ vod.viewCount }}회 <span class="mx-1">·</span> {{ vod.createdAt.slice(0, 10) }}
                      </p>
                    </div>
                  </div>
                </div>
              </template>
            </div>

            <!-- VOD 없을 때 -->
            <div v-else class="text-center text-muted py-5 w-100">
              재생 가능한 VOD가 없습니다.
            </div>

            <!-- 페이지네이션 -->
            <nav v-if="totalPages > 1" class="d-flex justify-content-center mt-3 w-100">
              <ul class="pagination mb-0">
                <!-- 이전 페이지 -->
                <li class="page-item" :class="{ disabled: currentPage === 1 }">
                  <a class="page-link" @click="changePage(currentPage - 1)">Previous</a>
                </li>
                <!-- 이전 그룹 -->
                <li class="page-item" :class="{ disabled: !pageGroup.hasPrevGroup }">
                  <a class="page-link" @click="changePage(pageGroup.prevPage)">«</a>
                </li>
                <!-- 그룹 내 페이지 번호 -->
                <li
                    v-for="p in pageGroup.pages"
                    :key="p"
                    class="page-item"
                    :class="{ active: currentPage === p }"
                >
                  <a class="page-link" @click="changePage(p)">{{ p }}</a>
                </li>
                <!-- 다음 그룹 -->
                <li class="page-item" :class="{ disabled: !pageGroup.hasNextGroup }">
                  <a class="page-link" @click="changePage(pageGroup.nextPage)">»</a>
                </li>
                <!-- 다음 페이지 -->
                <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                  <a class="page-link" @click="changePage(currentPage + 1)">Next</a>
                </li>
              </ul>
            </nav>
          </div>

          <div class="card shadow-sm mb-4 p-4 d-flex">
            <h5 class="fw-bold">{{ data.name }} 변호사의 법률 템플릿</h5>
            <p class="mb-0">{{  }}</p>

            <div v-if="productList.length > 0" class="row g-4 row-cols-lg-5 row-cols-2 row-cols-md-3">
              <div class="col-md-3 mb-4" v-for="product in productList" :key="product.no">
                <ProductCard
                    :no="product.no"
                    :imageUrl="product.imageUrl"
                    :title="product.title"
                    :originalPrice="product.originalPrice"
                    :discountPercent="product.discountPercent"
                    :discountedPrice="product.discountedPrice"
                />
              </div>
            </div>

            <div v-else class="text-center text-muted py-5">
              등록된 상품이 없습니다.
            </div>
          </div>

          <div class="card shadow-sm mb-4 p-4 d-flex">
            <h5 class="fw-bold">{{ data.name }} 변호사가 답변한 상담글</h5>
            <CardTable v-if="data.recentBoards.length > 0" :List="data.recentBoards" :maxLines="4" />

            <div v-else class="text-center text-muted py-5">
              답변한 게시글이 없습니다.
            </div>
          </div>
        </div>
      </div>
    </div>
  </HomepageFrame>
</template>

<style scoped>
.cursor-pointer {
  cursor: pointer;
}

.card.cursor-pointer:hover {
  box-shadow: 0 0 0.5rem rgba(0, 0, 0, 0.15);
  transform: scale(1.01);
  transition: all 0.2s;
}
</style>
