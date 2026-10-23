import 'package:aku_motor/core/network/api_client.dart';
import 'package:aku_motor/features/motors/data/api_motor_repository.dart';
import 'package:aku_motor/features/motors/domain/motor.dart';
import 'package:flutter_test/flutter_test.dart';

class MockApiClient implements ApiClient {
  MockApiClient({
    this.response = const ApiResponse(statusCode: 200, body: '[]'),
    this.postResponse,
    this.putResponse,
    this.deleteResponse,
    this.throwException,
  });

  ApiResponse response;
  ApiResponse? postResponse;
  ApiResponse? putResponse;
  ApiResponse? deleteResponse;
  Object? throwException;

  String? requestedPath;
  Map<String, dynamic>? requestedBody;

  @override
  Future<ApiResponse> get(String path) async {
    requestedPath = path;
    if (throwException != null) throw throwException!;
    return response;
  }

  @override
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    requestedPath = path;
    requestedBody = body;
    if (throwException != null) throw throwException!;
    return postResponse ?? response;
  }

  @override
  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    requestedPath = path;
    requestedBody = body;
    if (throwException != null) throw throwException!;
    return putResponse ?? response;
  }

  @override
  Future<ApiResponse> delete(String path) async {
    requestedPath = path;
    if (throwException != null) throw throwException!;
    return deleteResponse ?? response;
  }
}

