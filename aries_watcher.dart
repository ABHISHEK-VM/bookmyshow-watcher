import 'dart:io';

Future<void> main() async {
  print('====================================');
  print('🚀 GitHub Action is running!');
  print('⏰ Current Time (UTC): ${DateTime.now().toUtc()}');
  print('🖥️ Platform: ${Platform.operatingSystem}');
  print('👤 User: ${Platform.environment['USER'] ?? 'Unknown'}');
  print('====================================');
}
