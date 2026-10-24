enum MessageSender { user, jx, system }

enum EmotionState { happy, cute, thinking, excited, attentive, playful }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final EmotionState emotion;
  final String? audioPath;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.emotion = EmotionState.happy,
    this.audioPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'emotion': emotion.name,
      'audioPath': audioPath,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      text: map['text'],
      sender: MessageSender.values.firstWhere(
        (e) => e.name == map['sender'],
        orElse: () => MessageSender.jx,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      emotion: EmotionState.values.firstWhere(
        (e) => e.name == map['emotion'],
        orElse: () => EmotionState.happy,
      ),
      audioPath: map['audioPath'],
    );
  }
}
