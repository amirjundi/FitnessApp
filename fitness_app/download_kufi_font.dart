import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  // Try Google Fonts CDN directly
  final urls = [
    'https://fonts.gstatic.com/s/droidarabickufi/v8/3W_m6BcvhA43vLkDoPE3k0BxJG4ZnzR_kZZ2.ttf',
  ];
  
  final files = [
    File('assets/fonts/DroidArabicKufi-Regular.ttf'),
  ];
  
  for (int i = 0; i < urls.length; i++) {
    try {
      print('Downloading ${files[i].path}...');
      final response = await http.get(Uri.parse(urls[i]));
      
      if (response.statusCode == 200) {
        await files[i].parent.create(recursive: true);
        await files[i].writeAsBytes(response.bodyBytes);
        print('SUCCESS: Downloaded ${files[i].path} (${response.bodyBytes.length} bytes)');
      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
