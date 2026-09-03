package com.mecaniqa.cloud.controller;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class StatusController {

    private final JdbcTemplate jdbcTemplate;
    private final StringRedisTemplate redisTemplate;

    public StatusController(JdbcTemplate jdbcTemplate, StringRedisTemplate redisTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.redisTemplate = redisTemplate;
    }

    @GetMapping("/status")
    public Map<String, String> status() {
        Map<String, String> response = new LinkedHashMap<>();
        response.put("application", "MecaniQA Cloud");
        response.put("status", "UP");
        return response;
    }

    @GetMapping("/dependencies")
    public Map<String, String> dependencies() {
        Map<String, String> response = new LinkedHashMap<>();

        Integer mysqlResult = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
        response.put("mysql", mysqlResult != null && mysqlResult == 1 ? "UP" : "DOWN");

        redisTemplate.opsForValue().set("mecaniqa:health", "UP");
        String redisResult = redisTemplate.opsForValue().get("mecaniqa:health");
        response.put("redis", "UP".equals(redisResult) ? "UP" : "DOWN");

        return response;
    }
}
