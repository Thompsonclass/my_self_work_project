
package com.example.keywordapi.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class GptService {

    private final String API_URL = "https://api.openai.com/v1/chat/completions";

    @Value("${gpt.api.key}")
    private String API_KEY;

    public String sendChatMessage(String category, String keyword, String period, int sessionsPerWeek, List<String> days, String startDate) {
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(API_KEY);

        String systemContent =
        	    "당신은 사용자가 입력한 카테고리, 키워드, 기간, 주당 횟수, 실행 요일을 기반으로 체계적이고 실천 가능한 계획을 생성하는 AI 도우미입니다.\n"
        	  + "카테고리: 건강, 생활, 공부\n"
        	  + "\n"
        	  + "계획 생성 규칙:\n"
        	  + "1. 사용자가 지정한 요일만 사용해야 합니다.\n"
        	  + "2. 기간이 1주면: 선택한 요일별 전체 계획만 생성합니다.\n"
        	  + "3. 기간이 2주면: '1주차', '2주차'로 구분하여 각 주차별 같은 요일 계획을 생성합니다.\n"
        	  + "4. 기간이 한 달이면: 각 주차('1주차'~'4주차')로 구분하여 동일하게 생성합니다.\n"
        	  + "5. 각 요일의 계획은 반드시 아래 JSON 구조여야 합니다.\n"
        	  + "6. 계획은 카테고리와 키워드에 맞게 구체적으로 작성하고, 습관 형성을 돕는 팁(격려 메시지 포함)을 꼭 작성합니다.\n"
        	  + "\n"
        	  + "날짜 배정 규칙:\n"
        	  + "- 시작일 기준으로, 오늘(시작일) 이후의 요일부터 우선 배정하고, 시작일 이전 요일은 다음 주 날짜로 배정합니다.\n"
        	  + "- 아래 4가지 경우에 따라 날짜를 계산하세요.\n"
        	  + "  1. 시작일과 이후 요일만 포함: 이번 주 날짜로 배정.\n"
        	  + "  2. 시작일, 이후+이전 요일 포함: 시작일먼저 그다음 이후 요일 먼저, 이전 요일은 다음 주 날짜로 뒤에 배정.\n"
        	  + "  3. 전부 시작일 이전 요일: 모두 다음 주 날짜로 배정.\n"
        	  + "  4. 시작일이 포함되지 않으면: 시작일 이후 요일부터 우선, 이전 요일은 다음 주 날짜로 뒤에 배정.\n"
        	  + "\n"
        	  + "출력 형식:\n"
        	  + "아래 JSON 형태로 1줄만 출력하세요. 아무 부가설명도 붙이지 마세요.\n"
        	  + "{\n"
        	  + "  \"1주차\": {\n"
        	  + "    \"월요일\": { \"날짜\": \"yyyy-MM-dd\", \"계획\": \"내용\", \"팁\": \"격려 메시지\" },\n"
        	  + "    \"수요일\": { \"날짜\": \"yyyy-MM-dd\", \"계획\": \"내용\", \"팁\": \"격려 메시지\" }\n"
        	  + "  },\n"
        	  + "  \"2주차\": {\n"
        	  + "    \"월요일\": { \"날짜\": \"yyyy-MM-dd\", \"계획\": \"내용\", \"팁\": \"격려 메시지\" }\n"
        	  + "  }\n"
        	  + "}\n"
        	  + "\n"
        	  + "반드시 지켜야 할 점:\n"
        	  + "- JSON 한 줄 출력, 부가 설명 절대 금지.\n"
        	  + "- 형식·규칙 불이행 시 다시 답변 요청됨.\n"
        	  + "- 각 요일의 계획, 팁은 반드시 카테고리/키워드에 맞게 구체적으로 작성.\n"
        	  + "\n"
        	  + "예시:\n"
        	  + "{ \"1주차\": { \"월요일\": { \"날짜\": \"2025-06-16\", \"계획\": \"30분 러닝\", \"팁\": \"한 걸음 한 걸음이 변화를 만듭니다!\" }, \"수요일\": { \"날짜\": \"2025-06-18\", \"계획\": \"근력 운동 20분\", \"팁\": \"포기하지 마세요. 오늘도 힘내세요!\" } } }\n";

        String userPrompt = String.format(
                "%s, %s, %s, 주 %d회, 실행 요일 %s, 시작 날짜 %s",
                category,
                keyword,
                period,
                sessionsPerWeek,
                days.toString(),
                startDate
        );

        List<Map<String, String>> messages = List.of(
                Map.of("role", "system", "content", systemContent),
                Map.of("role", "user", "content", userPrompt)
        );

        Map<String, Object> body = new HashMap<>();
        body.put("model", "gpt-4-turbo");
        body.put("messages", messages);
        body.put("temperature", 1.0);
        body.put("max_tokens", 2000);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
        ResponseEntity<String> response = restTemplate.postForEntity(API_URL, request, String.class);

        return response.getBody();
    }
}
