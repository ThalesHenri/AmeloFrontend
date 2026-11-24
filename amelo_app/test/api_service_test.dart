import 'dart:convert';

import 'package:amelo_app/repository/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'image requests refresh an expired token once when sent concurrently',
    () async {
      var refreshRequests = 0;
      final imageAuthorizations = <String?>[];
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/auth/token/refresh')) {
          refreshRequests++;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return http.Response(
            jsonEncode({'access': 'fresh-access', 'refresh': 'fresh-refresh'}),
            200,
          );
        }

        imageAuthorizations.add(request.headers['authorization']);
        if (request.headers['authorization'] == 'Bearer expired-access') {
          return http.Response('{"detail":"Invalid token."}', 401);
        }

        return http.Response.bytes(
          [1, 2, 3],
          200,
          headers: {'content-type': 'image/png'},
        );
      });
      addTearDown(client.close);

      final api = ApiService.forTesting(client)
        ..setTokens(
          accessToken: 'expired-access',
          refreshToken: 'refresh-token',
        );
      final imageUri = Uri.parse('${ApiService.baseUrl}/anexos/5/arquivo/');

      final images = await Future.wait([
        api.getBytes(imageUri),
        api.getBytes(imageUri),
        api.getBytes(imageUri),
      ]);

      expect(refreshRequests, 1);
      expect(api.authToken, 'fresh-access');
      expect(imageAuthorizations, [
        'Bearer expired-access',
        'Bearer expired-access',
        'Bearer expired-access',
        'Bearer fresh-access',
        'Bearer fresh-access',
        'Bearer fresh-access',
      ]);
      expect(images.map((image) => image.toList()).toList(), [
        [1, 2, 3],
        [1, 2, 3],
        [1, 2, 3],
      ]);
    },
  );
}
