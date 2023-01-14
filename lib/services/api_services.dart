// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;

class ApiServices {
  static const apiKey = "WX4fDhPfx18b68TGuXgP5yko";
  static var baseUrl = Uri.parse("https://api.remove.bg/v1.0/removebg");

  static removeBg(String imgPath) async {
    try {
      var req = http.MultipartRequest("POST", baseUrl);
      req.headers.addAll({"X-API-Key": apiKey});
      req.files.add(await http.MultipartFile.fromPath("image_file", imgPath));
      final res = await req.send();
      if (res.statusCode == 200) {
        http.Response img = await http.Response.fromStream(res);
        return img.bodyBytes;
      } else {
        print('api faild');
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
