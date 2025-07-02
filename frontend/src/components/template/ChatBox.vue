<script setup>
import { ref, watch, nextTick } from 'vue'
import http from '@/libs/HttpRequester'
import html2pdf from 'html2pdf.js'

const props = defineProps({
  content: String,
  description: String,
  variables: {
    type: Array,
    required: true
  },
  orderNo: {
    type: Number,
    required: true
  },
  tmplNo: {
    type: Number,
    required: true
  },
})

// 채팅 상태
const messages = ref([
  { role: 'assistant', content: '안녕하세요! 문서 작성을 도와드릴게요. 필요한 정보를 하나씩 물어볼게요.' }
])

const input = ref('')
const finalHtml = ref('') // 완성된 문서 HTML

// 메시지 전송 → Gemini 호출
async function send() {
  const text = input.value.trim()
  if (!text) return

  messages.value.push({ role: 'user', content: text })
  input.value = ''

  try {
    const res = await http.post('/api/gemini/interview', {
      description: props.description,
      content: props.content,
      variables: props.variables,
      history: messages.value,
      orderNo: props.orderNo,
      tmplNo: props.tmplNo,
    })

    messages.value.push({ role: 'assistant', content: res.data.reply })

    // AI 응답 후에도 스크롤 내리기
    scrollToBottom()

    if (res.data.allVariablesFilled) {
      finalHtml.value = res.data.finalHtml
    }

  } catch (err) {
    console.error(err)
    messages.value.push({
      role: 'assistant',
      content: 'AI 서버와의 통신 중 오류가 발생했습니다.'
    })
    scrollToBottom()
  }
}

// PDF 저장
async function downloadPdf() {
  await nextTick()
  const element = document.querySelector('.preview-content')
  if (!element) {
    alert("PDF로 저장할 내용이 없습니다.")
    return
  }
  html2pdf().set({
    margin: 10,
    filename: 'document.pdf',
    image: {type: 'jpeg', quality: 0.98},
    html2canvas: {scale: 2},
    jsPDF: {unit: 'mm', format: 'a4', orientation: 'portrait'},
    pagebreak: {mode: ['avoid-all', 'css', 'legacy']}
  }).from(element).save()
}

const chatContainer = ref(null)

// 스크롤을 맨 아래로 내리는 함수
function scrollToBottom() {
  nextTick(() => {
    const el = chatContainer.value
    if (el) {
      // 부드러운 스크롤로 맨 아래로
      el.scrollTo({
        top: el.scrollHeight,
        behavior: 'smooth'
      })
    }
  })
}

// 메시지가 추가될 때마다 스크롤 내리기
watch(messages, () => {
  scrollToBottom()
}, { deep: true })

function formatMessage(text) {
  return text
      .replace(/```html/g, '')           // 코드 블럭 시작 제거
      .replace(/```/g, '')               // 코드 블럭 끝 제거
      .replace(/<br\s*\/?>/gi, '\n')     // <br> → 줄바꿈
      .replace(/<\/?p>/gi, '\n')         // <p> → 줄바꿈
      .replace(/\n{2,}/g, '\n')          // 연속 줄바꿈 하나로 정리
      .trim()                            // 앞뒤 공백 제거
}

</script>

<template>
  <div class="card p-3 mt-4 chat-box">
    <h5 class="mb-3">AI 채팅</h5>

    <!-- 채팅 영역 -->
    <div class="chat-messages mb-3" ref="chatContainer">
      <div
          v-for="(msg, i) in messages"
          :key="i"
          :class="['message', msg.role]"
      >
        <strong class="me-2">{{ msg.role === 'user' ? '' : '🤖' }}</strong>
        <pre class="message-text">{{ formatMessage(msg.content) }}</pre>
      </div>
    </div>

    <!-- 입력창 -->
    <div class="input-group mb-3">
      <input
          v-model="input"
          @keyup.enter="send"
          type="text"
          class="form-control"
          placeholder="메시지를 입력하세요..."
      />
      <button class="btn btn-primary" @click="send">전송</button>
    </div>

    <!-- 문서 미리보기 -->
    <div v-if="finalHtml" class="preview-box">
      <h6 class="mb-2">문서 미리보기</h6>
      <div class="preview-content border p-3 mb-2" v-html="finalHtml" />
      <button class="btn btn-danger w-100" @click="downloadPdf">PDF로 저장</button>
    </div>
  </div>
</template>

<style scoped>
.chat-box {
  background: #f9f9f9;
}
.chat-messages {
  max-height: 400px;
  overflow-y: auto;
  overflow-x: hidden; /* 가로 스크롤 숨기기 */
  scroll-behavior: smooth;
  padding: 10px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  background: #fff;
}

.message {
  margin-bottom: 1rem;
  max-width: 100%;
  word-wrap: break-word; /* 긴 단어 줄바꿈 */

  padding: 8px 0; /* 상하 패딩 추가 */
}

.message-text {
  background: none;
  border: none;
  margin: 0;
  padding: 8px 12px;
  border-radius: 12px;
  display: inline-block;
  max-width: 80%;
  word-wrap: break-word;
  word-break: break-word; /* 강제 줄바꿈 */
  white-space: pre-wrap;
  font-family: inherit;
  font-size: 14px;
  line-height: 1.4;
}

.message.user .message-text {
  background-color: #4a508f;
  color: white;
  margin-left: auto;
}

.message.assistant .message-text {
  background-color: #f1f3f4;
  color: #333;
}
.message.user {
  text-align: right;
}
.message.assistant {
  text-align: left;
}
.preview-box {
  background: #fff;
  border-top: 1px solid #ddd;
  padding-top: 1rem;
}
.preview-content {
  background: #fcfcfc;
  white-space: pre-wrap;
  min-height: 100px;
  word-wrap: break-word;
  overflow-wrap: break-word;
  max-width: 100%;
}
</style>