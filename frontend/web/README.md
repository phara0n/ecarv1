# eCar Garage Management Web Admin Interface

A Flutter web application for garage administrators to manage customers, vehicles, repairs, and invoices for the eCar Garage in Tunisia.

## Repository
- **GitHub:** [https://github.com/phara0n/ecarv1](https://github.com/phara0n/ecarv1)

## Features

- Admin authentication and authorization
- Customer management (add, edit, remove)
- Vehicle management with detailed service history
- Repair tracking and management
- Invoice generation and management
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
- `lib/screens/` - UI screens for the admin interface
- `lib/services/` - API communication and business logic
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