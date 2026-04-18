import 'package:hive/hive.dart';
import 'order_item.dart';

part 'delivery.g.dart';

@HiveType(typeId: 0)
enum DeliveryStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  delivered,

  @HiveField(3)
  failed,
}

extension DeliveryStatusX on DeliveryStatus {
  String get label {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.inProgress:
        return 'In Progress';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.failed:
        return 'Failed';
    }
  }
}

@HiveType(typeId: 1)
class Delivery extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerName;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final List<OrderItem> items;

  @HiveField(5)
  DeliveryStatus status;

  @HiveField(6)
  final DateTime scheduledTime;

  @HiveField(7)
  DateTime? deliveredAt;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  final double totalAmount;

  @HiveField(10)
  final int stopNumber;

  Delivery({
    required this.id,
    required this.customerName,
    required this.address,
    required this.phone,
    required this.items,
    required this.scheduledTime,
    required this.totalAmount,
    required this.stopNumber,
    this.status = DeliveryStatus.pending,
    this.deliveredAt,
    this.notes,
  });

  int get totalUnits => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isCompleted => status == DeliveryStatus.delivered;
  bool get isFailed => status == DeliveryStatus.failed;
  bool get isPending => status == DeliveryStatus.pending;
  bool get isInProgress => status == DeliveryStatus.inProgress;

  Delivery copyWith({
    DeliveryStatus? status,
    DateTime? deliveredAt,
    String? notes,
  }) {
    return Delivery(
      id: id,
      customerName: customerName,
      address: address,
      phone: phone,
      items: items,
      scheduledTime: scheduledTime,
      totalAmount: totalAmount,
      stopNumber: stopNumber,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
    );
  }
}
