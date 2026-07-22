import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/facility.dart';

class FacilityProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Facility> _facilities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Facility> get facilities => _facilities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFacilities() async {
    _errorMessage = null;
    _setLoading(true);
    try {
      final data = await _supabase
          .from('facilities')
          .select()
          .order('name', ascending: true);
      _facilities = data.map((e) => Facility.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = "Failed to load facilities: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createFacility(Facility facility) async {
    try {
      await _supabase.from('facilities').insert(facility.toJson());
      await fetchFacilities();
      return true;
    } catch (e) {
      _errorMessage = "Failed to create facility: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFacility(int id, Facility facility) async {
    try {
      final data = facility.toJson()..remove('id');
      await _supabase.from('facilities').update(data).eq('id', id);
      await fetchFacilities();
      return true;
    } catch (e) {
      _errorMessage = "Failed to update facility: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFacility(int id) async {
    try {
      await _supabase.from('facilities').delete().eq('id', id);
      await fetchFacilities();
      return true;
    } catch (e) {
      _errorMessage = "Failed to delete facility: $e";
      notifyListeners();
      return false;
    }
  }

  Future<void> adjustStock(int facilityId, int delta) async {
    final current = _facilities.firstWhere((f) => f.id == facilityId);
    final newStock = current.stock + delta;
    await _supabase
        .from('facilities')
        .update({'stock': newStock})
        .eq('id', facilityId);
    await fetchFacilities();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
