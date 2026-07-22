import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/loan.dart';

class LoanProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Loan> _loans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Loan> get loans => _loans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLoans(bool isAdmin, String userId) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      final query = _supabase.from('loans').select();
      final data = isAdmin
          ? await query.order('created_at', ascending: false)
          : await query
                .eq('user_id', userId)
                .order('created_at', ascending: false);
      _loans = data.map((e) => Loan.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = "Failed to load loans: $e";
    } finally {
      _setLoading(false);
    }
  }

  // --- MAHASISWA ---

  Future<bool> createLoanRequest(Loan loan) async {
    try {
      await _supabase.from('loans').insert(loan.toJson());
      return true;
    } catch (e) {
      _errorMessage = "Failed to submit loan request: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> returnLoan(int loanId) async {
    try {
      await _supabase
          .from('loans')
          .update({'status': 'returned'})
          .eq('id', loanId);
      return true;
    } catch (e) {
      _errorMessage = "Failed to return item: $e";
      notifyListeners();
      return false;
    }
  }

  // --- ADMIN ---

  Future<bool> approveLoan(int loanId) async {
    try {
      await _supabase
          .from('loans')
          .update({'status': 'approved'})
          .eq('id', loanId);
      return true;
    } catch (e) {
      _errorMessage = "Failed to approve: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectLoan(int loanId) async {
    try {
      await _supabase
          .from('loans')
          .update({'status': 'rejected'})
          .eq('id', loanId);
      return true;
    } catch (e) {
      _errorMessage = "Failed to reject: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyReturn(int loanId) async {
    try {
      await _supabase
          .from('loans')
          .update({'status': 'completed'})
          .eq('id', loanId);
      return true;
    } catch (e) {
      _errorMessage = "Failed to verify: $e";
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
