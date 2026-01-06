import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> download(String url, String filepath) async {
  final file = File(filepath);
  print('Downloading $filepath...');
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
      print('Saved $filepath');
    } else {
      print('Failed ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

void main() async {
  await download(
    'https://github.com/google/fonts/raw/main/ofl/notokufiarabic/NotoKufiArabic-Regular.ttf',
    'assets/fonts/NotoKufiArabic-Regular.ttf'
  );
  await download(
    'https://github.com/google/fonts/raw/main/ofl/notokufiarabic/NotoKufiArabic-Bold.ttf',
    'assets/fonts/NotoKufiArabic-Bold.ttf'
  );
}
