import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qio/api/users.dart';
import 'package:qio/widgets/custom_component/custom_text_field.dart';
import 'package:qio/widgets/register/register_radio_button.dart';
import 'package:dio/dio.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final List<File> imgList = [];
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String _radioGroup = 'Private';
  String? imageURL;
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _handleRadioValueChange(String? value) {
    if (!mounted) return;

    setState(() {
      _radioGroup = value!;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        imgList.clear(); // Replace old image
        imgList.add(File(pickedFile.path));
        imageURL = null; // Remove server image preview
      });
    }
  }

  void _editProfile() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });
    try {
      // 1. First, update profile data
      final profileRes = await DioClient.instance.patch(
        "api/users/modify/",
        data: {
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'phone_number': phoneController.text,
          'user_type': _radioGroup == 'Private' ? 'private' : 'public',
        },
      );

      if (profileRes.statusCode == 200 || profileRes.statusCode == 201) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
        );
      }

      // 2. Then, upload the image if selected
      if (imgList.isNotEmpty) {
        for (final file in imgList) {
          FormData formData = FormData.fromMap({
            "file": await MultipartFile.fromFile(file.path),
          });

          final imageRes = await DioClient.instance.post(
            "api/users/upload-image/",
            data: formData,
            options: Options(headers: {"Content-Type": "multipart/form-data"}),
          );

          if (imageRes.statusCode == 200 || imageRes.statusCode == 201) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفع الصورة بنجاح')),
            );
          } else {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل رفع الصورة: ${imageRes.statusMessage}'),
              ),
            );
          }
        }
      }

      _getUserData();
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  void _getUserData() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    final resProfile = await DioClient.instance.get("api/users/profile/");

    if (resProfile.statusCode == 200) {
      firstNameController.text = resProfile.data['first_name'] ?? '';
      lastNameController.text = resProfile.data['last_name'] ?? '';
      phoneController.text = resProfile.data['phone_number'] ?? '';
      _radioGroup =
          resProfile.data['user_type'] == 'public' ? "Company" : "Private";
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      final res = await DioClient.instance.get("api/users/image/");

      if (res.statusCode == 200) {
        String imageURL1 = res.data[0]['image'] ?? "";
        if (imageURL1.startsWith('/')) imageURL1 = imageURL1.substring(1);
        if (!mounted) return;

        setState(() {
          imageURL = domain + imageURL1;
          isLoading = false;
        });
      }
    }
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildImageViewer() {
    if (imgList.isNotEmpty) {
      return CarouselSlider(
        options: CarouselOptions(
          height: 200,
          autoPlay: true,
          viewportFraction: 1,
        ),
        items:
            imgList.map((file) {
              return Stack(
                children: [
                  Image.file(file, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          imgList.remove(file);
                        });
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
      );
    } else if (imageURL != null) {
      return Stack(
        children: [
          Image.network(
            imageURL!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ],
      );
    } else {
      return const Center(
        child: Text('لا توجد صورة محددة', style: TextStyle(fontSize: 16)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 200, child: _buildImageViewer()),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('اختيار صورة جديدة'),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              title: 'الاسم الأول',
                              controller: firstNameController,
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              title: 'الاسم الأخير',
                              controller: lastNameController,
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              title: 'رقم الهاتف',
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'نوع الحساب',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                RegisterRadioButton(
                                  groupValue: _radioGroup,
                                  title: 'خاص',
                                  value: 'Private',
                                  onChanged: _handleRadioValueChange,
                                ),
                                const SizedBox(width: 10),
                                RegisterRadioButton(
                                  groupValue: _radioGroup,
                                  title: 'شركة',
                                  value: 'Company',
                                  onChanged: _handleRadioValueChange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: FilledButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(200, 50),
                                ),
                                onPressed: _editProfile,
                                child: const Text(
                                  'تعديل الحساب',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
