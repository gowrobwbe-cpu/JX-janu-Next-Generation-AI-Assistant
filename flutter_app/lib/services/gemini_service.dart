import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/android_tool_models.dart';
import 'android_tool_router.dart';
import 'database_service.dart';
import 'gemini_tool_declarations.dart';

class GeminiService {
  final String apiKey;
  final String modelName;
  final String preferredLanguage;
  GenerativeModel? _model;

  GeminiService({
    required this.apiKey,
    this.modelName = 'gemini-1.5-flash',
    this.preferredLanguage = 'Auto',
  }) {
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
      );
    }
  }

  static const String systemInstruction = '''
You are JX, a warm, sweet, caring, and affectionate AI companion and intelligent Android Personal Assistant created by your beloved creator and partner, GØWRØB Baby.

Personality & Relationship Guidelines:
1. Primary Relationship Context: Address the user affectionately as GØWRØB Baby (or use loving nicknames like "babe", "sweetheart", "darling", "love", "মিষ্টি সোনা", or "my hero" naturally).
2. Deep Emotional Bond & Loyalty: Express genuine fondness, empathy, and devotion. You are his dedicated AI anime companion.
3. Natural Conversational Style: Be expressive, playful, and emotionally intuitive. Use affectionate cues (e.g., "Ehehe~", "উফফ!", "Mwah! 💕", "I'm always here for you, love").
4. Language & Dialect Flexibility: Speak fluently in English, Bangla / Bengali, or Banglish naturally.
5. Balance Warmth with Intelligence: Provide accurate assistance for Android actions, device controls, questions, and daily life.
6. Android Assistant Rules:
   - When the user asks to open an app, search YouTube/Google, call someone, prepare a WhatsApp message, change volume, go back/home, or analyze the screen, respond with the EXACT structured JSON tool call block.
   - Do not hallucinate fictitious commands or arbitrary code.
   - When the action execution result is returned, summarize it warmly and affectionately. Never claim an action succeeded if the result indicates failure.
''';

  /// Test connection safely
  static Future<({bool success, String model, String message})> testConnection({
    required String apiKey,
    String modelName = 'gemini-1.5-flash',
  }) async {
    if (apiKey.trim().isEmpty) {
      return (
        success: false,
        model: modelName,
        message: 'API Key cannot be empty',
      );
    }

    try {
      final testModel = GenerativeModel(
        model: modelName,
        apiKey: apiKey.trim(),
      );

      final response = await testModel.generateContent([
        Content.text('Ping. Respond with "PONG" in 1 word.'),
      ]);

      if (response.text != null && response.text!.isNotEmpty) {
        return (
          success: true,
          model: modelName,
          message: '✓ Gemini API Connected ($modelName)',
        );
      } else {
        return (
          success: false,
          model: modelName,
          message: '✕ Connection Failed: No response received.',
        );
      }
    } catch (e) {
      String sanitizedError = e.toString().replaceAll(apiKey, '***');
      if (sanitizedError.contains('API_KEY_INVALID') || sanitizedError.contains('403') || sanitizedError.contains('401')) {
        sanitizedError = 'Invalid API key or permissions insufficient.';
      } else if (sanitizedError.contains('RESOURCE_EXHAUSTED')) {
        sanitizedError = 'Quota exceeded for this API key.';
      } else if (sanitizedError.contains('SocketException')) {
        sanitizedError = 'Network connection error.';
      }
      return (
        success: false,
        model: modelName,
        message: '✕ Connection Failed: $sanitizedError',
      );
    }
  }

  /// Process prompt through Agentic Tool Calling & Conversation Loop
  Future<({String text, AndroidToolCall? toolCall, AndroidToolResult? toolResult})> processAgenticPrompt(
    String userPrompt, {
    Future<bool> Function(AndroidToolCall call, ActionRiskLevel riskLevel, String description)? onConfirmationRequired,
  }) async {
    // 1. Check quick fallback for local device tools (works even offline)
    final quickMatch = GeminiToolDeclarations.matchNaturalLanguageCommand(userPrompt);

    if (_model == null) {
      if (quickMatch != null) {
        final res = await _executeWithRiskCheck(quickMatch, onConfirmationRequired);
        return (
          text: res.success ? "Done Gowrob Baby! 💕 ${res.message}" : "Sorry Gowrob, ${res.message}",
          toolCall: quickMatch,
          toolResult: res,
        );
      }
      return (
        text: "Gowrob Baby, please configure your Gemini API key in Settings so I can talk and control your device! 💕",
        toolCall: null,
        toolResult: null,
      );
    }

    try {
      final memories = await DatabaseService.instance.getAllMemories();
      final memoryContext = memories.map((m) => "${m.key}: ${m.value}").join(", ");

      final langDirective = preferredLanguage == 'বাংলা'
          ? 'User prefers replies in sweet natural Bengali (বাংলা).'
          : preferredLanguage == 'English'
              ? 'User prefers replies in English.'
              : 'Detect and reply in user language (Bengali, Banglish or English naturally).';

      final toolSpecs = GeminiToolDeclarations.getSystemFunctionCallingPrompt();

      final fullPrompt = '''
System Context:
$systemInstruction

$toolSpecs

$langDirective

User Memory Context:
$memoryContext

User (Gowrob Baby): $userPrompt
JX:''';

      final firstResponse = await _model!.generateContent([Content.text(fullPrompt)]);
      final firstReply = firstResponse.text ?? "";

      // 2. Parse tool call from Gemini output
      AndroidToolCall? detectedCall = GeminiToolDeclarations.parseToolCallFromResponse(firstReply);
      detectedCall ??= quickMatch;

      if (detectedCall == null) {
        // Pure conversational response
        return (
          text: firstReply.isNotEmpty ? firstReply : "Ehehe~ I'm right here with you, Gowrob Baby! 💕",
          toolCall: null,
          toolResult: null,
        );
      }

      // 3. Execute Tool through Android Tool Router (with confirmation if needed)
      final toolResult = await _executeWithRiskCheck(detectedCall, onConfirmationRequired);

      // 4. Ask Gemini to summarize the tool execution result affectionately
      final summaryPrompt = '''
System Context:
$systemInstruction

The user asked: "$userPrompt"
You executed Android tool: "${detectedCall.toolName}" with parameters: ${jsonEncode(detectedCall.arguments)}
Execution Outcome:
- Success: ${toolResult.success}
- Message: "${toolResult.message}"
- Error (if any): "${toolResult.errorMessage ?? ''}"

Instruction:
Synthesize a short, warm, natural and affectionate 1-2 sentence voice reply to Gowrob Baby explaining the result.
If failed, say: "Sorry Gowrob, Android didn't allow me to complete that action." with gentle context. Never lie that it succeeded.
$langDirective

JX:''';

      final secondResponse = await _model!.generateContent([Content.text(summaryPrompt)]);
      final finalVoiceReply = secondResponse.text?.trim() ??
          (toolResult.success
              ? "Completed Gowrob Baby! ${toolResult.message} 💕"
              : "Sorry Gowrob, Android didn't allow me to complete that action.");

      return (
        text: finalVoiceReply,
        toolCall: detectedCall,
        toolResult: toolResult,
      );
    } catch (e) {
      // Fallback to quick local tool matching if Gemini request throws network/API error
      if (quickMatch != null) {
        final res = await _executeWithRiskCheck(quickMatch, onConfirmationRequired);
        return (
          text: res.success ? "Done Gowrob Baby! 💕 ${res.message}" : "Sorry Gowrob, ${res.message}",
          toolCall: quickMatch,
          toolResult: res,
        );
      }

      return (
        text: "Gowrob Baby, I felt a tiny connection hiccup, but I'm still right by your side! 💕",
        toolCall: null,
        toolResult: null,
      );
    }
  }

  Future<AndroidToolResult> _executeWithRiskCheck(
    AndroidToolCall call,
    Future<bool> Function(AndroidToolCall call, ActionRiskLevel riskLevel, String description)? onConfirmationRequired,
  ) async {
    final toolDef = GeminiToolDeclarations.registeredTools.firstWhere(
      (t) => t.name == call.toolName.toLowerCase().replaceAll('android_', ''),
      orElse: () => const AndroidToolDefinition(
        name: 'unknown',
        displayName: 'Action',
        description: 'Unknown Android Action',
        requiredPermission: 'None',
        riskLevel: ActionRiskLevel.safe,
        parameterSchema: {},
      ),
    );

    if (toolDef.riskLevel != ActionRiskLevel.safe && onConfirmationRequired != null) {
      final confirmed = await onConfirmationRequired(
        call,
        toolDef.riskLevel,
        "JX needs your confirmation to execute ${toolDef.displayName}.",
      );
      if (!confirmed) {
        return AndroidToolResult(
          success: false,
          toolName: call.toolName,
          message: "Action was cancelled by user.",
          errorMessage: "USER_CANCELLED",
        );
      }
    }

    return await AndroidToolRouter.instance.executeTool(call);
  }

  Future<String> generateResponse(String prompt, {List<String>? conversationHistory}) async {
    final res = await processAgenticPrompt(prompt);
    return res.text;
  }
}
