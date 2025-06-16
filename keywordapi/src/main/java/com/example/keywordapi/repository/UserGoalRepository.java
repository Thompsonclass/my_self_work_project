package com.example.keywordapi.repository;

import com.example.keywordapi.entity.User;
import com.example.keywordapi.entity.UserGoal;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserGoalRepository extends JpaRepository<UserGoal, Long> {
	boolean existsByUser(User user);
}
