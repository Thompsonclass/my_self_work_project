package com.capstone.cap.dto;


import lombok.Data;
import java.util.List;

/**
 * OpenAI Chat API 요청 본문 DTO
 */
@Data
public class GPTRequest {
    private String model; // 사용할 GPT 모델 이름
    private List<Message> messages; // 채팅 메시지 배열
    private double temperature; // 창의성 정도 (0~2)
    private int max_tokens; // 최대 응답 길이
}
