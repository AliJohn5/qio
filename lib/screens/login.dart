import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/screens/change_name.dart';
import 'package:qio/screens/confirm_register.dart';
import 'package:qio/screens/home.dart';
import 'package:qio/screens/loading.dart';
import 'package:qio/screens/register.dart';
import 'package:qio/screens/reset_password.dart';
import 'package:qio/widgets/login/app_header.dart';
import 'package:qio/widgets/custom_component/custom_text_field.dart';
import 'package:qio/widgets/custom_component/password_text_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _submit() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return;
    }
    if (!mounted) return;
    showLoadingDialog(context);
    final res = await AuthService.login(email: email, password: password);
    if (!mounted) return;
    hideLoadingDialog(context);

    if (res.statusCode == 200) {
      String firstName = res.data['first_name'] ?? '';
      String lastName = res.data['last_name'] ?? '';

      if (firstName == '' || lastName == '') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChangeName()),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Home()),
          (Route route) => false,
        );
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم تسجيل الدخول بنجاح')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.data.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            AppHeader(),
            CustomTextField(
              title: 'البريد الإلكتروني',
              controller: emailController,
            ),
            const SizedBox(height: 10),
            PasswordTextField(passwordController: passwordController),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetPassword()),
                    );
                  },
                  child: const Text('هل نسيت كلمة المرور؟'),
                ),
              ],
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width, 50),
              ),
              onPressed: _submit,
              child: Text(
                'تسجيل الدخول',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 5),
                const Text('ليس لديك حساب؟'),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: const Text('إنشاء حساب'),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 5),
                const Text('تريد تأكيد التسجيل؟'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmRigester(),
                      ),
                    );
                  },
                  child: const Text('تأكيد'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
