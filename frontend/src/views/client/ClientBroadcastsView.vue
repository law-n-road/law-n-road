<script>
import {defineComponent, ref, onMounted, onBeforeUnmount, nextTick} from "vue";
import SockJS from "sockjs-client";
import {Client} from "@stomp/stompjs";
import ClientFrame from "@/components/layout/client/ClientFrame.vue";
import {OpenVidu} from "openvidu-browser";
import axios from "axios";
import {useRoute, useRouter} from "vue-router";
import {getValidToken, makeApiRequest} from "@/libs/axios-auth.js";
import { computed } from 'vue';
import { onBeforeRouteLeave } from 'vue-router'


export default defineComponent({
  components: {ClientFrame},
  setup() {
    /** =============== 방송 관련 =============== */
    const videoContainer = ref(null);
    const route = useRoute();
    const router = useRouter();
    const broadcastNo = ref(Number(route.params.broadcastNo));
    const session = ref(null);
    const broadcastInfo = ref({
      title: "",
      scheduleNo: 0,
      categoryName: "",
      keywords: [],
      userNo: 0,
      lawyerName: "",
      lawyerProfilePath: ""
    });

    //embed ( 홈뷰에서 보이게 )
    const isEmbedMode = computed(() => route.query.embed === 'true')

    // 방송 실시간 시간
    const elapsedTime = ref("00:00:00");
    let streamStartTime = null;
    let timerInterval = null;
    // 시청자 수
    const viewerCount = ref(0);
    // 신고 관련 상태
    const showReportModal = ref(false) // 모달 열기/닫기
    const reportReasonCode = ref('')   // 선택된 신고 사유 코드
    const reportDetail = ref('')       // 상세 사유

    // 신고 사유 코드 목록 (백엔드와 일치)
    const reportReasonOptions = ref([])

    const loadReportReasons = async () => {
      try {
        const res = await makeApiRequest({
          method: 'get',
          url: '/api/client/broadcast/report-reasons'
        })
        if (res?.data) {
          reportReasonOptions.value = res.data
          console.log('✅ 신고 사유 목록 로딩 완료:', res.data)
        }
      } catch (error) {
        console.error('❌ 신고 사유 목록 로딩 실패:', error)
      }
    }


    // 시간 계산
    const startTimer = () => {
      timerInterval = setInterval(() => {
        const now = new Date();
        const diff = new Date(now.getTime() - streamStartTime.getTime());
        const hh = String(diff.getUTCHours()).padStart(2, "0");
        const mm = String(diff.getUTCMinutes()).padStart(2, "0");
        const ss = String(diff.getUTCSeconds()).padStart(2, "0");
        elapsedTime.value = `${hh}:${mm}:${ss}`;
      }, 1000);
    };

    const loadBroadcastInfo = async () => {
      try {
        const res = await makeApiRequest({
          method: 'get',
          url: `/api/client/broadcast/view-detail/${broadcastNo.value}`
        })
        if (res?.data) {
          broadcastInfo.value = res.data
          console.log("📄 방송 정보 로딩 완료:", res.data)
        }
      } catch (e) {
        console.error("❌ 방송 정보 조회 실패:", e)
      }
    }


    const connectOpenVidu = async () => {
      try {
        const res = await makeApiRequest({
          method: 'get',
          url: `/api/client/broadcast/${broadcastNo.value}/token`
        })

        if (res?.data) {
          const {sessionId, token, startTime} = res.data
          streamStartTime = new Date(startTime) // 방송 시작 시간 저장

          console.log("👁️ 시청자 sessionId:", sessionId)
          console.log("🔑 시청자 token:", token)

          const OV = new OpenVidu()
          session.value = OV.initSession()

          // 시청자 수 업데이트 함수
          const updateViewerCount = () => {
            if (!session.value) return
            viewerCount.value = session.value.remoteConnections.size
          }

          // 시청자 수 동기화 이벤트
          session.value.on("connectionCreated", updateViewerCount)
          session.value.on("connectionDestroyed", updateViewerCount)

          // 스트림 수신 처리
          session.value.on("streamCreated", ({stream}) => {
            console.log("📡 시청자: streamCreated 발생")

            const subscriber = session.value.subscribe(stream, undefined)
            console.log("Subscribing to", stream.connection.connectionId)

            // 방송 시간 타이머 시작
            startTimer()

            nextTick(() => {
              const video = document.createElement("video")
              video.autoplay = true
              video.playsInline = true
              video.muted = true
              video.style.width = "100%"
              video.style.height = "100%"
              video.style.objectFit = "cover"

              subscriber.addVideoElement(video)

              if (videoContainer.value) {
                videoContainer.value.innerHTML = ""
                videoContainer.value.appendChild(video)
                console.log("✅ [시청자] video element append 완료")
              } else {
                console.warn("❌ videoContainer is null")
              }
            })
          })

          await session.value.connect(token)
          console.log("✅ [시청자] 방송 연결 완료")
        }
      } catch (err) {
        console.error("❌ [시청자] 방송 연결 실패:", err)
      }
    }


    const submitReport = async () => {
      if (!reportReasonCode.value) {
        alert('신고 사유를 선택해주세요.');
        return;
      }
      const reportData = {
        broadcastNo: broadcastNo.value,
        reasonCode: reportReasonCode.value,
        detailReason: reportDetail.value
      }
      try {
        await makeApiRequest({
          method: 'post',
          url: '/api/client/broadcast/report',
          data: reportData
        });

        alert('신고가 정상적으로 접수되었습니다.');
        showReportModal.value = false;
        reportReasonCode.value = '';
        reportDetail.value = '';
      } catch (err) {
        console.error('신고 실패', err);
        alert('신고 처리 중 오류가 발생했습니다.');
      }
    };

    const applyKeywordAlert = async () => {
      const lawyerName = broadcastInfo.value.lawyerName

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

    const goToLawyerHomepage = () => {
      const userNo = broadcastInfo.value.userNo
      if (!userNo || userNo === 0) {
        alert('변호사 정보가 없습니다.')
        return
      }
      router.push(`/lawyer/${userNo}/homepage`)
    }

    onBeforeRouteLeave((to, from, next) => {
      if (session.value) {
        session.value.disconnect()
        console.log('🔌 시청자 페이지 라우트 이탈: disconnect 호출')
      }
      next()
    })

    /** 언마운트 / 마운트 정리 */
    onBeforeUnmount(() => {
      console.log("시청자 페이지 종료 - 세션 종료");
      if (session.value) session.value.disconnect();
      if (timerInterval) clearInterval(timerInterval);
      stompClient.value?.deactivate?.();
      closeDropdown();
      window.removeEventListener('mousedown', handlePreQClickOutside);

    });

    onMounted(() => {
      fetchMyNoAndIsStopped();
      connect();
      loadBroadcastInfo();
      connectOpenVidu();
      loadReportReasons();
    });


    /** =============== 채팅 관련 =============== */
    const stompClient = ref(null);
    const message = ref("");
    const messages = ref([]);
    const messageContainer = ref(null);
    const nicknameColors = ref({});
    const myNo = ref(null);
    const isStopped = ref(false);

    //드롭다운/신고 모달 상태
    const dropdownIdx = ref(null);
    const selectedUser = ref(null);
    const selectedMessage = ref(null);
    const isConfirmModal = ref(false);
    const isCompleteModal = ref(false);
    const selectedUserNo = ref(null);
    let noticeInterval = null;

    // 닉네임별 랜덤 색상
    const colorPalette = [
      "#1abc9c", "#034335", "#84ddaa", "#450978",
      "#184563", "#8bc2e4", "#c791dd", "#8e44ad",
      "#837225", "#876124", "#004aff", "#ff6400",
      "#ec8d85", "#c0392b", "#246667", "#e4de0d"
    ];

    function getRandomColor() {
      return colorPalette[Math.floor(Math.random() * colorPalette.length)];
    }

    function getNicknameColor(nick) {
      if (!nicknameColors.value[nick]) {
        nicknameColors.value[nick] = getRandomColor();
      }
      return nicknameColors.value[nick];
    }

    async function fetchMyNo() {
      const token = await getValidToken();
      if (!token) {
        alert("로그인이 필요합니다!");
        return false;
      }
      const res = await axios.get("/api/client/my-no", {
        headers: {Authorization: `Bearer ${token}`}
      });
      myNo.value = res.data;
      return true;
    }

    // STOMP 연결 및 입장 메시지 전송
    const connect = () => {
      const token = localStorage.getItem("token");
      if (!token) {
        alert("로그인이 필요합니다!");
        return;
      }
      fetchMyNo().then((ok) => {
        if (!ok) return;

        stompClient.value = new Client({
          webSocketFactory: () => new SockJS("http://localhost:8080/ws"),
          reconnectDelay: 5000,
          connectHeaders: {
            Authorization: `Bearer ${token}`,
          },
          onConnect: () => {
            startAutoNotice(); // 자동공지 시작

            // 채팅방 메시지 구독
            stompClient.value.subscribe(
                `/topic/${broadcastNo.value}`,
                (msg) => {
                  const data = JSON.parse(msg.body);

                  // 금칙어/경고 메시지(본인만 알림)
                  if (data.type === "WARNING") {
                    if (data.userNo === myNo.value) {
                      alert(data.message || "🚨욕설 또는 부적절한 내용이 포함되어 있습니다!");
                    }
                    return;
                  }
                  // 메시지 id(no)가 이미 있으면 내용만 바꿔치기(블라인드 반영)
                  if (data.no !== undefined && data.no !== null) {
                    const idx = messages.value.findIndex((m) => m.no === data.no);
                    if (idx !== -1) {
                      // 기존 메시지 내용을 갱신 (메시지, blind 등 모든 필드 교체)
                      messages.value[idx] = { ...messages.value[idx], ...data };
                      return;
                    }
                  }

                  // 입장 메시지는 여기서만 push! (중복 방지)
                  if (data.type === "ENTER") {
                    messages.value.push(data);
                    scrollToBottom();
                    return;
                  }

                  // 나머지 메시지(일반채팅/공지/자동응답/환영 등)는 채팅창에 추가
                  messages.value.push(data);
                  scrollToBottom();
                }
            );

            // 입장(서버에 알림)
            stompClient.value.publish({

              destination: "/app/chat.addUser",
              body: JSON.stringify({ broadcastNo: broadcastNo.value }),
              headers: {
                Authorization: `Bearer ${token}`,
              },
            });

            messages.value.push({
              type: "WELCOME",
              message:
                  "📢 도로 위 질서만큼이나 채팅 예절도 중요합니다. 부적절한 내용은 전송이 제한되니 모두가 함께 즐기는 방송을 만들어주세요. 😊",
            });
          },

          onStompError: (frame) => {
            if (frame.body && frame.body.includes("expired")) {
              alert("로그인이 만료되었습니다. 다시 로그인 해주세요.");
              localStorage.removeItem("token");
              location.href = "/login";
            } else {
              console.error("STOMP error:", frame);
            }
          },
        });
        stompClient.value.activate();
      });
    };

    const startAutoNotice = () => {
      if (noticeInterval) clearInterval(noticeInterval); // 중복 방지
      noticeInterval = setInterval(async () => {
        if (!stompClient.value?.connected) return;
       },
      );
    };

    const sendMessage = async () => {
      const trimmed = message.value.trim();
      if (!trimmed || !stompClient.value?.connected) return;

      try {
        const token = await getValidToken();
        if (!token) {
          alert("로그인이 필요합니다!");
          return;
        }

        stompClient.value.publish({
          destination: "/app/chat.sendMessage",
          body: JSON.stringify({
            broadcastNo: broadcastNo.value,
            scheduleNo: broadcastInfo.value.scheduleNo,
            message: trimmed,
            userNo: myNo.value,
          }),
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        message.value = "";
        scrollToBottom();
      } catch (err) {
        console.error('메시지 전송 실패:', err);
        alert('메시지 전송 중 오류가 발생했습니다.');
      }
    };
    // 스크롤 자동 하단 이동
    const scrollToBottom = () => {
      nextTick(() => {
        if (messageContainer.value) {
          messageContainer.value.scrollTop = messageContainer.value.scrollHeight;
        }
      });
    };

    // 닉네임 드롭다운
    const openDropdown = (idx, msg) => {
      dropdownIdx.value = idx;
      selectedUser.value = msg.nickname;
      selectedMessage.value = msg.message;
      selectedUserNo.value = msg.userNo;
      setTimeout(() => {
        window.addEventListener("mousedown", onWindowClick);
      }, 0);
    };

    const closeDropdown = () => {
      dropdownIdx.value = null;
      window.removeEventListener("mousedown", onWindowClick);
    };

    const onWindowClick = (e) => {
      if (!e.target.closest(".nickname-dropdown")) closeDropdown();
    };

    // 신고 모달
    const onReportClick = () => {
      isConfirmModal.value = true;
      closeDropdown();
    };

    const confirmReport = async () => {
      try {
        const token = await getValidToken();
        await axios.post(
            "/api/client/chat/report",
            {
              userNo: selectedUserNo.value,
              reportedUserNo: myNo.value,
              nickname: selectedUser.value,
              message: selectedMessage.value,
            },
            {
              headers: {Authorization: `Bearer ${token}`}
            },
        );
      } catch (e) {
      }
      isConfirmModal.value = false;
      isCompleteModal.value = true;

    };

    const closeCompleteModal = () => {
      isCompleteModal.value = false;
    };


// 사전 질문 표시
    const showPreQDropdown = ref(false);
    const preQuestions = ref([]);
    const isPreQLoading = ref(false);
    const preQBtnRef = ref(null);
    const preQDropdownRef = ref(null);

    // API 호출
    const fetchPreQuestions = async () => {
      try {
        const token = await getValidToken();
        const res = await axios.get(`/api/client/broadcasts/schedule/${broadcastNo.value}`, {
          headers: {Authorization: `Bearer ${token}`}
        });
        const data = Array.isArray(res.data) ? res.data : res.data.data;
        preQuestions.value = data.map(q => ({
          ...q,
          checked: false
        }));
      } catch (e) {
        console.error("사전 질문 불러오기 실패:", e);
      }
    };

    const togglePreQDropdown = async () => {
      showPreQDropdown.value = !showPreQDropdown.value;
      if (showPreQDropdown.value) {
        await fetchPreQuestions();
        // 클릭 바깥 감지
        nextTick(() => window.addEventListener('mousedown', handlePreQClickOutside));
      } else {
        window.removeEventListener('mousedown', handlePreQClickOutside);
      }
    };

    const handlePreQClickOutside = (e) => {
      // 드롭다운과 버튼 바깥 클릭시 닫힘
      if (
          preQDropdownRef.value && !preQDropdownRef.value.contains(e.target) &&
          preQBtnRef.value && !preQBtnRef.value.contains(e.target)
      ) {
        showPreQDropdown.value = false;
        window.removeEventListener('mousedown', handlePreQClickOutside);
      }
    };
    const selectedUserToShow = computed(() => {
      return selectedUser.value && selectedUser.value.trim() !== ''
          ? selectedUser.value
          : broadcastInfo.value.lawyerName+" 변호사";
    });
    // 사용자 상태 가져오기
    async function fetchIsStopped(userNo) {
      const res = await axios.get(`/api/client/is-stopped/${userNo}`);
      console.log('실제 응답:', res.data);
      isStopped.value = res.data.is_stopped === 1;
    }
    async function fetchMyNoAndIsStopped() {
      const ok = await fetchMyNo();
      if (ok) {
        await fetchIsStopped(myNo.value);
      }
    }


    return {
      videoContainer,
      broadcastInfo,
      broadcastNo,
      message,
      messages,
      sendMessage,
      messageContainer,
      dropdownIdx,
      openDropdown,
      closeDropdown,
      onReportClick,
      isConfirmModal,
      isCompleteModal,
      confirmReport,
      closeCompleteModal,
      selectedUser,
      selectedMessage,
      getNicknameColor,
      elapsedTime,
      viewerCount,
      showReportModal,
      reportReasonCode,
      reportDetail,
      reportReasonOptions,
      submitReport,
      myNo,
      showPreQDropdown, preQuestions, isPreQLoading,
      goToLawyerHomepage,
      togglePreQDropdown, preQBtnRef, preQDropdownRef,selectedUserToShow,isStopped,
      applyKeywordAlert,
      isEmbedMode,
    };
  }
});
</script>
<template>
  <!-- ✅ embed 모드: 오직 영상만 (ClientFrame 포함 X) -->
  <div v-if="isEmbedMode" class="embed-video-only">
    <div ref="videoContainer" class="w-100 h-100"></div>
  </div>

  <!-- ✅ 일반 모드: 전체 방송 UI (ClientFrame 포함) -->
  <ClientFrame v-else>
    <div class="position-relative w-100 vh-100">
      <!-- 방송 카드 -->
      <div class="position-absolute top-0 start-0 bg-dark shadow rounded d-flex flex-column"
           style="width: calc(100% - 480px); margin: 2rem;">

        <!-- 영상 -->
        <div ref="videoContainer" style="height: 520px;" class="rounded-top"></div>

        <!-- 방송 정보 -->
        <div class="bg-light text-dark p-5 rounded-bottom position-relative">
          <div class="mb-3">
            <h2 class="fs-3 fw-bold mb-2">{{ broadcastInfo.title }}</h2>
            <div class="d-flex justify-content-between align-items-center">
              <div>
                <span
                    v-for="(keyword, index) in broadcastInfo.keywords"
                    :key="index"
                    class="text-muted me-3 fs-6 fw-semibold"
                    style="opacity: 0.75;"
                ># {{ keyword }}</span>
              </div>
              <div class="text-muted d-flex gap-4 align-items-center">
                <span>
                  <span class="blinking-dot"></span>
                  {{ elapsedTime }} 스트리밍 중
                </span>
                <span>👥 {{ viewerCount }}명 시청 중</span>
              </div>
            </div>
          </div>

          <!-- 프로필 + 알림 + 신고 -->
          <div class="d-flex justify-content-between align-items-end mt-4">
            <div class="d-flex align-items-center">
              <div @click="goToLawyerHomepage" role="button"
                   class="profile-border-hover position-relative d-flex justify-content-center align-items-center">
                <img :src="broadcastInfo.lawyerProfilePath"
                     alt="변호사 프로필"
                     class="rounded-circle"
                     style="width: 68px; height: 68px; object-fit: cover;" />
                <div class="position-absolute bottom-0 start-50 translate-middle-x bg-danger text-white fw-bold px-2 py-1 rounded"
                     style="font-size: 0.8rem; line-height: 1; transform: translate(-30%, 70%);">
                  LIVE
                </div>
              </div>
              <div class="d-flex align-items-center ms-3">
                <span @click="goToLawyerHomepage"
                      role="button"
                      class="fs-5 fw-bold me-3 text-primary text-decoration-none"
                      style="cursor: pointer;">
                  {{ broadcastInfo.lawyerName }} 변호사
                </span>
                <button class="btn btn-outline-primary btn-sm" @click="applyKeywordAlert">
                  🔔 알림신청
                </button>
              </div>
            </div>
            <button class="btn btn-outline-danger btn-sm" @click="showReportModal = true">
              🚨 방송 신고
            </button>
          </div>
        </div>
      </div>


      <!-- 신고 모달 -->
      <div v-if="showReportModal"
           class="position-fixed top-0 start-0 w-100 h-100 bg-dark bg-opacity-50 d-flex align-items-center justify-content-center"
           style="z-index: 1050;">
        <div class="bg-white p-4 rounded shadow" style="width: 480px;">

          <!-- 제목 -->
          <h5 class="fw-bold mb-3">🚨 방송 신고</h5>

          <!-- 방송 제목 표시 박스 -->
          <div class="bg-light p-3 rounded text-dark fw-semibold mb-3">
            {{ broadcastInfo.title }}
          </div>

          <hr class="my-3"/>

          <!-- 신고 사유 라디오 버튼 목록 -->
          <div class="mb-4">
            <label class="form-label d-block mb-3 fw-semibold">신고 사유</label>
            <div class="d-flex flex-column gap-3">
              <div
                  v-for="option in reportReasonOptions"
                  :key="option.code"
                  class="border rounded px-3 py-2 d-flex align-items-center"
                  :class="{
            'bg-light border-primary': reportReasonCode === option.code,
            'bg-white': reportReasonCode !== option.code
          }"
                  style="cursor: pointer; transition: background-color 0.2s;"
                  @click="reportReasonCode = option.code"
              >
                <input
                    class="form-check-input me-3"
                    type="radio"
                    :id="option.code"
                    name="reportReason"
                    :value="option.code"
                    v-model="reportReasonCode"
                    style="cursor: pointer;"
                />
                <label
                    class="form-check-label fs-6 fw-normal text-dark mb-0"
                    :for="option.code"
                    style="cursor: pointer;"
                >
                  {{ option.label }}
                </label>
              </div>
            </div>
          </div>

          <hr class="my-3"/>

          <!-- 상세 입력 -->
          <div class="mb-4">
            <label class="form-label fw-semibold">상세 내용 <span class="text-muted">(선택)</span></label>
            <textarea
                v-model="reportDetail"
                class="form-control"
                rows="3"
                placeholder="신고 내용을 구체적으로 작성해 주세요."
            ></textarea>
          </div>

          <!-- 버튼 -->
          <div class="d-flex justify-content-end gap-2">
            <button class="btn btn-secondary px-4" @click="showReportModal = false">취소</button>
            <button class="btn btn-danger px-4" @click="submitReport">신고 제출</button>
          </div>
        </div>
      </div>


      <!-- 채팅 영역 -->
      <div class="position-absolute border rounded shadow p-4 d-flex flex-column bg-white"
           style="width: 400px; height: 715px; top: 2rem; right: 2rem;">

        <!-- 채팅 상단 제목 및 아이콘 -->
        <div class="d-flex align-items-center justify-content-between mb-3 pb-2 border-bottom position-relative">
          <!-- 왼쪽: 채팅 타이틀 -->
          <div class="fw-bold fs-5">채팅</div>
          <!-- 오른쪽: 사전질문 버튼 -->
          <div style="display: flex; flex-direction: column; align-items: center;">
            <button class="btn btn-link px-1 py-0 text-decoration-none d-flex flex-column align-items-center"
                    style="font-size:1.23rem;"
                    @click="togglePreQDropdown"
                    ref="preQBtnRef"
                    title="사전질문 보기">
              <span>📝</span>
              <span style="font-size:0.7rem; color:#222; margin-top:-5px;">사전 질문</span>
            </button>
          </div>
          <!-- 드롭다운(채팅 상단 전체 너비) -->
          <div v-if="showPreQDropdown"
               class="preq-dropdown"
               ref="preQDropdownRef"
               style="position:absolute; top:110%; left:0; right:0; width:100%; min-width:0; max-width:none; z-index:1000;">
            <div class="preq-dropdown-inner">
              <div class="fw-bold px-2 pt-2 pb-1" style="font-size:1.05rem;">사전 질문 목록</div>
              <div v-if="isPreQLoading" class="px-3 py-3 text-muted small">불러오는 중...</div>
              <div v-else-if="preQuestions.length === 0" class="px-3 py-3 text-muted small">등록된 사전 질문이 없습니다.</div>
              <ul v-else class="list-group preq-scroll" style="max-height:220px; overflow:auto;">
                <li v-for="q in preQuestions" :key="q.no"
                    class="border rounded-2 my-2 mx-2 shadow-sm px-3 py-2"
                    style="font-size:0.99rem; background: #fff;">
                  <div class="fw-semibold mb-1" style="color:#3180e3">{{ q.nickname }}</div>
                  <div style="color:#222">{{ q.content }}</div>
                </li>
              </ul>
            </div>
          </div>
        </div>


        <!-- 메시지 출력 -->
        <div ref="messageContainer"
             class="flex-grow-1 overflow-auto mb-3 scroll-hidden"
             style="scroll-behavior: smooth;">
          <div v-for="(msg, index) in messages" :key="index" class="mb-3" style="position:relative;">
            <!-- 1. 입장 안내 메시지 -->
            <div v-if="msg.type === 'ENTER'"
                 class="w-100 text-center"
                 style="color: #435879; font-size: 0.75rem;">
              {{ msg.message }}
            </div>

            <!-- 2. 자동응답 -->
            <div v-else-if="msg.type === 'AUTO_REPLY'"
                 class="w-100 text-center"
                 v-html="msg.message.replace(/\n/g, '<br>')"
                 style="background: #ffffff; color: #34559c; border-radius: 12px; font-size: 0.85rem; font-weight: 500; padding: 10px 2px; margin: 6px 0;">
            </div>

            <!-- 3. 환영 메시지 -->
            <div v-else-if="msg.type === 'WELCOME'"
                 class="w-100 text-center"
                 style="color: rgb(120,118,118); background: #e4e4e4; border-radius: 12px; font-size: 0.84rem; padding: 9px 2px;">
              {{ msg.message }}
            </div>

            <!-- 4. 변호사 전용 메시지  -->
            <div v-else-if="msg.type === 'Lawyer'"
                 style="font-size: 0.95rem; display: flex; align-items: center;">
              <!-- 닉네임: 검정색 고정 + 클릭 가능 -->
              <span
                  @click.stop="Number(msg.userNo) !== Number(myNo) && openDropdown(index, msg)"
                  :style="{
          color: '#222',
          userSelect: 'text',
          cursor: Number(msg.userNo) === Number(myNo) ? 'default' : 'pointer',
        }">👑 {{ broadcastInfo.lawyerName }} 변호사
        <span v-if="dropdownIdx === index && Number(msg.userNo) !== Number(myNo)"
              class="nickname-dropdown"
              style="position:absolute;top:120%;left:0;z-index:10000;">
          <ul class="dropdown-custom-menu">
            <li class="menu-report" @click.stop="onReportClick">🚨 메시지 신고 🚨</li>
          </ul>
        </span>
      </span>
              <!-- 메시지: 빨간색 -->
              <span style="color: #fd1900; margin-left: 0.6em;">
        {{ msg.message }}
      </span>
            </div>

            <!-- 5. 공지 메시지 -->
            <div v-else-if="msg.type === 'NOTICE'"
                 class="w-100 text-center"
                 style="color: #7e7e7e; background: #e3eaff; border-radius: 12px; font-size: 0.8rem; font-weight: 600; padding: 9px 2px;">
              <span style="margin-right:6px;"></span>
              {{ msg.message }}
            </div>

            <!-- 6. 기본 채팅 메시지 (일반 유저 채팅) -->
            <div v-else style="font-size: 0.95rem; display: flex; align-items: center;">
              <!-- 닉네임 드롭다운 & 랜덤 색상 -->
              <span
                  @click.stop="Number(msg.userNo) !== Number(myNo) && openDropdown(index, msg)"
                  :style="{
              color: getNicknameColor(msg.nickname),
              cursor: Number(msg.userNo) === Number(myNo) ? 'default' : 'pointer',
              userSelect: 'text',
              position: 'relative',
              padding: '2px 7px',
              borderRadius: '7px',
              transition: 'background 0.14s'
        }"
                  :class="{'nickname-hoverable': Number(msg.userNo) !== Number(myNo)}">
        {{ msg.nickname }}

                <!-- 드롭다운 메뉴 -->
        <span
            v-if="dropdownIdx === index && Number(msg.userNo) !== Number(myNo)"
            class="nickname-dropdown"
            style="position:absolute;top:120%;left:0;z-index:10000;">
          <ul class="dropdown-custom-menu">
            <li class="menu-report" @click.stop="onReportClick">
              🚨 메시지 신고
            </li>
          </ul>
        </span>
      </span>

              <!-- 메시지 본문 -->
              <span style="color:#222; margin-left:0.7em; line-height:1.6; word-break:break-all;">
        {{ msg.message }}
      </span>
            </div>
          </div>
        </div>

        <!-- 입력창 -->
        <div class="d-flex flex-column">
          <input v-model="message"
                 type="text"
                 class="form-control bg-body-secondary text-dark border-0 rounded-pill px-3 py-2"
                 :placeholder="isStopped ? '🚫 채팅이 제한된 회원입니다.' : '채팅을 입력해 주세요.'"
                 @keyup.enter="sendMessage"
                 maxlength="100"
                 :disabled="isStopped" />

        </div>
      </div>

        <!-- 신고 확인 모달 -->
      <div v-if="isConfirmModal" class="modal-overlay-dark">
        <div class="modal-custom-box shadow">
          <div class="modal-custom-content">
            <div class="modal-custom-msg">
              <div class="modal-custom-text text-center">
                <span class="fs-5 fw-bold text-danger">⚠️ 신고 확인</span><br>
                <span class="d-block mt-2"><strong>{{ selectedUserToShow }}</strong>님의 메시지를 신고하시겠습니까?</span>
                <span class="d-block mt-2 text-muted small">신고된 메시지는 처리를 위해 수집됩니다.</span>
                <div class="reported-message-box mt-3 mb-1">
                  "{{ selectedMessage }}"
                </div>
              </div>
            </div>
            <div class="modal-custom-btns d-flex gap-2 justify-content-center mt-3">
              <button class="modal-btn-cancel" @click="isConfirmModal=false">취소</button>
              <button class="modal-btn-ok" @click="confirmReport">확인</button>
            </div>
          </div>
        </div>
      </div>

      <!-- 신고 완료 모달 -->
      <div v-if="isCompleteModal" class="modal-overlay-dark">
        <div class="modal-custom-box shadow">
          <div class="modal-custom-content">
            <div class="modal-custom-msg">
              <div class="modal-custom-text text-center">
                <span class="fs-5 fw-bold text-success">✔️ 신고 접수 완료</span><br>
                <span class="d-block mt-2">
            메시지 신고가 정상 접수되었습니다.<br>
            가이드 위반 여부 검토 후 조치 예정입니다.<br>
            감사합니다.
          </span>
              </div>
            </div>
            <div class="modal-custom-btns d-flex justify-content-center mt-3">
              <button class="modal-btn-ok" @click="closeCompleteModal">확인</button>
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
  -ms-overflow-style: none;
}

