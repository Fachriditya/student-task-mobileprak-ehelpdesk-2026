import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/priority_selector.dart';
import 'dart:typed_data'; // Untuk tipe data Bytes (Gambar)
import 'package:image_picker/image_picker.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = "Account Access"; 
  String _priority = "Medium";

  // 1. Variabel penampung gambar
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  
  // 2. Fungsi untuk membuka galeri/file explorer
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final bytes = await image.readAsBytes(); 
      setState(() {
        _selectedFileBytes = bytes;
        _selectedFileName = image.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Support Ticket", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("TITLE *"),
            TextField(controller: _titleController, decoration: _inputDecoration("Brief summary of your issue")),
            
            const SizedBox(height: 20),
            _buildLabel("CATEGORY *"),
            _buildCategoryDropdown(),
            
            const SizedBox(height: 20),
            _buildLabel("PRIORITY"),
            PrioritySelector(selectedPriority: _priority, onSelected: (p) => setState(() => _priority = p)),
            
            const SizedBox(height: 20),
            _buildLabel("DESCRIPTION *"),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: _inputDecoration("Describe your issue in detail..."),
            ),
            
            const SizedBox(height: 24),
            _buildLabel("ATTACHMENTS (OPTIONAL)"),
            // 3. Memanggil desain area upload yang baru
            _buildUploadArea(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: ticketProvider.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B39EF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: ticketProvider.isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text("Submit Ticket", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  // 4. Desain area upload yang bisa diklik dan berubah warna
  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickImage, // Eksekusi fungsi buka galeri
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.none),
          borderRadius: BorderRadius.circular(16),
          // Warna berubah jika gambar sudah dipilih
          color: _selectedFileBytes != null 
              ? const Color(0xFFEef2FF) 
              : Colors.grey.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(
              _selectedFileBytes != null ? Icons.check_circle : Icons.cloud_upload_outlined, 
              size: 40, 
              color: const Color(0xFF4B39EF)
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFileBytes != null ? "File Terpilih!" : "Tap to upload image", 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              _selectedFileBytes != null ? _selectedFileName! : "PNG, JPG up to 10MB", 
              style: const TextStyle(fontSize: 12, color: Colors.grey)
            ),
          ],
        ),
      ),
    );
  }

  // 5. Fungsi submit mengirim data file ke Provider
  void _submit() async {
    // Sedikit validasi tambahan biar nggak ngirim data kosong
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title dan Description wajib diisi!"), backgroundColor: Colors.red)
      );
      return;
    }

    final success = await context.read<TicketProvider>().addTicket({
      "title": _titleController.text,
      "category": _category,
      "priority": _priority,
      "description": _descController.text,
      // Mengirim file dan namanya ke tahap selanjutnya
      "fileBytes": _selectedFileBytes,
      "fileName": _selectedFileName,
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tiket berhasil dibuat!"), backgroundColor: Colors.green)
      );
    }
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          items: ["Account Access", "Hardware", "Software", "Network"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (val) => setState(() => _category = val!),
        ),
      ),
    );
  }
}