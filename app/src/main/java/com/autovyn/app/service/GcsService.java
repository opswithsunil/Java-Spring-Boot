package com.autovyn.app.service;

import com.autovyn.app.config.AppProperties;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.HttpMethod;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.net.URL;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

@Service
public class GcsService {
    private final Storage storage;
    private final String bucket;

    public GcsService(AppProperties props) {
        this.storage = StorageOptions.getDefaultInstance().getService();
        this.bucket = props.getGcs().getBucket();
    }

    public boolean isConfigured() {
        return bucket != null && !bucket.isBlank();
    }

    public String upload(MultipartFile file, String objectName) {
        try {
            if (!isConfigured()) throw new IllegalStateException("GCS bucket not configured");
            BlobId blobId = BlobId.of(bucket, objectName);
            BlobInfo blobInfo = BlobInfo.newBuilder(blobId).build();
            storage.create(blobInfo, file.getBytes());
            return objectName;
        } catch (Exception e) {
            throw new RuntimeException("GCS upload failed", e);
        }
    }

    public URL signUrl(String objectName, Duration ttl) {
        if (!isConfigured()) throw new IllegalStateException("GCS bucket not configured");
        BlobInfo blobInfo = BlobInfo.newBuilder(BlobId.of(bucket, objectName)).build();
        Map<String, String> extHeaders = new HashMap<>();
        return storage.signUrl(blobInfo, ttl.toSeconds(), java.util.concurrent.TimeUnit.SECONDS, Storage.SignUrlOption.httpMethod(HttpMethod.GET), Storage.SignUrlOption.withExtHeaders(extHeaders));
    }
}


