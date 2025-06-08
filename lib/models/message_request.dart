class MessageRequest {
  final String phoneNumber;
  final String? textMessage;

  MessageRequest({
    required this.phoneNumber,
    this.textMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'textMessage': textMessage,
    };
  }
}