import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data'; 
import 'package:image_picker/image_picker.dart'; 
import '../../../../main.dart'; 
import '../../../ticket/data/models/ticket_model.dart'; 
import '../../../ticket/presentation/providers/ticket_provider.dart'; 
import '../../../comment/presentation/providers/comment_provider.dart'; 
import '../../../comment/presentation/widgets/comment_bubble.dart'; 
import '../../../auth/presentation/providers/auth_provider.dart'; 
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../history/presentation/pages/ticket_history_page.dart';

class TicketDetailPage extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailPage({super.key, required this.ticket});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final _commentController = TextEditingController();
  
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  String? selectedHelpdeskId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().fetchComments(widget.ticket.id);
      
      final role = context.read<AuthProvider>().user?.role.toLowerCase() ?? supabase.auth.currentUser?.userMetadata?['role']?.toString().toLowerCase() ?? '';
      final hasAdminAccess = (role == 'admin' || role == 'isadmin' || role == 'issuperadmin');
      
      if (hasAdminAccess) {
        context.read<ProfileProvider>().loadHelpdeskUsers();
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedFileBytes = bytes;
        _selectedFileName = image.name;
      });
    }
  }

  void _handleSendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty && _selectedFileBytes == null) return; 

    final textToSend = text;
    final fileBytesToSend = _selectedFileBytes;
    final fileNameToSend = _selectedFileName;

    _commentController.clear();
    setState(() {
      _selectedFileBytes = null;
      _selectedFileName = null;
    });
    
    final role = context.read<AuthProvider>().user?.role.toLowerCase() 
                 ?? supabase.auth.currentUser?.userMetadata?['role']?.toString().toLowerCase() 
                 ?? 'user';

    await context.read<CommentProvider>().sendComment(
      widget.ticket, 
      textToSend,
      role, 
      fileBytes: fileBytesToSend,
      fileName: fileNameToSend,
    );  
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = supabase.auth.currentUser?.id;
    
    final role = authProvider.user?.role.toLowerCase() ?? supabase.auth.currentUser?.userMetadata?['role']?.toString().toLowerCase() ?? '';
    final hasAdminAccess = (role == 'admin' || role == 'isadmin' || role == 'issuperadmin');
    final isHelpdesk = (role == 'helpdesk');
    
    final isTicketClosed = widget.ticket.status.toLowerCase() == 'closed';
    final canCloseTicket = !isTicketClosed && isHelpdesk;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.black87),
          label: const Text("Back", style: TextStyle(color: Colors.black87, fontSize: 14)),
        ),
        title: const Text("Ticket Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketHistoryPage(
                    ticketId: widget.ticket.id,
                    ticketTitle: widget.ticket.title,
                  ),
                ),
              );
            },
          )
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- SECTION ADMIN ONLY: ASSIGN HELPDESK ---
                  // 👇 HANYA ADA 1 BLOK SEKARANG DENGAN LOGIKA PENJAGA YANG SUPER KETAT
                  if (hasAdminAccess && !isTicketClosed && (widget.ticket.helpdeskId == null || widget.ticket.helpdeskId!.isEmpty)) ...[
                    _buildCardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ADMIN COMMAND: ASSIGN TICKET", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 12, letterSpacing: 1.2)),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Assign to Helpdesk",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                            ),
                            items: context.watch<ProfileProvider>().helpdeskUsers.map((user) {
                              return DropdownMenuItem(value: user.id, child: Text(user.fullName));
                            }).toList(),
                            onChanged: (val) => setState(() => selectedHelpdeskId = val),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4B39EF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                              ),
                              onPressed: selectedHelpdeskId == null ? null : () async {
                                final success = await context.read<TicketProvider>().assignTicketToHelpdesk(widget.ticket.id, selectedHelpdeskId!);
                                
                                if (success && mounted) {
                                  await context.read<HistoryProvider>().addHistoryLog(widget.ticket.id, 'Tiket ditugaskan kepada Helpdesk');
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket successfully assigned!")));
                                  Navigator.pop(context); // Kembali agar UI ter-refresh 
                                }
                              },
                              child: const Text("Execute Assign", style: TextStyle(color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 1. SECTION: HEADER TICKET
                  _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(widget.ticket.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                            const SizedBox(width: 12),
                            _buildStatusPill(widget.ticket.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTagPill(Icons.sell_outlined, widget.ticket.category.isNotEmpty ? widget.ticket.category : "General"),
                            const SizedBox(width: 8),
                            _buildPriorityPill(widget.ticket.priority),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildProgressTracker(widget.ticket.status), 
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ),
                        Text("Created: ${widget.ticket.date.length >= 10 ? widget.ticket.date.substring(0, 10) : widget.ticket.date}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. SECTION: DESCRIPTION
                  _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("DESCRIPTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        Text(widget.ticket.description, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. SECTION: ATTACHMENT TIKET UTAMA
                  if (widget.ticket.attachmentUrl != null) ...[
                    _buildCardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ATTACHMENT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.ticket.attachmentUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 4. SECTION: COMMENTS
                  _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("COMMENTS (${commentProvider.comments.length})", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                        const SizedBox(height: 16),
                        
                        if (commentProvider.isLoading)
                          const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                        else if (commentProvider.comments.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text("Belum ada diskusi untuk tiket ini.\nKirimkan pesan pertamamu!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                            ),
                          )
                        else
                          ...commentProvider.comments.map((comment) {
                            bool isMyComment = comment.userId == currentUserId;
                            return CommentBubble(
                                comment: comment, 
                                currentUserRole: role, 
                              );
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- BOTTOM CHAT INPUT (Dinamis: Hilang jika Closed) ---
          isTicketClosed
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: const Text(
                  "THIS TICKET IS CLOSED",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- TOMBOL CLOSE TICKET (KHUSUS ADMIN/HELPDESK) ---
                      if (canCloseTicket)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12)
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Close Ticket?"),
                                  content: const Text("Apakah kamu yakin masalah ini sudah selesai? Tiket tidak akan bisa dikomentari lagi."),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                      onPressed: () => Navigator.pop(context, true), 
                                      child: const Text("Ya, Tutup", style: TextStyle(color: Colors.white))
                                    ),
                                  ],
                                )
                              );

                              if (confirm == true) {
                                final success = await context.read<TicketProvider>().closeTicket(widget.ticket.id);
                                if (success && mounted) {
                                  await context.read<HistoryProvider>().addHistoryLog(widget.ticket.id, 'Tiket telah diselesaikan dan ditutup');
                                  Navigator.pop(context); 
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket Successfully Closed!")));
                                }
                              }
                            },
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                            label: const Text("Mark as Closed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),

                      // PREVIEW GAMBAR SEBELUM DIKIRIM
                      if (_selectedFileBytes != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.image, color: Color(0xFF4B39EF)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedFileName ?? 'Gambar terpilih',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                onPressed: () => setState(() {
                                  _selectedFileBytes = null;
                                  _selectedFileName = null;
                                }),
                              )
                            ],
                          ),
                        ),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.attach_file, color: Colors.grey),
                            onPressed: _pickImage,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _commentController, 
                              decoration: InputDecoration(
                                hintText: "Write a reply...",
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _handleSendComment, 
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(24)),
                              child: const Icon(Icons.send, color: Color(0xFF4B39EF), size: 20),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: child,
    );
  }

  Widget _buildStatusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFEef2FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF4B39EF).withValues(alpha: 0.2))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF4B39EF)), const SizedBox(width: 6),
          Text(status, style: const TextStyle(color: Color(0xFF4B39EF), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTagPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey), const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPriorityPill(String priority) {
    Color color = priority.toLowerCase() == 'high' ? Colors.red : (priority.toLowerCase() == 'medium' ? Colors.orange : Colors.teal);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color), const SizedBox(width: 6),
          Text(priority, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProgressTracker(String currentStatus) {
    final status = currentStatus.toLowerCase(); 
    return Row(
      children: [
        _buildStep("Open", isActive: true), 
        Expanded(child: Container(height: 2, color: const Color(0xFFEEEEEE))),
        _buildStep("Assign", isActive: status == "assign" || status == "in progress" || status == "closed"),
        Expanded(child: Container(height: 2, color: const Color(0xFFEEEEEE))),
        _buildStep("In Progress", isActive: status == "in progress" || status == "closed"),
        Expanded(child: Container(height: 2, color: const Color(0xFFEEEEEE))),
        _buildStep("Closed", isActive: status == "closed"),
      ],
    );
  }

  Widget _buildStep(String label, {required bool isActive}) {
    return Column(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isActive ? const Color(0xFF4B39EF) : Colors.grey.shade300, width: 2), color: Colors.white),
          child: Center(
            child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? const Color(0xFF4B39EF) : Colors.transparent)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.black87 : Colors.grey)),
      ],
    );
  }
}