import '../../../core/network/dio_client.dart';
import '../../../core/errors/exceptions.dart';

class AssistantRemoteDatasource {
  final DioClient client;
  const AssistantRemoteDatasource({required this.client});

  Future<String> sendMessage({
    required String message,
    required String language,
    List<Map<String, dynamic>>? history,
    String? conversationId,
    String? imageBase64,
  }) async {
    // Backend (NdiogoyeChatView) : POST /api/ai/ndiogoye/chat/
    //   body  {message, chat_history:[{role, content}], conversation_id,
    //          image_base64?}  -> {intent, action, reply}
    // `conversation_id` est requis en pratique : le backend l'enregistre en
    // `session_id` non-nullable et renvoie une 500 s'il est absent.
    // `image_base64` (optionnel) : Ndiogoye lit le document photographié (vision).
    final res = await client.post('/ai/ndiogoye/chat/', data: {
      'message': message,
      'chat_history': history ?? [],
      if (conversationId != null) 'conversation_id': conversationId,
      if (imageBase64 != null) 'image_base64': imageBase64,
    });
    if ((res.statusCode == 200) && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      // `reply` est le champ officiel ; `answer` gardé en repli défensif.
      final reply = (data['reply'] ?? data['answer']) as String?;
      if (reply != null && reply.isNotEmpty) return reply;
    }
    throw const ApiException(message: 'Réponse invalide du serveur');
  }
}
