package com.example.keywordapi.repository;

import com.example.keywordapi.entity.GoalStatistics;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface GoalStatisticsRepository extends JpaRepository<GoalStatistics, Long> {
    List<GoalStatistics> findByUserEmail(String userEmail);
}
