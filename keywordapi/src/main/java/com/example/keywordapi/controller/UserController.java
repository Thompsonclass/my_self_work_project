package com.example.keywordapi.controller;

import com.example.keywordapi.dto.UserSignupRequest;
import com.example.keywordapi.entity.User;
import com.example.keywordapi.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/signup")
    public ResponseEntity<String> signup(@RequestBody UserSignupRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                                 .body("이미 존재하는 사용자입니다.");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setUid(request.getUid());
        user.setNickname(request.getNickname());
        user.setProvider(request.getProvider());
        LocalDateTime now = LocalDateTime.now();
        user.setCreatedAt(now);
        user.setUpdatedAt(now);

        userRepository.save(user);
        return ResponseEntity.ok("회원가입 완료");
    }
}
