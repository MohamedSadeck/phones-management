import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phones_management/providers/phone_provider.dart';
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
  int _selectedCostPrice = 0;
  int _selectedSalePrice = 0;

  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  bool priceIsValid = true;
  bool costPriceIsValid = true;
  bool salePriceIsValid = true;

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
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
                costPriceField(), // reordered and renamed
                const SizedBox(height: 18),
                salePriceField(), // renamed
                const SizedBox(height: 18),
                noteField(context),
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
        bool isValid = true;
        if (_selectedSalePrice == 0) {
          setState(() {
            salePriceIsValid = false;
            isValid = false;
          });
        }
        if (_selectedCostPrice == 0) {
          setState(() {
            costPriceIsValid = false;
            isValid = false;
          });
        }

        if (_formKey.currentState!.validate() && isValid) {
          Phone newPhone = Phone(
            id: const Uuid().v4(),
            brand: _selectedBrand!,
            ram: _selectedRam!,
            storage: _selectedStorage!,
            salePrice: _selectedSalePrice,
            costPrice: _selectedCostPrice,
            name: nameController.text,
            isAvailable: true,
            note: noteController.text,
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
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
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

  Container salePriceField() {
    // renamed from sellingPriceField
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: salePriceIsValid ? Colors.grey : Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          'Sale Price', // renamed
          style: TextStyle(
            color: _selectedSalePrice == 0 ? Colors.grey[700] : Colors.black,
          ),
        ),
        trailing: Text(
          '$_selectedSalePrice Da',
          style: const TextStyle(fontSize: 18),
        ),
        onTap: () => _showPricePicker('sale'), // renamed
      ),
    );
  }

  Container costPriceField() {
    // renamed from buyingPriceField
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: costPriceIsValid ? Colors.grey : Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          'Cost Price', // renamed
          style: TextStyle(
            color: _selectedCostPrice == 0 ? Colors.grey[700] : Colors.black,
          ),
        ),
        trailing: Text(
          '$_selectedCostPrice Da',
          style: const TextStyle(fontSize: 18),
        ),
        onTap: () => _showPricePicker('cost'), // renamed
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

  TextFormField noteField(BuildContext context) {
    return TextFormField(
      controller: noteController,
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Note',
        hintText: 'Add any additional information',
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

  Future<void> _showPricePicker([String? priceType]) async {
    List<int>? selectedDigits = await showModalBottomSheet<List<int>>(
      context: context,
      builder: (BuildContext context) {
        // Get the current value based on price type
        int initialValue =
            priceType == 'sale' ? _selectedSalePrice : _selectedCostPrice;

        return PricePicker(
          initialDigits: [
            initialValue ~/ 10000,
            (initialValue ~/ 1000) % 10,
            (initialValue ~/ 100) % 10,
          ],
        );
      },
    );

    if (selectedDigits != null) {
      setState(() {
        int newPrice = selectedDigits[0] * 10000 +
            selectedDigits[1] * 1000 +
            selectedDigits[2] * 100;

        if (priceType == 'sale') {
          _selectedSalePrice = newPrice;
        } else {
          _selectedCostPrice = newPrice;
        }
      });
    }
  }
}
