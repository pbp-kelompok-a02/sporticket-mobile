import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporticket_mobile/screens/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _imageBase64;
  String? _imageName;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      String mimeType = "image/jpeg";
      if (pickedFile.path.endsWith(".png")) {
        mimeType = "image/png";
      }

      final String formattedBase64 = "data:$mimeType;base64,$base64Image";

      setState(() {
        _imageBase64 = formattedBase64;
        _imageName = pickedFile.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final request = context.watch<CookieRequest>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
                Text(
                  "Back",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 30,
                              horizontal: 20,
                            ),
                            color: primaryColor,
                            child: Column(
                              children: [
                                const Text(
                                  "Welcome!",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "To keep connected with Sporticket, please login with your personal details.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: primaryColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.all(24.0),
                            color: Colors.white,
                            child: Column(
                              children: [
                                const Text(
                                  "Register",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                _buildInputLabel("Full name"),
                                _buildTextField(
                                  controller: _nameController,
                                  hint: "Your name",
                                  primaryColor: primaryColor,
                                ),
                                const SizedBox(height: 16),

                                _buildInputLabel("Email"),
                                _buildTextField(
                                  controller: _emailController,
                                  hint: "you@example.com",
                                  primaryColor: primaryColor,
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInputLabel("Password"),
                                          _buildTextField(
                                            controller: _passwordController,
                                            hint: "Password",
                                            primaryColor: primaryColor,
                                            isPassword: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInputLabel("Confirm Password"),
                                          _buildTextField(
                                            controller:
                                                _confirmPasswordController,
                                            hint: "Confirm Password",
                                            primaryColor: primaryColor,
                                            isPassword: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                _buildInputLabel("Phone (optional)"),
                                _buildTextField(
                                  controller: _phoneController,
                                  hint: "Enter your phone number",
                                  primaryColor: primaryColor,
                                ),
                                const SizedBox(height: 16),

                                _buildInputLabel("Profile photo (optional)"),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _imageName ?? "Choose file...",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (_imageBase64 != null)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        height: 45,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (_passwordController.text !=
                                                _confirmPasswordController
                                                    .text) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Passwords do not match",
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                              return;
                                            }

                                            setState(() => _isLoading = true);

                                            try {
                                              final response = await request.postJson(
                                                "https://laudya-michelle-sporticket.pbp.cs.ui.ac.id/account/register-mobile/",
                                                jsonEncode({
                                                  'name': _nameController.text,
                                                  'email':
                                                      _emailController.text,
                                                  'password':
                                                      _passwordController.text,
                                                  'password2':
                                                      _confirmPasswordController
                                                          .text,
                                                  'phone_number':
                                                      _phoneController.text,
                                                  'profile_photo':
                                                      _imageBase64 ?? "",
                                                }),
                                              );

                                              if (context.mounted) {
                                                setState(
                                                  () => _isLoading = false,
                                                );

                                                if (response['success'] ==
                                                    true) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        response['message'],
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginPage(),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        response['message'] ??
                                                            "Registration failed",
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                setState(
                                                  () => _isLoading = false,
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Error: $e"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: const Text(
                                            'Create account',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Color primaryColor,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}