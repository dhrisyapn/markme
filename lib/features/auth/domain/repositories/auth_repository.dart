import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/employee_profile.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Authenticates with Supabase Auth via email and password, then fetches the profile.
  Future<Result<EmployeeProfile, Failure>> login({
    required String email,
    required String password,
  });

  /// Restores session using stored JWT tokens and profile cache.
  Future<Result<EmployeeProfile, Failure>> restoreSession();

  /// Logs out of Supabase and clears secure storage and SQLite local data.
  Future<Result<void, Failure>> logout();

  /// Fetches the fresh employee profile for the currently authenticated user.
  Future<Result<EmployeeProfile, Failure>> getProfile(String userId);
}

