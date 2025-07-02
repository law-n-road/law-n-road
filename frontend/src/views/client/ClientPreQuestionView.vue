<script setup>
import ClientFrame from "@/components/layout/client/ClientFrame.vue";
import { nextTick, onMounted, ref, watch, computed } from "vue";
import axios from "axios";
import { useRoute } from "vue-router";
import basicThumbnail from '@/assets/images/thumbnail/basic_thumbnail.png';
import { getValidToken } from "@/libs/axios-auth.js";

const nickname = ref('');
const inputContent = ref('');
const preQuestion = ref({});
const route = useRoute();
const scheduleNo = route.params.scheduleNo;
const myUserNo = ref(null);
const preQuestionList = ref(null);

// base64url -> base64 변환 및 디코딩 (JWT 대응)
function base64UrlDecode(str) {
  if (!str) return '';
  str = str.replace(/-/g, '+').replace(/_/g, '/');
  while (str.length % 4) str += '=';
  return atob(str);
}

// 스크롤 하단 이동 함수
const scrollToPreQuestionBottom = () => {
  nextTick(() => {
    if (preQuestionList.value) {
      preQuestionList.value.scrollTop = preQuestionList.value.scrollHeight;
    }
  });
};

// preQuestions가 바뀔 때마다 스크롤 맨 아래로
watch(
    () => preQuestion.value.preQuestions,
    scrollToPreQuestionBottom,
    { deep: true }
);

// 이미 질문 등록 여부
const alreadyAsked = computed(() => {
  if (!preQuestion.value.preQuestions || !myUserNo.value) return false;
  return preQuestion.value.preQuestions.some(q => q.userNo === myUserNo.value);
});

// 방송 시작 시간 기준 사전질문 입력 가능 여부
const canAskPreQuestion = computed(() => {
  if (!preQuestion.value.startTime) return false;
  const start = new Date(preQuestion.value.startTime);
  const now = new Date();
  return (start - now) > 10 * 60 * 1000;
});


onMounted(async () => {
  const token = await getValidToken();
  if (token) {
    try {
      const payloadStr = token.split('.')[1];
      if (payloadStr) {
        const decoded = base64UrlDecode(payloadStr);
        const payload = JSON.parse(decoded);
        myUserNo.value = payload.no;
      }
    } catch (e) {
      myUserNo.value = null;
      console.warn("JWT decode error:", e);
    }
  }

  const preQRes = await axios.get(`/api/client/broadcasts/schedule/${scheduleNo}/preQuestion`);
  const data = preQRes.data;

  if (Array.isArray(data.preQuestions)) {
    data.preQuestions = data.preQuestions.filter(
        q =>
            q && typeof q === 'object' && !Array.isArray(q) &&
            Object.keys(q).length > 0 &&
            q.nickname &&
            q.preQuestionContent
    );
  }

  preQuestion.value = data;
  scrollToPreQuestionBottom();
});

const submitQuestion = async () => {
  if (!inputContent.value.trim()) {
    alert('내용을 입력해주세요!');
    return;
  }
  // 방송 시작 시간 검사 (등록 시점)
  if (preQuestion.value.startTime) {
    const start = new Date(preQuestion.value.startTime);
    const now = new Date();
    const diff = start - now;

    if (diff <= 10 * 60 * 1000) {
      alert('방송 시작 10분 전에는 사전질문을 등록할 수 없습니다.');
      return;
    }
  }

  const token = await getValidToken();
  if (!token) {
    alert("로그인이 필요합니다!");
    return;
  }
  try {
    await axios.post(
        `/api/client/broadcasts/schedule/${scheduleNo}/preQuestion`,
        {
          scheduleNo: scheduleNo,
          nickname: nickname.value,
          preQuestionContent: inputContent.value
        },
        {
          headers: {
            Authorization: `Bearer ${token}`
          }
        }
    );
    inputContent.value = '';
    alert('질문이 등록되었습니다.');
    const preQRes = await axios.get(`/api/client/broadcasts/schedule/${scheduleNo}/preQuestion`);
    preQuestion.value = preQRes.data;
    scrollToPreQuestionBottom();
  } catch (e) {
    alert('등록에 실패했습니다.');
  }
};

const deleteQuestion = async (q) => {
  if (!confirm('정말 삭제하시겠습니까?')) return;
  try {
    await axios.delete(
        `/api/client/broadcasts/schedule/${scheduleNo}/preQuestion/${q.no}`,
        {
          headers: { Authorization: `Bearer ${await getValidToken()}` }
        }
    );
    location.reload();
  } catch (e) {
    alert('삭제에 실패했습니다.');
  }
};

function getQuestionStyle(index) {
  const colors = ['bg-success bg-opacity-10', 'bg-warning bg-opacity-10', 'bg-danger bg-opacity-10'];
  return colors[index % colors.length];
}

