import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/tenant_bill_entity.dart';

class PdfInvoiceHelper {
  static Future<File> generateInvoicePdf(TenantBillEntity bill) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Top accent line
                pw.Container(height: 6, color: PdfColor.fromHex('#C9972B')),
                pw.SizedBox(height: 20),
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('LEDGERLY INVOICE',
                            style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#10233B'))),
                        pw.Text('Bill Number: ${bill.billNumber}',
                            style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColor.fromHex('#E4573D'), width: 2),
                      ),
                      child: pw.Text(
                        bill.status.toUpperCase(),
                        style: pw.TextStyle(
                            color: PdfColor.fromHex('#E4573D'),
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                // Bill metadata
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BILL TO:',
                            style: pw.TextStyle(
                                color: PdfColor.fromHex('#8A93A6'),
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text(bill.tenantName,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        pw.Text('Room Number: ${bill.roomNumber}'),
                        pw.Text('Billing Period: ${bill.month}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('INVOICE DATE: ${bill.createdDate.day}/${bill.createdDate.month}/${bill.createdDate.year}'),
                        pw.Text('DUE DATE: ${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}'),
                      ],
                    ),
                  ],
                ),
                pw.Divider(height: 40),
                // Item Table
                pw.Table(
                  columnWidths: const {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('DESCRIPTION',
                            style: pw.TextStyle(
                                color: PdfColor.fromHex('#8A93A6'),
                                fontWeight: pw.FontWeight.bold)),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('AMOUNT',
                                style: pw.TextStyle(
                                    color: PdfColor.fromHex('#8A93A6'),
                                    fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    _buildTableRow('Rent Amount', bill.rent),
                    if (bill.electricity > 0)
                      _buildTableRow('Electricity Charge (${bill.electricityUnits.toStringAsFixed(1)} units)', bill.electricity),
                    if (bill.maintenance > 0) _buildTableRow('Maintenance Charge', bill.maintenance),
                    if (bill.other > 0) _buildTableRow('Other Charge', bill.other),
                    if (bill.previousDue > 0) _buildTableRow('Previous Balance Due', bill.previousDue),
                    if (bill.advanceAdjustment > 0) _buildTableRow('Advance Adjustment', -bill.advanceAdjustment),
                    if (bill.discount > 0) _buildTableRow('Discount Applied', -bill.discount),
                  ],
                ),
                pw.Divider(height: 40),
                // Total Row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL DUE',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('INR ${bill.total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#C9972B'))),
                  ],
                ),
                pw.SizedBox(height: 50),
                pw.Center(
                  child: pw.Text('Thank you for your prompt payment!',
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                ),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${bill.billNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<String> getOrUploadPdfUrl(TenantBillEntity bill) async {
    if (bill.pdfUrl.isNotEmpty) return bill.pdfUrl;

    // 1. Generate local PDF
    final file = await generateInvoicePdf(bill);

    // 2. Upload to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('properties/${bill.propertyId}/bills/${bill.id}.pdf');
    final uploadTask = await storageRef.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // 3. Cache URL in bills document
    await FirebaseFirestore.instance.collection('bills').doc(bill.id).update({
      'pdfUrl': downloadUrl,
    });

    return downloadUrl;
  }

  static Future<void> printInvoice(TenantBillEntity bill) async {
    final file = await generateInvoicePdf(bill);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => file.readAsBytesSync(),
    );
  }
}

pw.TableRow _buildTableRow(String desc, double amount) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Text(desc, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('${amount < 0 ? '-' : ''}INR ${amount.abs().toStringAsFixed(2)}'),
        ),
      ),
    ],
  );
}
