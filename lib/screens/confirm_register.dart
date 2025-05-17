import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/screens/loading.dart';
import 'package:qio/screens/login.dart';
import 'package:qio/widgets/login/app_header.dart';
import 'package:qio/widgets/custom_component/custom_text_field.dart';

class ConfirmRigester extends StatefulWidget {
  const ConfirmRigester({super.key});

  @override
  State<ConfirmRigester> createState() => _ConfirmRigesterState();
}

class _ConfirmRigesterState extends State<ConfirmRigester> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  Future<void> _submit() async {
    final email = emailController.text;
    final code = codeController.text;

    if (email.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return;
    }
    if (!mounted) return;
    showLoadingDialog(context);

    final res = await AuthService.verifyCode(email: email, code: code);

    if (!mounted) return;
    hideLoadingDialog(context);

    if (res.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم التأكيد بناح')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.data.toString())));
    }
  }

  Future<void> _reset() async {
    final email = emailController.text;
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يرجى إدخال الإيميل')));
      return;
    }

    if (!mounted) return;
    showLoadingDialog(context);

    final res = await AuthService.resetPasswordRequest(email: email);

    if (!mounted) return;
    hideLoadingDialog(context);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم إرسال الرمز')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.data.toString())));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد التسجيل')),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _reset,
                  child: const Text('إعادة إرسال الرمز'),
                ),
              ],
            ),
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
