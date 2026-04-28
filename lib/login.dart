import 'package:flutter/material.dart';
import 'package:flutter_booking/dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future _login() async {
    var url = Uri.parse(
      "http://localhost/flutter_college_news/php_api/auth/login.php",
    );

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _emailController.text,
        "password": _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username หรือ Password ไม่ถูกต้อง"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void login() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => DashboardPage()));
  }

  void _openRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
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
                    // key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'เข้าสู่ระบบ',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'เข้าใช้งานระบบข่าวสารวิทยาลัย',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 28),
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
                          textInputAction: TextInputAction.done,
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
                          onFieldSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _login,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('เข้าสู่ระบบ'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _openRegister,
                          child: const Text('ยังไม่มีบัญชี? สมัครสมาชิก'),
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

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College News'),
        actions: [
          IconButton(
            tooltip: 'ออกจากระบบ',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'ยินดีต้อนรับ',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(displayName, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          const _NewsPreviewCard(
            title: 'ประกาศข่าวสารล่าสุด',
            description:
                'หน้านี้เป็นตัวอย่างหลังเข้าสู่ระบบ ยังไม่เชื่อมต่อ API',
            icon: Icons.campaign_outlined,
          ),
          const SizedBox(height: 12),
          const _NewsPreviewCard(
            title: 'กิจกรรมวิทยาลัย',
            description: 'สามารถนำส่วนนี้ไปเชื่อมฐานข้อมูลหรือ API ภายหลังได้',
            icon: Icons.event_note_outlined,
          ),
        ],
      ),
    );
  }
}

class _NewsPreviewCard extends StatelessWidget {
  const _NewsPreviewCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}
