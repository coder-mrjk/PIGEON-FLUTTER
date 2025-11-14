import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai;

import '../core/config/api_config.dart';
import '../core/models/ui_chat_message.dart';
import '../widgets/message_bubble.dart';

class AIToolkitChatScreen extends StatefulWidget {
  const AIToolkitChatScreen({super.key});

  @override
  State<AIToolkitChatScreen> createState() => _AIToolkitChatScreenState();
}

class _AIToolkitChatScreenState extends State<AIToolkitChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  genai.GenerativeModel? _model;
  genai.ChatSession? _chat;
  bool _streaming = true;

  @override
  void initState() {
    super.initState();
    if (APIConfig.isGoogleConfigured) {
      _model = genai.GenerativeModel(
        model: APIConfig.googleModel,
        apiKey: APIConfig.googleAPIKey,
        generationConfig: genai.GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1000,
        ),
      );
      _chat = _model!.startChat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Toolkit (Gemini)'),
        actions: [
          Row(
            children: [
              const Text('Stream'),
              Switch(
                value: _streaming,
                onChanged: (v) => setState(() => _streaming = v),
              ),
              const SizedBox(width: 8),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Start chatting with Gemini'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final ui = _messages[index];
                      return MessageBubble(message: ui);
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _send,
                    child: const Text('Send'),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  final List<UIChatMessage> _messages = [];

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _model == null || _chat == null) return;

    final now = DateTime.now();
    _messages.add(UIChatMessage(content: text, isUser: true, timestamp: now));
    setState(() {});

    _controller.clear();

    try {
      if (_streaming) {
        var acc = '';
        // Add placeholder assistant message
        _messages.add(UIChatMessage(
            content: '',
            isUser: false,
            timestamp: DateTime.now(),
            senderName: 'Gemini'));
        setState(() {});

        await for (final chunk
            in _chat!.sendMessageStream(genai.Content.text(text))) {
          acc += chunk.text ?? '';
          _messages[_messages.length - 1] = UIChatMessage(
            content: acc,
            isUser: false,
            timestamp: DateTime.now(),
            senderName: 'Gemini',
          );
          setState(() {});
        }
      } else {
        final resp = await _chat!.sendMessage(genai.Content.text(text));
        _messages.add(UIChatMessage(
          content: resp.text ?? '',
          isUser: false,
          timestamp: DateTime.now(),
          senderName: 'Gemini',
        ));
        setState(() {});
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gemini error: ${e.toString()}')),
      );
    }
  }
}
