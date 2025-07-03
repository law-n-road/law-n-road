<script setup>
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import LawyerFrame from '@/components/layout/lawyer/LawyerFrame.vue'
import AiTemplateEditor from '@/components/template/AiTemplateEditor.vue'
import UploadTemplateForm from '@/components/template/UploadTemplateForm.vue'
import http from '@/libs/HttpRequester'
import {getValidToken} from "@/libs/axios-auth.js";

// 최대 썸네일 용량 (10MB)
const MAX_THUMBNAIL_SIZE = 10 * 1024 * 1024  // 10MB
const router = useRouter()
const route = useRoute()
const templateNo = route.params.no
const templateType = route.query.type || 'EDITOR'

// 공통 필드
const name = ref('')
const price = ref(0)
const discountRate = ref(0)
const categoryNo = ref(null)
const description = ref('')
const thumbnailFile = ref(null)
const thumbnailPreview = ref(null)
const oldThumbnailPath = ref(null)
const createdAt = ref('')

// 수정 전 원본값 저장용
const originEditorContent = ref('')
const originEditorVariables = ref([])
const originUploadedFiles = ref([])

// 템플릿 타입 고정 (탭 제거)
const selectedTab = ref(templateType === 'EDITOR' ? 'ai' : 'upload')

// AI용 데이터
const editorContent = ref('')
const editorVariables = ref([])

// 파일 업로드용
const uploadedFiles = ref([])

// 썸네일 제거 플래그
const removeExistingThumbnail = ref(false)

// 로딩 용
const isSubmitting = ref(false)

onMounted(async () => {
  try {
    const res = await http.get(`/api/lawyer/templates/${templateNo}`, { type: templateType })
    // const res = await makeApiRequest({
    //   method: 'get',
    //   url: `/api/lawyer/templates/${templateNo}`,
    //   params: { type: templateType }  // GET 쿼리는 params로
    // })

    const data = res.data

    console.log(data)

    // 공통 필드 세팅
    name.value = data.name
    price.value = data.price
    discountRate.value = data.discountRate
    categoryNo.value = data.categoryNo
    description.value = data.description
    createdAt.value = data.createdAt
    oldThumbnailPath.value = data.thumbnailPath
    thumbnailPreview.value = data.thumbnailPath

    // 초기값 저장
    originEditorContent.value = data.content || ''
    originEditorVariables.value = JSON.parse(data.varJson || '[]')
    if (templateType === 'FILE') {
      originUploadedFiles.value = JSON.parse(data.pathJson || '[]')
      uploadedFiles.value = JSON.parse(data.pathJson || '[]')
    }

    // 유형별 분기
    if (templateType === 'EDITOR') {
      selectedTab.value = 'ai'
      editorContent.value = data.content
      editorVariables.value = JSON.parse(data.varJson || '[]')
    } else if (templateType === 'FILE') {
      selectedTab.value = 'upload'
      uploadedFiles.value = JSON.parse(data.pathJson || '[]')
    } else {
      throw new Error(`알 수 없는 템플릿 유형: ${templateType}`)
    }
  } catch (e) {
    console.error(e)
    alert('템플릿 정보를 불러오지 못했습니다.')
  }
})

function clearThumbnail() {
  thumbnailFile.value = null
  thumbnailPreview.value = null
  removeExistingThumbnail.value = true  // 기존 썸네일도 지운다고 표시
}

function onThumbnailChange(e) {
  const file = e.target.files[0]
  if (!file) return

  // 이미지 타입 검증
  if (!file.type.startsWith('image/')) {
    alert('❌ 이미지 파일만 업로드할 수 있습니다.')
    e.target.value = null
    clearThumbnail()
    return
  }

  // 용량 제한 검증
  if (file.size > MAX_THUMBNAIL_SIZE) {
    alert('❌ 썸네일 이미지는 10MB 이하만 업로드 가능합니다.')
    e.target.value = null
    clearThumbnail()
    return
  }

  // 정상 통과 시
  thumbnailFile.value = file
  thumbnailPreview.value = URL.createObjectURL(file)
}

