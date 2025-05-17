import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/screens/confirm_register.dart';
import 'package:qio/screens/loading.dart';
import 'package:qio/screens/login.dart';
import 'package:qio/screens/terms.dart';
import 'package:qio/widgets/login/app_header.dart';
import 'package:qio/widgets/custom_component/custom_switch.dart';
import 'package:qio/widgets/custom_component/custom_text_field.dart';
import 'package:qio/widgets/custom_component/password_text_field.dart';
import 'package:qio/widgets/register/register_radio_button.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String _radioGroup = 'Private';
  bool _agreed = false;

  void _handleRadioValueChange(String? value) {
      if (!mounted) return;

    setState(() {
      _radioGroup = value!;
    });
  }

  void _submit() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty || !_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى ملء جميع الحقول والموافقة على الشروط والأحكام'),
        ),
      );
      return;
    }

    if (!mounted) return;
    showLoadingDialog(context);
    final res = await AuthService.register(
      email: email,
      password: password,
      userType: _radioGroup == 'Private' ? 'private' : 'public',
    );
    if (!mounted) return;
    hideLoadingDialog(context);

    if (res.statusCode == 201) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfirmRigester()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إنشاء الحساب, الرجاء تأكيده بالكود المرسل إلى إيميلك',
          ),
        ),
      );
    } else {
      if (res.data['email'][0] != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res.data['email'].toString())));
      } else if (res.data['password'] != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.data['password'].toString())),
        );
      } else if (res.data['user_type'] != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.data['user_type'].toString())),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ ما يرجى إعادة المحاولة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(),
            Text('نوع الحساب', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            Row(
              children: [
                RegisterRadioButton(
                  groupValue: _radioGroup,
                  title: 'خاص',
                  value: 'Private',
                  onChanged: _handleRadioValueChange,
                ),
                SizedBox(width: 10),
                RegisterRadioButton(
                  groupValue: _radioGroup,
                  title: 'شركة',
                  value: 'Company',
                  onChanged: _handleRadioValueChange,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'معلومات الحساب',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 20),
            CustomTextField(
              title: 'البريد الإلكتروني',
              controller: emailController,
            ),
            const SizedBox(height: 10),
            PasswordTextField(passwordController: passwordController),
            const SizedBox(height: 10),
            //switch button to agree to terms and conditions
            Row(
              children: [
                CustomSwitch(
                  value: _agreed,
                  onChanged: (value) {
      if (!mounted) return;

                    setState(() {
                      _agreed = value;
                    });
                  },
                ),
                const SizedBox(width: 10),
                Text('أوافق على'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Terms()),
                    );
                  },
                  child: const Text('الشروط والأحكام'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width, 50),
              ),
              onPressed: _submit,
              child: Text(
                'إنشاء حساب',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 5),
                const Text('لديك حساب؟'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
