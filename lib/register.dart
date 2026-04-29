import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const _registerApiUrl =
    'http://localhost/flutter_college_news_app/php_api/auth/register.php';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  String selectedRole = 'student';
  String selectedFaculty = '1';

  Future<void> register() async {
    final url = Uri.parse(_registerApiUrl);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "role": selectedRole,
        "faculty_id": selectedRole == 'employee' ? null : selectedFaculty,
      }),
    );

    final data = jsonDecode(response.body);

    if (!mounted) return;

    if (data['status'] == 'success') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("สมัครสมาชิกสำเร็จ")));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${data['message'] ?? 'สมัครไม่สำเร็จ'}"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    await register();
  }

  void _backToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'สมัครสมาชิก',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'สร้างบัญชีเพื่อใช้งานระบบข่าวสารมหาวิทยาลัย',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'ชื่อผู้ใช้',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกชื่อผู้ใช้';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'อีเมล',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) return 'กรุณากรอกอีเมล';
                            if (!email.contains('@')) {
                              return 'กรุณากรอกอีเมลให้ถูกต้อง';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่าน',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'แสดงรหัสผ่าน'
                                  : 'ซ่อนรหัสผ่าน',
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกรหัสผ่าน';
                            }
                            if (value.length < 6) {
                              return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'ยืนยันรหัสผ่าน',
                            prefixIcon: Icon(Icons.verified_user_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณายืนยันรหัสผ่าน';
                            }
                            if (value != _passwordController.text) {
                              return 'รหัสผ่านไม่ตรงกัน';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _register(),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          items: const [
                            DropdownMenuItem(
                              value: 'student',
                              child: Text('นักศึกษา'),
                            ),
                            DropdownMenuItem(
                              value: 'employee',
                              child: Text('พนักงาน'),
                            ),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              selectedRole = value ?? selectedRole;
                            });
                          },
                          decoration: const InputDecoration(labelText: "บทบาท"),
                        ),
                        if (selectedRole != 'employee') ...<Widget>[
                          const SizedBox(height: 16),
                          DropdownButtonFormField(
                            initialValue: selectedFaculty,
                            items: const [
                              DropdownMenuItem(
                                value: '1',
                                child: Text('เทคโนโลยีสารสนเทศ'),
                              ),
                              DropdownMenuItem(
                                value: '2',
                                child: Text('นิติศาสตร์'),
                              ),
                              DropdownMenuItem(
                                value: '3',
                                child: Text('บริหารธุรกิจ'),
                              ),
                              DropdownMenuItem(
                                value: '4',
                                child: Text('ศิลปะศาสตร์'),
                              ),
                              DropdownMenuItem(value: '5', child: Text('บัญชี')),
                              DropdownMenuItem(
                                value: '6',
                                child: Text('โลจิสติกส์และซัพพลายเชน'),
                              ),
                              DropdownMenuItem(
                                value: '7',
                                child: Text('นิเทศศาสตร์'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedFaculty = value.toString();
                              });
                            },
                            decoration: const InputDecoration(labelText: "คณะ"),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _register,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('สมัครสมาชิก'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _backToLogin,
                          child: const Text('มีบัญชีแล้ว? เข้าสู่ระบบ'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
