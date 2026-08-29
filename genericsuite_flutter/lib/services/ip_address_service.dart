import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

import 'utilities.dart';

const ipAddressSvDebug = false;

Future<String?> getPublicIpAddress() async {
  try {
    const url = 'https://api.ipify.org';
    if (ipAddressSvDebug) {
      logDebug("IPAddressService | getPublicIpAddress | url: $url");
    }
    var response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      if (ipAddressSvDebug) {
        logDebug(
          "IPAddressService | getPublicIpAddress | Failed to get public IP. Status code: ${response.statusCode}",
        );
      }
      return null;
    }
  } catch (e) {
    if (ipAddressSvDebug) {
      logDebug(
        "IPAddressService | getPublicIpAddress | Error fetching public IP: $e",
      );
    }
    return null;
  }
}

Future<String?> getLocalIpAddress() async {
  try {
    final info = NetworkInfo();
    var wifiIP = await info.getWifiIP();
    if (ipAddressSvDebug) {
      logDebug("IPAddressService | getLocalIpAddress | wifiIP: $wifiIP");
    }
    return wifiIP;
  } catch (e) {
    if (ipAddressSvDebug) {
      logDebug(
        "IPAddressService | getLocalIpAddress | Error fetching local IP: $e",
      );
    }
    return null;
  }
}
