package com.autovyn.app.web;

import com.autovyn.app.service.GcsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.net.URL;
import java.time.Duration;
import java.util.Map;

@RestController
@RequestMapping("/v1/files")
public class FileController {
    private final GcsService gcsService;

    public FileController(GcsService gcsService) {
        this.gcsService = gcsService;
    }

    @PostMapping(consumes = { "multipart/form-data" })
    public ResponseEntity<Map<String, Object>> upload(@RequestPart("file") MultipartFile file) {
        if (!gcsService.isConfigured()) {
            return ResponseEntity.status(501).body(Map.of("error", "GCS not configured"));
        }
        String objectName = "uploads/" + System.currentTimeMillis() + "_" + file.getOriginalFilename();
        gcsService.upload(file, objectName);
        return ResponseEntity.ok(Map.of("object", objectName));
    }

    @GetMapping("/signed-url")
    public ResponseEntity<Map<String, Object>> signedUrl(@RequestParam("object") String object) {
        if (!gcsService.isConfigured()) {
            return ResponseEntity.status(501).body(Map.of("error", "GCS not configured"));
        }
        URL url = gcsService.signUrl(object, Duration.ofMinutes(15));
        return ResponseEntity.ok(Map.of("url", url.toString()));
    }
}