function getTextColorClass(index) {
  const colors = ['text-success', 'text-warning', 'text-danger'];
  return colors[index % colors.length];
}
</script>

<template>
  <ClientFrame>
    <div class="container my-5 min-vh-80 d-flex">
      <div class="bg-white border border-2 rounded-4 shadow px-5 py-4 w-100" style="min-height: 70vh;">
        <div class="row" style="height: 100%;">
          <!-- 왼쪽: 방송 정보 -->
          <div class="col-md-7 d-flex flex-column justify-content-center align-items-center" style="min-height: 70vh;">
            <!-- 상단 이미지 -->
            <div class="w-100 d-flex justify-content-center mb-4 mt-3">
              <img
                  :src="preQuestion.thumbnailPath || basicThumbnail"
                  alt="방송 이미지"
                  style="max-width: 100%; height: 100%; border-radius: 18px;"
              />
            </div>
            <!-- 방송 상세 카드 -->
            <div class="bg-white border rounded-4 shadow p-4 w-100 d-flex flex-row align-items-center gap-4" style="min-height: 230px;">
              <div class="d-flex flex-column align-items-center" style="min-width: 130px;">
                <img
                    :src= "preQuestion.profile"
                    alt="프로필"
                    class="rounded-circle border border-2 shadow-sm"
                    style="width: 108px; height: 108px; object-fit: cover;"
                />
                <span class="mt-3 fw-semibold fs-5 text-primary text-center" style="letter-spacing:0.03em;">
                  {{ preQuestion.lawyerName }} 변호사
                </span>
              </div>
              <!-- 방송 정보 텍스트 -->

              <div class="text-start flex-grow-1">
                <div class="fw-bold fs-2 mb-2">{{ preQuestion.name }}</div>
                <div class="text-muted fs-5 mb-2">{{ preQuestion.scheduleContent }}</div>
                <div class="fs-5 mb-1">
                  <i class="bi bi-calendar2-week text-primary me-1"></i>
                  {{ preQuestion.date }}
                  <span v-if="preQuestion.startTime">｜{{ preQuestion.startTime?.slice(11, 16) }} ~ {{ preQuestion.endTime?.slice(11, 16) }}</span>
                </div>
                <div class="mt-2">
                  <span class="badge bg-primary-100 text-primary me-1" v-for="(kw, idx) in preQuestion.keywords" :key="idx" style="font-size:1.07em;">
                    #{{ kw }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- 오른쪽: 사전 질문 영역 -->
          <div class="col-md-5 d-flex flex-column" style="min-height: 70vh;">
            <div class="mb-3">
              <span class="fs-4 fw-bold text-dark">사전 질문 등록</span>
            </div>
            <!-- 사전 질문 목록 -->
            <div ref="preQuestionList" class="flex-grow-1 overflow-auto" style="min-height: 0; max-height: 900px;">
              <div v-if="preQuestion.preQuestions && preQuestion.preQuestions.length > 0">
                <div
                    v-for="(q, index) in preQuestion.preQuestions"
                    :key="index"
                    class="rounded-3 p-3 mb-2"
                    :class="getQuestionStyle(index)">
                  <div class="d-flex align-items-center justify-content-between">
                    <span class="fw-bold" :class="getTextColorClass(index)">[{{ q.nickname }}]</span>
                    <button
                        v-if="q.userNo === myUserNo"
                        class="btn btn-link btn-sm text-danger px-2"
                        @click="deleteQuestion(q)"
                        style="text-decoration: underline;">
                      삭제
                    </button>
                  </div>
                  <div>{{ q.preQuestionContent }}</div>
                </div>
              </div>
              <div v-else class="text-muted text-center py-4">
                아직 등록된 사전질문이 없습니다.
              </div>
            </div>
            <!-- 질문 입력창 노출 조건 -->
            <form
                class="row g-2 align-items-center mt-auto"
                style="margin-bottom: 0;"
                @submit.prevent="submitQuestion"
                v-if="!alreadyAsked && canAskPreQuestion"
            >
              <div class="col">
                <input type="text" class="form-control fs-5" placeholder="사전질문을 등록하세요"
                       v-model="inputContent"/>
              </div>
              <div class="col-auto">
                <button type="submit" class="btn btn-primary fs-5 px-4">등록</button>
              </div>
            </form>
            <!-- 이미 등록 -->
            <div v-else-if="alreadyAsked" class="text-success text-center py-2">
              이미 사전질문을 등록하셨습니다.
            </div>
            <!-- 시간 제한 -->
            <div v-else-if="!canAskPreQuestion" class="text-muted text-center py-2">
              방송 시작 10분 전에는 사전질문 등록이 불가능합니다.
            </div>
            <!-- (여분 대비용) -->
            <div v-else class="text-success text-center py-2">
              이미 사전질문을 등록하셨습니다.
            </div>
          </div>
        </div>
      </div>
    </div>
  </ClientFrame>
</template>
