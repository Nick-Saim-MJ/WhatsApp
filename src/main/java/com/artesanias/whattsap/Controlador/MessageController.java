package com.artesanias.whattsap.Controlador;

import com.artesanias.whattsap.DTOs.MessageRequestDto;
import com.artesanias.whattsap.DTOs.MessageResponseDto;
import com.artesanias.whattsap.Servicios.MessageService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

@RestController
@RequestMapping("/api/messages")
@CrossOrigin(origins = "*")
public class MessageController {

    @Autowired
    private MessageService messageService;

    @PostMapping("/send-text")
    public ResponseEntity<MessageResponseDto> sendTextMessage(@Valid @RequestBody MessageRequestDto request) {
        MessageResponseDto response = messageService.sendTextMessage(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/send-with-file")
    public ResponseEntity<MessageResponseDto> sendMessageWithFile(
            @RequestParam("phoneNumber") String phoneNumber,
            @RequestParam(value = "textMessage", required = false) String textMessage,
            @RequestParam("file") MultipartFile file) {

        MessageRequestDto request = new MessageRequestDto(phoneNumber, textMessage);
        MessageResponseDto response = messageService.sendMessageWithFile(request, file);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/history/{phoneNumber}")
    public ResponseEntity<List<MessageResponseDto>> getMessageHistory(@PathVariable String phoneNumber) {
        List<MessageResponseDto> history = messageService.getMessageHistory(phoneNumber);
        return ResponseEntity.ok(history);
    }

    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("WhatsApp Service is running");
    }
}