void main() {
  // =========================================================================
  // UNIT TEST 1: MODEL VALID
  // =========================================================================
  test('Unit Test 1 (model valid): parsing JSON valid menghasilkan entitas Motor yang benar', () {
    final validJson = {
      'Id': 101,
      'Brand': 'Honda',
      'Model': 'Vario 160',
      'Year': 2024,
      'CurrentKilometer': 8500,
      'CreatedAt': '2026-10-01T10:00:00.000Z',
    };

    final motor = Motor.fromJson(validJson);

    expect(motor.id, '101');
    expect(motor.brand, 'Honda');
    expect(motor.model, 'Vario 160');
    expect(motor.year, 2024);
    expect(motor.currentKilometer, 8500);
    expect(motor.createdAt, DateTime.parse('2026-10-01T10:00:00.000Z'));
  });

  // =========================================================================
  // UNIT TEST 2: MODEL INVALID
  // =========================================================================
  test('Unit Test 2 (model invalid): parsing JSON tanpa atribut wajib melempar FormatException', () {
    final missingBrandJson = {
      'Id': 102,
      // 'Brand' sengaja dihilangkan
      'Model': 'NMAX 155',
      'Year': 2023,
      'CurrentKilometer': 12000,
    };

    expect(
      () => Motor.fromJson(missingBrandJson),
      throwsA(isA<FormatException>()),
    );

    final invalidYearJson = {
      'Id': 103,
      'Brand': 'Yamaha',
      'Model': 'Aerox',
      'Year': 'bukan_angka_tahun',
      'CurrentKilometer': 5000,
    };

    expect(
      () => Motor.fromJson(invalidYearJson),
      throwsA(isA<FormatException>()),
    );
  });

  // =========================================================================
  // UNIT TEST 3: API SUKSES
  // =========================================================================
  test('Unit Test 3 (API sukses): memuat daftar data motor saat backend merespons HTTP 200', () async {
    const jsonResponse = '''
    [
      {
        "Id": 1,
        "Brand": "Honda",
        "Model": "Beat Street",
        "Year": 2023,
        "CurrentKilometer": 6000,
        "CreatedAt": "2026-10-01T08:00:00.000Z"
      },
      {
        "Id": 2,
        "Brand": "Yamaha",
        "Model": "NMAX 155",
        "Year": 2024,
        "CurrentKilometer": 14000,
        "CreatedAt": "2026-10-05T09:30:00.000Z"
      }
    ]
    ''';

    final mockClient = MockApiClient(
      response: const ApiResponse(statusCode: 200, body: jsonResponse),
    );
    final repository = ApiMotorRepository(mockClient);

    final motors = await repository.getAll();

    expect(mockClient.requestedPath, '/motors');
    expect(motors.length, 2);
    expect(motors[0].brand, 'Honda');
    expect(motors[0].model, 'Beat Street');
    expect(motors[1].brand, 'Yamaha');
    expect(motors[1].currentKilometer, 14000);
  });

  // =========================================================================
  // UNIT TEST 4: DATA KOSONG
  // =========================================================================
  test('Unit Test 4 (data kosong): mengembalikan list kosong [] saat response backend []', () async {
    final mockClient = MockApiClient(
      response: const ApiResponse(statusCode: 200, body: '[]'),
    );
    final repository = ApiMotorRepository(mockClient);

    final motors = await repository.getAll();

    expect(mockClient.requestedPath, '/motors');
    expect(motors, isEmpty);
  });

  // =========================================================================
  // UNIT TEST 5: HTTP GAGAL
  // =========================================================================
  test('Unit Test 5 (HTTP gagal): melempar ApiException saat server merespons non-200 (HTTP 500)', () async {
    final mockClient = MockApiClient(
      response: const ApiResponse(
        statusCode: 500,
        body: '{"Message": "Terjadi kesalahan internal pada server database."}',
      ),
    );
    final repository = ApiMotorRepository(mockClient);

    expect(
      () => repository.getAll(),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
      ),
    );
  });

  // =========================================================================
  // UNIT TEST 6: JSON RUSAK
  // =========================================================================
  test('Unit Test 6 (JSON rusak): melempar FormatException saat response HTTP 200 malformed', () async {
    final mockClient = MockApiClient(
      response: const ApiResponse(
        statusCode: 200,
        body: '{"Id": 1, "Brand": "Yamaha", INVALID_JSON_SYNTAX_HERE',
      ),
    );
    final repository = ApiMotorRepository(mockClient);

    expect(
      () => repository.getAll(),
      throwsA(isA<FormatException>()),
    );
  });

  // =========================================================================
  // UNIT TEST 7: CREATE / POST KE BACKEND (TAMBAHAN)
  // =========================================================================
  test('Unit Test 7 (Create POST): POST data draft ke /motors dan menerima ID baru', () async {
    const createdResponse = '''
    {
      "Id": 99,
      "Brand": "Suzuki",
      "Model": "Satria F150",
      "Year": 2022,
      "CurrentKilometer": 9000,
      "CreatedAt": "2026-10-10T12:00:00.000Z"
    }
    ''';

    final mockClient = MockApiClient(
      postResponse: const ApiResponse(statusCode: 201, body: createdResponse),
    );
    final repository = ApiMotorRepository(mockClient);

    const draft = MotorDraft(
      brand: 'Suzuki',
      model: 'Satria F150',
      year: 2022,
      currentKilometer: 9000,
    );

    final created = await repository.create(draft);

    expect(mockClient.requestedPath, '/motors');
    expect(mockClient.requestedBody?['Brand'], 'Suzuki');
    expect(created.id, '99');
    expect(created.model, 'Satria F150');
  });

  // =========================================================================
  // UNIT TEST 8: UPDATE / PUT KE BACKEND (TAMBAHAN)
  // =========================================================================
  test('Unit Test 8 (Update PUT): update data ke /motors/:id dan menerima hasil update', () async {
    const updatedResponse = '''
    {
      "Id": 99,
      "Brand": "Suzuki",
      "Model": "Satria F150 Fi",
      "Year": 2022,
      "CurrentKilometer": 10500,
      "CreatedAt": "2026-10-10T12:00:00.000Z"
    }
    ''';

    final mockClient = MockApiClient(
      putResponse: const ApiResponse(statusCode: 200, body: updatedResponse),
    );
    final repository = ApiMotorRepository(mockClient);

    const draft = MotorDraft(
      brand: 'Suzuki',
      model: 'Satria F150 Fi',
      year: 2022,
      currentKilometer: 10500,
    );

    final updated = await repository.update('99', draft);

    expect(mockClient.requestedPath, '/motors/99');
    expect(updated.model, 'Satria F150 Fi');
    expect(updated.currentKilometer, 10500);
  });

  // =========================================================================
  // UNIT TEST 9: DELETE KE BACKEND (TAMBAHAN)
  // =========================================================================
  test('Unit Test 9 (Delete DELETE): menghapus data via DELETE /motors/:id dengan status 204', () async {
    final mockClient = MockApiClient(
      deleteResponse: const ApiResponse(statusCode: 204, body: ''),
    );
    final repository = ApiMotorRepository(mockClient);

    await repository.delete('99');

    expect(mockClient.requestedPath, '/motors/99');
  });
}
