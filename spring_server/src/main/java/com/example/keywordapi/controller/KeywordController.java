package com.example.keywordapi.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@CrossOrigin(origins = "*") // Flutter 웹 요청 허용
public class KeywordController {

    @PostMapping("/keywords")
    public ResponseEntity<Map<String, Object>> receiveKeywords(@RequestBody Map<String, List<String>> payload) {
        List<String> keywords = payload.get("keywords");

        Map<String, Object> result = new HashMap<>();
        result.put("receivedCount", keywords.size());
        result.put("response", "총 " + keywords.size() + "개의 키워드를 받았습니다!");

        return ResponseEntity.ok(result);
    }
}
