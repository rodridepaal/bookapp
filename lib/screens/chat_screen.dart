import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Biar teks rapi

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Halo! Saya AI Assistant BookApp. Ada yang bisa saya bantu? Kamu bisa tanya rekomendasi buku, atau cara pakai aplikasi ini.',
      'isUser': false,
    }
  ];
  bool _isLoading = false;

  // api buat cetbot
  final String _apiKey = 'AIzaSyC0F3aWwQmUNLxO0AA9NG1gdV6YKJl5ITw';

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.text(
        "Kamu adalah asisten AI yang ramah dan membantu untuk aplikasi bernama 'bookapp'. "
        "BookApp adalah aplikasi untuk mencari buku, menyimpan ke 'Read List', dan menandai 'Finished'. "
        "Jawablah pertanyaan pengguna tentang buku, rekomendasi bacaan, atau cara menggunakan aplikasi dengan sopan dan ringkas. "
        "Gunakan bahasa Indonesia yang santai tapi sopan."
      ),
    );
    _chatSession = _model.startChat();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final String userText = _controller.text;
    
    setState(() {
      _messages.add({'text': userText, 'isUser': true});
      _isLoading = true; 
    });
    _controller.clear();

    try {
      // Kirim pesan ke Gemini
      final response = await _chatSession.sendMessage(Content.text(userText));
      final textResponse = response.text;

      if (mounted) {
        setState(() {
          _messages.add({
            'text': textResponse ?? "Maaf, saya sedang bingung.", 
            'isUser': false
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': "Waduh, koneksi ke bookchat terputus. Coba lagi ya! (Error: $e)", 
            'isUser': false
          });
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("bookchat", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Bagian List Pesan
          Expanded(
            child: ListView.builder(
              reverse: true, 
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isUser = message['isUser'];

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.black : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                      ),
                    ),
                    // Pakai MarkdownBody biar teks dari AI rapi (bold, list, dll)
                    child: isUser 
                      ? Text(message['text'], style: const TextStyle(color: Colors.white))
                      : MarkdownBody(
                          data: message['text'],
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: Colors.black),
                          ),
                        ),
                  ),
                );
              },
            ),
          ),
          
          // Indikator Loading (Ketik...)
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("AI sedang mengetik...", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
            ),

          // Bagian Input Teks
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Tanya sesuatu...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _isLoading ? Colors.grey : Colors.black,
                  child: IconButton(
                    icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}