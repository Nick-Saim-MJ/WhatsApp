class MessageResponse {
  final int id;
  final String phoneNumber;
  final String? textMessage;
  final String? fileUrl;
  final String status;
  final String? whatsappMessageId;
  final String message;

  MessageResponse({
    required this.id,
    required this.phoneNumber,
    this.textMessage,
    this.fileUrl,
    required this.status,
    this.whatsappMessageId,
    required this.message,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      id: json['id'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      textMessage: json['textMessage'],
      fileUrl: json['fileUrl'],
      status: json['status'] ?? 'UNKNOWN',
      whatsappMessageId: json['whatsappMessageId'],
      message: json['message'] ?? '',
    );
  }
}