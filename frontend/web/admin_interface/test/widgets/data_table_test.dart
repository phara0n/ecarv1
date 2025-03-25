import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_interface/widgets/custom_data_table.dart';

void main() {
  group('CustomDataTable Widget Tests', () {
    testWidgets('CustomDataTable displays columns and rows correctly', (WidgetTester tester) async {
      // Define columns
      final columns = [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Email')),
      ];
      
      // Define rows
      final rows = [
        DataRow(cells: [
          DataCell(Text('1')),
          DataCell(Text('John Doe')),
          DataCell(Text('john.doe@example.com')),
        ]),
        DataRow(cells: [
          DataCell(Text('2')),
          DataCell(Text('Jane Smith')),
          DataCell(Text('jane.smith@example.com')),
        ]),
      ];
      
      // Build our widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomDataTable(
            columns: columns,
            rows: rows,
          ),
        ),
      ));

      // Verify columns are displayed
      expect(find.text('ID'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      
      // Verify rows are displayed
      expect(find.text('1'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('jane.smith@example.com'), findsOneWidget);
    });
    
    testWidgets('CustomDataTable displays empty state when no rows', (WidgetTester tester) async {
      // Define columns
      final columns = [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Name')),
      ];
      
      // Build our widget with empty rows
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomDataTable(
            columns: columns,
            rows: [],
            emptyMessage: 'No data available',
          ),
        ),
      ));

      // Verify columns are still displayed
      expect(find.text('ID'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      
      // Verify empty message is displayed
      expect(find.text('No data available'), findsOneWidget);
    });
    
    testWidgets('CustomDataTable displays loading state correctly', (WidgetTester tester) async {
      // Define columns
      final columns = [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Name')),
      ];
      
      // Build our widget in loading state
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomDataTable(
            columns: columns,
            rows: [],
            isLoading: true,
          ),
        ),
      ));

      // Verify loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('CustomDataTable pagination works correctly', (WidgetTester tester) async {
      // Define columns
      final columns = [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Name')),
      ];
      
      // Define rows (more than one page)
      final rows = List.generate(15, (index) => 
        DataRow(cells: [
          DataCell(Text('${index + 1}')),
          DataCell(Text('Person ${index + 1}')),
        ])
      );
      
      // Track current page
      int currentPage = 0;
      
      // Build our widget with pagination
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomDataTable(
            columns: columns,
            rows: rows,
            pageSize: 5,
            rowsPerPage: 5,
            currentPage: currentPage,
            totalItems: rows.length,
            onPageChanged: (page) {
              currentPage = page;
            },
          ),
        ),
      ));

      // Verify initial state shows first page items
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Person 1'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Person 5'), findsOneWidget);
      
      // Verify pagination info is displayed
      expect(find.text('1-5 of 15'), findsOneWidget);
      
      // Find and tap next page button
      final nextPageButton = find.byIcon(Icons.chevron_right);
      expect(nextPageButton, findsOneWidget);
      await tester.tap(nextPageButton);
      await tester.pumpAndSettle();
      
      // Verify onPageChanged was called
      expect(currentPage, 1);
    });
    
    testWidgets('CustomDataTable sorting works correctly', (WidgetTester tester) async {
      // Track sort column index and ascending
      int? sortColumnIndex;
      bool isAscending = true;
      
      // Define columns with onSort callback
      final columns = [
        DataColumn(
          label: Text('ID'),
          onSort: (columnIndex, ascending) {
            sortColumnIndex = columnIndex;
            isAscending = ascending;
          },
        ),
        DataColumn(label: Text('Name')),
      ];
      
      // Define rows
      final rows = [
        DataRow(cells: [
          DataCell(Text('1')),
          DataCell(Text('John')),
        ]),
        DataRow(cells: [
          DataCell(Text('2')),
          DataCell(Text('Jane')),
        ]),
      ];
      
      // Build our widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomDataTable(
            columns: columns,
            rows: rows,
            sortColumnIndex: sortColumnIndex,
            sortAscending: isAscending,
          ),
        ),
      ));

      // Find and tap on the sortable column header
      final idColumnHeader = find.text('ID');
      expect(idColumnHeader, findsOneWidget);
      await tester.tap(idColumnHeader);
      await tester.pump();
      
      // Verify onSort was called with correct parameters
      expect(sortColumnIndex, 0);
      expect(isAscending, true);
      
      // Tap again to change sort direction
      await tester.tap(idColumnHeader);
      await tester.pump();
      
      // Verify sort direction was changed
      expect(sortColumnIndex, 0);
      expect(isAscending, false);
    });
    
    testWidgets('CustomDataTable handles row selection correctly', (WidgetTester tester) async {
      // Track selected row
      int? selectedRow;
      
      // Define columns
      final columns = [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Name')),
      ];
      
      // Define rows with onSelectChanged callback
      final rows = [
        DataRow(
          cells: [
            DataCell(Text('1')),
            DataCell(Text('John')),
          ],
          onSelectChanged: (selected) {
            if (selected!) selectedRow = 0;
          },
        ),
        DataRow(
          cells: [
            DataCell(Text('2')),
            DataCell(Text('Jane')),
          ],
          onSelectChanged: (selected) {
            if (selected!) selectedRow = 1;
          },
        ),
      ];
      
      // Build our widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomDataTable(
            columns: columns,
            rows: rows,
          ),
        ),
      ));

      // Find and tap the first row
      final johnCell = find.text('John');
      expect(johnCell, findsOneWidget);
      await tester.tap(johnCell);
      await tester.pump();
      
      // Verify the correct row was selected
      expect(selectedRow, 0);
      
      // Find and tap the second row
      final janeCell = find.text('Jane');
      expect(janeCell, findsOneWidget);
      await tester.tap(janeCell);
      await tester.pump();
      
      // Verify the correct row was selected
      expect(selectedRow, 1);
    });
  });
} 