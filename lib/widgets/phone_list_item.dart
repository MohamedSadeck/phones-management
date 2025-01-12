import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/phone.dart';
import '../screens/edit_phone_screen.dart';

class PhoneListItem extends StatelessWidget {
  final Phone phone;
  const PhoneListItem({
    required this.phone,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.all(4.0),
      child: ListTile(
        leading: Image.asset(brandsImages[brandsList.indexOf(phone.brand)]),
        title: Text(
          phone.name,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            EditPhoneScreen.routeName,
            arguments: phone,
          );
        },
        subtitle: Text(
          '${phone.ram}/${phone.storage}',
          style:
              const TextStyle(fontSize: 17.0), // Adjust the font size as needed
        ),
        trailing: Text(
          '${phone.price} Da',
          style: const TextStyle(
              fontSize: 20.0,
              fontWeight:
                  FontWeight.bold), // Adjust the font size and style as needed
        ),
      ),
    );
  }
}
