import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ecoloop/core/services/api_client.dart';
import 'package:ecoloop/core/services/ecoloop_api_service.dart';

void main() {
  group('ApiClient Tests', () {
    test('GET request successfully parses JSON payload', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/test-endpoint') {
          return http.Response(jsonEncode({'status': 'ok', 'count': 42}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(baseUrl: 'http://mock-api', httpClient: mockClient);
      final response = await apiClient.get('/test-endpoint');

      expect(response['status'], 'ok');
      expect(response['count'], 42);
    });

    test('Throws AuthTokenException on 401 Unauthorized', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Invalid or expired token'}), 401);
      });

      final apiClient = ApiClient(baseUrl: 'http://mock-api', httpClient: mockClient);
      expect(
        () => apiClient.get('/protected'),
        throwsA(isA<AuthTokenException>()),
      );
    });

    test('Throws ApiException on 500 Server Error', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Database connection failed'}), 500);
      });

      final apiClient = ApiClient(baseUrl: 'http://mock-api', httpClient: mockClient);
      expect(
        () => apiClient.get('/error-route'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('EcoLoopApiService Tests', () {
    test('calculateCarbon sends request and deserializes result', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['category'], 'transport');
        expect(body['quantity'], 20.0);

        return http.Response(
          jsonEncode({
            'category': 'transport',
            'activityType': 'Car',
            'quantity': 20.0,
            'unit': 'km',
            'estimatedCo2Kg': 3.6,
            'confidence': 'preliminary_model',
            'methodology': 'IPCC Transport Baseline',
          }),
          200,
        );
      });

      final apiService = EcoLoopApiService(ApiClient(baseUrl: 'http://mock-api', httpClient: mockClient));
      final res = await apiService.calculateCarbon(
        category: 'transport',
        activityType: 'Car',
        quantity: 20.0,
        unit: 'km',
      );

      expect(res['estimatedCo2Kg'], 3.6);
      expect(res['methodology'], 'IPCC Transport Baseline');
    });
  });
}