.blinking-dot {
  width: 10px;
  height: 10px;
  background-color: red;
  border-radius: 50%;
  animation: blink 1s infinite;
  display: inline-block;
  margin-right: 6px;
  vertical-align: middle;
}

@keyframes blink {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.3;
  }
}

.preq-dropdown {
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(24, 36, 72, 0.12);
  border: 1px solid #e4e4e7;
  animation: preq-drop-in 0.17s;
}

.preq-dropdown-inner {
  padding: 0 18px 10px 18px;
}


.preq-scroll::-webkit-scrollbar {
  width: 5px;
  background: #eee;
}

.preq-scroll::-webkit-scrollbar-thumb {
  background: #d3d3d3;
  border-radius: 5px;
}

@keyframes preq-drop-in {
  from {
    opacity: 0;
    transform: translateY(-14px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 닉네임 호버 효과 (본인 제외) */
.nickname-hoverable:hover {
  background: #f3f7fe !important;
}

/* 드롭다운 전체 영역 */
.nickname-dropdown {
  min-width: 140px;
  background: #c5c5c5;
  border-radius: 10px;
  box-shadow: 0 4px 18px 0 rgba(40,55,100,0.12);
  padding: 2px 0;
  margin-top: 2px;
  animation: dropdownPop 0.18s cubic-bezier(.4,1.6,.6,1);
}

/* 드롭다운 내부 메뉴 */
.dropdown-custom-menu {
  list-style: none;
  margin: 0;
  padding: 0;
}

.menu-report {
  font-size: 1.03rem;
  font-weight: 500;
  color: #d73737;
  padding: 7px 10px;
  border-radius: 8px;
  cursor: pointer;
  transition: background 0.11s, color 0.13s;
  text-align: left;
}
.menu-report:hover {
  background: #a6a4a4;
  color: #b90000;
}

/* 드롭다운 애니메이션 */
@keyframes dropdownPop {
  0% { transform: translateY(-8px) scale(0.92); opacity: 0;}
  100% { transform: translateY(0) scale(1); opacity: 1;}
}


/* 모달 전체 어두운 오버레이 */
.modal-overlay-dark {
  position: fixed;
  z-index: 11000;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.55);
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 모달 컨테이너 */
.modal-custom-box {
  background: #fff;
  border-radius: 18px;
  min-width: 340px;
  max-width: 95vw;
  box-shadow: 0 6px 36px 0 rgba(60, 60, 60, 0.16);
  padding: 32px 26px 20px 26px;
  animation: modalPop 0.21s cubic-bezier(.4, 1.6, .6, 1);
}

/* 모달 내부 컨텐츠 */
.modal-custom-content {
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* 메시지 텍스트 */
.modal-custom-text {
  font-size: 1.06rem;
  color: #242424;
}

/* 신고 메시지 강조 박스 */
.reported-message-box {
  background: #f7f7f8;
  border: 1px solid #f2b3b3;
  color: #ce2222;
  border-radius: 8px;
  padding: 7px 14px;
  font-size: 0.98rem;
  font-style: italic;
  word-break: break-all;
  margin-top: 0.9em;
  max-width: 280px;
}

/* 버튼 컨테이너 */
.modal-custom-btns {
  width: 100%;
  margin-top: 12px;
}

/* 취소/확인 버튼 공통 */
.modal-btn-cancel, .modal-btn-ok {
  min-width: 90px;
  padding: 8px 0 7px 0;
  border-radius: 7px;
  border: none;
  font-size: 1.07rem;
  font-weight: 500;
  letter-spacing: 0.01em;
  cursor: pointer;
  transition: background 0.13s;
}

/* 취소 버튼 */
.modal-btn-cancel {
  background: #f7f8fa;
  color: #555;
  border: 1px solid #ddd;
}

.modal-btn-cancel:hover {
  background: #e4e8eb;
}

/* 확인 버튼 */
.modal-btn-ok {
  background: #347dff;
  color: #fff;
  border: 1px solid #2d6bd7;
  margin-left: 8px;
}

.modal-btn-ok:hover {
  background: #1955bf;
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

.embed-video-only {
  width: 100%;
  height: 100vh;
  background-color: black;
}
</style>
