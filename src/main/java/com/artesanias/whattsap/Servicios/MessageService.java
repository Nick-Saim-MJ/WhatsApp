package com.artesanias.whattsap.Servicios;


import com.artesanias.whattsap.DTOs.MessageRequestDto;
import com.artesanias.whattsap.DTOs.MessageResponseDto;
import com.artesanias.whattsap.Model.Message;
import com.artesanias.whattsap.Model.MessageStatus;
import com.artesanias.whattsap.Repositorio.MessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MessageService {

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private CloudinaryService cloudinaryService;

    @Autowired
    private WhatsAppService whatsAppService;

    public MessageResponseDto sendTextMessage(MessageRequestDto request) {
        try {
            // Crear el mensaje en la base de datos
            Message message = new Message(request.getPhoneNumber(), request.getTextMessage());
            message = messageRepository.save(message);

            // Enviar el mensaje por WhatsApp
            String whatsappMessageId = whatsAppService.sendTextMessage(
                    request.getPhoneNumber(),
                    request.getTextMessage()
            );

            // Actualizar el mensaje con el ID de WhatsApp
            message.setWhatsappMessageId(whatsappMessageId);
            message.setStatus(MessageStatus.SENT);
            message = messageRepository.save(message);

            return new MessageResponseDto(
                    message.getId(),
                    message.getPhoneNumber(),
                    MessageStatus.SENT,
                    "Mensaje enviado exitosamente"
            );

        } catch (Exception e) {
            // Manejar error
            return handleError(request.getPhoneNumber(), e.getMessage());
        }
    }

    public MessageResponseDto sendMessageWithFile(MessageRequestDto request, MultipartFile file) {
        try {
            // Crear el mensaje en la base de datos
            Message message = new Message(request.getPhoneNumber(), request.getTextMessage());
            message.setFileName(file.getOriginalFilename());
            message.setFileType(file.getContentType());
            message = messageRepository.save(message);

            // Subir archivo a Cloudinary
            String fileUrl = cloudinaryService.uploadFile(file);
            message.setFileUrl(fileUrl);
            message = messageRepository.save(message);

            // Enviar archivo por WhatsApp
            String whatsappMessageId = whatsAppService.sendFileMessage(
                    request.getPhoneNumber(),
                    fileUrl,
                    file.getOriginalFilename(),
                    request.getTextMessage()
            );

            // Actualizar el mensaje con el ID de WhatsApp
            message.setWhatsappMessageId(whatsappMessageId);
            message.setStatus(MessageStatus.SENT);
            message = messageRepository.save(message);

            MessageResponseDto response = new MessageResponseDto(
                    message.getId(),
                    message.getPhoneNumber(),
                    MessageStatus.SENT,
                    "Mensaje con archivo enviado exitosamente"
            );
            response.setFileUrl(fileUrl);

            return response;

        } catch (Exception e) {
            return handleError(request.getPhoneNumber(), e.getMessage());
        }
    }

    public List<MessageResponseDto> getMessageHistory(String phoneNumber) {
        List<Message> messages = messageRepository.findByPhoneNumberOrderByCreatedAtDesc(phoneNumber);

        return messages.stream().map(message -> {
            MessageResponseDto dto = new MessageResponseDto();
            dto.setId(message.getId());
            dto.setPhoneNumber(message.getPhoneNumber());
            dto.setTextMessage(message.getTextMessage());
            dto.setFileUrl(message.getFileUrl());
            dto.setStatus(message.getStatus());
            dto.setWhatsappMessageId(message.getWhatsappMessageId());
            return dto;
        }).collect(Collectors.toList());
    }

    private MessageResponseDto handleError(String phoneNumber, String errorMessage) {
        Message message = new Message(phoneNumber, null);
        message.setStatus(MessageStatus.FAILED);
        message.setErrorMessage(errorMessage);
        messageRepository.save(message);

        return new MessageResponseDto(
                message.getId(),
                phoneNumber,
                MessageStatus.FAILED,
                "Error: " + errorMessage
        );
    }
}