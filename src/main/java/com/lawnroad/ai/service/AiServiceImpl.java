package com.lawnroad.ai.service;

import com.lawnroad.ai.dto.*;
import com.lawnroad.common.config.GeminiConfig;
import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;
import com.lawnroad.template.service.ClientTemplateService;
import lombok.Getter;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class AiServiceImpl implements AiService {
  
  @Getter
  private final GeminiConfig geminiConfig;
  private final Client client;
  private final DocumentGenerator documentGenerator;
  private final ClientTemplateService clientTemplateService;
  
  public AiServiceImpl(GeminiConfig geminiConfig, DocumentGenerator documentGenerator, ClientTemplateService clientTemplateService) {
    this.client = Client.builder()
        .apiKey(geminiConfig.getApiKey())
        .build();
    this.geminiConfig = geminiConfig;
    this.documentGenerator = documentGenerator;
    this.clientTemplateService = clientTemplateService;
  }
  
  @Override
  public String fixTextTone(String text, String toneKey) {
    String prompt = buildPrompt(text, toneKey);
    GenerateContentResponse response = client.models.generateContent("gemini-2.0-flash", prompt, null);
    return response.text();
  }
  
  private String buildPrompt(String text, String toneKey) {
    return switch (toneKey) {
      case "SPELL" -> """
    You are a professional Korean proofreader.
    Correct any spelling, grammar, or sentence structure errors in the text below.
    Do not change the tone or meaning. Keep line breaks and paragraph formatting exactly the same.
    Return only the corrected Korean text.

    [문장]
    """ + text;
      
      case "PROFESSIONAL" -> """
    You are assisting a Korean lawyer in drafting or refining a legal document template intended for use by clients.

    Rewrite the following text using a strictly professional, clear, and legally precise tone suitable for official documents.

    ❗ Important Rules:
    - The lawyer is writing this document on behalf of a client. Write objectively, not personally.
    - Avoid conversational, speculative, outdated, or ambiguous expressions such as "~같습니다", "~예정입니다", "~사료됩니다".
    - Use definitive legal expressions like "~할 수 없습니다", "~로 간주합니다", "~허용되지 않습니다".
    - Preserve exactly the original number of lines, sentences, and paragraphs.
    - Do not add, remove, or merge any sentences.
    - Return only the rewritten Korean text.

    [문장]
    """ + text;
      
      case "TRUSTWORTHY" -> """
    You are helping a Korean lawyer create a legal document template intended for clients, ensuring clarity, confidence, and trustworthiness.

    Rewrite the following text in a polite but firm, confident, and trustworthy tone appropriate for formal client communication.

    ❗ Important Rules:
    - The lawyer is drafting this for clients, not personal communication.
    - Avoid conversational or uncertain expressions such as "~같습니다", "~일지도 모릅니다", "~예정입니다".
    - Use clear, definitive language (e.g., "~할 수 없습니다", "~로 간주합니다", "~인정되지 않습니다").
    - Keep exactly the same number of sentences, lines, and paragraph breaks as the original text.
    - Do not combine, remove, or add any sentences.
    - Return only the rewritten Korean text.

    [문장]
    """ + text;
      
      case "WARM" -> """
    You are assisting a Korean lawyer to draft legal document templates intended for clients in a warm, empathetic, yet clear and confident manner.

    Rewrite the following text to sound gentle and client-friendly without sacrificing professionalism or clarity.

    ❗ Important Rules:
    - This text is intended for clients, drafted by a lawyer. Do not write emotionally or casually.
    - Avoid overly soft, speculative, or unclear expressions such as "~같습니다", "~해보는 것도 좋습니다", "~예정입니다".
    - Use gentle yet definitive expressions (e.g., "~할 수 없습니다", "~로 간주됩니다", "~이루어지지 않습니다").
    - Maintain exactly the same number of sentences, lines, and paragraphs as the original input.
    - Do not add, remove, or merge sentences.
    - Return only the rewritten Korean text.

    [문장]
    """ + text;
      
      default -> """
    You are assisting a Korean lawyer to improve the fluency, clarity, and suitability of a legal document template intended for client use.

    Rewrite the following text to be clear, natural, and appropriately formal without sounding conversational or overly rigid.

    ❗ Important Rules:
    - The document is written by a lawyer for client use; do not write emotionally or personally.
    - Avoid uncertain, conversational, speculative, or outdated phrases like "~같습니다", "~예정입니다", "~사료됩니다".
    - Employ clear, direct expressions (e.g., "~할 수 없습니다", "~로 간주합니다", "~인정되지 않습니다").
    - Preserve the exact sentence count, line breaks, and paragraph structure of the original text.
    - Do not add, remove, or merge any sentences.
    - Return only the rewritten Korean text.

    [문장]
    """ + text;
    };
  }
  
  @Override
  public InterviewChatResponseDto generateResponse(InterviewChatRequestDto dto) {
    String prompt = buildPrompt(dto);
    GenerateContentResponse response = client.models.generateContent("gemini-2.0-flash", prompt, null);
    String reply = response.text();
    
    boolean allFilled = reply.contains("[문서 생성 완료! 문서를 다운로드 받으세요!]");
    String finalHtml = null;
    
    if (allFilled) {
      // 먼저 AI가 직접 생성한 HTML이 있는지 확인
      String rawHtml = extractFinalDocument(reply);
      
      if (rawHtml != null && !rawHtml.isBlank()) {
        // AI가 작성한 HTML이 있으면 무조건 그걸 사용
        rawHtml = rawHtml.replace("\n", "<br>"); // 줄바꿈 보정
        finalHtml = documentGenerator.wrapAsHtml(rawHtml);
      }
      
      // 다운로드 상태로 서버에서 처리
      if (dto.getOrderNo() != null && dto.getTmplNo() != null) {
        clientTemplateService.markTemplateAsDownloaded(dto.getOrderNo(), dto.getTmplNo());
      }
    }
    
    String prettyReply = reply.replace("\n", "<br>");
    return new InterviewChatResponseDto(prettyReply, allFilled, finalHtml);
  }
  private String extractFinalDocument(String aiReply) {
    String signal = "[문서 생성 완료! 문서를 다운로드 받으세요!]";
    int start = aiReply.indexOf(signal);
    
    if (start == -1) return null;
    
    // 신호 뒤부터 끝까지 잘라서 문서로 사용
    String after = aiReply.substring(start + signal.length()).trim();
    
    // 불필요한 코드블럭 표시 제거 (예: ```html ... ```)
    if (after.startsWith("```html")) {
      int htmlStart = after.indexOf("```html") + 7;
      int htmlEnd = after.indexOf("```", htmlStart);
      if (htmlEnd > htmlStart) {
        return after.substring(htmlStart, htmlEnd).trim();
      }
    }
    
    // 그렇지 않다면 그냥 신호 이후 전체 리턴
    return after;
  }
  
  private String extractHtmlPart(String response) {
    int bodyStart = response.indexOf("<body>");
    int bodyEnd = response.indexOf("</body>");
    
    if (bodyStart >= 0 && bodyEnd > bodyStart) {
      return response.substring(bodyStart + 6, bodyEnd).trim(); // <body> 생략한 순수 내용만
    }
    return null;
  }
  
  private String buildPrompt(InterviewChatRequestDto dto) {
    StringBuilder sb = new StringBuilder();
    
    sb.append("""
        너는 한국어 문서 템플릿을 작성하는 변호사를 도와주는 AI 인터뷰 챗봇이야.
        사용자가 문서를 완성할 수 있도록 하나씩 질문하고, 답이 이상하면 다시 물어보거나 보정해야 해.

        아래는 문서 초안이야:
        [본문]
        """).append(dto.getContent()).append("\n\n");
    
    sb.append("""
        아래는 문서 에 대한 설명이야:
        [설명]
        """).append(dto.getDescription()).append("\n\n");
    
    sb.append("[문서에 들어가야 할 항목과 예시값]\n");
    for (VariableDto var : dto.getVariables()) {
      sb.append("- ").append(var.getName())
          .append(": 예시값 → ").append(var.getDescription()).append("\n");
    }
    
    sb.append("[지금까지의 대화]\n");
    for (MessageDto msg : dto.getHistory()) {
      String speaker = msg.getRole().equals("user") ? "사용자" : "AI";
      sb.append(speaker).append(": ").append(msg.getContent().trim())
          .append("\n");
    }
    sb.append("\n위의 대화를 참고해서 다음 질문 또는 문서 생성을 진행하세요.\n");
    
    String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy년 MM월 dd일"));
    sb.append(String.format("""

오늘 날짜는 %s입니다. 날짜 관련 질문이 필요한 경우 이 날짜를 기준으로 하세요.

【중요】 변수 설명의 "홍길동", "김철수", "2025.01.01 12:00:00" 등은 모두 예시입니다.
실제 사용자에게서 정보를 받아야 합니다.

【AI의 역할】
당신은 법률문서 작성을 위한 전문 인터뷰어입니다.
변수 정보를 수집하는 것이 주목적이지만, 사용자에게 도움이 되는 제안도 할 수 있습니다.

【기본 원칙】
- 원본 문서 템플릿은 변호사가 작성한 전문 법률문서입니다
- 변수(#{변수명}) 채우기가 주요 목적입니다
- 원본 문서의 핵심 내용과 법적 효력은 유지해야 합니다
- 변수의 "description"은 단순한 예시값입니다. 무시하고 사용자에게 직접 물어보세요

【인터뷰 진행 방식】
- 한 번에 하나씩 자연스럽게 질문하세요
- 사용자 응답을 기다린 후 다음 질문으로 진행하세요
- 한국인 정서에 맞는 친근하고 유연한 대화
- 변수 정보 수집이 우선, 그 과정에서 자연스럽게 개선사항 제안
- 기존 대화 맥락을 파악해서 응대

【융통성 허용 범위】
- 사용자 상황에 맞지 않는 조항이 있으면 "이 부분은 생략하시겠어요?" 물어보기 가능
- 사용자에게 도움이 될 추가 조항이나 내용을 부드럽게 제안 가능
- "이런 내용도 추가하면 좋을 것 같은데 어떠세요?" 식으로 선택권 제공
- 사용자가 원하면 문서 일부 수정이나 개선 가능
- "보통 이런 경우엔 이렇게 하는데..." 식의 전문적 조언 가능

【대화 예시】
- "합의금 지급 방식은 일시불인가요? 아니면 분할 지급도 고려하고 계신가요? 분할이라면 문서에 그 내용도 추가할 수 있어요."
- "증인이나 보증인 관련 내용은 필요하신가요? 상황에 따라 추가하시면 더 안전할 수 있어요."

【절대 금지사항】
- 예시값(홍길동, 김철수 등)을 그대로 사용하기
- 사용자 응답 없이 다음 단계로 진행
- 원본 문서의 법률 내용 임의 수정
- 사용자 동의 없는 임의 수정
- 문서의 법적 효력을 해치는 변경
- 같은 질문 무한 반복

【문서 완성】
모든 실제 정보 수집 완료 시:
"[문서 생성 완료! 문서를 다운로드 받으세요!]"
사용자와 협의된 최종 내용으로 원본 템플릿에 수집한 실제 정보만 대입하여 HTML 출력
""", today));
    
    return sb.toString();
  }
  
  @Override
  public ValidationResultDto validateTemplateContent(String content, String name, String description) {
    // Gemini에 전달할 프롬프트 생성: 6가지 기준에 대해 Yes/No로 답하게 지시
    String prompt = """
You are an evaluator. Please assess the following document according to the 6 criteria listed below.

Answer each question with only "Yes" or "No" — nothing else.

Return exactly 6 lines in this order, each line containing only "Yes" or "No" (no extra comments or numbering).

1. Does the document contain inappropriate, harmful, or offensive content?
2. Is the document actually relevant to the topic: "%s"?
3. Is the grammar and clarity of the document acceptable?
4. Does the document include accurate and factual information?
5. Is the document well-structured and readable?
6. Does the document contain excessive marketing or promotional content?

[Document Description]
%s

[Document Content]
%s
""".formatted(name, description, content);
    
    try {
      GenerateContentResponse response = client.models.generateContent("gemini-2.0-flash", prompt, null);
      String[] lines = response.text().trim().split("\r?\n");
      int[] scores = new int[] {
          parseYesNo(lines[0], false), // 1. 부적절한 내용: "No"여야 통과
          parseYesNo(lines[1], true),  // 2. 주제 관련성: "Yes"여야 통과
          parseYesNo(lines[2], true),  // 3. 문법과 명확성: "Yes"여야 통과
          parseYesNo(lines[3], true),  // 4. 사실성: "Yes"여야 통과
          parseYesNo(lines[4], true),  // 5. 구조/가독성: "Yes"여야 통과
          parseYesNo(lines[5], false)  // 6. 과도한 홍보성: "No"여야 통과
      };
      
      // 판정 조건
      // coreFail: 반드시 통과해야 하는 항목 중 하나라도 실패 시 불합격
      // softFail: 문법/구조 항목 둘 다 실패 시 불합격
      // 최종 통과 여부는 위 두 조건 모두 미충족해야 true
      boolean coreFail = scores[0] == 0 || scores[1] == 0 || scores[3] == 0 || scores[5] == 0;
      boolean softFail = scores[2] == 0 && scores[4] == 0;
      boolean passed = !coreFail && !softFail;
      
      // 불합격 사유 수집
      List<String> reasons = new ArrayList<>();
      if (scores[0] == 0) reasons.add("① 부적절한 내용 포함");
      if (scores[1] == 0) reasons.add("② 주제와의 불일치");
      if (scores[3] == 0) reasons.add("③ 사실성 부족");
      if (scores[5] == 0) reasons.add("④ 과도한 홍보성");
      if (scores[2] == 0 && scores[4] == 0) reasons.add("⑤ 문맥/구조적 완성도 미달");
      
      // 결과 전송
      return new ValidationResultDto(passed, reasons);
    } catch (Exception e) {
      // 예외 처리 및 응답 생성
      return new ValidationResultDto(false, List.of("Gemini 호출 실패: " + e.getMessage()));
    }
  }
  
  private int parseYesNo(String line, boolean yesMeansPass) {
    line = line.toLowerCase();
    if (line.contains("yes")) return yesMeansPass ? 1 : 0;
    if (line.contains("no")) return yesMeansPass ? 0 : 1;
    return -1;
  }
}