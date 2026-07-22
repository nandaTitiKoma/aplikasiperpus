import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loan_provider.dart';
import '../../models/loan.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<LoanProvider>(
      context,
      listen: false,
    ).fetchLoans(false, authProvider.user!.id);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'returned':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = Provider.of<LoanProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Peminjaman Saya'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: loanProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : loanProvider.loans.isEmpty
          ? const Center(child: Text('Belum ada riwayat peminjaman.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: loanProvider.loans.length,
              itemBuilder: (context, index) {
                final loan = loanProvider.loans[index];
                return _LoanCard(
                  loan: loan,
                  statusColor: _statusColor(loan.status),
                  onChanged: _load,
                );
              },
            ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final Loan loan;
  final Color statusColor;
  final VoidCallback onChanged;

  const _LoanCard({
    required this.loan,
    required this.statusColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Peminjaman #${loan.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loan.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tanggal: ${loan.loanDate.day}/${loan.loanDate.month}/${loan.loanDate.year}',
          ),
          Text(
            'Waktu: ${loan.startTime.substring(0, 5)} - ${loan.endTime.substring(0, 5)}',
          ),
          if (loan.purpose != null) Text('Keperluan: ${loan.purpose}'),
          if (loan.status == 'approved') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final loanProvider = Provider.of<LoanProvider>(
                    context,
                    listen: false,
                  );
                  final ok = await loanProvider.returnLoan(loan.id!);
                  if (ok) onChanged();
                },
                child: const Text('Kembalikan Barang'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
