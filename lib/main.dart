import 'package:flutter/material.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'auth_service.dart';
import 'verification_page.dart';
import 'lobby_page.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

void main() {
  runApp(MyApp());
}

// 1
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _amplifyConfigured = false;
  final _amplify = Amplify();
  final _authService = AuthService();
  @override
  void initState() {
    super.initState();
    _configureAmplify();
    //_authService.checkAuthStatus();
    _authService.showLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery App',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      home: StreamBuilder<AuthState>(
          // 2
          stream: _authService.authStateController.stream,
          builder: (context, snapshot) {
            // 3
            if (snapshot.hasData) {
              return Navigator(
                pages: [
                  // 4
                  // Show Login Page
                  if (snapshot.data.authFlowStatus == AuthFlowStatus.login)
                    MaterialPage(
                        child: LoginPage(
                            didProvideCredentials:
                                _authService.loginWithCredentials,
                            shouldShowSignUp: _authService.showSignUp)),

                  // 5
                  // Show Sign Up Page
                  if (snapshot.data.authFlowStatus == AuthFlowStatus.signUp)
                    MaterialPage(
                        child: SignUpPage(
                            didProvideCredentials:
                                _authService.signUpWithCredentials,
                            shouldShowLogin: _authService.showLogin)),

                  // Show Verification Code Page
                  if (snapshot.data.authFlowStatus ==
                      AuthFlowStatus.verification)
                    MaterialPage(
                        child: VerificationPage(
                            didProvideVerificationCode:
                                _authService.verifyCode)),
                  // Show Camera Flow
                  if (snapshot.data.authFlowStatus == AuthFlowStatus.session)
                    MaterialPage(
                        child: LobbyPage())
                ],
                onPopPage: (route, result) => route.didPop(result),
              );
            } else {
              // 6
              return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              );
            }
          }),
          debugShowCheckedModeBanner: false,
    );
  }

  void _configureAmplify() async {
    _amplify.addPlugin(
        authPlugins: [AmplifyAuthCognito()]);

    if (!mounted) return;

    try {
      await _amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
      print(_amplifyConfigured);
      print('Successfully configured Amplify 🎉');
    } catch (e) {
      print(e);
      print('Could not configure Amplify ☠️');
    }
  }
}
