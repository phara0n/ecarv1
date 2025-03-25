import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/invoice.dart';
import '../providers/auth_provider.dart';
import '../services/invoice_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailsScreen({Key? key, required this.invoiceId}) : super(key: key);

  @override
  _InvoiceDetailsScreenState createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  late Future<Invoice> _invoiceFuture;
  final InvoiceService _invoiceService = InvoiceService();
  
  @override
  void initState() {
    super.initState();
    _invoiceFuture = _invoiceService.getInvoiceDetails(widget.invoiceId);
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    final currencyFormat = NumberFormat.currency(
      locale: locale.toString(),
      symbol: localizations.currency,
      decimalDigits: 3, // Tunisian currency uses 3 decimal places
    );
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.invoiceDetailsTitle),
          actions: [
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () => _downloadInvoice(context),
              tooltip: localizations.downloadInvoice,
            ),
          ],
        ),
        body: FutureBuilder<Invoice>(
          future: _invoiceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: LoadingIndicator());
            } else if (snapshot.hasError) {
              return Center(child: ErrorMessage(message: snapshot.error.toString()));
            } else if (!snapshot.hasData) {
              return Center(child: Text(localizations.errorMessage));
            }
            
            final invoice = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, invoice, localizations),
                  SizedBox(height: 24),
                  _buildInvoiceDetails(context, invoice, localizations, currencyFormat),
                  SizedBox(height: 24),
                  _buildRepairDetails(context, invoice, localizations),
                  SizedBox(height: 24),
                  _buildVehicleDetails(context, invoice, localizations),
                  SizedBox(height: 24),
                  _buildPaymentStatus(context, invoice, localizations),
                  SizedBox(height: 32),
                  _buildActions(context, invoice, localizations),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, Invoice invoice, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "eCar Garage",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          // "Facture Normalisée" for Tunisian standardized invoicing
          "Facture Normalisée",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Divider(thickness: 2),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              "${localizations.invoiceNumber}: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(invoice.invoiceNumber),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Text(
              "${localizations.invoiceDate}: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(invoice.issueDate),
          ],
        ),
      ],
    );
  }
  
  Widget _buildInvoiceDetails(
    BuildContext context, 
    Invoice invoice, 
    AppLocalizations localizations,
    NumberFormat currencyFormat
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.invoiceDetailsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            
            // Pre-tax amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${localizations.amount} (HT):"),
                Text(currencyFormat.format(invoice.amount)),
              ],
            ),
            SizedBox(height: 8),
            
            // Tunisian VAT amount (19%)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TVA (19%):"),
                Text(currencyFormat.format(invoice.taxAmount)),
              ],
            ),
            Divider(),
            
            // Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total (TTC):",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormat.format(invoice.totalAmount),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRepairDetails(BuildContext context, Invoice invoice, AppLocalizations localizations) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.repairDetailsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text(invoice.repair.description),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "${localizations.repairDate}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(invoice.repair.completionDate ?? "-"),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "${localizations.technicianName}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(invoice.repair.technicianName ?? "-"),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVehicleDetails(BuildContext context, Invoice invoice, AppLocalizations localizations) {
    final vehicle = invoice.repair.vehicle;
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.vehicleDetails,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  "${localizations.brand}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(vehicle.brand),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "${localizations.model}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(vehicle.model),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "${localizations.year}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(vehicle.year.toString()),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "${localizations.licensePlate}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(vehicle.licensePlate),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentStatus(BuildContext context, Invoice invoice, AppLocalizations localizations) {
    // Get appropriate color and text for payment status
    Color statusColor;
    String statusText;
    
    switch (invoice.paymentStatus) {
      case 'paid':
        statusColor = Colors.green;
        statusText = localizations.paid;
        break;
      case 'partial':
        statusColor = Colors.orange;
        statusText = localizations.partial;
        break;
      default:
        statusColor = Colors.red;
        statusText = localizations.unpaid;
        break;
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.paymentStatus,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (invoice.paymentStatus == 'paid' || invoice.paymentStatus == 'partial')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Text(
                      "${localizations.paymentMethod}: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_getPaymentMethod(invoice.paymentMethod, localizations)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  String _getPaymentMethod(String? method, AppLocalizations localizations) {
    if (method == null) return '-';
    
    switch (method) {
      case 'cash':
        return localizations.paymentMethodCash;
      case 'credit_card':
        return localizations.paymentMethodCard;
      case 'bank_transfer':
        return localizations.paymentMethodBank;
      default:
        return method;
    }
  }
  
  Widget _buildActions(BuildContext context, Invoice invoice, AppLocalizations localizations) {
    final isCustomer = Provider.of<AuthProvider>(context).user?.role == 'customer';
    
    // Only show payment button for customers with unpaid invoices
    if (isCustomer && invoice.paymentStatus == 'unpaid') {
      return ElevatedButton(
        onPressed: () => _showPaymentOptions(context, invoice, localizations),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: Text(localizations.payInvoice),
      );
    }
    
    return SizedBox.shrink();
  }
  
  void _showPaymentOptions(BuildContext context, Invoice invoice, AppLocalizations localizations) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.selectPaymentMethod,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.payments),
                title: Text(localizations.paymentMethodCash),
                subtitle: Text(localizations.paymentMethodCashDesc),
                onTap: () {
                  Navigator.pop(context);
                  // Logic for cash payment
                },
              ),
              ListTile(
                leading: Icon(Icons.credit_card),
                title: Text(localizations.paymentMethodCard),
                subtitle: Text(localizations.paymentMethodCardDesc),
                onTap: () {
                  Navigator.pop(context);
                  // Logic for credit card payment
                },
              ),
              ListTile(
                leading: Icon(Icons.account_balance),
                title: Text(localizations.paymentMethodBank),
                subtitle: Text(localizations.paymentMethodBankDesc),
                onTap: () {
                  Navigator.pop(context);
                  // Logic for bank transfer
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _downloadInvoice(BuildContext context) async {
    try {
      final invoice = await _invoiceFuture;
      if (invoice.pdfUrl != null) {
        if (await canLaunch(invoice.pdfUrl!)) {
          await launch(invoice.pdfUrl!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).errorMessage))
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).noPdfAvailable))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }
} 