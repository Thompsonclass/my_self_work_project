package com.capstone.cap.service;


import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class GptService {

    public String sendChatMessage(List<Map<String, String>> messages) {
        // HTTP 요청 생성: GPT API 호출 부분
        RestTemplate restTemplate = new RestTemplate();
        String url = "https://api.openai.com/v1/chat/completions";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth("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");

        Map<String, Object> body = new HashMap<>();
        body.put("model", "gpt-4-turbo");
        body.put("messages", messages);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
        ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);

        return response.getBody();
    }
}
