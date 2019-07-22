import 'package:dio/dio.dart';

class GetIPCommand {}

final url = "http://ip.jsontest.com/";

Stream getIp(command) async* {
  var resp = await Dio().get(url);
  var json = resp.data;
  yield json['ip'];
}
