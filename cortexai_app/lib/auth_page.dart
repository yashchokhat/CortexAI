import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'widgets/cupertino_auth_field.dart';
import 'widgets/glass_container.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  final bool initialIsRegister;

  const AuthPage({
    super.key,
    this.initialIsRegister = false,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool _isRegister;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
    _emailController.text = 'abhixyzxyz@gmail.com';
    _nameController.text = 'Abhishek Patel';
    _passwordController.text = 'password123';
    _repeatPasswordController.text = 'password123';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthAction() async {
    setState(() => _isLoading = true);

    try {
      if (_isRegister) {
        await AuthService.instance.registerWithEmail(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await AuthService.instance.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.04, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Authentication Error', style: TextStyle(decoration: TextDecoration.none)),
            content: Text(e.toString(), style: const TextStyle(decoration: TextDecoration.none)),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFF000000), // Pure #000
        textTheme: CupertinoTextThemeData(
          primaryColor: Colors.white,
          textStyle: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
            fontFamily: '.SF Pro Text',
          ),
        ),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          color: Colors.white,
          fontFamily: '.SF Pro Text',
        ),
        child: CupertinoPageScaffold(
          backgroundColor: const Color(0xFF000000), // Pure #000
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTopHeader(),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: _buildFormCard(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: const Color(0x2EFFFFFF),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Row: Back button & App Name Logo (Head.png)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlassContainer(
                width: 40,
                height: 40,
                blur: 20,
                borderRadius: BorderRadius.circular(20),
                backgroundColor: const Color(0x1FFFFFFF),
                borderColor: const Color(0x33FFFFFF),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (_isRegister) {
                      setState(() => _isRegister = false);
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                  child: const Icon(
                    CupertinoIcons.chevron_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              // App Name Logo from Head.png (enlarged for prominence)
              Hero(
                tag: 'cortex_head_logo',
                child: Image.asset(
                  'lib/icon/head_banner.png',
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 40), // Balances the back button
            ],
          ),

          const SizedBox(height: 16),

          // Title
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _isRegister
                  ? 'Registration in to your\nAccount'
                  : 'Sign in to your\nAccount',
              key: ValueKey(_isRegister ? 'reg_title' : 'login_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                decoration: TextDecoration.none,
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                height: 1.25,
                letterSpacing: -0.2,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _isRegister
                  ? 'Please fill in the details to create your account.'
                  : 'Please enter your credentials to continue.',
              key: ValueKey(_isRegister ? 'reg_sub' : 'login_sub'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                decoration: TextDecoration.none,
                color: Color(0x99FFFFFF), // 60% white
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF080808),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border(
          top: BorderSide(
            color: Color(0x2EFFFFFF),
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22.0, 24.0, 22.0, 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Registration: Full Name
          if (_isRegister) ...[
            CupertinoAuthField(
              label: 'Full Name',
              controller: _nameController,
              placeholder: 'Abhishek Patel',
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 14),
          ],

          // Email
          CupertinoAuthField(
            label: 'Email',
            controller: _emailController,
            placeholder: 'abhixyzxyz@gmail.com',
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 14),

          // Password
          CupertinoAuthField(
            label: 'Password',
            controller: _passwordController,
            isPassword: true,
          ),

          // Registration: Repeat Password
          if (_isRegister) ...[
            const SizedBox(height: 14),
            CupertinoAuthField(
              label: 'Repeat Password',
              controller: _repeatPasswordController,
              isPassword: true,
            ),
          ],

          // Forgot Password (Login only)
          if (!_isRegister) ...[
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                minSize: 20,
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Reset Password', style: TextStyle(decoration: TextDecoration.none)),
                      content: const Text(
                        'A password reset link will be sent to your registered email address.',
                        style: TextStyle(decoration: TextDecoration.none),
                      ),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action Button (Login / Register): High-end Pure White with Black Text
          Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(26),
              onPressed: _isLoading ? null : _handleAuthAction,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Center(
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: Colors.black)
                      : Text(
                          _isRegister ? 'Register' : 'Login',
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black, // Pure black on white
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ),
          ),

          // Social logins (Login only)
          if (!_isRegister) ...[
            const SizedBox(height: 24),

            // Divider: Or login with
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0x26FFFFFF),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                  child: Text(
                    'Or login with',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Color(0x99FFFFFF),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0x26FFFFFF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Social Buttons Row
            Row(
              children: [
                // Apple Button
                Expanded(
                  child: _buildSocialButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      await AuthService.instance.signInWithApple();
                      if (mounted) _navigateToHome();
                    },
                    icon: const Icon(
                      Icons.apple,
                      color: Colors.white,
                      size: 22,
                    ),
                    label: 'Apple',
                  ),
                ),
                const SizedBox(width: 14),
                // Google Button
                Expanded(
                  child: _buildSocialButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      await AuthService.instance.signInWithGoogle();
                      if (mounted) _navigateToHome();
                    },
                    icon: _buildGoogleGLogo(),
                    label: 'Google',
                  ),
                ),
              ],
            ),
          ],

          const Spacer(),
          const SizedBox(height: 24),

          // Bottom Toggle Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have account? ",
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: Color(0x80FFFFFF),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 20,
                onPressed: () {
                  setState(() {
                    _isRegister = !_isRegister;
                  });
                },
                child: Text(
                  _isRegister ? 'Log In' : 'Register',
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required Widget icon,
    required String label,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0x26FFFFFF),
          width: 1,
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(24),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                decoration: TextDecoration.none,
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleGLogo() {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: const Text(
        'G',
        style: TextStyle(
          decoration: TextDecoration.none,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
          fontFamily: 'sans-serif',
        ),
      ),
    );
  }
}
