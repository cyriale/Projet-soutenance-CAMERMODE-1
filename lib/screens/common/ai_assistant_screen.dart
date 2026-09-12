import 'package:flutter/material.dart';
import '../../services/ai_chat_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../core/app_colors.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  final AIChatService _aiService = AIChatService();
  bool _isLoading = false;
  String? _userMorphology;
  String? _userFaceShape;

  final List<String> _suggestions = [
    "Quelle tenue pour un mariage coutumier ?",
    "Quelle robe pour ma morphologie ?",
    "Différence entre Ndop et Toghu ?",
    "Coiffure tendance pour visage ovale",
    "Tarifs moyens de couture à Douala",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // Message de bienvenue initial
    _messages.add({
      "role": "ai",
      "text": "Bonjour ! Je suis votre styliste et conseiller CamerMode IA 🤖✨.\n\nPosez-moi vos questions sur le choix des tissus (Ndop, Toghu, Bazin, Wax), les coupes adaptées à votre silhouette ou les coiffures idéales. Comment puis-je vous sublimer aujourd'hui ?",
    });
  }

  Future<void> _loadUserProfile() async {
    final user = AuthService().currentUser;
    if (user != null) {
      final profile = await UserService().getUser(user.uid);
      if (profile != null && mounted) {
        setState(() {
          _userMorphology = profile.morphologieType;
          _userFaceShape = profile.formeVisage;
        });
      }
    }
  }

  void _sendMessage([String? presetText]) async {
    final text = presetText ?? _controller.text;
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text.trim()});
      _isLoading = true;
    });
    if (presetText == null) _controller.clear();
    _scrollToBottom();

    final aiResponse = await _aiService.getAIResponse(
      text.trim(),
      userMorphology: _userMorphology,
      userFaceShape: _userFaceShape,
    );

    if (mounted) {
      setState(() {
        _messages.add({"role": "ai", "text": aiResponse});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  void _showApiKeyDialog() {
    final keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.key, color: AppColors.rose),
            SizedBox(width: 8),
            Text("Clé API Google Gemini", style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "L'application intègre déjà un moteur IA autonome. Si vous possédez une clé API Google AI Studio (commençant par AIzaSy...), vous pouvez la renseigner ici :",
              style: TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: InputDecoration(
                hintText: "Collez votre clé AIzaSy...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer")),
          ElevatedButton(
            onPressed: () {
              if (keyController.text.trim().isNotEmpty) {
                _aiService.updateApiKey(keyController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Clé API Gemini configurée avec succès !"), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
            child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Styliste CamerMode IA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Conseiller Mode & Beauté Africaine", style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.noir,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined, size: 20),
            tooltip: "Configurer clé Gemini",
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Suggestions rapides
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 11, color: AppColors.noir)),
                    backgroundColor: AppColors.rose.withOpacity(0.08),
                    side: BorderSide(color: AppColors.rose.withOpacity(0.3)),
                    onPressed: () => _sendMessage(s),
                  ),
                )).toList(),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.rose,
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.rose : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Text(
                            msg["text"]!,
                            style: TextStyle(
                              color: isUser ? Colors.white : AppColors.noir,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.noir,
                          child: const Icon(Icons.person, color: Colors.white, size: 16),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: Colors.white,
              child: Row(
                children: const [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.rose)),
                  SizedBox(width: 12),
                  Text("L'IA CamerMode compose votre réponse...", style: TextStyle(fontSize: 12, color: AppColors.texteSecondaire)),
                ],
              ),
            ),

          // Zone de saisie
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
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Posez votre question (Français, Anglais, Camfranglais)...",
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.texteSecondaire),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: AppColors.roseClair,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
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
