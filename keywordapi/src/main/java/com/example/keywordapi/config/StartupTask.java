package com.example.keywordapi.config;

import com.example.keywordapi.service.GoalMigrationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
public class StartupTask implements ApplicationRunner {

    @Autowired
    private GoalMigrationService goalMigrationService;

    @Override
    public void run(ApplicationArguments args) {
        goalMigrationService.migrateExpiredGoalsToStatistics();
        System.out.println("앱 시작 시 목표 자동 마이그레이션 완료");
    }
}
