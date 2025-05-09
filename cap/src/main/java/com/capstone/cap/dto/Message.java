package com.capstone.cap.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


/**
 * GPT 메시지 포맷 클래스
 * role: system, user, assistant 중 하나
 * content: 해당 메시지 내용
 */

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Message {

    private String role; // 메시지 역할 (system, user, assistant)
    private String content;  // 메시지 내용

}