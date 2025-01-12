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

  late String _id;
  late String _selectedBrand;
  late String _selectedRam;
  late String _selectedStorage;
  late int _selectedPrice;
  late int _selectedCostPrice; // renamed
  late int _selectedSalePrice; // renamed
  late String _phoneName;
  late String _note;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();

    // Set initial values based on the received phone data
  }

  @override
  void didChangeDependencies() {
    final phone = ModalRoute.of(context)?.settings.arguments as Phone;
    _id = phone.id;
    _selectedBrand = phone.brand;
    _selectedRam = phone.ram;
    _selectedStorage = phone.storage;
    _selectedPrice = phone.price;
    _selectedCostPrice = phone.costPrice; // renamed
    _selectedSalePrice = phone.salePrice; // renamed
    _phoneName = phone.name;
    _note = phone.note;
    _isAvailable = phone.isAvailable;
    super.didChangeDependencies();
  }

  bool priceIsValid = true;
  bool costPriceIsValid = true; // renamed
  bool salePriceIsValid = true; // renamed

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
    final oldPhone = ModalRoute.of(context)!.settings.arguments as Phone;
    // print(phone.name);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Edit'),
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
                const SizedBox(height: 18),
                costPriceField(), // reordered and renamed
                const SizedBox(height: 18),
                salePriceField(), // renamed
                const SizedBox(height: 18),
                noteField(context),
                const SizedBox(height: 18),
                // imageUrlField(context),
                Switch(
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                      oldPhone.setAvailable(_isAvailable);
                    }),
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
        if (_selectedPrice == 0) {
          setState(() {
            priceIsValid = false;
            isValid = false;
          });
        }
        if (_selectedCostPrice == 0) {
          // renamed
          setState(() {
            costPriceIsValid = false; // renamed
            isValid = false;
          });
        }
        if (_selectedSalePrice == 0) {
          // renamed
          setState(() {
            salePriceIsValid = false; // renamed
            isValid = false;
          });
        }

        if (_formKey.currentState!.validate() && isValid) {
          Phone updatedPhone = Phone(
            id: _id,
            brand: _selectedBrand,
            ram: _selectedRam,
            storage: _selectedStorage,
            price: _selectedPrice,
            costPrice: _selectedCostPrice, // renamed
            salePrice: _selectedSalePrice, // renamed
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

  Container costPriceField() {
    // renamed
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: costPriceIsValid ? Colors.grey : Colors.red), // renamed
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          'Cost Price', // renamed
          style: TextStyle(
            color: _selectedCostPrice == 0
                ? Colors.grey[700]
                : Colors.black, // renamed
          ),
        ),
        trailing: Text(
          '$_selectedCostPrice Da', // renamed
          style: const TextStyle(fontSize: 18),
        ),
        onTap: () => _showPricePicker('cost'), // renamed
      ),
    );
  }

  Container salePriceField() {
    // renamed
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: salePriceIsValid ? Colors.grey : Colors.red), // renamed
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          'Sale Price', // renamed
          style: TextStyle(
            color: _selectedSalePrice == 0
                ? Colors.grey[700]
                : Colors.black, // renamed
          ),
        ),
        trailing: Text(
          '$_selectedSalePrice Da', // renamed
          style: const TextStyle(fontSize: 18),
        ),
        onTap: () => _showPricePicker('sale'), // renamed
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
        int initialValue = priceType == 'sale' // renamed
            ? _selectedSalePrice // renamed
            : priceType == 'cost' // renamed
                ? _selectedCostPrice // renamed
                : _selectedPrice;

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
          // renamed
          _selectedSalePrice = newPrice; // renamed
        } else if (priceType == 'cost') {
          // renamed
          _selectedCostPrice = newPrice; // renamed
        } else {
          _selectedPrice = newPrice;
        }
      });
    }
  }
}
