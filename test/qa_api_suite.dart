import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  const baseUrl = 'https://idxfalcon.sytes.net/digipay';
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  group('DigiPay Live Production QA Test Suite', () {
    String? token;
    String? bcaBankId;
    String? beneficiaryId;

    test('QA-01: Health check / Banks list inquiry', () async {
      final res = await dio.get('/api/v1/banks');
      expect(res.statusCode, 200);
      expect(res.data['success'], true);
      final banks = res.data['data'] as List;
      expect(banks.isNotEmpty, true);

      final bca = banks.firstWhere((b) => b['code'] == 'BCA');
      expect(bca, isNotNull);
      bcaBankId = bca['id'];
      print('✔ QA-01 Passed: Retrieved ${banks.length} banks from live server.');
    });

    test('QA-02: Check / validate bank account unauthorized guard', () async {
      expect(bcaBankId, isNotNull);
      try {
        await dio.post(
          '/api/v1/beneficiaries/check',
          data: {
            'bank_id': bcaBankId,
            'account_number': '1234567890',
          },
        );
        fail('Should reject request without Bearer token');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 401);
        print('✔ QA-02 Passed: Endpoint strictly guarded by 401 Unauthorized.');
      }
    });

    test('QA-03: User Login & JWT generation', () async {
      final res = await dio.post(
        '/api/v1/auth/login',
        data: {
          'email': 'sender1@example.com',
          'password': 'Password123!',
        },
      );
      expect(res.statusCode, 200);
      expect(res.data['success'], true);
      final data = res.data['data'];
      expect(data['email'], 'sender1@example.com');
      expect(data['bearer_token'], isNotNull);
      token = data['bearer_token'];
      print('✔ QA-03 Passed: User authenticated. Token received.');
    });

    test('QA-04: User Balance query (Live Wallet)', () async {
      expect(token, isNotNull);
      final res = await dio.get(
        '/api/v1/balance',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      expect(res.statusCode, 200);
      expect(res.data['success'], true);
      final balData = res.data['data'];
      expect(balData['currency'], 'IDR');
      expect(balData['available_balance'], isNotNull);
      print('✔ QA-04 Passed: Available Balance = Rp ${balData['available_balance']}');
    });

    test('QA-05: PIN Verification (Layer 2 Security)', () async {
      expect(token, isNotNull);
      final res = await dio.post(
        '/api/v1/auth/pin/verify',
        data: {'pin': '123456'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      expect(res.statusCode, 200);
      expect(res.data['success'], true);
      print('✔ QA-05 Passed: PIN 123456 verified.');
    });

    test('QA-06: Beneficiary Check & Save', () async {
      expect(token, isNotNull);
      expect(bcaBankId, isNotNull);

      // Check account
      final checkRes = await dio.post(
        '/api/v1/beneficiaries/check',
        data: {
          'bank_id': bcaBankId,
          'account_number': '1234567890',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      expect(checkRes.statusCode, 200);
      expect(checkRes.data['data']['account_holder_name'], 'Budi Santoso');

      // Save beneficiary
      final saveRes = await dio.post(
        '/api/v1/beneficiaries',
        data: {
          'bank_id': bcaBankId,
          'account_number': '1234567890',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      expect(saveRes.statusCode, 201);
      beneficiaryId = saveRes.data['data']['id'];
      print('✔ QA-06 Passed: Beneficiary Budi Santoso verified and saved. ID = $beneficiaryId');
    });

    test('QA-07: Get User Beneficiaries list', () async {
      expect(token, isNotNull);
      final res = await dio.get(
        '/api/v1/beneficiaries',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      expect(res.statusCode, 200);
      expect(res.data['success'], true);
      final list = res.data['data'] as List;
      expect(list.isNotEmpty, true);
      if (beneficiaryId == null && list.isNotEmpty) {
        beneficiaryId = list.first['id'];
      }
      print('✔ QA-07 Passed: User has ${list.length} saved beneficiaries.');
    });

    test('QA-08: Transfer Money with Idempotency Key', () async {
      expect(token, isNotNull);
      expect(beneficiaryId, isNotNull);

      final idempotencyKey = const Uuid().v4();
      final res = await dio.post(
        '/api/v1/transfers',
        data: {
          'beneficiary_id': beneficiaryId,
          'amount': 10000,
          'pin': '123456',
          'description': 'QA Automated Test Transfer',
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Idempotency-Key': idempotencyKey,
        }),
      );
      expect(res.statusCode, 201);
      expect(res.data['success'], true);
      final tx = res.data['data']['transaction'];
      expect(tx['amount'], 10000);
      expect(tx['fee'], 6500);
      expect(tx['total_amount'], 16500);
      print('✔ QA-08 Passed: Transfer initiated. Ref: ${tx['reference_no']}, Status: ${tx['status']}');
    });

    test('QA-09: Transfer History query & filtering', () async {
      expect(token, isNotNull);
      final res = await dio.get(
        '/api/v1/transfers',
        queryParameters: {'limit': 5},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      expect(res.statusCode, 200);
      expect(res.data['success'], true);
      final history = res.data['data'] as List;
      expect(history.isNotEmpty, true);
      print('✔ QA-09 Passed: Retrieved ${history.length} transactions from history.');
    });
  });
}
