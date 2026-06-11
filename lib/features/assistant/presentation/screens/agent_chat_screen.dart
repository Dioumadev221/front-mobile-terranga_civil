import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/assistant_provider.dart';
import '../../domain/models/message_model.dart';

// ── Palette chatbot ───────────────────────────────────────────
const _navy     = Color(0xFF0A1F5C);
const _green    = Color(0xFF1D9E75);
const _bg       = Color(0xFFF5F7FA);
const _userBg   = Color(0xFF0A1F5C);
const _botBg    = Colors.white;
const _grey     = Color(0xFF8E9BAE);

class AgentChatScreen extends ConsumerStatefulWidget {
  const AgentChatScreen({super.key});

  @override
  ConsumerState<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends ConsumerState<AgentChatScreen> {
  final _textCtr   = TextEditingController();
  final _scrollCtr = ScrollController();
  final _picker    = ImagePicker();

  bool _hasText     = false;
  bool _isRecording = false;
  int  _recordSecs  = 0;
  String? _playingId;

  @override
  void dispose() {
    _textCtr.dispose();
    _scrollCtr.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtr.hasClients) {
        _scrollCtr.animateTo(
          _scrollCtr.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText() async {
    final text = _textCtr.text.trim();
    if (text.isEmpty) return;
    _textCtr.clear();
    setState(() => _hasText = false);
    await ref.read(assistantProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _sendQuick(String text) async {
    await ref.read(assistantProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _startRecording() {
    setState(() { _isRecording = true; _recordSecs = 0; });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecording || !mounted) return false;
      setState(() => _recordSecs++);
      return _isRecording;
    });
  }

  Future<void> _stopRecording() async {
    final secs = _recordSecs;
    setState(() => _isRecording = false);
    final msg = MessageModel.voice(
      filePath: '',
      durationSec: secs,
      language: ref.read(assistantProvider).language,
    );
    ref.read(assistantProvider.notifier).addLocalMessage(msg);
    _scrollToBottom();
    await ref.read(assistantProvider.notifier)
        .sendMessage('[Message vocal — ${secs}s]');
    _scrollToBottom();
  }

  void _cancelRecording() => setState(() => _isRecording = false);

  void _togglePlay(MessageModel msg) =>
      setState(() => _playingId = _playingId == msg.id ? null : msg.id);

  void _showAttachSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttachSheet(
        onGallery: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
        onCamera:  () { Navigator.pop(context); _pickImage(ImageSource.camera); },
        onDoc: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documents bientôt disponibles')));
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final xf = await _picker.pickImage(source: source, imageQuality: 80);
    if (xf == null || !mounted) return;
    ref.read(assistantProvider.notifier)
        .addLocalMessage(MessageModel.image(
          filePath: xf.path,
          language: ref.read(assistantProvider).language));
    _scrollToBottom();
    await ref.read(assistantProvider.notifier).sendMessage('[Image envoyée]');
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantProvider);
    final empty = state.messages.isEmpty && !state.isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: _bg,
      appBar: _ChatHeader(
        onClear: () => ref.read(assistantProvider.notifier).clearHistory(),
      ),
      body: Column(
        children: [
          // ── Zone messages ─────────────────────────────────
          Expanded(
            child: empty
                ? _WelcomeView(onQuick: _sendQuick)
                : ListView.builder(
                    controller: _scrollCtr,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == state.messages.length) {
                        return const _TypingBubble();
                      }
                      final msg = state.messages[i];
                      final showDate = i == 0 ||
                          !_sameDay(state.messages[i - 1].timestamp, msg.timestamp);
                      return Column(children: [
                        if (showDate) _DateLabel(dt: msg.timestamp),
                        _MessageBubble(
                          msg: msg,
                          isPlaying: _playingId == msg.id,
                          onPlayTap: () => _togglePlay(msg),
                        ),
                      ]);
                    },
                  ),
          ),

          // ── Barre d'enregistrement ────────────────────────
          if (_isRecording)
            _RecordBar(
              secs: _recordSecs,
              onCancel: _cancelRecording,
              onStop: _stopRecording,
            ),

          // ── Barre de saisie ───────────────────────────────
          if (!_isRecording)
            _InputBar(
              controller: _textCtr,
              hasText: _hasText,
              isLoading: state.isLoading,
              onChanged: (v) => setState(() => _hasText = v.trim().isNotEmpty),
              onSend: _sendText,
              onAttach: _showAttachSheet,
              onMicStart: _startRecording,
            ),
        ],
      ),
    ));
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── AppBar chatbot ────────────────────────────────────────────
class _ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClear;
  const _ChatHeader({required this.onClear});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1F5C), Color(0xFF1B3A8A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // Retour
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              // Avatar avec indicateur online
              Stack(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: OverflowBox(
                        maxWidth: 100,
                        maxHeight: 100,
                        alignment: const Alignment(0, -0.65),
                        child: Image.asset(
                          'assets/images/assistante.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 1, bottom: 1,
                    child: Container(
                      width: 11, height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                        border: Border.all(color: _navy, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Nom + statut
              Expanded(
                child: Text('Agent Teranga IA',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                    )),
              ),
              // Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (v) { if (v == 'clear') onClear(); },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444), size: 18),
                      SizedBox(width: 8),
                      Text('Effacer la conversation',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Vue d'accueil ─────────────────────────────────────────────
class _WelcomeView extends StatelessWidget {
  final Future<void> Function(String) onQuick;
  const _WelcomeView({required this.onQuick});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          const Text('Bonjour ! 👋',
              style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700,
                color: _navy, fontFamily: 'Poppins',
              )),
          const SizedBox(height: 8),
          Text(
            'Je suis Agent Teranga IA, votre assistant pour toutes vos démarches civiles au Sénégal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, color: Colors.grey[600],
              fontFamily: 'Poppins', height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // Titre suggestions
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Questions fréquentes',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: Colors.grey[500], fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                )),
          ),
          const SizedBox(height: 12),
          // Chips suggestions
          ...[
            ('💡', 'Comment obtenir un acte de naissance ?'),
            ('💍', 'Comment demander un acte de mariage ?'),
            ('📋', 'Quels documents sont nécessaires ?'),
            ('⏱️', 'Quel est le délai de traitement ?'),
          ].map((q) => _QuickChip(icon: q.$1, label: q.$2, onTap: () => onQuick(q.$2))),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  const _QuickChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    fontSize: 13, color: _navy,
                    fontFamily: 'Poppins', fontWeight: FontWeight.w500,
                  )),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: _grey),
          ],
        ),
      ),
    );
  }
}

