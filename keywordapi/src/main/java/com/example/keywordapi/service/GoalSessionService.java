package com.example.keywordapi.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.keywordapi.entity.GoalSession;
import com.example.keywordapi.repository.GoalSessionRepository;

@Service
public class GoalSessionService {

    @Autowired
    private GoalSessionRepository goalSessionRepository;

    public void updateSessionContent(Long id, String dailyGoalDetail, String tip, Boolean isComplete) {
        GoalSession session = goalSessionRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("세션 ID가 존재하지 않습니다."));

        session.setDailyGoalDetail(dailyGoalDetail);
        session.setTip(tip);
        if (isComplete != null) {
            session.setIsCompleted(isComplete);
        }

        goalSessionRepository.save(session);
    }

}
