import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/phone_provider.dart';

class PriceRangeSelector extends StatefulWidget {
  final Function(int min, int max) onRangeChanged;

  const PriceRangeSelector({super.key, required this.onRangeChanged});

  @override
  State<PriceRangeSelector> createState() => _PriceRangeSelectorState();
}

class _PriceRangeSelectorState extends State<PriceRangeSelector> {
  int _minPrice = 10000;
  int _maxPrice = 100000; // Default maximum price

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context);
    return Column(
      children: [
        Text('Price Range: $_minPrice - $_maxPrice'),
        RangeSlider(
          values: RangeValues(
            _minPrice.toDouble().clamp(phoneProvider.getMinPrice().toDouble(),
                phoneProvider.getMaxPrice().toDouble()),
            _maxPrice.toDouble().clamp(phoneProvider.getMinPrice().toDouble(),
                phoneProvider.getMaxPrice().toDouble()),
          ),
          min: phoneProvider.getMinPrice().toDouble(),
          max: phoneProvider.getMaxPrice().toDouble(),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start.toInt();
              _maxPrice = values.end.toInt();
              widget.onRangeChanged(_minPrice, _maxPrice);
            });
          },
          labels: RangeLabels(
            _minPrice.toStringAsFixed(0),
            _maxPrice.toStringAsFixed(0),
          ),
          divisions:
              ((phoneProvider.getMaxPrice() - phoneProvider.getMinPrice()) ~/
                  5000),
        ),
      ],
    );
  }
}
