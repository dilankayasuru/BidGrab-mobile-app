import 'dart:convert';
import 'dart:io';

import 'package:bidgrab/config.dart';
import 'package:bidgrab/controllers/auction_controller.dart';
import 'package:bidgrab/controllers/category_controller.dart';
import 'package:bidgrab/models/category.dart';
import 'package:bidgrab/models/specs.dart';
import 'package:bidgrab/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class CreateNewAuction extends StatefulWidget {
  const CreateNewAuction({super.key});

  static String id = '/create';

  @override
  State<CreateNewAuction> createState() => _CreateNewAuctionState();
}

class _CreateNewAuctionState extends State<CreateNewAuction> {
  late Future<List<Category>> futureCategories;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startingPriceController =
      TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _dimensionsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _manufacturedYearController =
      TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  String selectedCategoryId = "";
  String condition = "";
  String duration = "";
  List<File> images = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _takePhoto() async {
    if (images.length >= 5) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Maximum number of images can upload is 5"),
          content: Lottie.asset("images/lottie/robot.json"),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Okay"),
            )
          ],
        ),
      );
      return;
    }
    final uploadedPhoto =
        await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (uploadedPhoto != null) {
        images.add(File(uploadedPhoto.path));
      }
    });
  }

  Future<void> _uploadPhoto() async {
    final uploadedPhoto =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (uploadedPhoto != null) {
        images.add(File(uploadedPhoto.path));
      }
    });
  }

  void _submit() async {
    final specs = Specs(
      brand: _brandController.text,
      material: _materialController.text,
      dimensions: _dimensionsController.text,
      features: _featuresController.text,
      manufacturedYear: _manufacturedYearController.text,
      color: _colorController.text,
      model: _modelController.text,
      size: _sizeController.text,
      location: _locationController.text,
    );
    await AuctionController.create(
      title: _titleController.text,
      description: _descriptionController.text,
      startingPrice: double.parse(_startingPriceController.text),
      categoryId: selectedCategoryId,
      condition: condition,
      images: images,
      duration: int.parse(duration),
      startingDate: _dateController.text,
      specs: specs.toJson(),
    ).then((response) {
      print(response.body);
      var decoded = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(decoded["message"]),
          content: Lottie.asset(
            response.statusCode != 201
                ? "images/lottie/robot.json"
                : "images/lottie/highfive.json",
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                if (response.statusCode != 201) {
                  Navigator.pushNamed(context, Profile.id);
                }
              },
              child: const Text("Okay"),
            )
          ],
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    futureCategories =
        CategoryController.fetchCategories(http.Client(), 'categories');
  }

  @override
  Widget build(BuildContext context) {

    Future<void> _getLocation() async {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      // Check for location permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${Config.GOOGLE_API_KEY}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'].isNotEmpty) {
          setState(() {
            print(data['results'][0]['formatted_address']);
            _locationController.text = data['results'][0]['formatted_address'];
          });
        } else {
          throw Exception('No address found');
        }
      } else {
        throw Exception('Failed to get address');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new auction"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Images",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _takePhoto();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.camera),
                          Text("Take photos"),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _uploadPhoto();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.upload),
                          Text("Upload photos"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flex(
                  direction: Axis.horizontal,
                  spacing: 8,
                  children: images
                      .map(
                        (image) => Image.file(
                          image,
                          width: 64,
                          height: 64,
                        ),
                      )
                      .toList()),
              const SizedBox(height: 16),
              const Text(
                "Auction information",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Title"),
                ),
                controller: _titleController,
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 5,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Description"),
                ),
                controller: _descriptionController,
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Category>>(
                future: futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('An error has occurred!'),
                    );
                  } else if (snapshot.hasData) {
                    List<Category> categories = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      items: categories
                          .map<DropdownMenuItem<String>>((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedCategoryId = value!;
                        });
                      },
                      hint: const Text("Select category"),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                items: <String>['new', 'user', 'pre-owned', 'reconditioned']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    condition = value!;
                  });
                },
                hint: const Text("Select condition"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Starting Date"),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                items: <String>['1', '3', '5', '7', '10']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('$value Days'),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    duration = value!;
                  });
                },
                hint: const Text("Select duration"),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Starting price"),
                ),
                controller: _startingPriceController,
              ),
              const SizedBox(height: 16),
              const Text(
                "Item specifications - Optional",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Brand"),
                ),
                controller: _brandController,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Model"),
                ),
                controller: _modelController,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Size"),
                ),
                controller: _sizeController,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Color"),
                ),
                controller: _colorController,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Material"),
                ),
                controller: _materialController,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Dimensions"),
                ),
                controller: _dimensionsController,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Manufactured Year"),
                ),
                controller: _manufacturedYearController,
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Features"),
                ),
                controller: _featuresController,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  label: Text("Location"),
                ),
                controller: _locationController,
              ),
              TextButton(
                onPressed: () {
                  _getLocation();
                },
                child: const Text("Get location"),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? double.infinity
                        : 320,
                child: FilledButton(
                  onPressed: () {
                    _submit();
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
