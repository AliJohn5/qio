import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/screens/home.dart';
import 'package:qio/screens/loading.dart';

class ChangeName extends StatefulWidget {
  const ChangeName({super.key});

  @override
  State<ChangeName> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  final TextEditingController firstNameControler = TextEditingController();
  final TextEditingController lastNameControler = TextEditingController();

  void _submit() async {
    final firstName = firstNameControler.text;
    final lastName = lastNameControler.text;

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يرجى إدخال جميع الحقول')));
    }
    if (!mounted) return;
    showLoadingDialog(context);

    final res = await DioClient.instance.post(
      '/api/users/name/',
      data: {'first_name': firstName, 'last_name': lastName},
    );

    if (!mounted) return;
    hideLoadingDialog(context);

    if (res.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم التعيين')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.data.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تغيير الاسم')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text('يرجى إدخال اسمك الأول والأخير.'),
            const SizedBox(height: 10),
            TextField(
              controller: firstNameControler,
              decoration: const InputDecoration(
                hintText: 'الاسم الأول',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 10),
            TextField(
              controller: lastNameControler,
              decoration: const InputDecoration(
                hintText: 'الكنية',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width, 50),
              ),
              onPressed: _submit,
              child: Text(
                'تغيير الاسم',
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
