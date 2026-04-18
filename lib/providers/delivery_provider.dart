import 'package:flutter/foundation.dart';
import '../models/delivery.dart';
import '../services/hive_service.dart';

class DeliveryProvider extends ChangeNotifier {
  List<Delivery> _deliveries = [];
  bool _isLoading = false;
  String? _error;

  List<Delivery> get deliveries => List.unmodifiable(_deliveries);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<Delivery> get pending =>
      _deliveries.where((d) => d.status == DeliveryStatus.pending).toList();

  List<Delivery> get inProgress =>
      _deliveries.where((d) => d.status == DeliveryStatus.inProgress).toList();

  List<Delivery> get completed =>
      _deliveries.where((d) => d.status == DeliveryStatus.delivered).toList();

  List<Delivery> get failed =>
      _deliveries.where((d) => d.status == DeliveryStatus.failed).toList();

  int get totalStops => _deliveries.length;
  int get completedCount => completed.length;
  int get remainingCount => pending.length + inProgress.length;

  double get totalRevenue => completed.fold(0, (sum, d) => sum + d.totalAmount);

  double get completionRate =>
      totalStops == 0 ? 0 : completedCount / totalStops;

  DeliveryProvider() {
    _loadDeliveries();
  }

  void _loadDeliveries() {
    final box = HiveService.deliveries;
    _deliveries = box.values.toList()
      ..sort((a, b) => a.stopNumber.compareTo(b.stopNumber));
    notifyListeners();
  }

  Future<void> updateStatus(Delivery delivery, DeliveryStatus newStatus) async {
    _setLoading(true);
    try {
      delivery.status = newStatus;
      if (newStatus == DeliveryStatus.delivered) {
        delivery.deliveredAt = DateTime.now();
      }
      await delivery.save();
      _loadDeliveries();
    } catch (e) {
      _error = 'Failed to update status: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addNote(Delivery delivery, String note) async {
    delivery.notes = note;
    await delivery.save();
    _loadDeliveries();
  }

  Future<void> resetDemoData() async {
    _setLoading(true);
    try {
      await HiveService.clearAll();
      await HiveService.init();
      _loadDeliveries();
    } catch (e) {
      _error = 'Failed to reset data: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
