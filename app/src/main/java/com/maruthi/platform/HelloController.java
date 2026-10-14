package com.maruthi.platform;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
public class HelloController {

    @Value("${app.message:Hello from the CI/CD platform sample service}")
    private String message;

    @Value("${app.version:local}")
    private String version;

    @GetMapping("/")
    public Map<String, Object> index() {
        return Map.of(
                "message", message,
                "version", version,
                "timestamp", Instant.now().toString()
        );
    }

    @GetMapping("/api/status")
    public Map<String, Object> status() {
        return Map.of(
                "service", "sample-service",
                "status", "UP",
                "version", version
        );
    }
}
