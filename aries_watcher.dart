import 'dart:async';
import 'dart:convert';
import 'dart:io';

const url =
    'https://in.bookmyshow.com/api/movies-data/v4/showtimes-by-event/primary-dynamic?eventCode=ET00502630&dateCode=&isDesktop=true&regionCode=TRIV&xLocationShared=false&memberId=&lsId=&subCode=&lat=8.4875&lon=76.9525';

const ntfyTopic = 'aries-alerts';

class ConsoleColor {
  static const reset = '\x1B[0m';
  static const red = '\x1B[31m';
  static const green = '\x1B[32m';
  static const yellow = '\x1B[33m';
  static const blue = '\x1B[34m';
}

int? previousResponseSize;

Future<void> sendNtfyNotification(String title, String message) async {
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('https://ntfy.sh/$ntfyTopic'));
    request.headers.set(HttpHeaders.contentTypeHeader,'text/plain; charset=utf-8');
    request.headers.set('Title', title.replaceAll(RegExp(r'[^\x20-\x7E]'), ''));
    request.headers.set('Priority', '5');
    request.write(message);
    final response = await request.close();
    print('[NTFY] Status=${response.statusCode}');
  } catch (e) {
    print('[NTFY] Error: $e');
  }
}

Future<void> sendFoundAlerts() async {
  const title = 'BookMyShow Alert';
  const message = '''
Aries Plex bookings are LIVE!

Open BookMyShow immediately and book your seats.

https://in.bookmyshow.com/
''';

  for (int i = 1; i <= 3; i++) {
    print('Alert $i/3');
    await sendNtfyNotification(title, message);
    await Future.delayed(const Duration(seconds: 2));
  }
}

Future<void> main() async {
  print('Started BookMyShow Watcher');

  try {
    final request = await HttpClient().getUrl(Uri.parse(url));
    request.headers.set('x-region-code', 'TRIV');

    final response = await request.close();

    if (response.statusCode != 200) {
      await sendNtfyNotification('BookMyShow API Failure','Status Code: ${response.statusCode}');
      return;
    }

    final body = await response.transform(utf8.decoder).join();

    if (body.contains('Cloudflare') || body.contains('Just a moment')) {
      await sendNtfyNotification('BookMyShow Blocked','Cloudflare challenge detected');
      return;
    }

    print('Status=${response.statusCode} Size=${body.length}');

    if (previousResponseSize != null && previousResponseSize != body.length) {
      await sendNtfyNotification(
        'BookMyShow Response Changed',
        'Response size changed from $previousResponseSize to ${body.length}',
      );
    }

    previousResponseSize = body.length;

    final found = body.contains('"venueCode":"ASLC"') ||
        body.contains('Ariesplex SL Cinemas');

    if (found) {
      print('THEATRE FOUND');
      await sendFoundAlerts();
    } else {
      print('Theatre not found');
    }
  } catch (e) {
    await sendNtfyNotification('BookMyShow Watcher Error','$e');
  }

  print('GitHub Action Finished');
}
