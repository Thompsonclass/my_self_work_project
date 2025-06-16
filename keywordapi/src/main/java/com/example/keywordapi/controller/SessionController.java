package com.example.keywordapi.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.keywordapi.service.GoalSessionService;

@RestController
@RequestMapping("/api/sessions")
public class SessionController {

    @Autowired
    private GoalSessionService goalSessionService;

    @PutMapping("/update")
    public ResponseEntity<?> updateSession(@RequestBody Map<String, Object> payload) {
        try {
            Long id = Long.parseLong(payload.get("id").toString());
            String dailyGoalDetail = payload.get("dailyGoalDetail") != null ? payload.get("dailyGoalDetail").toString() : "";
            String tip = payload.get("tip") != null ? payload.get("tip").toString() : null;

            Boolean isComplete = null;
            if (payload.containsKey("isComplete")) {
                isComplete = Boolean.parseBoolean(payload.get("isComplete").toString());
            }


            goalSessionService.updateSessionContent(id, dailyGoalDetail, tip, isComplete);
            return ResponseEntity.ok("세션이 성공적으로 업데이트되었습니다.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("업데이트 실패: " + e.getMessage());
        }
    }


}
