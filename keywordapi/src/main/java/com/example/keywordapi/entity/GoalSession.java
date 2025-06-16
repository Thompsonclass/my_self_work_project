package com.example.keywordapi.entity;

import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "goal_sessions")
public class GoalSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    @JsonIgnore 
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "goal_id")
    private UserGoal userGoal;
    
    @Column(name = "is_completed")
    private Boolean isCompleted = false;


    private String sessionDay;
    private String dailyGoalDetail;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    @Column(name = "session_date")
    private LocalDate sessionDate;
    @Column(columnDefinition = "TEXT")
    private String tip;


    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public UserGoal getUserGoal() { return userGoal; }
    public void setUserGoal(UserGoal userGoal) { this.userGoal = userGoal; }

    public String getSessionDay() { return sessionDay; }
    public void setSessionDay(String sessionDay) { this.sessionDay = sessionDay; }

    public String getDailyGoalDetail() { return dailyGoalDetail; }
    public void setDailyGoalDetail(String dailyGoalDetail) { this.dailyGoalDetail = dailyGoalDetail; }

    @JsonProperty("isComplete")
    public Boolean getIsCompleted() { return isCompleted; }
    public void setIsCompleted(Boolean isCompleted) { this.isCompleted = isCompleted; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public LocalDate getSessionDate() {  return sessionDate;   }
    public void setSessionDate(LocalDate sessionDate) { this.sessionDate = sessionDate; }
    
    public String getTip() {return tip;    }
    public void setTip(String tip) { this.tip = tip;}

}
