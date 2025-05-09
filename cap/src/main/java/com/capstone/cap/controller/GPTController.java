package com.capstone.cap.controller;

import com.capstone.cap.dto.GPTRequest;
import com.capstone.cap.dto.Message;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;


/**
 * GPT API 연동용 컨트롤러
 * 내부에서 고정된 message 배열을 구성하여 OpenAI Chat API로 요청을 보냄
 */
@RestController
@RequestMapping("/gpt")
@RequiredArgsConstructor
public class GPTController {

    @Value("${gpt.model}")        // application.properties에서 모델명 로딩
    private String model;

    @Value("${gpt.api.url}")      // OpenAI API URL 로딩
    private String apiUrl;

    @Value("${gpt.api.key}")      // API 키 로딩
    private String apiKey;

    private final RestTemplate restTemplate;  // Spring HTTP 클라이언트

    /**
     * GET /gpt/chat 요청 시 실행
     * OpenAI에 메시지 배열을 POST로 전달하여 응답을 반환
     */
    @GetMapping("/chat")
    public String chat() throws JsonProcessingException {
        
    	// 현재 날짜 구하기
        LocalDate today = LocalDate.now();

        // yyyy-MM-dd 형식 지정
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // 포맷팅
        String formattedDate = today.format(formatter);
    	
    	// 메시지 리스트 생성
        List<Message> messages = new ArrayList<>();
        messages.add(new Message("system", 
        	    "당신은 사용자가 제공한 키워드에 따라 체계적이고 실천 가능한 계획을 JSON 형식으로 제공하는 도우미입니다. " +
        	    "계획은 다음과 같은 카테고리로 나뉩니다:" +
        	    "- 건강: 운동루틴, 식단관리, 수면관리" +
        	    "- 생활: 청소루틴, 금연, 시간관리" +
        	    "- 공부: 자격증공부, 영어학습, 독서" +
        	    "공통 키워드는 다음과 같습니다:" +
        	    "- 기간: 1주일, 2주일, 한달" +
        	    "- 횟수: 일주일에 몇 번 할 것인지 (예: 3번)" +
        	    "- 실행 요일: 어떤 요일에 실행할 것인지 (예: [월, 수, 금])" +
        	    "요청된 기간에 따라:" +
        	    "- 1주일이면 지정된 요일에 대한 전체 계획," +
        	    "- 2주일이면 '1주차', '2주차'로 구분하여 요일별 계획," +
        	    "- 한 달이면 주 단위로 전체 계획을 제공해야 합니다." +
        	    "각 요일 계획은 다음과 같은 세부 요소를 포함해야 합니다:" +
        	    "- 활동 계획 (예: 상세계획	)" +
        	    "- 팁 (예: 습관 형성을 돕는 조언,격려 하는 메세지 포함)" +
        	    "주의사항(피해야 할 행동, 유의점 등)도 함께 포함해주세요." +
        	    "현재 날짜를 받아 해당 요일과 날짜를 매핑해주세요."+
        	    "응답은 반드시 JSON 형식으로 출력하며, 예시는 다음 구조를 참고하세요:" +
				"{" +
				"  \"category\": \"건강\"," +
			    "  \"sub_category\": \"운동관리\"," +
			    "  \"기간\": \"1주일\"," +
			    "  \"횟수\": \"주 3회\"," +
			    "  \"실행 요일\": [\"월\", \"수\", \"금\"]," +
				"  \"월요일\": {" +
				"    \"날짜\": \"yyyy-mm-yy\"," +
				"    \"계획\": \"상세계획 하는시간\"," +
				"    \"팁\": \"습관 형성을 돕는 조언,격려 하는 메세지\"" +
				"  }," +
				"  \"화요일\": {" +
				"    \"날짜\": \"yyyy-mm-yy\"," +
				"    \"계획\": \"상세계획 하는시간\"," +
				"    \"팁\": \"습관 형성을 돕는 조언,격려 하는 메세지\"" +
				"  }," +
				"  \"금요일\": {" +
				"    \"날짜\": \"yyyy-mm-yy\"," +
				"    \"계획\": \"상세계획 하는시간\"," +
				"    \"팁\": \"습관 형성을 돕는 조언,격려 하는 메세지\"" +
				"  }," +
				"  \"주의사항\": \"전체 계획을 수행하기전에 필요한 주의 사항\"" +
				"}"+
				"하나의 줄로 출력해주세요."
        	));

            messages.add(new Message("user", "건강"+","+"다이어트"+","+"1주일"+","+"5번"+","+"[월,화,목,금,일]"+","+formattedDate));

        // GPT 요청 본문 구성
        GPTRequest requestBody = new GPTRequest();
        requestBody.setModel(model);            // 사용할 모델
        requestBody.setMessages(messages);      // 메시지 배열
        requestBody.setTemperature(1.0);        // 창의성 (0~2)
        requestBody.setMax_tokens(2000);         // 최대 응답 길이

        // HTTP 요청 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey); // Authorization: Bearer <API_KEY>

        // HTTP 요청 객체 구성
        HttpEntity<GPTRequest> request = new HttpEntity<>(requestBody, headers);

        // 요청 JSON 로그 출력 (디버깅용)
        ObjectMapper mapper = new ObjectMapper();
        System.out.println("REQ JSON: " + mapper.writeValueAsString(requestBody));

        // GPT API에 요청 보내고 응답 받기
        ResponseEntity<String> response = restTemplate.postForEntity(apiUrl, request, String.class);

        // GPT 응답 본문 반환
        return response.getBody();
    }
}
