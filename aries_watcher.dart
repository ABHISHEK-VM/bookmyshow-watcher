import 'dart:convert';
import 'dart:io';

const url =
    'https://in.bookmyshow.com/api/movies-data/v4/showtimes-by-event/primary-dynamic?eventCode=ET00502630&dateCode=&isDesktop=true&regionCode=TRIV&xLocationShared=false&memberId=&lsId=&subCode=&lat=8.4875&lon=76.9525';

Future<void> sendNtfyNotification() async {
  final topic = Platform.environment['NTFY_TOPIC'];

  final client = HttpClient();

  final request = await client.postUrl(
    Uri.parse('https://ntfy.sh/$topic'),
  );

  request.headers.set(
    'Title',
    'BookMyShow Alert',
  );

  request.write(
    '🔥 Aries Plex bookings are LIVE!',
  );

  final response = await request.close();

  print(
    'NTFY Status: ${response.statusCode}',
  );
}

Future<void> main() async {
  final request =
      await HttpClient().getUrl(
    Uri.parse(url),
  );

  request.headers.set(
    'x-region-code',
    'TRIV',
  );

  final response =
      await request.close();

  final body =
      await response.transform(
    utf8.decoder,
  ).join();

  print(
    'Status=${response.statusCode}',
  );

  final found =
      body.contains('"venueCode":"ASLC"') ||
      body.contains('Ariesplex SL Cinemas');

  if (!found) {
    print('Not Found');
    exit(0);
  }

  print('FOUND');

  await sendNtfyNotification();
}
