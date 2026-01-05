import '../entities/session.dart';

abstract class AuthRepository {
  Future<Session> login(
    String username,
    String password, {
    String? deviceToken,
  });

  Future<void> saveSession(Session session);

  Future<Session?> getSession();

  Future<void> clearSession();
}
