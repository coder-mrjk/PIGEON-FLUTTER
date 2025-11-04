class UIChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? senderName;

  const UIChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.senderName,
  });
}
