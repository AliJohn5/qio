import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/screens/loading.dart';
import 'package:qio/screens/login.dart';
import 'package:qio/widgets/custom_component/password_text_field.dart';
import 'package:qio/widgets/login/app_header.dart';
import 'package:qio/widgets/custom_component/custom_text_field.dart';

class ConfirmReset extends StatefulWidget {
  const ConfirmReset({super.key});

  @override
  State<ConfirmReset> createState() => _ConfirmResetState();
}

class _ConfirmResetState extends State<ConfirmReset> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _submit() async {
    final email = emailController.text;
    final code = codeController.text;
    final password = passwordController.text;

    if (email.isEmpty || code.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return;
    }
    if (!mounted) return;
    showLoadingDialog(context);

    final res = await AuthService.resetPasswordConfirm(
      email: email,
      code: code,
      newPassword: password,
    );

    if (!mounted) return;
    hideLoadingDialog(context);

    if (res.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم التأكيد بنجاح')));
    }
    else{
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.data.toString())));
    }

    // Save the login state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تغيير كلمة المرور')),
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
            CustomTextField(title: 'الكود', controller: codeController),
            const SizedBox(height: 10),
            PasswordTextField(passwordController: passwordController),
            const SizedBox(height: 10),

            FilledButton(
              style: FilledButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width, 50),
              ),
              onPressed: _submit,
              child: Text(
                'تأكيد',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
