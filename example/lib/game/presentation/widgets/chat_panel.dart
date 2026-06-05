import 'package:flutter/material.dart';

import '../../domain/entities/chat_message.dart';

class ChatPanel extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool canGuess;
  final ValueChanged<String> onGuessSubmitted;

  const ChatPanel({
    super.key,
    required this.messages,
    required this.canGuess,
    required this.onGuessSubmitted,
  });

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(ChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onGuessSubmitted(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final msg = widget.messages[index];
              final isSystem = msg.playerName == 'System';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text.rich(
                  TextSpan(children: [
                    if (!isSystem)
                      TextSpan(
                        text: '${msg.playerName}: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: msg.isCorrectGuess
                              ? Colors.green
                              : colorScheme.onSurface,
                        ),
                      ),
                    TextSpan(
                      text: msg.text,
                      style: TextStyle(
                        color: isSystem
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight:
                            isSystem ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        if (widget.canGuess)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your guess...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submit(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
