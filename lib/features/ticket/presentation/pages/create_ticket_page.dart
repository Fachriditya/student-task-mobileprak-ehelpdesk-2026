import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/priority_selector.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = "Account Access"; // Default
  String _priority = "Medium";

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("New Support Ticket"), leading: const BackButton()),
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
            _buildUploadArea(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: ticketProvider.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF)),
                child: ticketProvider.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Submit Ticket", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  Widget _buildUploadArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.none), // Bisa diganti DottedBorder
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.withOpacity(0.05),
      ),
      child: const Column(
        children: [
          Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF4B39EF)),
          SizedBox(height: 8),
          Text("Tap to upload file", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("PNG, JPG, PDF up to 10MB", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  void _submit() async {
    final success = await context.read<TicketProvider>().addTicket({
      "title": _titleController.text,
      "category": _category,
      "priority": _priority,
      "description": _descController.text,
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tiket berhasil dibuat!")));
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