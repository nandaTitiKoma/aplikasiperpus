import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/facility_provider.dart';
import '../../models/facility.dart';
import 'loan_form_screen.dart';
import 'my_loans_screen.dart';
import '../login_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FacilityProvider>(context, listen: false).fetchFacilities();
    });
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_CatalogTab(onLogout: _logout), const MyLoansScreen()];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: 'Katalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Peminjaman Saya',
          ),
        ],
      ),
    );
  }
}

class _CatalogTab extends StatelessWidget {
  final VoidCallback onLogout;
  const _CatalogTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final facilityProvider = Provider.of<FacilityProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Katalog Fasilitas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<FacilityProvider>(
              context,
              listen: false,
            ).fetchFacilities(),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
        ],
      ),
      body: facilityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : facilityProvider.errorMessage != null
          ? Center(child: Text(facilityProvider.errorMessage!))
          : facilityProvider.facilities.isEmpty
          ? const Center(child: Text('Belum ada fasilitas tersedia.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: facilityProvider.facilities.length,
              itemBuilder: (context, index) {
                final facility = facilityProvider.facilities[index];
                return _FacilityCard(facility: facility);
              },
            ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final Facility facility;
  const _FacilityCard({required this.facility});

  @override
  Widget build(BuildContext context) {
    final available = facility.stock > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: facility.photoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(facility.photoUrl!, fit: BoxFit.cover),
                )
              : const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.deepPurple,
                ),
        ),
        title: Text(
          facility.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${facility.category} • Stok: ${facility.stock}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: available ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            available ? 'Tersedia' : 'Habis',
            style: TextStyle(
              color: available ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        onTap: available
            ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LoanFormScreen(facility: facility),
                ),
              )
            : null,
      ),
    );
  }
}
