
import 'package:campus_mart_admin/features/auth/repository/auth_repository.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(authRepoService: ref.watch(authRepoProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository authRepoService;
  AuthController({required this.authRepoService})
      : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await authRepoService.login(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  Future<void> signout() async {
    state = const AsyncValue.loading();
    try {
      await authRepoService.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
