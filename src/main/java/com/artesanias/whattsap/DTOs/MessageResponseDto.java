package com.artesanias.whattsap.DTOs;

import com.artesanias.whattsap.Model.MessageStatus;

public class MessageResponseDto {
    private Long id;
    private String phoneNumber;
    private String textMessage;
    private String fileUrl;
    private MessageStatus status;
    private String whatsappMessageId;
    private String message;

    // Constructores
    public MessageResponseDto() {}

    public MessageResponseDto(Long id, String phoneNumber, MessageStatus status, String message) {
        this.id = id;
        this.phoneNumber = phoneNumber;
        this.status = status;
        this.message = message;
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getTextMessage() { return textMessage; }
    public void setTextMessage(String textMessage) { this.textMessage = textMessage; }

    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }

    public MessageStatus getStatus() { return status; }
    public void setStatus(MessageStatus status) { this.status = status; }

    public String getWhatsappMessageId() { return whatsappMessageId; }
    public void setWhatsappMessageId(String whatsappMessageId) { this.whatsappMessageId = whatsappMessageId; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