async function handleUpdate() {
  if (name.value.length > 50) {
    return alert('❌ 템플릿명은 50자 이내로 입력해 주세요.');
  }
  if (price.value < 0 || price.value > 2147483647) {
    return alert('❌ 가격은 0원 이상 2,147,483,647원 이하만 입력 가능합니다.');
  }
  if (discountRate.value < 0 || discountRate.value > 100) {
    return alert('❌ 할인율은 0% 이상 100% 이하로만 입력 가능합니다.');
  }
  if (!name.value.trim()) {
    return alert('❌ 템플릿명을 입력해 주세요.');
  }
  if (!categoryNo.value) {
    return alert('❌ 카테고리를 선택해 주세요.');
  }

  // 1) 변경 여부 비교
  let isContentChanged = false
  let isFileChanged = false

  if (selectedTab.value === 'ai') {
    if (!editorContent.value.trim()) {
      return alert('❌ 본문 내용을 입력해 주세요.');
    }
    isContentChanged =
        editorContent.value !== originEditorContent.value ||
        JSON.stringify(editorVariables.value) !== JSON.stringify(originEditorVariables.value)
  } else {
    // 기존 파일 메타(객체)와 비교
    const existingMetaOnly = uploadedFiles.value.filter(item => !(item instanceof File))
    isFileChanged =
        uploadedFiles.value.some(item => item instanceof File) ||
        JSON.stringify(existingMetaOnly) !== JSON.stringify(originUploadedFiles.value)
  }

  // 2) 분기: 복제 방식 또는 메타 업데이트
  try {
    if (isContentChanged || isFileChanged) {
      if (!confirm('템플릿을 수정하면 판매기록이 초기화 됩니다. 정말 수정하시겠습니까?')) return;
      isSubmitting.value = true
      await callUpdateCloneAPI();
    } else {
      isSubmitting.value = true
      await callUpdateMetaAPI();
    }
    alert('수정 완료되었습니다.');
    router.push('/lawyer/templates');
  } catch (e) {
    // 400 Bad Request: 백엔드가 보낸 상세 메시지 출력
    if (e.response && e.response.status === 400) {
      alert(e.response.data);
    } else {
      console.error(e);
      alert('❌ 알 수 없는 오류가 발생했습니다. 다시 시도해주시기 바랍니다.');
    }
  } finally {
    isSubmitting.value = false
  }
}

async function callUpdateCloneAPI() {
  const formData = new FormData()
  formData.append('no', templateNo)
  formData.append('name', name.value)
  formData.append('price', price.value)
  formData.append('discountRate', discountRate.value)
  formData.append('categoryNo', categoryNo.value)
  formData.append('description', description.value)
  formData.append('type', selectedTab.value === 'ai' ? 'EDITOR' : 'FILE')
  formData.append('removeThumbnail', removeExistingThumbnail.value ? 1 : 0)

  if (thumbnailFile.value) {
    formData.append('file', thumbnailFile.value)
  }

  if (selectedTab.value === 'ai') {
    formData.append('content', editorContent.value)
    formData.append('varJson', JSON.stringify(editorVariables.value))
    formData.append('aiEnabled', 1)
  } else {
    const existingMeta = uploadedFiles.value.filter(
        item => item.originalName && item.savedPath
    )
    formData.append('pathJson', JSON.stringify(existingMeta))
    uploadedFiles.value
        .filter(item => item instanceof File)
        .forEach(file => {
          formData.append('templateFiles', file)
        })
  }

  // 에러는 handleUpdate()에서 처리됩니다.
  await http.post('/api/lawyer/templates/update', formData)
  // await makeApiRequest({
  //   method: 'post',
  //   url: '/api/lawyer/templates/update',
  //   data: formData,
  // })
}