// ── Séparateur date ───────────────────────────────────────────
class _DateLabel extends StatelessWidget {
  final DateTime dt;
  const _DateLabel({required this.dt});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Aujourd\'hui';
    if (d == today.subtract(const Duration(days: 1))) return 'Hier';
    return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(_label(),
            style: const TextStyle(
              fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Poppins',
            )),
      ),
    ),
  );
}

// ── Bulle message ─────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isPlaying;
  final VoidCallback onPlayTap;
  const _MessageBubble({required this.msg, required this.isPlaying, required this.onPlayTap});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar bot
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: _green,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 17),
            ),
            const SizedBox(width: 8),
          ],
          // Bulle
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: msg.type == MessageType.image
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? _userBg : _botBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 6, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildContent(isUser),
                  const SizedBox(height: 4),
                  Text(
                    _fmt(msg.timestamp),
                    style: TextStyle(
                      fontSize: 10, fontFamily: 'Poppins',
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.5)
                          : _grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildContent(bool isUser) {
    final textColor = isUser ? Colors.white : const Color(0xFF1E293B);

    switch (msg.type) {
      case MessageType.voice:
        return _VoiceBubble(
          msg: msg, isUser: isUser, isPlaying: isPlaying, onTap: onPlayTap,
        );
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(msg.filePath!), width: 220, height: 180, fit: BoxFit.cover,
          ),
        );
      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_rounded,
                color: isUser ? Colors.white70 : _green, size: 26),
            const SizedBox(width: 8),
            Flexible(
              child: Text(msg.fileName ?? msg.content,
                  style: TextStyle(
                    fontSize: 13, fontFamily: 'Poppins', color: textColor,
                  )),
            ),
          ],
        );
      default:
        return Text(msg.content,
            style: TextStyle(
              fontSize: 14, fontFamily: 'Poppins',
              color: textColor, height: 1.5,
            ));
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
}

