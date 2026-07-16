import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/tenant_bill_entity.dart';
import 'pdf_invoice_helper.dart';
import '../../../../core/theme/app_theme.dart';

class ShareBillSheet extends StatefulWidget {
  final TenantBillEntity bill;

  const ShareBillSheet({super.key, required this.bill});

  @override
  State<ShareBillSheet> createState() => _ShareBillSheetState();
}

class _ShareBillSheetState extends State<ShareBillSheet> {
  bool _isLoading = false;

  String _getWhatsAppMessage() {
    final dueDateStr = DateFormat('dd MMM yyyy').format(widget.bill.dueDate);
    return 'Hello ${widget.bill.tenantName}, Please find attached your monthly rent bill for ${widget.bill.month}. Total Amount: ₹${widget.bill.total.toStringAsFixed(0)} Due Date: $dueDateStr. Kindly make the payment on or before the due date. Thank you.';
  }

  String _getEmailSubject() {
    return 'Rent Bill - ${widget.bill.month}';
  }

  String _getEmailBody() {
    final dueDateStr = DateFormat('dd MMM yyyy').format(widget.bill.dueDate);
    return 'Dear ${widget.bill.tenantName},\n\nPlease find attached your monthly rent bill.\n\nTotal Amount: ₹${widget.bill.total.toStringAsFixed(0)}\nDue Date: $dueDateStr.\n\nKindly make the payment before the due date.\n\nThank you.';
  }

  Future<void> _shareViaWhatsApp() async {
    setState(() => _isLoading = true);
    try {
      final file = await PdfInvoiceHelper.generateInvoicePdf(widget.bill);
      // Native OS sharing via share_plus with prefilled text
      await Share.shareXFiles([XFile(file.path)], text: _getWhatsAppMessage());
    } catch (e) {
      _showToast('Failed to share via WhatsApp');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _shareViaEmail() async {
    setState(() => _isLoading = true);
    try {
      final file = await PdfInvoiceHelper.generateInvoicePdf(widget.bill);
      // Native OS sharing via share_plus with subject and body
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: _getEmailSubject(),
        text: _getEmailBody(),
      );
    } catch (e) {
      _showToast('Failed to share via Email');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _shareAsPdf() async {
    setState(() => _isLoading = true);
    try {
      final file = await PdfInvoiceHelper.generateInvoicePdf(widget.bill);
      await Share.shareXFiles([XFile(file.path)], subject: 'Invoice ${widget.bill.billNumber}');
    } catch (e) {
      _showToast('Failed to share PDF');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _downloadAndSavePdf() async {
    setState(() => _isLoading = true);
    try {
      // 1. Generate & Upload to Storage (caches URL)
      final storageUrl = await PdfInvoiceHelper.getOrUploadPdfUrl(widget.bill);
      
      // 2. Open print dialog or layout PDF
      await PdfInvoiceHelper.printInvoice(widget.bill);
      _showToast('PDF Generated & Ready for Print/Save');
    } catch (e) {
      _showToast('Failed to print/save PDF');
    }
    setState(() => _isLoading = false);
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LedgerlyColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Share Invoice',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: LedgerlyColors.navy900,
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: LedgerlyColors.gold))
          else
            Column(
              children: [
                _buildShareOption(
                  icon: HugeIcons.strokeRoundedWhatsapp,
                  title: 'Share via WhatsApp',
                  subtitle: 'Prefilled template with attached PDF',
                  color: const Color(0xFF25D366),
                  onTap: _shareViaWhatsApp,
                ),
                const SizedBox(height: 12),
                _buildShareOption(
                  icon: HugeIcons.strokeRoundedMailAtSign01,
                  title: 'Share via Email',
                  subtitle: 'Prefilled subject/body with attached PDF',
                  color: LedgerlyColors.indigo,
                  onTap: _shareViaEmail,
                ),
                const SizedBox(height: 12),
                _buildShareOption(
                  icon: HugeIcons.strokeRoundedShare01,
                  title: 'Share as PDF file',
                  subtitle: 'Open native OS share sheet',
                  color: LedgerlyColors.gold,
                  onTap: _shareAsPdf,
                ),
                const SizedBox(height: 12),
                _buildShareOption(
                  icon: HugeIcons.strokeRoundedPrinter,
                  title: 'Download / Print PDF',
                  subtitle: 'Send to local storage or printer',
                  color: LedgerlyColors.navy950,
                  onTap: _downloadAndSavePdf,
                ),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required dynamic icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: LedgerlyColors.borderLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: HugeIcon(icon: icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: LedgerlyColors.navy900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: LedgerlyColors.inkSoftLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: LedgerlyColors.inkSoftLight),
          ],
        ),
      ),
    );
  }
}
