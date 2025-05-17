import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/category.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/screens/loading.dart';
import 'package:qio/services/location_service.dart';
import 'package:qio/widgets/custom_component/custom_text_field.dart';
import 'package:dio/dio.dart';

class AddOffer extends StatefulWidget {
  const AddOffer({super.key});

  @override
  State<AddOffer> createState() => _AddOfferState();
}

class _AddOfferState extends State<AddOffer> {
  final List<File> imgList = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? offerType;
  String? category;
  String? currency;
  String? location;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final loc = await LocationService.getLocation();
    if (!mounted) return;

    setState(() {
      location = loc;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickMultiImage();
    if (pickedFile.isNotEmpty) {
      if (!mounted) return;

      setState(() {
        imgList.addAll(pickedFile.map((file) => File(file.path)));
      });
    }
  }

  void _addOffer() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context);
      final position = await _requestLocationPermission();
      if (!mounted) return;
      hideLoadingDialog(context);

      try {
        final formData = FormData.fromMap({
          'title': titleController.text,
          'description': descriptionController.text,
          'offer_type': offerType,
          'category_type': category,
          'price': priceController.text,
          'currency_type': currency,
          'phone_number': phoneController.text,
          'latitude': position?.latitude ?? 0,
          'longitude': position?.longitude ?? 0,
          'images': await Future.wait(
            imgList.map((file) async {
              return await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              );
            }).toList(),
          ),
        });

        final res = await DioClient.instance.post(
          "api/offer/offers/create/",
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );

        if (res.statusCode == 201) {
          titleController.clear();
          descriptionController.clear();
          priceController.clear();
          phoneController.clear();
          imgList.clear();
          offerType = null;
          category = null;
          currency = null;
          location = null;
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم إنشاء العرض بنجاح')));
          return;
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(res.data.toString())));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ أثناء الإرسال: $e')));
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('خطأ أثناء الإرسال')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عرض')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child:
                    imgList.isEmpty
                        ? const Center(child: Text('لا توجد صورة محددة'))
                        : CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            autoPlay: true,
                            viewportFraction: 1,
                          ),
                          items:
                              imgList
                                  .map(
                                    (item) => Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => Scaffold(
                                                      appBar: AppBar(
                                                        actions: [
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                            onPressed: () {
                                                              if (!mounted) {
                                                                return;
                                                              }

                                                              setState(() {
                                                                imgList.remove(
                                                                  item,
                                                                );
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      body: Center(
                                                        child: Image.file(
                                                          item,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Image.file(
                                            item,
                                            width: double.infinity,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              if (!mounted) return;

                                              setState(() {
                                                imgList.remove(item);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
              ),
              SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('إضافة صورة'),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            title: const Text('أنا أبحث عن'),
                            value: 'looking',
                            groupValue: offerType,
                            onChanged: (String? value) {
                              if (!mounted) return;

                              setState(() {
                                offerType = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            title: const Text('أنا أعرض'),
                            value: 'offering',
                            groupValue: offerType,
                            onChanged: (String? value) {
                              if (!mounted) return;

                              setState(() {
                                offerType = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      title: 'عنوان العرض',
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال عنوان';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    //Category dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        labelText: 'التصنيف',
                      ),
                      items:
                          OfferCategory.allex.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Icon(
                                    OfferCategory.getIcon(value),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  SizedBox(width: 10),
                                  Text(OfferCategory.translate(value)),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (!mounted) return;

                        setState(() {
                          category = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء تحديد تصنيف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      title: 'وصف العرض',
                      controller: descriptionController,
                      keyboardType: TextInputType.text,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال وصف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            title: 'السعر',
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال سعر';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              labelText: 'العملة',
                            ),
                            items:
                                Currency.values.map<DropdownMenuItem<String>>((
                                  Currency value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value.toString().split('.').last,
                                    child: Text(value.name),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (!mounted) return;

                              setState(() {
                                currency = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء تحديد عملة';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      title: 'رقم الهاتف',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال رقم الهاتف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: FilledButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(200, 50),
                        ),
                        onPressed: _addOffer,
                        child: const Text(
                          'إضافة العرض',
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

  Future<Position?> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition();
        return position;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
