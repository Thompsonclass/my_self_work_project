// UserGoalController.java
package com.example.keywordapi.controller;

import com.example.keywordapi.entity.GoalSession;
import com.example.keywordapi.entity.User;
import com.example.keywordapi.entity.UserGoal;
import com.example.keywordapi.repository.UserGoalRepository;
import com.example.keywordapi.repository.UserRepository;
import com.example.keywordapi.service.GoalMigrationService;
import com.example.keywordapi.service.GptService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.*;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/goals")
public class UserGoalController {

    @Autowired
    private UserGoalRepository userGoalRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private GptService gptService;
    
    @Autowired
    private GoalMigrationService goalMigrationService;

    @PostMapping("/init")
    public ResponseEntity<?> initGoal(@RequestBody Map<String, Object> payload) {
        String email = (String) payload.get("email");
        String category = (String) payload.get("category");
        String keyword = (String) payload.get("keyword");
        String period = (String) payload.get("period");
        Number spw = (Number) payload.get("sessionsPerWeek");

        if (email == null || category == null || keyword == null || period == null || spw == null) {
            return ResponseEntity.badRequest().body("모든 필드를 입력해야 합니다.");
        }

        Map<String, Object> temp = new HashMap<>();
        temp.put("email", email);
        temp.put("category", category);
        temp.put("keyword", keyword);
        temp.put("period", period);
        temp.put("sessionsPerWeek", spw.intValue());

        return ResponseEntity.ok(temp);
    }

    @PostMapping("/migrate")
    public ResponseEntity<String> migrateExpiredGoalsToStatistics() {
        goalMigrationService.migrateExpiredGoalsToStatistics();
        return ResponseEntity.ok("종료된 목표를 통계 테이블로 이동 완료");
    }
    
    @GetMapping("/exists")
    public ResponseEntity<Boolean> doesUserHaveGoal(@RequestParam String email) {
        User user = userRepository.findByEmail(email);
        if (user == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(false);

        boolean hasGoal = userGoalRepository.existsByUser(user);
        return ResponseEntity.ok(hasGoal);
    }

    
    @PostMapping("/finalize")
    public ResponseEntity<?> finalizeGoal(@RequestBody Map<String, Object> payload) {
        try {
            String email = (String) payload.get("email");
            User user = userRepository.findByEmail(email);
            if (user == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("유저가 존재하지 않습니다.");
            }

            String category = (String) payload.get("category");
            String keyword = (String) payload.get("keyword");
            String period = (String) payload.get("period");
            int sessionsPerWeek = ((Number) payload.get("sessionsPerWeek")).intValue();
            List<String> selectedDays = (List<String>) payload.get("selectedDays");
            String startDateStr = LocalDate.now().toString();

            String gptResponse = gptService.sendChatMessage(category, keyword, period, sessionsPerWeek, selectedDays, startDateStr);
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(gptResponse);
            String contentRaw = root.get("choices").get(0).get("message").get("content").asText();
            JsonNode parsedContent = mapper.readTree(contentRaw);

            Map<String, LocalDate> dateMap = computeDateMap(selectedDays, LocalDate.parse(startDateStr));

            UserGoal goal = new UserGoal();
            goal.setUser(user);
            goal.setCategory(category);
            goal.setKeyword(keyword);
            goal.setPeriod(period);
            goal.setSessionsPerWeek(sessionsPerWeek);
            goal.setCreatedAt(LocalDateTime.now());
            goal.setUpdatedAt(LocalDateTime.now());

            for (String weekKey : iterable(parsedContent.fieldNames())) {
                if (!weekKey.endsWith("주차")) continue;

                JsonNode weekNode = parsedContent.get(weekKey);
                for (String day : selectedDays) {
                    String label = day + "요일";
                    if (weekNode.has(label)) {
                        JsonNode node = weekNode.get(label);
                        GoalSession session = new GoalSession();
                        session.setUserGoal(goal);
                        session.setSessionDay(day);
                        session.setDailyGoalDetail(node.get("계획").asText());
                        session.setTip(node.has("팁") ? node.get("팁").asText() : null);
                        session.setSessionDate(LocalDate.parse(node.get("날짜").asText()));
                        session.setIsCompleted(false);
                        session.setCreatedAt(LocalDateTime.now());
                        session.setUpdatedAt(LocalDateTime.now());
                        goal.getGoalSessions().add(session);
                    }
                }
            }

            UserGoal saved = userGoalRepository.save(goal);
            return new ResponseEntity<>(saved, HttpStatus.CREATED);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("오류 발생: " + e.getMessage());
        }
    }

    private static Iterable<String> iterable(Iterator<String> it) {
        return () -> it;
    }

    private Map<String, LocalDate> computeDateMap(List<String> daysKor, LocalDate startDate) {
        Map<String, DayOfWeek> korToDay = Map.of(
                "월", DayOfWeek.MONDAY,
                "화", DayOfWeek.TUESDAY,
                "수", DayOfWeek.WEDNESDAY,
                "목", DayOfWeek.THURSDAY,
                "금", DayOfWeek.FRIDAY,
                "토", DayOfWeek.SATURDAY,
                "일", DayOfWeek.SUNDAY
        );

        Map<String, LocalDate> result = new HashMap<>();
        for (String korDay : daysKor) {
            DayOfWeek target = korToDay.get(korDay);
            LocalDate next = startDate.with(TemporalAdjusters.nextOrSame(target));
            result.put(korDay, next);
        }
        return result;
    }
    
    @GetMapping("/sessions")
    public ResponseEntity<?> getSessions(@RequestParam("email") String email) {
        User user = userRepository.findByEmail(email);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("유저가 존재하지 않습니다.");
        }
        List<GoalSession> sessions = user.getUserGoals().stream()
            .flatMap(g -> g.getGoalSessions().stream())
            .collect(Collectors.toList());

        return ResponseEntity.ok(sessions);
    }
}
