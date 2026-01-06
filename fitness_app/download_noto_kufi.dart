import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> download(String url, String path) async {
  final file = File(path);
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
      print('Downloaded $path');
    } else {
      print('Failed ${response.statusCode} for $url');
    }
  } catch (e) {
    print('Error $e');
  }
}

void main() async {
  await download('https://github.com/google/fonts/raw/main/ofl/notokufiarabic/NotoKufiArabic-Regular.ttf', 'assets/fonts/NotoKufiArabic-Regular.ttf');
  await download('https://github.com/google/fonts/raw/main/ofl/notokufiarabic/NotoKufiArabic-Bold.ttf', 'assets/fonts/NotoKufiArabic-Bold.ttf');
}
