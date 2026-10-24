enum ActionRiskLevel {
  safe,
  userConfirmation,
  highRisk,
}

enum ActionExecutionStatus {
  idle,
  understanding,
  executing,
  completed,
  failed,
}

class AndroidToolDefinition {
  final String name;
  final String displayName;
  final String description;
  final String requiredPermission;
  final ActionRiskLevel riskLevel;
  final Map<String, dynamic> parameterSchema;

  const AndroidToolDefinition({
    required this.name,
    required this.displayName,
    required this.description,
    required this.requiredPermission,
    required this.riskLevel,
    required this.parameterSchema,
  });
}

class AndroidToolCall {
  final String toolName;
  final Map<String, dynamic> arguments;
  final String? callId;

  AndroidToolCall({
    required this.toolName,
    required this.arguments,
    this.callId,
  });

  factory AndroidToolCall.fromJson(Map<String, dynamic> json) {
    return AndroidToolCall(
      toolName: json['tool'] ?? json['toolName'] ?? json['name'] ?? '',
      arguments: (json['arguments'] as Map<String, dynamic>?) ?? 
                 (json['args'] as Map<String, dynamic>?) ?? {},
      callId: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'tool': toolName,
    'arguments': arguments,
    if (callId != null) 'id': callId,
  };
}

class AndroidToolResult {
  final bool success;
  final String toolName;
  final String message;
  final dynamic data;
  final String? errorMessage;
  final DateTime timestamp;

  AndroidToolResult({
    required this.success,
    required this.toolName,
    required this.message,
    this.data,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'success': success,
    'tool': toolName,
    'result': message,
    if (data != null) 'data': data,
    if (errorMessage != null) 'error': errorMessage,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ActionHUDState {
  final ActionExecutionStatus status;
  final String actionTitle;
  final String actionDetail;
  final String? subMessage;
  final DateTime timestamp;

  ActionHUDState({
    required this.status,
    required this.actionTitle,
    required this.actionDetail,
    this.subMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  static ActionHUDState idle() => ActionHUDState(
    status: ActionExecutionStatus.idle,
    actionTitle: '',
    actionDetail: '',
  );
}
