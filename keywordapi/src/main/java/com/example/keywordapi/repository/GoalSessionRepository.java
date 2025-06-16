package com.example.keywordapi.repository;

import com.example.keywordapi.entity.GoalSession;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GoalSessionRepository extends JpaRepository<GoalSession, Long> {
}