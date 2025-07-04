<script setup>
import { ref, onMounted, nextTick } from "vue";
import { useRoute, useRouter } from "vue-router";
import axios from "axios";
import ClientFrame from "@/components/layout/client/ClientFrame.vue";
import {makeApiRequest} from "@/libs/axios-auth.js";
import http from '@/libs/HttpRequester'
import { getUserRole } from '@/service/authService.js'

// 라우터에서 방송 번호 가져오기
const route = useRoute();
const router = useRouter();
const broadcastNo = route.params.broadcastNo;

// vod 불러오기
const vodInfo = ref(null);

// formatDuration 함수 정의
const formatDuration = (seconds) => {
  const h = String(Math.floor(seconds / 3600)).padStart(2, "0");
  const m = String(Math.floor((seconds % 3600) / 60)).padStart(2, "0");
  const s = String(seconds % 60).padStart(2, "0");
  return `${h}:${m}:${s}`;
};

// vod 가져오는 함수
const fetchVodInfo = async () => {
  try {
    const res = await http.get(`/api/public/vod/view/${broadcastNo}`)
    vodInfo.value = res.data
  } catch (err) {
    console.error("❌ VOD 정보 가져오기 실패:", err)
  }
}


const goToLawyerHomepage = () => {
  const userNo = vodInfo.value.lawyerNo;
  if (!userNo || userNo === 0) {
    alert('변호사 정보가 없습니다.');
    return;
  }
  router.push(`/homepage/${userNo}`);
};


const applyKeywordAlert = async () => {
  const role = getUserRole()  // null 이면 비회원

  if (!role) {
    alert('로그인 후 이용 가능합니다.')
    return
  } else if (role === 'LAWYER') {
    alert('변호사는 알림신청 불가능합니다.')
    return
  }

  const lawyerName = vodInfo.value.lawyerName

  if (!lawyerName) {
    alert('변호사 정보가 없습니다.')
    return
  }

  const confirmed = confirm(`'${lawyerName}' 변호사의 방송 알림을 신청하시겠습니까?`)
  if (!confirmed) return

  try {
    await makeApiRequest({
      method: 'post',
      url: '/api/client/keyword-alert/apply',
      params: {
        keyword: lawyerName
      }
    })
      alert('🔔 알림 신청이 완료되었습니다!')
  } catch (err) {
    if (err.response?.status === 400) {
      alert(`⚠️ ${err.response.data}`) // 예: 이미 신청함
    } else {
      alert('❌ 알림 신청 중 오류가 발생했습니다.')
      console.error(err)
    }
  }
}


// 컴포넌트 마운트 시 실행
onMounted(() => {
  fetchVodInfo();
  playChatsLikeLive();
});





// 메시지 관련 상태
const messages = ref([]);
const messageContainer = ref(null);

let chatLogs = [];
let vodStartTime = null;
let chatIntervalId = null;

const scrollToBottom = () => {
  nextTick(() => {
    if (messageContainer.value) {
      messageContainer.value.scrollTop = messageContainer.value.scrollHeight;
    }
  });
};

// 채팅을 영상 위치에 맞게 표시
const updateMessagesByCurrentTime = () => {
  if (!videoRef.value) return;
  const curTime = videoRef.value.currentTime;
  messages.value = chatLogs.filter(msg => msg.seconds <= curTime);
  scrollToBottom();
};



function parseDate(obj) {
  if (obj instanceof Date) return obj;
  if (obj && typeof obj === "object" && "$date" in obj) return new Date(obj.$date);
  if (typeof obj === "string") return new Date(obj);
  return null;
}

const playChatsLikeLive = async () => {
  const { data } = await axios.get(`/api/broadcast/${broadcastNo}/chats`);
  console.log('불러온 채팅 원본:', data);
  if (!data.length || !vodInfo.value?.startTime) {
    console.log('채팅 없음 또는 방송 시작시간 없음');
    return;
  }
  const broadcastStart = parseDate(vodInfo.value.startTime);
  console.log('방송 시작시간:', vodInfo.value.startTime, broadcastStart);
  chatLogs = data.map(msg => ({
    ...msg,
    createdAt: parseDate(msg.createdAt),
  }));
  chatLogs = chatLogs.map(msg => ({
    ...msg,
    seconds: (msg.createdAt - broadcastStart) / 1000 - 2.5,
  }));
  console.log('가공된 chatLogs:', chatLogs);
};

const videoRef = ref(null);

onMounted(async () => {
  await fetchVodInfo();
  await playChatsLikeLive();
  nextTick(() => {
    if (videoRef.value) {
      videoRef.value.addEventListener("play", () => {
        if (chatIntervalId) clearInterval(chatIntervalId);
        chatIntervalId = setInterval(updateMessagesByCurrentTime, 350);
      });
      videoRef.value.addEventListener("pause", () => {
        if (chatIntervalId) clearInterval(chatIntervalId);
        chatIntervalId = null;
      });
      videoRef.value.addEventListener("seeked", updateMessagesByCurrentTime);
      videoRef.value.addEventListener("ended", () => {
        if (chatIntervalId) clearInterval(chatIntervalId);
        chatIntervalId = null;
        updateMessagesByCurrentTime();
      });
      videoRef.value.addEventListener("loadedmetadata", updateMessagesByCurrentTime);
    }
  });
});
</script>


