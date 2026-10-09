/// Форматирование времени сообщений и тайлов чатов.
library;

/// Время сообщения как `HH:mm` (24 часа), как в макете Figma E-Chat.
String formatMessageTime(DateTime value) {
  final h = value.hour.toString().padLeft(2, '0');
  final m = value.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
