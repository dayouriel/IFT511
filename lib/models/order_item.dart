import 'package:hive/hive.dart';

part 'order_item.g.dart';

@HiveType(typeId: 3)
class OrderItem extends HiveObject {
  @HiveField(0)
  final String productName;

  @HiveField(1)
  final String sku;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double unitPrice;

  @HiveField(4)
  final String? flavour;

  @HiveField(5)
  final String size; // e.g. "500ml", "1L", "2L"

  OrderItem({
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.size,
    this.flavour,
  });

  double get lineTotal => quantity * unitPrice;

  String get displayName =>
      flavour != null ? '$productName – $flavour ($size)' : '$productName ($size)';
}
