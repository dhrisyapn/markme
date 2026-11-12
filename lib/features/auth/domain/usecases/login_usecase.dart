import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/employee_profile.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Result<EmployeeProfile, Failure>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}