// ── Bulle vocale ──────────────────────────────────────────────
class _VoiceBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isUser, isPlaying;
  final VoidCallback onTap;
  const _VoiceBubble({required this.msg, required this.isUser,
      required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUser ? Colors.white.withValues(alpha: 0.2) : _green,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isUser ? Colors.white : Colors.white, size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(18, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  width: 3,
                  height: (i % 4 == 0 ? 16 : i % 3 == 0 ? 10 : 6).toDouble(),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isPlaying && i < 8
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4))
                        : (isPlaying && i < 8
                            ? _green
                            : _grey.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
              ),
              const SizedBox(height: 3),
              Text(_fmt(msg.durationSec ?? 0),
                  style: TextStyle(
                    fontSize: 10, fontFamily: 'Poppins',
                    color: isUser ? Colors.white60 : _grey,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2,'0')}:${(s % 60).toString().padLeft(2,'0')}';
}

// ── Indicateur frappe ─────────────────────────────────────────
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900))..repeat();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 17),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _botBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final phase = (_ctrl.value - i * 0.18).clamp(0.0, 1.0);
                  final t = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8, height: 8,
                    transform: Matrix4.translationValues(0, -5 * t, 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(_grey, _green, t),
                    ),
                  );
                },
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Barre enregistrement ──────────────────────────────────────
class _RecordBar extends StatelessWidget {
  final int secs;
  final VoidCallback onCancel, onStop;
  const _RecordBar({required this.secs, required this.onCancel, required this.onStop});

  @override
  Widget build(BuildContext context) {
    final m = (secs ~/ 60).toString().padLeft(2,'0');
    final s = (secs % 60).toString().padLeft(2,'0');
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        GestureDetector(
          onTap: onCancel,
          child: const Icon(Icons.delete_outline_rounded,
              color: Color(0xFFEF4444), size: 26),
        ),
        const SizedBox(width: 12),
        const _PulsingDot(),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$m:$s enregistrement en cours...',
              style: const TextStyle(
                color: Color(0xFFEF4444), fontSize: 14, fontFamily: 'Poppins',
              )),
        ),
        GestureDetector(
          onTap: onStop,
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: _green, shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _green.withValues(alpha: 0.4),
                    blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override State<_PulsingDot> createState() => _PulsingDotState();
}
class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.lerp(const Color(0xFFEF4444),
            const Color(0xFFEF4444).withValues(alpha: 0.2), _c.value),
      ),
    ),
  );
}

// ── Barre de saisie ───────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText, isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend, onAttach, onMicStart;
  const _InputBar({
    required this.controller, required this.hasText,
    required this.isLoading, required this.onChanged,
    required this.onSend, required this.onAttach, required this.onMicStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, 8 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Bouton attach
            GestureDetector(
              onTap: onAttach,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _bg, shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: _grey, size: 22),
              ),
            ),
            const SizedBox(width: 8),
            // Champ texte
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    fontSize: 14, fontFamily: 'Poppins',
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Écrire un message...',
                    hintStyle: TextStyle(
                      color: _grey, fontSize: 14, fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Bouton mic / envoyer
            GestureDetector(
              onTap: () { if (hasText) onSend(); },
              onLongPressStart: (_) { if (!hasText) onMicStart(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46, height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasText ? _navy : _green,
                  boxShadow: [
                    BoxShadow(
                      color: (hasText ? _navy : _green).withValues(alpha: 0.35),
                      blurRadius: 8, offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  hasText ? Icons.send_rounded : Icons.mic_rounded,
                  color: Colors.white, size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sheet pièces jointes ──────────────────────────────────────
class _AttachSheet extends StatelessWidget {
  final VoidCallback onGallery, onCamera, onDoc;
  const _AttachSheet({required this.onGallery, required this.onCamera, required this.onDoc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Joindre un fichier',
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: _navy, fontFamily: 'Poppins',
              )),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AttachBtn(icon: Icons.photo_library_rounded,
                  label: 'Galerie', color: const Color(0xFF8B5CF6),
                  onTap: onGallery),
              _AttachBtn(icon: Icons.camera_alt_rounded,
                  label: 'Caméra', color: _green,
                  onTap: onCamera),
              _AttachBtn(icon: Icons.insert_drive_file_rounded,
                  label: 'Document', color: const Color(0xFFF59E0B),
                  onTap: onDoc),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttachBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachBtn({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 26),
      ),
      const SizedBox(height: 8),
      Text(label,
          style: const TextStyle(
            fontSize: 12, fontFamily: 'Poppins',
            color: Color(0xFF475569), fontWeight: FontWeight.w500,
          )),
    ]),
  );
}
