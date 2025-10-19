package com.autovyn.app.service;

import com.autovyn.app.config.AppProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.api.core.ApiFuture;
import com.google.cloud.pubsub.v1.Publisher;
import com.google.protobuf.ByteString;
import com.google.pubsub.v1.TopicName;
import com.google.pubsub.v1.PubsubMessage;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.util.Map;

@Component
public class EventPublisher {
    private final AppProperties props;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public EventPublisher(AppProperties props) {
        this.props = props;
    }

    public void publish(String eventType, Map<String, Object> payload) {
        String topicResource = props.getPubsub().getTopic();
        if (topicResource == null || topicResource.isBlank()) return;
        try {
            String json = objectMapper.writeValueAsString(payload);
            ByteString data = ByteString.copyFrom(json, StandardCharsets.UTF_8);
            Publisher publisher = Publisher.newBuilder(topicResource).build();
            PubsubMessage message = PubsubMessage.newBuilder()
                    .putAttributes("type", eventType)
                    .setData(data)
                    .build();
            ApiFuture<String> messageIdFuture = publisher.publish(message);
            messageIdFuture.get();
            publisher.shutdown();
        } catch (Exception ignored) {
        }
    }
}


