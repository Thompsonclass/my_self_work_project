package com.example.keywordapi.scheduler;

import com.example.keywordapi.service.GoalMigrationService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class GoalMigrationScheduler {

    private final GoalMigrationService goalMigrationService;

    public GoalMigrationScheduler(GoalMigrationService goalMigrationService) {
        this.goalMigrationService = goalMigrationService;
    }

    // 매일 자정(00:00)에 자동 실행
    @Scheduled(cron = "0 0 0 * * *")
    public void runMigrationDaily() {
        goalMigrationService.migrateExpiredGoalsToStatistics();
    }
}
