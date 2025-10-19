package com.autovyn.app.web;

import com.autovyn.app.domain.Item;
import com.autovyn.app.service.ItemService;
import com.autovyn.app.web.dto.ItemRequest;
import com.autovyn.app.web.dto.ItemResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/v1/items")
public class ItemController {
    private final ItemService itemService;

    public ItemController(ItemService itemService) {
        this.itemService = itemService;
    }

    @GetMapping
    public List<ItemResponse> list() {
        return itemService.findAll().stream().map(this::toResponse).collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ItemResponse> get(@PathVariable("id") Long id) {
        Optional<Item> item = itemService.getById(id);
        return item.map(this::toResponse)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    @PostMapping
    public ResponseEntity<ItemResponse> create(@Valid @RequestBody ItemRequest request) {
        Item item = itemService.create(request.getName(), request.getDescription());
        ItemResponse response = toResponse(item);
        return ResponseEntity.created(URI.create("/v1/items/" + item.getId())).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ItemResponse> update(@PathVariable("id") Long id, @Valid @RequestBody ItemRequest request) {
        Optional<Item> updated = itemService.update(id, request.getName(), request.getDescription());
        return updated.map(this::toResponse)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") Long id) {
        boolean deleted = itemService.delete(id);
        return deleted ? ResponseEntity.noContent().build() : ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }

    private ItemResponse toResponse(Item item) {
        ItemResponse r = new ItemResponse();
        r.setId(item.getId());
        r.setName(item.getName());
        r.setDescription(item.getDescription());
        r.setCreatedAt(item.getCreatedAt());
        r.setUpdatedAt(item.getUpdatedAt());
        return r;
    }
}


