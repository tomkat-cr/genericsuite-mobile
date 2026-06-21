import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

Future<String?> getPublicIpAddress() async {
  try {
    const url = 'https://api.ipify.org';
    var response = await http.get(Uri.parse(url)).timeout(
      const Duration(seconds: 5),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print('Failed to get public IP. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching public IP: $e');
    return null;
  }
}


Future<String?> getLocalIpAddress() async {
  try {
    final info = NetworkInfo();
    var wifiIP = await info.getWifiIP();
    return wifiIP;
  } catch (e) {
    return null;
  }
}
