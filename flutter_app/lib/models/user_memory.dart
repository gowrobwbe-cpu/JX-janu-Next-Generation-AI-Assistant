class UserMemory {
  final int? id;
  final String key;
  final String value;
  final String category;
  final DateTime updatedAt;

  UserMemory({
    this.id,
    required this.key,
    required this.value,
    this.category = 'general',
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'category': category,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserMemory.fromMap(Map<String, dynamic> map) {
    return UserMemory(
      id: map['id'],
      key: map['key'],
      value: map['value'],
      category: map['category'] ?? 'general',
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
