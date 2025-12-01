import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final Color primaryBlue = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // ini agar body memanjang ke belakang AppBar agar background full screen
      extendBodyBehindAppBar: true,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100, // agar ada space untuk tombol "Back"
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8), 
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios, color: primaryBlue, size: 20), 
                Text(
                  "Back", 
                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      
      body: Stack(
        children: [
          // background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login-background.png'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Column(
                        children: [                          
                          // promosi registrasi
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                            color: primaryBlue,
                            child: Column(
                              children: [
                                const Text(
                                  "Hello, Friend!",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Enter your personal details and start your ticket shopping with Sporticket.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: mengarah ke halaman Register
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: primaryBlue,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  ),
                                  child: const Text(
                                    "Register",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // form login
                          Container(
                            padding: const EdgeInsets.all(24.0),
                            color: Colors.white,
                            child: Column(
                              children: [
                                const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // input email
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Email", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        hintText: "Enter your email",
                                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: primaryBlue, width: 2),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // input password
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Password", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: "Enter your password",
                                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: primaryBlue, width: 2),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),

                                // checkbox remember me
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: primaryBlue,
                                        side: BorderSide(color: Colors.grey.shade400),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Remember me",
                                      style: TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // tombol login
                                _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : SizedBox(
                                    width: double.infinity,
                                    height: 45,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () async {
                                        setState(() => _isLoading = true);
                                        
                                        // TODO: ganti jadi link pws
                                        final response = await request.login(
                                          "http://10.0.2.2:8000/account/login-mobile/", 
                                          {
                                            'username': _emailController.text,
                                            'password': _passwordController.text,
                                            'remember_me': _rememberMe,
                                          },
                                        );

                                        setState(() => _isLoading = false);

                                        if (request.loggedIn) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text("Welcome ${response['username']}!"),
                                              backgroundColor: Colors.green,
                                              behavior: SnackBarBehavior.floating,
                                            ));
                                            Navigator.pop(context);
                                          }
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(response['message'] ?? "Login failed"),
                                              backgroundColor: Colors.red,
                                              behavior: SnackBarBehavior.floating,
                                            ));
                                          }
                                        }
                                      },
                                      child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}