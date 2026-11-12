import '../../../../core/config/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/attendance_action.dart';
import '../models/attendance_record_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<({AttendanceAction action, AttendanceRecordModel record})> markAttendance({
    required String sessionId,
    required String token,
    required double lat,
    required double lng,
  });

  Future<List<AttendanceRecordModel>> getMyHistory(String employeeId);

  Future<AttendanceRecordModel?> getTodayRecord(String employeeId, String todayDateUtc);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final DioClient _client;

  const AttendanceRemoteDataSourceImpl(this._client);

  @override
  Future<({AttendanceAction action, AttendanceRecordModel record})> markAttendance({
    required String sessionId,
    required String token,
    required double lat,
    required double lng,
  }) async {
    final response = await _client.post(
      AppConstants.rpcMarkAttendance,
      data: {
        'p_session_id': sessionId,
        'p_token': token,
        'p_lat': lat,
        'p_lng': lng,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Malformed mark_attendance RPC response');
    }

    final actionStr = data['action']?.toString() ?? 'check_in';
    final action = AttendanceAction.fromString(actionStr);

    final recordMap = data['record'] as Map<String, dynamic>;
    final record = AttendanceRecordModel.fromJson(recordMap);

    return (action: action, record: record);
  }

  @override
  Future<List<AttendanceRecordModel>> getMyHistory(String employeeId) async {
    final response = await _client.get(
      AppConstants.endpointAttendanceRecords,
      queryParameters: {
        'employee_id': 'eq.$employeeId',
        'order': 'work_date.desc',
      },
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((item) => AttendanceRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<AttendanceRecordModel?> getTodayRecord(String employeeId, String todayDateUtc) async {
    final response = await _client.get(
      AppConstants.endpointAttendanceRecords,
      queryParameters: {
        'employee_id': 'eq.$employeeId',
        'work_date': 'eq.$todayDateUtc',
        'limit': 1,
      },
    );

    final data = response.data;
    if (data is List && data.isNotEmpty) {
      return AttendanceRecordModel.fromJson(data.first as Map<String, dynamic>);
    }
    return null;
  }
}