<template>
  <ClientFrame>
    <div class="position-relative w-100 vh-100">
      <!-- VOD 카드 전체 영역 -->
      <div
          v-if="vodInfo"
            class="position-absolute top-0 start-0 bg-dark shadow rounded d-flex flex-column"
          style="width: calc(100% - 480px); margin: 2rem;"
        >
        <!-- 영상 출력 영역 -->
        <div
            ref="videoContainer"
            style="height: 520px;"
            class="rounded-top d-flex align-items-center justify-content-center bg-black"
        >
          <video
              v-if="vodInfo?.vodPath"
              ref="videoRef"
              :src="vodInfo.vodPath"
              controls
              class="w-100 h-100"
              style="object-fit: cover; border-radius: 0.5rem;"
          >
            해당 브라우저는 video 태그를 지원하지 않습니다.
          </video>
        </div>

        <!-- VOD 정보 영역 -->
        <div class="bg-light text-dark p-5 rounded-bottom position-relative">
          <!-- 방송 제목 -->
          <div class="mb-3">
            <h2 class="fs-3 fw-bold mb-1">{{ vodInfo.title }}</h2>

            <!-- 키워드 & 영상 길이/조회수/업로드일자 -->
            <div class="d-flex justify-content-between align-items-center">
              <!-- 키워드 -->
              <div>
                <span
                    v-for="(keyword, index) in vodInfo.keywords"
                    :key="index"
                    class="text-muted me-3 fs-6 fw-semibold"
                    style="opacity: 0.75;"
                ># {{ keyword }}</span>
              </div>

              <!-- 영상 정보 -->
              <div class="text-muted d-flex gap-4 align-items-center">
                <!-- 영상 길이 (⏱️ 테두리 강조) -->
                <span class="border px-2 py-1 rounded text-dark-gray">
                  ⏱️ {{ formatDuration(vodInfo.duration) }}
                </span>

                <!-- 조회수 (숫자만 진하게) -->
                <span>
                  조회수 <span class="fw-bold text-dark-gray">{{ vodInfo.viewCount }}</span>회
                </span>

                <!-- 업로드 일자 -->
                <span class="text-dark-gray">{{ vodInfo.createdAt.slice(0, 10) }}</span>
              </div>
            </div>
          </div>

          <!-- 변호사 정보 -->
          <div class="d-flex align-items-center mt-3">
            <!-- 프로필 이미지 -->
            <div
                @click="goToLawyerHomepage"
                role="button"
                class="profile-border-hover position-relative d-flex justify-content-center align-items-center"
            >
              <img
                  :src="vodInfo.lawyerProfile"
                  alt="변호사 프로필"
                  class="rounded-circle"
                  style="width: 68px; height: 68px; object-fit: cover;"
              />
            </div>
            <!-- 이름 -->
            <div class="d-flex align-items-center ms-3">
            <span
                @click="goToLawyerHomepage"
                role="button"
                class="fs-5 fw-bold me-3 text-primary text-decoration-none"
                style="cursor: pointer;"
            >
                  {{ vodInfo.lawyerName }} 변호사
                </span>
              <button class="btn btn-outline-primary btn-sm" @click="applyKeywordAlert">
                🔔 알림신청
              </button>
            </div>
          </div>
        </div>
      </div>


      <!-- 채팅 영역 전체 -->
      <div
          class="position-absolute border rounded shadow p-4 d-flex flex-column"
          style="width: 400px; height: 718px; top: 2rem; right: 2rem;"
      >
        <!-- 메시지 출력 영역 (스크롤 + 자동 아래로 이동) -->
        <div
            ref="messageContainer"
            class="flex-grow-1 overflow-auto mb-3 scroll-hidden"
            style="scroll-behavior: smooth;"
        >
          <div v-for="(msg, index) in messages" :key="index" class="mb-3">
            <div
                v-if="msg.type === 'ENTER'"
                class="w-100 text-center"
                style="color: #007bff; font-size: 0.9rem;"
            >
              {{ msg.message }}
            </div>
            <div v-else style="font-size: 1.0rem; font-weight: bold;">
              {{ msg.nickname }} : {{ msg.message }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </ClientFrame>
</template>

<style scoped>
.scroll-hidden::-webkit-scrollbar {
  display: none;
}
.scroll-hidden {
  -ms-overflow-style: none;     /* IE, Edge */
}

/* 애니메이션 */
@keyframes modalPop {
  0% {
    transform: scale(0.85);
    opacity: 0;
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

.profile-border-hover {
  width: 80px;
  height: 80px;
  border: 3px solid #15ea7e;
  border-radius: 50%;
  cursor: pointer;
  transition: border-width 0.2s ease;
}
.profile-border-hover:hover {
  border-width: 5px;
}
</style>
