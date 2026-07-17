import 'dart:convert';
import 'dart:io';

const ntfyTopic = 'aries-alerts';

class ConsoleColor {
  static const reset = '\x1B[0m';
  static const red = '\x1B[31m';
  static const blue = '\x1B[34m';
}

Future<void> sendNtfyNotification(String title, String message) async {
  try {
    final client = HttpClient();

    final request = await client.postUrl(
      Uri.parse('https://ntfy.sh/$ntfyTopic'),
    );

    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'text/plain; charset=utf-8',
    );

    request.headers.set(
      'Title',
      title.replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
    );

    request.headers.set('Priority', '5');

    request.write(message);

    final response = await request.close();

    print(
      '${ConsoleColor.blue}[NTFY] Status=${response.statusCode}${ConsoleColor.reset}',
    );
  } catch (e) {
    print(
      '${ConsoleColor.red}[NTFY] Error: $e${ConsoleColor.reset}',
    );
  }
}

Future<void> main() async {
  print("🚀 GitHub Action Started");

  await sendNtfyNotification(
    "GitHub Action Test",
    """
✅ GitHub Action executed successfully!

Time (UTC): ${DateTime.now().toUtc()}

If you received this notification, ntfy is working correctly from GitHub Actions.
""",
  );

  print("✅ Finished");
}
