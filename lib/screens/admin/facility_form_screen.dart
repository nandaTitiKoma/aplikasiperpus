import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/facility.dart';
import '../../providers/facility_provider.dart';

class FacilityFormScreen extends StatefulWidget {
  final Facility? facility;

  const FacilityFormScreen({super.key, this.facility});

  bool get isEdit => facility != null;

  @override
  State<FacilityFormScreen> createState() => _FacilityFormScreenState();
}

class _FacilityFormScreenState extends State<FacilityFormScreen> {
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _notesController = TextEditingController();
  final _photoUrlController = TextEditingController();

  String? _category;

  final List<String> _categories = [
    'Ruangan',
    'Proyektor',
    'Kamera',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _nameController.text = widget.facility!.name;
      _stockController.text = widget.facility!.stock.toString();
      _notesController.text = widget.facility!.notes ?? '';
      _category = widget.facility!.category;
      _photoUrlController.text = widget.facility!.photoUrl ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _notesController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_nameController.text.trim().isEmpty ||
        _category == null ||
        _stockController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lengkapi semua data.')));
      return;
    }

    final facilityProvider = Provider.of<FacilityProvider>(
      context,
      listen: false,
    );
    final facility = Facility(
      id: widget.facility?.id,
      name: _nameController.text.trim(),
      category: _category!,
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      notes: _notesController.text.trim(),
      photoUrl: _photoUrlController.text.trim().isEmpty
          ? null
          : _photoUrlController.text.trim(), // <-- ganti baris ini
    );

    final success = widget.isEdit
        ? await facilityProvider.updateFacility(widget.facility!.id!, facility)
        : await facilityProvider.createFacility(facility);

    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final facilityProvider = Provider.of<FacilityProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Fasilitas' : 'Input Fasilitas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Link Foto:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _photoUrlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'https://contoh.com/gambar.jpg',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Preview gambar dari link
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _photoUrlController.text.trim().isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 32,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Preview foto akan muncul di sini',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _photoUrlController.text.trim(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 140,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Text(
                                'Link gambar tidak valid',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Nama Fasilitas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        hint: const Text('Pilih...'),
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _category = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stok:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Catatan/Spek:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Kondisi barang...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(height: 28),

            if (facilityProvider.errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  facilityProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: facilityProvider.isLoading ? null : _save,
                child: facilityProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Simpan Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
