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

  // Original values for change detection
  String _originalBrand = '';
  String _originalRam = '';
  String _originalStorage = '';
  int _originalCostPrice = 0;
  int _originalSalePrice = 0;
  String _originalPhoneName = '';
  String _originalNote = '';
  bool _originalIsAvailable = false;

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

      // Store original values for change detection
      _originalBrand = phone.brand;
      _originalRam = phone.ram;
      _originalStorage = phone.storage;
      _originalCostPrice = phone.costPrice;
      _originalSalePrice = phone.salePrice;
      _originalPhoneName = phone.name;
      _originalNote = phone.note;
      _originalIsAvailable = phone.isAvailable;
    }
    super.didChangeDependencies();
  }

  bool costPriceIsValid = true;
  bool salePriceIsValid = true;

  bool _hasUnsavedChanges() {
    return _selectedBrand != _originalBrand ||
        _selectedRam != _originalRam ||
        _selectedStorage != _originalStorage ||
        _selectedCostPrice != _originalCostPrice ||
        _selectedSalePrice != _originalSalePrice ||
        _phoneName != _originalPhoneName ||
        _note != _originalNote ||
        _isAvailable != _originalIsAvailable;
  }

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
                'You have unsaved changes. What would you like to do?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // Keep editing
                child: const Text('Keep Editing'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Discard
                child: const Text('Discard'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Close dialog
                  _saveChanges(); // Save and exit
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _saveChanges() {
    final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
    final oldPhone = ModalRoute.of(context)!.settings.arguments as Phone;

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
  }

  @override
  Widget build(BuildContext context) {
    print('Edit Phone Screen');
    log('Edit Phone Screen');
    debugPrint('Edit Phone Screen');
    final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
    final oldPhone = ModalRoute.of(context)!.settings.arguments as Phone;
    // print(phone.name);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        if (_hasUnsavedChanges()) {
          final shouldDiscard = await _showDiscardDialog();
          if (shouldDiscard) {
            Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Phone'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                if (_hasUnsavedChanges()) {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Phone'),
                      content: const Text(
                          'You have unsaved changes. Are you sure you want to delete this phone? All changes will be lost.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true) {
                    print("Deleting phone with id: ${oldPhone.id}");
                    phoneProvider.removePhone(oldPhone.id);
                    Navigator.pop(context);
                  }
                } else {
                  print("Deleting phone with id: ${oldPhone.id}");
                  phoneProvider.removePhone(oldPhone.id);
                  Navigator.pop(context);
                }
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
      ),
    );
  }

  ElevatedButton editPhoneButton(
      PhoneProvider phoneProvider, BuildContext context, Phone oldPhone) {
    return ElevatedButton(
      onPressed: () async {
        _saveChanges();
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
