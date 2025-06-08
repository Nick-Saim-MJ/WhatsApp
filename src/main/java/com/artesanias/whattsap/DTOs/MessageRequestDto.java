package com.artesanias.whattsap.DTOs;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;


public class MessageRequestDto {
    @NotBlank(message = "El número de teléfono es obligatorio")
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Número de teléfono inválido")
    private String phoneNumber;

    private String textMessage;

    // Constructores
    public MessageRequestDto() {}

    public MessageRequestDto(String phoneNumber, String textMessage) {
        this.phoneNumber = phoneNumber;
        this.textMessage = textMessage;
    }

    // Getters y Setters
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getTextMessage() { return textMessage; }
    public void setTextMessage(String textMessage) { this.textMessage = textMessage; }
}