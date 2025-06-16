// GoalStatisticsController.java
package com.example.keywordapi.controller;

import com.example.keywordapi.entity.GoalStatistics;
import com.example.keywordapi.repository.GoalStatisticsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/statistics")
public class GoalStatisticsController {

    @Autowired
    private GoalStatisticsRepository goalStatisticsRepository;

    @GetMapping
    public ResponseEntity<List<GoalStatistics>> getStatistics(@RequestParam("email") String email) {
        List<GoalStatistics> stats = goalStatisticsRepository.findByUserEmail(email);
        return ResponseEntity.ok(stats);
    }
}
