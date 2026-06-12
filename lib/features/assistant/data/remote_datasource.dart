import '../../../core/network/dio_client.dart';
import '../../../core/errors/exceptions.dart';

class AssistantRemoteDatasource {
  final DioClient client;
  const AssistantRemoteDatasource({required this.client});

  Future<String> sendMessage({
    required String message,
    required String language,
    List<Map<String, dynamic>>? history,
  }) async {
    // Backend: POST /api/ai/ndiogoye/chat/  body {question, chat_history} -> {answer}
    final res = await client.post('/ai/ndiogoye/chat/', data: {
      'question': message,
      'chat_history': history ?? [],
    });
    if ((res.statusCode == 200) && res.data != null) {
      return (res.data as Map<String, dynamic>)['answer'] as String;
    }
    throw const ApiException(message: 'Réponse invalide du serveur');
  }
}
