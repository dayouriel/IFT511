// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryAdapter extends TypeAdapter<Delivery> {
  @override
  final int typeId = 1;

  @override
  Delivery read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Delivery(
      id: fields[0] as String,
      customerName: fields[1] as String,
      address: fields[2] as String,
      phone: fields[3] as String,
      items: (fields[4] as List).cast<OrderItem>(),
      scheduledTime: fields[6] as DateTime,
      totalAmount: fields[9] as double,
      stopNumber: fields[10] as int,
      status: fields[5] as DeliveryStatus,
      deliveredAt: fields[7] as DateTime?,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Delivery obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.scheduledTime)
      ..writeByte(7)
      ..write(obj.deliveredAt)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.totalAmount)
      ..writeByte(10)
      ..write(obj.stopNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeliveryStatusAdapter extends TypeAdapter<DeliveryStatus> {
  @override
  final int typeId = 2;

  @override
  DeliveryStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeliveryStatus.pending;
      case 1:
        return DeliveryStatus.inProgress;
      case 2:
        return DeliveryStatus.delivered;
      case 3:
        return DeliveryStatus.failed;
      default:
        return DeliveryStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, DeliveryStatus obj) {
    switch (obj) {
      case DeliveryStatus.pending:
        writer.writeByte(0);
        break;
      case DeliveryStatus.inProgress:
        writer.writeByte(1);
        break;
      case DeliveryStatus.delivered:
        writer.writeByte(2);
        break;
      case DeliveryStatus.failed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
