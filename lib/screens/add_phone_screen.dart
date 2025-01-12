import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/phone_provider.dart';
import 'package:uuid/uuid.dart';

import '../constants/constants.dart';
import '../models/phone.dart';
import '../widgets/price_picker.dart';

class AddPhoneScreen extends StatefulWidget {
  static const routeName = "/add-phone";
  const AddPhoneScreen({super.key});

  @override
  State<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedBrand;
  String? _selectedRam;
  String? _selectedStorage;
  int _selectedPrice = 0;

  TextEditingController nameController = TextEditingController();

  bool priceIsValid = true;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Phone'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                brandDropDown(),
                const SizedBox(height: 18),
                phoneNameField(context),
                const SizedBox(height: 18),
                storageRamRow(),
                const SizedBox(height: 18),
                priceField(),
                // const SizedBox(height: 18),
                // imageUrlField(context),
                const SizedBox(height: 18),
                addPhoneButton(phoneProvider, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton addPhoneButton(
      PhoneProvider phoneProvider, BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_selectedPrice == 0) {
          setState(() {
            priceIsValid = false;
          });
        } else if (!priceIsValid) {
          setState(() {
            priceIsValid = true;
          });
        }
        if (_formKey.currentState!.validate()) {
          // Get other values and create the Phone instance
          // You can access _selectedBrand.name and other properties here
          Phone newPhone = Phone(
            id: const Uuid().v4(),
            brand: _selectedBrand!,
            ram: _selectedRam!,
            storage: _selectedStorage!,
            price: _selectedPrice,
            name: nameController.text,
            isAvailable: true,
          );
          phoneProvider.addPhone(newPhone);
          Navigator.pop(context);
        }
      },
      child: const Text('Add the Phone'),
    );
  }

  DropdownButtonFormField<String> brandDropDown() {
    return DropdownButtonFormField<String>(
      value: _selectedBrand,
      onChanged: (String? newValue) {
        setState(() {
          _selectedBrand = newValue;
        });
      },
      items: brandsList.map<DropdownMenuItem<String>>((String brand) {
        return DropdownMenuItem<String>(
          value: brand,
          child: Row(
            children: [
              Image.asset(
                brandsImages[brandsList.indexOf(brand)],
                height: 80,
                width: 70,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(brand),
              ),
            ],
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Brand',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select a brand';
        }
        return null;
      },
    );
  }

  TextFormField phoneNameField(BuildContext context) {
    return TextFormField(
      controller: nameController,
      decoration: InputDecoration(
        labelText: 'Phone Name',
        hintText: 'Enter the phone name',
        contentPadding: const EdgeInsets.all(15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Type the name';
        }
        return null;
      },
    );
  }

  Row storageRamRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedRam,
            onChanged: (String? newValue) {
              setState(() {
                _selectedRam = newValue;
              });
            },
            items: ramOptions.map<DropdownMenuItem<String>>((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Ram',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: (value) {
              if (value == null) {
                return 'Select the Ram';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedStorage,
            onChanged: (String? newValue) {
              setState(() {
                _selectedStorage = newValue;
              });
            },
            items:
                storageOptions.map<DropdownMenuItem<String>>((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Storage',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: (value) {
              if (value == null) {
                return 'Select the storage';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Container priceField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: priceIsValid ? Colors.grey : Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          'Price',
          style: TextStyle(
            color: _selectedPrice == 0 ? Colors.grey[700] : Colors.black,
          ),
        ),
        focusColor: Colors.red,
        trailing: Text(
          '$_selectedPrice Da',
          style: const TextStyle(fontSize: 18),
        ),
        onTap: _showPricePicker, // Show price picker modal
      ),
    );
  }

  TextFormField imageUrlField(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Image URL',
        hintText: 'Enter the URL',
        contentPadding: const EdgeInsets.all(15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  String? validatePrice(int price) {
    if (price == 0) {
      return 'Please select a valid price';
    }
    return null;
  }

  Future<void> _showPricePicker() async {
    List<int>? selectedDigits = await showModalBottomSheet<List<int>>(
      context: context,
      builder: (BuildContext context) {
        return PricePicker(
          initialDigits: [
            _selectedPrice ~/ 10000,
            (_selectedPrice ~/ 1000) % 10,
            (_selectedPrice ~/ 100) % 10,
          ],
        );
      },
    );

    if (selectedDigits != null) {
      setState(() {
        _selectedPrice = selectedDigits[0] * 10000 +
            selectedDigits[1] * 1000 +
            selectedDigits[2] * 100;
      });
    }
  }
}
