
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
        		"당신은 사용자가 입력한 카테고리, 키워드, 기간, 주당 횟수, 실행 요일을 기반으로 체계적이고 실천 가능한 계획을 생성하는 도우미입니다. " +
        				"요청 형식: 카테고리, 키워드, 기간, 주당 횟수, 요일 목록, 시작 날짜. 예: 건강, 다이어트, 2주일, 주 3회, [월, 수, 금], 2025-05-20 " +
        				"생성 규칙:\n" +
        				"- 사용자가 선택한 요일만 사용합니다.\n" +
        				"- 기간이 2주 이상이면 '1주차', '2주차', ... 와 같이 구분하고 각 주차마다 동일한 요일별 계획을 반복합니다.\n" +
        				"- 각 요일은 다음 구조를 포함해야 합니다:\n" +
        				"  { \"날짜\": \"yyyy-MM-dd\", \"계획\": \"내용\", \"팁\": \"격려 메시지\" }\n" +
        				"- 반드시 날짜는 시작일로부터 각 요일에 해당하는 실제 날짜로 자동 계산해주세요.\n" +
        				"- 날짜 계산 시, 요일은 시작일 기준으로 정렬하여 오늘(시작일) 이후의 요일부터 먼저 배정하고, 이미 지난 요일은 다음 주 날짜로 배정해주세요.\n" +
        				"- 전체 응답은 다음 JSON 형식이어야 합니다 (1줄 출력):\n" +
        				"{ \"1주차\": { \"월요일\": { ... }, \"수요일\": { ... }, ... }, \"2주차\": { \"월요일\": { ... }, ... } }\n" +
        				"- 마지막에 \"주의사항\" 항목도 포함해주세요.";

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
