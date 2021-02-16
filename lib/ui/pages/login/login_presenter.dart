abstract class LoginPresenter {
  Stream<String> get emailErrorStream;
  Stream<String> get passwordErrorStream;
  Stream<String> get mainerrorStream;
  Stream<bool> get isFormErrorStream;
  Stream<bool> get isLoading;
  void validateEmail(String email);
  void validatePassword(String pass);
  Future<void> auth();
  void dispose();
}
