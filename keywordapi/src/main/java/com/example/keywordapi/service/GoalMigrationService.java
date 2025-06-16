package com.example.keywordapi.service;

import com.example.keywordapi.entity.GoalSession;
import com.example.keywordapi.entity.GoalStatistics;
import com.example.keywordapi.entity.UserGoal;
import com.example.keywordapi.repository.GoalStatisticsRepository;
import com.example.keywordapi.repository.UserGoalRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class GoalMigrationService {

    @Autowired
    private GoalStatisticsRepository goalStatisticsRepository;

    @Autowired
    private UserGoalRepository userGoalRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Transactional
    public void migrateExpiredGoalsToStatistics() {
        List<UserGoal> expiredGoals = userGoalRepository.findAll().stream()
                .filter(goal -> goal.getGoalSessions().stream()
                        .map(GoalSession::getSessionDate)
                        .max(LocalDate::compareTo)
                        .orElse(LocalDate.MIN)
                        .isBefore(LocalDate.now()))
                .toList();

        for (UserGoal goal : expiredGoals) {
            GoalStatistics stat = new GoalStatistics();
            stat.setUserEmail(goal.getUser().getEmail());
            stat.setCategory(goal.getCategory());
            stat.setKeyword(goal.getKeyword());
            stat.setCreatedAt(goal.getCreatedAt());
            stat.setCompletedAt(goal.getGoalSessions().stream()
                    .map(GoalSession::getSessionDate)
                    .max(LocalDate::compareTo)
                    .orElse(LocalDate.now())
                    .atStartOfDay());

            try {
                List<Map<String, Object>> sessionList = goal.getGoalSessions().stream().map(session -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("sessionDate", session.getSessionDate().toString());
                    map.put("sessionDay", session.getSessionDay());
                    map.put("dailyGoalDetail", session.getDailyGoalDetail());
                    map.put("tip", session.getTip());
                    map.put("isCompleted", session.getIsCompleted());
                    return map;
                }).toList();

                String json = objectMapper.writeValueAsString(sessionList);
                stat.setSessionsJson(json);
            } catch (Exception e) {
                e.printStackTrace();
                continue;
            }

            goalStatisticsRepository.save(stat);
            userGoalRepository.delete(goal);
        }
    }
}
