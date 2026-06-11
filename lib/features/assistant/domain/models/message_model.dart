enum MessageType { text, voice, image, file }

/// Modèle d'un message dans la conversation avec l'agent IA
class MessageModel {
  final String id;
  final String content;       // texte ou transcription vocale
  final bool isUser;
  final DateTime timestamp;
  final String language;      // 'fr' ou 'wo'
  final MessageType type;
  final String? filePath;     // chemin local pour voix/image/fichier
  final String? fileName;     // nom affiché pour les fichiers
  final int? durationSec;     // durée en secondes pour les vocaux

  const MessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.language = 'fr',
    this.type = MessageType.text,
    this.filePath,
    this.fileName,
    this.durationSec,
  });

  factory MessageModel.user(String content, {String language = 'fr'}) =>
      MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
        language: language,
        type: MessageType.text,
      );

  factory MessageModel.assistant(String content, {String language = 'fr'}) =>
      MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        isUser: false,
        timestamp: DateTime.now(),
        language: language,
        type: MessageType.text,
      );

  factory MessageModel.voice({
    required String filePath,
    required int durationSec,
    String language = 'fr',
  }) =>
      MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '🎤 Message vocal',
        isUser: true,
        timestamp: DateTime.now(),
        language: language,
        type: MessageType.voice,
        filePath: filePath,
        durationSec: durationSec,
      );

  factory MessageModel.image({
    required String filePath,
    String language = 'fr',
  }) =>
      MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '🖼️ Image',
        isUser: true,
        timestamp: DateTime.now(),
        language: language,
        type: MessageType.image,
        filePath: filePath,
        fileName: filePath.split('/').last,
      );

  factory MessageModel.attachment({
    required String filePath,
    required String fileName,
    String language = 'fr',
  }) =>
      MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '📎 $fileName',
        isUser: true,
        timestamp: DateTime.now(),
        language: language,
        type: MessageType.file,
        filePath: filePath,
        fileName: fileName,
      );
}
