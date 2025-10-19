package com.autovyn.app.service;

import com.autovyn.app.domain.Item;
import com.autovyn.app.repository.ItemRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.Optional;

@Service
public class ItemService {
    private final ItemRepository itemRepository;
    private final EventPublisher eventPublisher;

    private static final String CACHE_PREFIX = "item:";
    private static final Duration CACHE_TTL = Duration.ofMinutes(10);

    public ItemService(ItemRepository itemRepository, EventPublisher eventPublisher) {
        this.itemRepository = itemRepository;
        this.eventPublisher = eventPublisher;
    }

    public java.util.List<Item> findAll() {
        return itemRepository.findAll();
    }

    public Optional<Item> getById(Long id) {
        return itemRepository.findById(id);
    }

    @Transactional
    public Item create(String name, String description) {
        OffsetDateTime now = OffsetDateTime.now();
        Item item = new Item();
        item.setName(name);
        item.setDescription(description);
        item.setCreatedAt(now);
        item.setUpdatedAt(now);
        Item saved = itemRepository.save(item);
        invalidateCache(saved.getId());
        eventPublisher.publish("item.created", java.util.Map.of(
                "id", saved.getId(),
                "name", saved.getName()
        ));
        return saved;
    }

    @Transactional
    public Optional<Item> update(Long id, String name, String description) {
        return itemRepository.findById(id).map(existing -> {
            existing.setName(name);
            existing.setDescription(description);
            existing.setUpdatedAt(OffsetDateTime.now());
            Item saved = itemRepository.save(existing);
            invalidateCache(id);
            eventPublisher.publish("item.updated", java.util.Map.of(
                    "id", saved.getId(),
                    "name", saved.getName()
            ));
            return saved;
        });
    }

    @Transactional
    public boolean delete(Long id) {
        if (!itemRepository.existsById(id)) return false;
        itemRepository.deleteById(id);
        invalidateCache(id);
        eventPublisher.publish("item.deleted", java.util.Map.of(
                "id", id
        ));
        return true;
    }

    public void invalidateCache(Long id) { }
}


