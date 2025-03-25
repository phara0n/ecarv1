# eCar Garage Management Web Admin Interface

A Flutter web application for garage administrators to manage customers, vehicles, repairs, and invoices for the eCar Garage in Tunisia.

## Repository
- **GitHub:** [https://github.com/phara0n/ecarv1](https://github.com/phara0n/ecarv1)

## Features

- Admin authentication and authorization
- Customer management (add, edit, remove)
- Vehicle management with detailed service history
- Repair tracking and management
  - Status tracking (pending, in progress, completed, cancelled)
  - Technician assignment
  - Parts and labor tracking
  - Service history for vehicles
  - Statistics and reporting
- Invoice generation and management
  - Create invoices for repairs
  - Track payment status (paid, pending, overdue)
  - Generate PDF invoices
  - Send invoices via email
  - Payment tracking and reporting
- Reporting and analytics dashboard
- Multilingual support (English, French, Arabic)

## Technologies Used

- Flutter Web for cross-platform development
- Provider for state management
- HTTP package for API communication
- Chart libraries for analytics
- PDF generation for reports and invoices

## Getting Started

### Prerequisites

- Flutter SDK
- Web browser (Chrome recommended for development)
- A running instance of the eCar Garage Management API

### Installation

1. Clone the repository: `git clone https://github.com/phara0n/ecarv1.git`
2. Navigate to the project directory: `cd ecarv1/frontend/web`
3. Run `flutter pub get` to install dependencies
4. Update the API base URL in configuration files
5. Run the app using `flutter run -d chrome`

## Deployment

The web admin interface can be deployed to:

- Firebase Hosting
- Netlify
- Custom VPS

## Project Structure

- `lib/models/` - Data models for the application
  - `repair.dart` - Model for repair management
  - `invoice.dart` - Model for invoice management
  - Other business models
- `lib/screens/` - UI screens for the admin interface
  - `dashboard_screen.dart` - Main dashboard with statistics
  - `repairs_screen.dart` - Complete repair management interface
  - `invoices_screen.dart` - Invoice management interface
- `lib/services/` - API communication and business logic
  - `auth_service.dart` - Handles authentication
  - `repair_service.dart` - Manages repair API requests
  - `invoice_service.dart` - Manages invoice API requests
- `lib/widgets/` - Reusable UI components
- `assets/` - Images, icons, and fonts

## Design

The admin interface features a professional design for garage administrators:

- Clean, functional layout for efficient workflow
- Data tables and forms for managing customer information
- Dashboard with key metrics and analytics
- Responsive design for desktop and tablet use

## License

This project is proprietary software created for eCar Garage. 