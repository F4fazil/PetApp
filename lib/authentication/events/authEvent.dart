import 'package:equatable/equatable.dart';

abstract class Authevent extends Equatable {
  const Authevent();

  @override
  List<Object> get props => [];
}

class SignInRequested extends Authevent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class SignupIsRequested extends Authevent {
  final String name;
  final String email;
  final String password;
  final String confirmpassword;
  const SignupIsRequested(
    this.email,
    this.password,
    this.confirmpassword,
    this.name,
  );
  @override
  List<Object> get props => [email, password];
}

class LogoutIsRequested extends Authevent {}
