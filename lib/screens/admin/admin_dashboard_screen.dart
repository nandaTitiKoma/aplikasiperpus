import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loan_provider.dart';
import '../../providers/facility_provider.dart';
import '../../models/loan.dart';
import 'facility_list_screen.dart';
import '../login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 1;

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const FacilityListScreen(),
      _ApprovalQueueTab(onLogout: _logout),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventaris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Permintaan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _ApprovalQueueTab extends StatefulWidget {
  final VoidCallback onLogout;
  const _ApprovalQueueTab({required this.onLogout});

  @override
  State<_ApprovalQueueTab> createState() => _ApprovalQueueTabState();
}

class _ApprovalQueueTabState extends State<_ApprovalQueueTab> {
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
    ).fetchLoans(true, authProvider.user!.id);
    Provider.of<FacilityProvider>(context, listen: false).fetchFacilities();
  }

  Future<void> _approve(Loan loan) async {
    final loanProvider = Provider.of<LoanProvider>(context, listen: false);
    final facilityProvider = Provider.of<FacilityProvider>(
      context,
      listen: false,
    );
    final ok = await loanProvider.approveLoan(loan.id!);
    if (ok) {
      await facilityProvider.adjustStock(loan.facilityId, -1);
      _load();
    }
  }

  Future<void> _reject(Loan loan) async {
    final loanProvider = Provider.of<LoanProvider>(context, listen: false);
    final ok = await loanProvider.rejectLoan(loan.id!);
    if (ok) _load();
  }

  Future<void> _verify(Loan loan) async {
    final loanProvider = Provider.of<LoanProvider>(context, listen: false);
    final facilityProvider = Provider.of<FacilityProvider>(
      context,
      listen: false,
    );
    final ok = await loanProvider.verifyReturn(loan.id!);
    if (ok) {
      await facilityProvider.adjustStock(loan.facilityId, 1);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = Provider.of<LoanProvider>(context);
    final pending = loanProvider.loans
        .where((l) => l.status == 'pending')
        .toList();
    final returned = loanProvider.loans
        .where((l) => l.status == 'returned')
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dasbor Admin'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: loanProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Antrean Persetujuan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (pending.isEmpty) const Text('Tidak ada pengajuan pending.'),
                ...pending.map(
                  (loan) => _PendingCard(
                    loan: loan,
                    onApprove: () => _approve(loan),
                    onReject: () => _reject(loan),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Menunggu Verifikasi Pengembalian',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (returned.isEmpty)
                  const Text('Tidak ada barang menunggu verifikasi.'),
                ...returned.map(
                  (loan) =>
                      _ReturnedCard(loan: loan, onVerify: () => _verify(loan)),
                ),
              ],
            ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingCard({
    required this.loan,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tanggal: ${loan.loanDate.day}/${loan.loanDate.month}/${loan.loanDate.year} | '
            '${loan.startTime.substring(0, 5)} - ${loan.endTime.substring(0, 5)}',
          ),
          if (loan.purpose != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${loan.purpose}"',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green.shade700,
                    elevation: 0,
                  ),
                  onPressed: onApprove,
                  child: const Text('✓ Setujui'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                  ),
                  onPressed: onReject,
                  child: const Text('✕ Tolak'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReturnedCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onVerify;
  const _ReturnedCard({required this.loan, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Peminjaman #${loan.id} — menunggu verifikasi'),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: onVerify,
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text(authProvider.user?.email ?? '')),
    );
  }
}