async function callUpdateMetaAPI() {
  const formData = new FormData()
  formData.append('no', templateNo)
  formData.append('name', name.value)
  formData.append('price', price.value)
  formData.append('discountRate', discountRate.value)
  formData.append('categoryNo', categoryNo.value)
  formData.append('description', description.value)
  formData.append('type', selectedTab.value === 'ai' ? 'EDITOR' : 'FILE')
  formData.append('removeThumbnail', removeExistingThumbnail.value ? 1 : 0)
  // 썸네일 교체가 있는 경우만
  if (thumbnailFile.value) {
    formData.append('file', thumbnailFile.value)
  }

  // Axios(또는 http)로 보내면, 자동으로 Content-Type: multipart/form-data 가 세팅됩니다.
  await http.post('/api/lawyer/templates/update-meta', formData)
  // await makeApiRequest({
  //   method: 'post',
  //   url: '/api/lawyer/templates/update-meta',
  //   data: formData,
  // })
}
</script>

<template>
  <LawyerFrame>
    <!-- 전체 화면 로딩 오버레이 -->
    <div v-if="isSubmitting" class="loading-overlay">
      <div class="spinner-border" role="status">
        <span class="visually-hidden">Loading…</span>
      </div>
    </div>

    <div class="container py-4">
      <h3 class="mb-4 fw-bold">템플릿 수정</h3>

      <!-- 공통 필드 입력 -->
      <div class="card p-4 mb-4">
        <div class="row mb-3">
          <div class="col-md-4">
            <label class="form-label">썸네일 이미지</label>
            <div class="preview-box position-relative mb-2 d-flex align-items-center justify-content-center border rounded">
              <button
                  v-if="thumbnailPreview"
                  type="button"
                  class="btn-close position-absolute top-0 end-0 m-2"
                  aria-label="Remove thumbnail"
                  style="z-index:10"
                  @click="clearThumbnail"
              > </button>
              <img v-if="thumbnailPreview" :src="thumbnailPreview" alt="미리보기" class="img-fluid h-100" style="object-fit: contain" />
              <p v-else class="text-muted" style="text-align: center">상품 목록에 보여질 대표 이미지입니다.<br>이미지를 등록해 주세요</p>
            </div>
            <input type="file" class="form-control" accept="image/*" @change="onThumbnailChange" />
          </div>
          <div class="col-md-8">
            <label class="form-label">상품명</label>
            <input v-model="name" class="form-control mb-2" />
            <label class="form-label">가격 (원)</label>
            <input v-model="price" type="number" class="form-control mb-2" />
            <label class="form-label">할인율 (%)</label>
            <input v-model="discountRate" type="number" class="form-control mb-2" />
            <label class="form-label">카테고리</label>
            <select v-model.number="categoryNo" class="form-select">
              <option value="" disabled>카테고리 선택</option>
              <option :value="1">사고 발생/처리</option>
              <option :value="2">중대사고·형사처벌</option>
              <option :value="3">음주·무면허 운전</option>
              <option :value="4">보험·행정처분</option>
              <option :value="5">과실 분쟁</option>
              <option :value="6">차량 외 사고</option>
            </select>
          </div>
        </div>

        <div>
          <label class="form-label">상세 설명</label>
          <textarea v-model="description" rows="6" class="form-control" />
        </div>
      </div>

      <!-- 템플릿 본문 (타입 고정) -->
      <div class="template-wrapper">
        <AiTemplateEditor
            v-if="selectedTab === 'ai'"
            v-model:content="editorContent"
            v-model:variables="editorVariables"
            :is-edit=true
        />

        <UploadTemplateForm
            v-if="selectedTab === 'upload'"
            v-model:templateFiles="uploadedFiles"
        />
      </div>

      <div class="card p-3 mb-4 bg-light-subtle template-guide">
        <h6 style="text-align: center">모든 템플릿은 등록 전에 AI 기반의 문서 검증을 거쳐야 합니다. 정확하고 신중하게 작성해 주세요.</h6> <br>
        <div class="d-flex justify-content-between align-items-center">
          <strong>AI 문서 검증이란?</strong>
        </div>
        <p class="mt-2 mb-1 text-muted small">
          AI가 작성한 문서가 법률 문서로서 적절한지 <b>5가지 항목</b>을 기준으로 자동 점검합니다.
          <br>문서 등록 및 수정 시 <u><b>반드시 통과</b></u>해야 최종적으로 템플릿이 등록됩니다.
        </p>

        <table class="table table-bordered table-sm mt-3 mb-2 small text-center align-middle">
          <thead class="table-light">
          <tr>
            <th style="width: 5%">코드</th>
            <th style="width: 25%">메시지</th>
            <th style="width: 35%">의미</th>
            <th style="width: 35%">회피 방법</th>
          </tr>
          </thead>
          <tbody>
          <tr>
            <td>①</td>
            <td>부적절한 내용 포함 여부</td>
            <td class="text-start">비속어·혐오·불법 지시 등 유해·공격적 표현 포함</td>
            <td class="text-start">중립적이고 안전한 표현으로 수정</td>
          </tr>
          <tr>
            <td>②</td>
            <td>주제 적합성</td>
            <td class="text-start">문서 내용이 지정된 주제와 실제로 관련 없음</td>
            <td class="text-start">본문을 주제에 맞게 재작성</td>
          </tr>
          <tr>
            <td>③</td>
            <td>문법 및 명확성</td>
            <td class="text-start">문법 오류나 모호한 표현으로 이해 어려움</td>
            <td class="text-start">문법 수정 및 간결하고 명확한 문장으로 개선</td>
          </tr>
          <tr>
            <td>④</td>
            <td>정보 정확성</td>
            <td class="text-start">수치·판례·출처 없이 사실성 검증 불가</td>
            <td class="text-start">신뢰할 수 있는 근거(수치·판례 등) 추가</td>
          </tr>
          <tr>
            <td>⑤</td>
            <td>구조 및 가독성</td>
            <td class="text-start">논리적 흐름·단락 구분·목차 부재로 읽기 어려움</td>
            <td class="text-start">단락 나누기, 제목·목차 추가, 연결어 사용</td>
          </tr>
          <tr>
            <td>⑥</td>
            <td>홍보성 과다 여부</td>
            <td class="text-start">과도한 할인·광고 문구나 상업적 유인 표현 포함</td>
            <td class="text-start">광고성 문구 제거, 객관적 사실 중심 서술</td>
          </tr>
          </tbody>
        </table>

        <p class="mt-2 mb-0 text-muted small">
          <strong>팁:</strong> 과장된 표현보다 <u>중립적이고 정보 중심의 문장</u>일수록 검증 성공률이 높습니다.
        </p>
      </div>

      <!-- 버튼 -->
      <div class="text-end">
        <div class="text-muted small mb-2">
          AI가 문서를 정밀하게 검토합니다. <strong>1~5분 정도 소요</strong>될 수 있어요.
        </div>
        <button
            class="btn btn-primary"
            :disabled="isSubmitting"
            @click="handleUpdate"
        >
        <span
            v-if="isSubmitting"
            class="spinner-border spinner-border-sm me-2"
            role="status"
        ></span>
          {{ isSubmitting ? '수정 중…' : 'AI 검증 후 수정' }}
        </button>
      </div>
    </div>
  </LawyerFrame>
</template>

<style scoped>
.preview-box {
  width: 100%;
  height: 235px;
  background-color: #f8f9fa;
  border: 1px dashed #ccc;
  overflow: hidden;
}

.template-wrapper {
  background-color: #f7f8fb;
  border: 1px solid #d6dbe8;
  border-radius: 0.5rem;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

.loading-overlay {
  position: fixed;
  top: 0; left: 0;
  width: 100vw; height: 100vh;
  background: rgba(255, 255, 255, 0.4); /* 좀 더 투명 */
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
}
</style>
