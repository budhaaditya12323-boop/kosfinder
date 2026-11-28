import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kos_model.dart';
import '../providers/auth_provider.dart';
import '../providers/owner_kos_provider.dart';

class KosFormScreen extends StatefulWidget {
  /// Jika null, berarti mode Tambah (Create). Jika ada nilai, berarti mode Edit.
  final Kos? existingKos;

  const KosFormScreen({super.key, this.existingKos});

  @override
  State<KosFormScreen> createState() => _KosFormScreenState();
}

class _KosFormScreenState extends State<KosFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _roomController;
  late TextEditingController _contactController;
  late TextEditingController _imageUrlController;

  String _selectedGender = 'putra';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final kos = widget.existingKos;

    _nameController = TextEditingController(text: kos?.name ?? '');
    _addressController = TextEditingController(text: kos?.address ?? '');
    _priceController = TextEditingController(text: kos?.price.toString() ?? '');
    _roomController = TextEditingController(text: kos?.roomAvailable.toString() ?? '1');
    _contactController = TextEditingController(text: kos?.contactNumber ?? '');
    _imageUrlController = TextEditingController(text: kos?.imageUrl ?? '');

    if (kos != null) {
      _selectedGender = kos.genderType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _roomController.dispose();
    _contactController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final ownerId = context.read<AuthProvider>().currentUser?.id ?? '';
    final provider = context.read<OwnerKosProvider>();

    // Normalisasi nomor HP
    final normalizedContact = Kos.normalizeContactNumber(_contactController.text);

    bool success;
    if (widget.existingKos == null) {
      // Mode Tambah (T17)
      final newKos = Kos(
        id: '', // ID akan digenerate oleh Supabase
        ownerId: ownerId,
        name: _nameController.text.trim(),
        genderType: _selectedGender,
        price: int.parse(_priceController.text.trim()),
        roomAvailable: int.parse(_roomController.text.trim()),
        address: _addressController.text.trim(),
        contactNumber: normalizedContact,
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      success = await provider.createKos(newKos);
    } else {
      // Mode Edit (T18 nanti)
      final updates = {
        'name': _nameController.text.trim(),
        'gender_type': _selectedGender,
        'price': int.parse(_priceController.text.trim()),
        'room_available': int.parse(_roomController.text.trim()),
        'address': _addressController.text.trim(),
        'contact_number': normalizedContact,
        'image_url': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      };
      success = await provider.updateKos(widget.existingKos!.id, updates, ownerId);
    }

    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingKos == null ? 'Kos berhasil ditambahkan!' : 'Kos berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke Dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal menyimpan data.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingKos != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Kos' : 'Tambah Kos Baru'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nama Kos
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kos',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama kos wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Tipe Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Tipe Kos',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'putra', child: Text('Putra')),
                  DropdownMenuItem(value: 'putri', child: Text('Putri')),
                  DropdownMenuItem(value: 'campur', child: Text('Campur')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGender = val);
                },
              ),
              const SizedBox(height: 16),

              // Harga
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga per Bulan (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Harga wajib diisi';
                  final price = int.tryParse(val);
                  if (price == null || price <= 0) return 'Harga harus berupa angka lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sisa Kamar (Validasi >= 0)
              TextFormField(
                controller: _roomController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sisa Kamar',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Sisa kamar wajib diisi';
                  final room = int.tryParse(val);
                  if (room == null) return 'Harus berupa angka';
                  if (room < 0) return 'Sisa kamar tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Alamat
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat / Lokasi',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Alamat wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Nomor HP
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp',
                  hintText: 'Contoh: 08123456789',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Nomor WA wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // URL Gambar
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEditMode ? 'Simpan Perubahan' : 'Simpan Kos', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}