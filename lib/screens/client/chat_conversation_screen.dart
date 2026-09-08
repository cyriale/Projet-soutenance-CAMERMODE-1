
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/dashboard_service.dart';

class ChatConversationScreen extends StatefulWidget {
  final String conversationId;
  final String prestataireNom;
  final String prestatairePhoto;
  final bool prestataireVerified;
  final String? articleRefTitre;
  final String? articleRefImageUrl;

  const ChatConversationScreen({
    super.key,
    required this.conversationId,
    required this.prestataireNom,
    required this.prestatairePhoto,
    this.prestataireVerified = true,
    this.articleRefTitre,
    this.articleRefImageUrl,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DashboardService _service = DashboardService();

  final List<String> _quickQuestions = [
    "Bonjour, cet article est-il disponible ?",
    "Faites-vous du sur-mesure ?",
    "Quel est le délai de confection ?",
    "Proposez-vous une prestation à domicile ?",
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? quickText]) {
    final text = quickText ?? _textController.text.trim();
    if (text.isEmpty) return;

    _service.sendMessage(
      convId: widget.conversationId,
      text: text,
      articleRefTitre: widget.articleRefTitre,
      articleRefImageUrl: widget.articleRefImageUrl,
    );

    _textController.clear();
    setState(() {});

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = _service.getMessagesForConv(widget.conversationId);

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.noir),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.prestatairePhoto),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.prestataireNom,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.noir),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.prestataireVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Colors.blue, size: 14),
                      ],
                    ],
                  ),
                  const Text("En ligne récemment", style: TextStyle(fontSize: 11, color: AppColors.texteSecondaire)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // En-tête Article référencé
          if (widget.articleRefTitre != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  if (widget.articleRefImageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.articleRefImageUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.image, size: 30),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Question à propos de :",
                          style: TextStyle(fontSize: 11, color: AppColors.texteSecondaire, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          widget.articleRefTitre!,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.noir),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Liste des messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.isFromUser;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.rose : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.noir,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            color: isMe ? Colors.white70 : AppColors.texteSecondaire,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Suggestions de questions rapides
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(_quickQuestions[index], style: const TextStyle(fontSize: 12, color: AppColors.noir)),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.ligne),
                  onPressed: () => _sendMessage(_quickQuestions[index]),
                );
              },
            ),
          ),

          // Barre de saisie
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.ligne)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Écrivez votre message...",
                        hintStyle: const TextStyle(color: AppColors.texteSecondaire, fontSize: 14),
                        filled: true,
                        fillColor: AppColors.roseClair,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.rose,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
