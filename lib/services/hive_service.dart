import 'package:hive_flutter/hive_flutter.dart';
import '../models/delivery.dart';
import '../models/order_item.dart';
import 'package:uuid/uuid.dart';

class HiveService {
  static const String deliveryBox = 'deliveries';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.openBox(settingsBox);
    await Hive.openBox<Delivery>(deliveryBox);

    // Seed demo data if box is empty
    final box = Hive.box<Delivery>(deliveryBox);
    if (box.isEmpty) {
      await _seedDemoData(box);
    }
  }

  static Future<void> _seedDemoData(Box<Delivery> box) async {
    const uuid = Uuid();
    final now = DateTime.now();

    final deliveries = [
      Delivery(
        id: uuid.v4(),
        customerName: 'Sunny Mart Superstore',
        address: '14 Rumuola Road, Port Harcourt',
        phone: '+234 803 111 2222',
        stopNumber: 1,
        scheduledTime: now.copyWith(hour: 9, minute: 0),
        totalAmount: 85500,
        items: [
          OrderItem(
            productName: 'Premium Ice Cream',
            sku: 'IC-VAN-2L',
            quantity: 12,
            unitPrice: 3500,
            size: '2L',
            flavour: 'Vanilla',
          ),
          OrderItem(
            productName: 'Premium Ice Cream',
            sku: 'IC-CHOC-2L',
            quantity: 10,
            unitPrice: 3500,
            size: '2L',
            flavour: 'Chocolate',
          ),
          OrderItem(
            productName: 'Sorbet Tub',
            sku: 'SB-STRAW-1L',
            quantity: 5,
            unitPrice: 2500,
            size: '1L',
            flavour: 'Strawberry',
          ),
        ],
        status: DeliveryStatus.delivered,
        deliveredAt: now.copyWith(hour: 9, minute: 45),
      ),
      Delivery(
        id: uuid.v4(),
        customerName: "Chike's Cold Room",
        address: '7 Ada George Road, Port Harcourt',
        phone: '+234 805 333 4444',
        stopNumber: 2,
        scheduledTime: now.copyWith(hour: 10, minute: 30),
        totalAmount: 42000,
        items: [
          OrderItem(
            productName: 'Premium Ice Cream',
            sku: 'IC-STRAW-1L',
            quantity: 8,
            unitPrice: 2800,
            size: '1L',
            flavour: 'Strawberry',
          ),
          OrderItem(
            productName: 'Frozen Yoghurt',
            sku: 'FY-MNG-500ML',
            quantity: 15,
            unitPrice: 1800,
            size: '500ml',
            flavour: 'Mango',
          ),
        ],
        status: DeliveryStatus.inProgress,
      ),
      Delivery(
        id: uuid.v4(),
        customerName: 'Domino Fast Foods',
        address: '3 Trans Amadi Industrial Layout',
        phone: '+234 807 555 6666',
        stopNumber: 3,
        scheduledTime: now.copyWith(hour: 11, minute: 30),
        totalAmount: 61500,
        items: [
          OrderItem(
            productName: 'Premium Ice Cream',
            sku: 'IC-MNT-2L',
            quantity: 6,
            unitPrice: 3500,
            size: '2L',
            flavour: 'Mint Choc Chip',
          ),
          OrderItem(
            productName: 'Premium Ice Cream',
            sku: 'IC-VAN-2L',
            quantity: 6,
            unitPrice: 3500,
            size: '2L',
            flavour: 'Vanilla',
          ),
          OrderItem(
            productName: 'Popsicle Pack',
            sku: 'PP-ASST-12PK',
            quantity: 20,
            unitPrice: 1500,
            size: '12-pack',
          ),
        ],
        status: DeliveryStatus.pending,
      ),
      Delivery(
        id: uuid.v4(),
        customerName: 'GreenLeaf Hotel & Suites',
        address: '22 Olu Obasanjo Road, GRA Phase 2',
        phone: '+234 809 777 8888',
        stopNumber: 4,
        scheduledTime: now.copyWith(hour: 13, minute: 0),
        totalAmount: 120000,
        items: [
          OrderItem(
            productName: 'Gelato Tub',
            sku: 'GT-PSTCH-2L',
            quantity: 10,
            unitPrice: 5500,
            size: '2L',
            flavour: 'Pistachio',
          ),
          OrderItem(
            productName: 'Gelato Tub',
            sku: 'GT-TRMSU-2L',
            quantity: 10,
            unitPrice: 5500,
            size: '2L',
            flavour: 'Tiramisu',
          ),
          OrderItem(
            productName: 'Sorbet Tub',
            sku: 'SB-LEMON-1L',
            quantity: 4,
            unitPrice: 2500,
            size: '1L',
            flavour: 'Lemon',
          ),
        ],
        status: DeliveryStatus.pending,
      ),
      Delivery(
        id: uuid.v4(),
        customerName: 'Port Harcourt Mall Food Court',
        address: 'Plot 1 Stadium Road, Rumuola',
        phone: '+234 811 999 0000',
        stopNumber: 5,
        scheduledTime: now.copyWith(hour: 14, minute: 30),
        totalAmount: 95000,
        items: [
          OrderItem(
            productName: 'Premium Ice Cream',
            sku: 'IC-CHOC-2L',
            quantity: 15,
            unitPrice: 3500,
            size: '2L',
            flavour: 'Chocolate',
          ),
          OrderItem(
            productName: 'Frozen Yoghurt',
            sku: 'FY-BLRY-500ML',
            quantity: 20,
            unitPrice: 1800,
            size: '500ml',
            flavour: 'Blueberry',
          ),
        ],
        status: DeliveryStatus.pending,
        notes: 'Call ahead 20 mins before arrival. Ask for Manager Emeka.',
      ),
    ];

    for (final d in deliveries) {
      await box.put(d.id, d);
    }
  }

  static Box<Delivery> get deliveries => Hive.box<Delivery>(deliveryBox);
  static Box get settings => Hive.box(settingsBox);

  static Future<void> updateDelivery(Delivery delivery) async {
    await delivery.save();
  }

  static Future<void> clearAll() async {
    await Hive.box<Delivery>(deliveryBox).clear();
    await Hive.box(settingsBox).clear();
  }
}
