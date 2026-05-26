import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'root_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  late Future<String?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getLoggedUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != null) {
          return const RootShell();
        }
        return const LoginScreen();
      },
    );
  }
}
