class Phone {
  final String id;
  final String brand;
  final String name;
  final String storage;
  final String ram;
  final int costPrice;
  final int salePrice;
  final String note;
  bool isAvailable;

  Phone({
    required this.id,
    required this.brand,
    required this.name,
    required this.storage,
    required this.ram,
    required this.costPrice,
    required this.salePrice,
    required this.isAvailable,
    this.note = '',
  });

  void setAvailable(bool isAvailable) {
    this.isAvailable = isAvailable;
  }

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      id: json['id'],
      brand: json['brand'] as String,
      name: json['name'] as String,
      storage: json['storage'] as String,
      ram: json['ram'] as String,
      costPrice: json['costPrice'] as int,
      salePrice: json['salePrice'] as int,
      isAvailable: json['isAvailable'] as bool,
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'ram': ram,
      'storage': storage,
      'costPrice': costPrice,
      'salePrice': salePrice,
      'name': name,
      'isAvailable': isAvailable,
      'note': note,
    };
  }
}
