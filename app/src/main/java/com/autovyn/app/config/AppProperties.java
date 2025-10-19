package com.autovyn.app.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "app")
public class AppProperties {
    private final Gcs gcs = new Gcs();
    private final Pubsub pubsub = new Pubsub();

    public Gcs getGcs() { return gcs; }
    public Pubsub getPubsub() { return pubsub; }

    public static class Gcs {
        private String bucket;
        public String getBucket() { return bucket; }
        public void setBucket(String bucket) { this.bucket = bucket; }
    }

    public static class Pubsub {
        private String topic;
        public String getTopic() { return topic; }
        public void setTopic(String topic) { this.topic = topic; }
    }
}


