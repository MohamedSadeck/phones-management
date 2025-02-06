import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phones_management/providers/phone_provider.dart';

import '../constants/constants.dart';
import '../models/phone.dart';
import '../widgets/price_picker.dart';

class EditPhoneScreen extends StatefulWidget {
  static const routeName = "/edit-phone";
  const EditPhoneScreen({super.key});

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  final _formKey = GlobalKey<FormState>();

  String _id = '';
  String _selectedBrand = '';
  String _selectedRam = '';
  String _selectedStorage = '';
  int _selectedPrice = 0;
  int _selectedCostPrice = 0;
  int _selectedSalePrice = 0;
  String _phoneName = '';
  String _note = '';
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();

    // Set initial values based on the received phone data
  }

  @override
  void didChangeDependencies() {
    if (_id.isEmpty) {
      final phone = ModalRoute.of(context)?.settings.arguments as Phone;
      _id = phone.id;
      _selectedBrand = phone.brand;
      _selectedRam = phone.ram;
      _selectedStorage = phone.storage;
      _selectedCostPrice = phone.costPrice;
      _selectedSalePrice = phone.salePrice;
      _phoneName = phone.name;
      _note = phone.note;
      _isAvailable = phone.isAvailable;
    }
    super.didChangeDependencies();
  }

  bool costPriceIsValid = true;
  bool salePriceIsValid = true;

  @override
  Widget build(BuildContext context) {
    print('Edit Phone Screen');
    log('Edit Phone Screen');
    debugPrint('Edit Phone Screen');
    final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
    final oldPhone = ModalRoute.of(context)!.settings.arguments as Phone;
    // print(phone.name);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Phone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              print("Deleting phone with id: ${oldPhone.id}");
              phoneProvider.removePhone(oldPhone.id);
              Navigator.pop(context);
            },
          ),
        ],
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
                costPriceField(), // reordered
                const SizedBox(height: 18),
                salePriceField(),
                const SizedBox(height: 18),
                noteField(context),
                const SizedBox(height: 18),
                // imageUrlField(context),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      _isAvailable ? 'Available for Sale' : 'Sold',
                      style: TextStyle(
                        color: _isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                      oldPhone.setAvailable(_isAvailable);
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 18),
                editPhoneButton(phoneProvider, context, oldPhone),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton editPhoneButton(
      PhoneProvider phoneProvider, BuildContext context, Phone oldPhone) {
    return ElevatedButton(
      onPressed: () async {
        bool isValid = true;
        if (_selectedCostPrice == 0) {
          setState(() {
            costPriceIsValid = false;
            isValid = false;
          });
        }
        if (_selectedSalePrice == 0) {
          setState(() {
            salePriceIsValid = false;
            isValid = false;
          });
        }

        if (_formKey.currentState!.validate() && isValid) {
          Phone updatedPhone = Phone(
            id: _id,
            brand: _selectedBrand,
            ram: _selectedRam,
            storage: _selectedStorage,
            costPrice: _selectedCostPrice,
            salePrice: _selectedSalePrice,
            name: _phoneName,
            isAvailable: _isAvailable,
            note: _note,
          );
          phoneProvider.updatePhone(oldPhone, updatedPhone);
          Navigator.pop(context);
        }
      },
      child: const Text('Save'),
    );
  }

  DropdownButtonFormField<String> brandDropDown() {
    return DropdownButtonFormField<String>(
      value: _selectedBrand,
      onChanged: (String? newValue) {
        setState(() {
          _selectedBrand = newValue!;
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
      initialValue: _phoneName,
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
      onChanged: (value) {
        _phoneName = value;
      },
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
                _selectedRam = newValue!;
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
                _selectedStorage = newValue!;
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

  Container costPriceField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: costPriceIsValid ? Colors.grey : Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          'Cost Price',
          style: TextStyle(
            color: _selectedCostPrice == 0 ? Colors.grey[700] : Colors.black,
          ),
        ),
        trailing: Text(
          _formatPrice(_selectedCostPrice),
          style: const TextStyle(fontSize: 18),
        ),
        onTap: () => _showPricePicker('cost'),
      ),
    );
  }

  Container salePriceField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: salePriceIsValid ? Colors.grey : Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          'Sale Price',
          style: TextStyle(
            color: _selectedSalePrice == 0 ? Colors.grey[700] : Colors.black,
          ),
        ),
        trailing: Text(
          _formatPrice(_selectedSalePrice),
          style: const TextStyle(fontSize: 18),
        ),
        onTap: () => _showPricePicker('sale'),
      ),
    );
  }

  TextFormField noteField(BuildContext context) {
    return TextFormField(
      initialValue: _note,
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
      onChanged: (value) {
        _note = value;
      },
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
        int initialValue = priceType == 'sale'
            ? _selectedSalePrice
            : priceType == 'cost'
                ? _selectedCostPrice
                : _selectedPrice;

        return PricePicker(
          initialDigits: [
            initialValue ~/ 100000,
            (initialValue ~/ 10000) % 10,
            (initialValue ~/ 1000) % 10,
            (initialValue ~/ 100) % 10,
          ],
        );
      },
    );

    if (selectedDigits != null) {
      setState(() {
        int newPrice = selectedDigits[0] * 100000 +
            selectedDigits[1] * 10000 +
            selectedDigits[2] * 1000 +
            selectedDigits[3] * 100;

        if (priceType == 'sale') {
          _selectedSalePrice = newPrice;
        } else if (priceType == 'cost') {
          _selectedCostPrice = newPrice;
        } else {
          _selectedPrice = newPrice;
        }
      });
    }
  }

  String _formatPrice(int price) {
    if (price == 0) return '0 DA';
    String priceStr = price.toString();
    final characters = priceStr.split('').reversed.toList();
    for (var i = 3; i < characters.length; i += 4) {
      characters.insert(i, ' ');
    }
    return '${characters.reversed.join('')} DA';
  }
}
