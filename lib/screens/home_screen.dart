// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:store_app/constants/constants.dart';
import 'package:store_app/providers/phone_provider.dart';
import 'package:store_app/screens/add_phone_screen.dart';
import 'package:store_app/screens/settings_screen.dart';
import 'package:store_app/widgets/price_range_selector.dart';

import '../models/phone.dart';
import '../widgets/phone_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Phone> phones = [];

  String selectedBrand = 'All';

  final _searchController = TextEditingController();

  RangeValues _selectedPriceRange =
      const RangeValues(10000, 100000); // Default values

  bool firstLaunch = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context);
    print('build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phones'),
        actions: [
          TextButton.icon(
            onPressed: () {
              _showPriceRangeBottomSheet(
                  context, phoneProvider.filteredPhones, phoneProvider);
            },
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.white,
            ),
            label: const Text(
              'Filter',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              if (firstLaunch) {
                phoneProvider.setFilteredPhones(phoneProvider.phones);
              }
              phoneProvider.toggleSortOrder();
              Fluttertoast.showToast(
                  msg: 'Sorted',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            icon: const Icon(
              Icons.sort,
              color: Colors.white,
            ),
            label: const Text(
              'Sort',
              style: TextStyle(color: Colors.white),
            ),
          ),

          IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(SettingsScreen.routeName),
              icon: const Icon(Icons.settings)),
          // TextButton(
          //     onPressed: () {
          //       // phoneProvider.clearPhones();
          //       // phoneProvider.showPhone();
          //       seePhones(phoneProvider.filteredPhones);
          //     },
          //     child: const Text(
          //       'Show',
          //       style: TextStyle(color: Colors.black),
          //     ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildSearchBar(phoneProvider),
            const SizedBox(height: 20), // Add spacing
            actionChipRow(context),
            const SizedBox(height: 20),
            Consumer<PhoneProvider>(builder: (context, value, child) {
              print('consumer rebuild');
              return phonesListView(context, phoneProvider);
            })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).pushNamed(AddPhoneScreen.routeName),
        icon: const Icon(Icons.add),
        label: const Text('Add a Phone'),
      ),
    );
  }

  Widget phonesListView(BuildContext context, PhoneProvider phoneProvider) {
    return firstLaunch
        ? // Add spacing
        FutureBuilder<List<Phone>>(
            future: phoneProvider.loadPhoneList(),
            builder: (context, snapshot) {
              firstLaunch = false;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error loading data');
              } else {
                phones = snapshot.data ?? [];
                return Expanded(
                  child: ListView.builder(
                    itemCount: phones.length,
                    itemBuilder: (ctx, index) {
                      return PhoneListItem(phone: phones[index]);
                    },
                  ),
                );
              }
            },
          )
        : Expanded(
            child: ListView.builder(
              itemCount: phoneProvider.filteredPhones.length,
              itemBuilder: (ctx, index) {
                return PhoneListItem(
                    phone: phoneProvider.filteredPhones[index]);
              },
            ),
          );
  }

  SingleChildScrollView actionChipRow(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ActionChip(
            label: Text(
              'All',
              style: TextStyle(
                color: selectedBrand == 'All'
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () {
              phoneProvider.updateFilteredPhones(
                  searchQuery: _searchController.text, selectedBrand: 'All');
              selectedBrand = "All";
            },
            backgroundColor: selectedBrand == 'All'
                ? Theme.of(context).primaryColor
                : Colors.transparent,
          ),
          ...brandsList.map((brand) {
            return ActionChip(
              label: Text(
                brand,
                style: TextStyle(
                  color: selectedBrand == brand
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () {
                selectedBrand = brand;
                phoneProvider.updateFilteredPhones(
                    searchQuery: _searchController.text,
                    selectedBrand: selectedBrand);
              },
              backgroundColor: selectedBrand == brand
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget buildSearchBar(PhoneProvider phoneProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search for a phone...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
        onChanged: (query) {
          phoneProvider.updateFilteredPhones(
              searchQuery: query, selectedBrand: selectedBrand);
        },
      ),
    );
  }

  void _onSearchTextChanged(String query) {
    final filteredPhones = phones
        .where(
            (phone) => phone.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  RangeValues calculatePriceRange(List<Phone> phones) {
    if (phones.isEmpty) {
      return const RangeValues(0, 1000); // Default values
    }

    int minPrice = phones[0].price;
    int maxPrice = phones[0].price;

    for (var phone in phones) {
      if (phone.price < minPrice) {
        minPrice = phone.price;
      }
      if (phone.price > maxPrice) {
        maxPrice = phone.price;
      }
    }

    return RangeValues(minPrice.toDouble(), maxPrice.toDouble());
  }

  void _showPriceRangeBottomSheet(
      BuildContext context, List<Phone> phones, PhoneProvider phoneProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select Price Range'),
                  const SizedBox(height: 16),
                  PriceRangeSelector(
                    onRangeChanged: (min, max) {
                      setState(() {
                        _selectedPriceRange =
                            RangeValues(min.toDouble(), max.toDouble());
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Filter phones based on the selected price range
                      List<Phone> filteredByPrice = phones.where((phone) {
                        return phone.price >= _selectedPriceRange.start &&
                            phone.price <= _selectedPriceRange.end;
                      }).toList();
                      phoneProvider.setFilteredPhones(filteredByPrice);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
