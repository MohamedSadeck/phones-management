import 'package:flutter/material.dart';

class PricePicker extends StatefulWidget {
  final List<int> initialDigits;

  const PricePicker({super.key, required this.initialDigits});

  @override
  State<PricePicker> createState() => _PricePickerState();
}

class _PricePickerState extends State<PricePicker> {
  late List<int> _selectedDigits;

  @override
  void initState() {
    super.initState();
    _selectedDigits = widget.initialDigits;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDigitSelector(0),
              _buildDigitSelector(1),
              _buildDigitSelector(2),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${_selectedDigits[0]}${_selectedDigits[1]} ${_selectedDigits[2]}00 DA',
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _selectedDigits),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitSelector(int index) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () {
            setState(() {
              _selectedDigits[index] = (_selectedDigits[index] + 1) % 10;
            });
          },
        ),
        Text(
          _selectedDigits[index].toString(),
          style: const TextStyle(fontSize: 40),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            setState(() {
              _selectedDigits[index] = (_selectedDigits[index] - 1 + 10) % 10;
            });
          },
        ),
      ],
    );
  }
}
