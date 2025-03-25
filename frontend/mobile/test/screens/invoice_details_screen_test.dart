import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ecar_garage/l10n/app_localizations.dart';
import 'package:ecar_garage/models/invoice.dart';
import 'package:ecar_garage/models/repair.dart';
import 'package:ecar_garage/models/customer.dart';
import 'package:ecar_garage/models/vehicle.dart';
import 'package:ecar_garage/providers/auth_provider.dart';
import 'package:ecar_garage/screens/invoice_details_screen.dart';
import 'package:ecar_garage/services/invoice_service.dart';

// Create mock classes
class MockInvoiceService extends Mock implements InvoiceService {}
class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockInvoiceService mockInvoiceService;
  late MockAuthProvider mockAuthProvider;
  
  // Test data
  final vehicle = Vehicle(
    id: 1,
    brand: 'BMW',
    model: '3 Series',
    year: 2018,
    licensePlate: '123 TUN 4567',
    currentMileage: 50000,
  );
  
  final repair = Repair(
    id: 1,
    description: 'Oil change and brake inspection',
    status: 'completed',
    startDate: '2023-05-15',
    completionDate: '2023-05-16',
    vehicle: vehicle,
    technicianName: 'Ahmed Ben Ali',
  );
  
  final customer = Customer(
    id: 1,
    firstName: 'Mohammed',
    lastName: 'Khadhraoui',
    email: 'mohammed@example.com',
    phone: '216 98 765 432',
    address: 'Tunis, Tunisia',
  );
  
  final invoice = Invoice(
    id: 1,
    invoiceNumber: 'ECAR/2023/050001',
    amount: 500.00,
    issueDate: '2023-05-16',
    paymentStatus: 'unpaid',
    paymentMethod: null,
    repair: repair,
    customer: customer,
    pdfUrl: 'https://example.com/invoice.pdf',
  );
  
  final partialInvoice = Invoice(
    id: 2,
    invoiceNumber: 'ECAR/2023/050002',
    amount: 500.00,
    issueDate: '2023-05-16',
    paymentStatus: 'partial',
    paymentMethod: 'cash',
    paidAmount: 200.00,
    repair: repair,
    customer: customer,
    pdfUrl: 'https://example.com/invoice.pdf',
  );
  
  final paidInvoice = Invoice(
    id: 3,
    invoiceNumber: 'ECAR/2023/050003',
    amount: 500.00,
    issueDate: '2023-05-16',
    paymentStatus: 'paid',
    paymentMethod: 'credit_card',
    paidAmount: 500.00,
    repair: repair,
    customer: customer,
    pdfUrl: 'https://example.com/invoice.pdf',
  );
  
  setUp(() {
    mockInvoiceService = MockInvoiceService();
    mockAuthProvider = MockAuthProvider();
  });
  
  Widget createWidgetUnderTest(Invoice testInvoice) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ],
        child: InvoiceDetailsScreen(invoiceId: testInvoice.id.toString()),
      ),
    );
  }
  
  testWidgets('displays invoice details correctly for unpaid invoice', (WidgetTester tester) async {
    // Setup mocks
    when(mockInvoiceService.getInvoiceDetails(any)).thenAnswer((_) async => invoice);
    
    // Build widget
    await tester.pumpWidget(createWidgetUnderTest(invoice));
    await tester.pumpAndSettle(); // Wait for future to complete
    
    // Verify basic information is displayed
    expect(find.text('Invoice Details'), findsOneWidget);
    expect(find.text('500.00'), findsOneWidget);
    expect(find.text('Unpaid'), findsOneWidget);
    
    // Verify invoice number and date are shown
    expect(find.textContaining(invoice.invoiceNumber), findsOneWidget);
    expect(find.textContaining(invoice.issueDate), findsOneWidget);
  });
  
  testWidgets('displays invoice details correctly for partially paid invoice', (WidgetTester tester) async {
    // Setup mocks
    when(mockInvoiceService.getInvoiceDetails(any)).thenAnswer((_) async => partialInvoice);
    
    // Build widget
    await tester.pumpWidget(createWidgetUnderTest(partialInvoice));
    await tester.pumpAndSettle(); // Wait for future to complete
    
    // Verify basic information is displayed
    expect(find.text('Invoice Details'), findsOneWidget);
    expect(find.text('500.00'), findsOneWidget);
    expect(find.text('Partially Paid'), findsOneWidget);
    
    // Verify paid amount and remaining amount are shown
    expect(find.text('200.00'), findsOneWidget);
    expect(find.text('300.00'), findsOneWidget);
  });
  
  testWidgets('displays invoice details correctly for paid invoice', (WidgetTester tester) async {
    // Setup mocks
    when(mockInvoiceService.getInvoiceDetails(any)).thenAnswer((_) async => paidInvoice);
    
    // Build widget
    await tester.pumpWidget(createWidgetUnderTest(paidInvoice));
    await tester.pumpAndSettle(); // Wait for future to complete
    
    // Verify basic information is displayed
    expect(find.text('Invoice Details'), findsOneWidget);
    expect(find.text('500.00'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    
    // Verify payment method is shown
    expect(find.text('Credit Card'), findsOneWidget);
  });
  
  testWidgets('shows payment options for unpaid invoice when user is customer', (WidgetTester tester) async {
    // Setup mocks
    when(mockInvoiceService.getInvoiceDetails(any)).thenAnswer((_) async => invoice);
    when(mockAuthProvider.user).thenReturn(User(id: 1, role: 'customer'));
    
    // Build widget
    await tester.pumpWidget(createWidgetUnderTest(invoice));
    await tester.pumpAndSettle(); // Wait for future to complete
    
    // Verify pay button is shown
    expect(find.text('Pay Invoice'), findsOneWidget);
    
    // Tap pay button and verify payment options are shown
    await tester.tap(find.text('Pay Invoice'));
    await tester.pumpAndSettle();
    
    expect(find.text('Select Payment Method'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Credit Card'), findsOneWidget);
    expect(find.text('Bank Transfer'), findsOneWidget);
  });
  
  testWidgets('does not show payment options for paid invoice', (WidgetTester tester) async {
    // Setup mocks
    when(mockInvoiceService.getInvoiceDetails(any)).thenAnswer((_) async => paidInvoice);
    when(mockAuthProvider.user).thenReturn(User(id: 1, role: 'customer'));
    
    // Build widget
    await tester.pumpWidget(createWidgetUnderTest(paidInvoice));
    await tester.pumpAndSettle(); // Wait for future to complete
    
    // Verify pay button is not shown
    expect(find.text('Pay Invoice'), findsNothing);
  });
} 