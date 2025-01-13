// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:phones_management/models/phone.dart';
import 'package:phones_management/models/phone_data.dart';

class PhoneProvider extends ChangeNotifier {
  List<Phone> _phones = [];
  List<Phone> _filteredPhones = [];

  bool _ascendingOrder = true;
  bool _showOnlyAvailable = false;

  List<Phone> get phones => _phones;
  List<Phone> get filteredPhones => _filteredPhones;
  bool get showOnlyAvailable => _showOnlyAvailable;

  Future<void> loadPhones() async {
    _phones = await loadPhoneData();
    // print('load phones $_phones');
  }

  Future<List<Phone>> loadPhoneList() {
    return loadPhoneData();
  }

  void setFilteredPhones(List<Phone> filteredPhones) {
    _filteredPhones = filteredPhones;
    notifyListeners();
  }

  void setShowOnlyAvailable(bool value) {
    _showOnlyAvailable = value;
    updateFilteredPhones();
  }

  void updateFilteredPhones(
      {String? searchQuery, String? selectedBrand}) async {
    await loadPhones();
    List<Phone> filteredByBrand = [];

    if (selectedBrand != null && selectedBrand != 'All') {
      filteredByBrand =
          _phones.where((phone) => phone.brand == selectedBrand).toList();
    } else {
      filteredByBrand = _phones;
    }

    if (_showOnlyAvailable) {
      filteredByBrand =
          filteredByBrand.where((phone) => phone.isAvailable).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      _filteredPhones = filteredByBrand
          .where((phone) =>
              phone.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    } else {
      _filteredPhones = filteredByBrand;
    }

    notifyListeners();
  }

  void toggleSortOrder() {
    _ascendingOrder = !_ascendingOrder;
    _filteredPhones.sort((a, b) {
      return _ascendingOrder
          ? a.salePrice.compareTo(b.salePrice)
          : b.salePrice.compareTo(a.salePrice);
    });

    notifyListeners();
  }

  int getMinPrice() {
    if (_phones.isEmpty) {
      return 10000;
    }
    return _phones
        .map((phone) => phone.salePrice)
        .reduce((a, b) => a < b ? a : b);
  }

  int getMaxPrice() {
    if (_phones.isEmpty) {
      return 100000; // Default maximum price
    }
    return _phones
        .map((phone) => phone.salePrice)
        .reduce((a, b) => a > b ? a : b);
  }

  void addPhone(Phone newPhone) {
    _phones.add(newPhone);
    savePhoneData(_phones);
    notifyListeners();
  }

  void updatePhone(Phone oldPhone, Phone updatedPhone) async {
    await loadPhones();
    int phoneIndex = -1;
    for (int i = 0; i < _phones.length; i++) {
      if (_phones[i].id == updatedPhone.id) {
        phoneIndex = i;
      }
    }
    if (phoneIndex != -1) {
      _phones[phoneIndex] = updatedPhone;
      savePhoneData(_phones);
      _filteredPhones = _phones;
      notifyListeners();
    }
  }

  void clearPhones() async {
    await clearPhoneData();
    await loadPhones();
    showPhone();
    notifyListeners();
  }

  Future<void> loadPhonesFromDatabase(List<Phone> phonesFromDatabase) async {
    _phones = phonesFromDatabase;
    _filteredPhones = _phones; // Make sure to update the filtered list as well
    savePhoneData(_phones);
    notifyListeners();
  }

  void showPhone() async {
    await loadPhones();
    print(_phones.length);
    for (Phone p in _phones) {
      print(p.name);
    }
  }
}
