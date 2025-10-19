package com.autovyn.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class AutovynApplication {
    public static void main(String[] args) {
        SpringApplication.run(AutovynApplication.class, args);
    }
}


