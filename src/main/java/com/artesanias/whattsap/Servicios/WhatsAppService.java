package com.artesanias.whattsap.Servicios;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.HashMap;
import java.util.Map;

@Service
public class WhatsAppService {

    @Value("${whatsapp.api-url}")
    private String whatsappApiUrl;

    @Value("${whatsapp.phone-number-id}")
    private String phoneNumberId;

    @Value("${whatsapp.access-token}")
    private String accessToken;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public String sendTextMessage(String phoneNumber, String message) {
        try {
            String url = whatsappApiUrl + "/" + phoneNumberId + "/messages";

            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("messaging_product", "whatsapp");
            requestBody.put("to", formatPhoneNumber(phoneNumber));
            requestBody.put("type", "text");

            Map<String, String> text = new HashMap<>();
            text.put("body", message);
            requestBody.put("text", text);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(accessToken);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);

            if (response.getStatusCode() == HttpStatus.OK) {
                Map<String, Object> responseBody = objectMapper.readValue(response.getBody(), Map.class);
                return ((Map<String, Object>) ((java.util.List) responseBody.get("messages")).get(0)).get("id").toString();
            }

            return null;
        } catch (Exception e) {
            throw new RuntimeException("Error enviando mensaje de WhatsApp: " + e.getMessage());
        }
    }

    public String sendFileMessage(String phoneNumber, String fileUrl, String fileName, String caption) {
        try {
            String url = whatsappApiUrl + "/" + phoneNumberId + "/messages";
            String fileType = getFileType(fileName);

            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("messaging_product", "whatsapp");
            requestBody.put("to", formatPhoneNumber(phoneNumber));
            requestBody.put("type", fileType);

            Map<String, Object> media = new HashMap<>();
            media.put("link", fileUrl);
            if (caption != null && !caption.isEmpty()) {
                media.put("caption", caption);
            }
            requestBody.put(fileType, media);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(accessToken);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);

            if (response.getStatusCode() == HttpStatus.OK) {
                Map<String, Object> responseBody = objectMapper.readValue(response.getBody(), Map.class);
                return ((Map<String, Object>) ((java.util.List) responseBody.get("messages")).get(0)).get("id").toString();
            }

            return null;
        } catch (Exception e) {
            throw new RuntimeException("Error enviando archivo de WhatsApp: " + e.getMessage());
        }
    }

    private String formatPhoneNumber(String phoneNumber) {
        // Remover espacios y caracteres especiales
        phoneNumber = phoneNumber.replaceAll("[^\\d+]", "");

        // Agregar código de país si no existe
        if (!phoneNumber.startsWith("+")) {
            phoneNumber = "+" + phoneNumber;
        }

        return phoneNumber;
    }

    private String getFileType(String fileName) {
        String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();

        switch (extension) {
            case "jpg":
            case "jpeg":
            case "png":
            case "gif":
                return "image";
            case "pdf":
                return "document";
            case "mp4":
            case "avi":
            case "mov":
                return "video";
            case "mp3":
            case "wav":
            case "ogg":
                return "audio";
            default:
                return "document";
        }
    }
}