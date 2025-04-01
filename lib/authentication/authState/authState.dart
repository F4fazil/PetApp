import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class Authstate extends Equatable {
  const Authstate();
  @override
  List<Object> get props => [];
}

class AuthInitial extends Authstate {}

class GoogleAuthenticated extends Authstate {
  final User user;
  const GoogleAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthLoading extends Authstate {}

class Authenticated extends Authstate {}

class UnAuthenticated extends Authstate {}

class OtpSentState extends Authstate {
  final String verificationId;
  const OtpSentState(this.verificationId);

  @override
  List<Object> get props => [verificationId];
}

class AuthError extends Authstate {
  final String error;
  const AuthError(this.error);
  @override
  List<Object> get props => [error];
}
