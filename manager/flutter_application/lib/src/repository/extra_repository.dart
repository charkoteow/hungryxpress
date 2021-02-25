import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'dart:convert';
import 'dart:io';

import '../helpers/custom_trace.dart';
import '../models/extra_group.dart';
import '../helpers/helper.dart';
import '../models/extra.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

/**
 * Category of Restaurant
 */
Future<Extra> addExtra(Extra extra) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}extras?$_apiToken';
  final client = new http.Client();
  try {
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(extra.toMap()),
    );
    return Extra.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Extra.fromJSON({});
  }
}

Future<Extra> updateExtra(Extra extra) async {
  Uri uri = Helper.getUri('api/extras/${extra.id}');
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Extra();
  }
  Map<String, dynamic> _queryParams = {};
  _queryParams['api_token'] = _user.apiToken;
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    uri.toString(),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(extra.toMap()),
  );
  return Extra.fromJSON(json.decode(response.body)['data']);
}