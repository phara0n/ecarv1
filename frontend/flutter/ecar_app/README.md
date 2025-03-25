# eCar Garage Management Mobile App

A Flutter-based mobile application for customers of eCar Garage in Tunisia. This application allows customers to manage their vehicles, view service history, access invoices, and track repair status.

## Repository
- **GitHub:** [https://github.com/phara0n/ecarv1](https://github.com/phara0n/ecarv1)

## Features

- User authentication using secure JWT tokens
- View and manage vehicle information
- Track vehicle service history
- Access and download repair invoices
- Update vehicle mileage
- Request service appointments
- Receive notifications about repair status

## Technologies Used

- Flutter for cross-platform mobile development (iOS & Android)
- Provider for state management
- HTTP package for API communication
- Flutter Secure Storage for token management
- Internationalization support for English, French, and Arabic

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or Xcode
- A running instance of the eCar Garage Management API

### Installation

1. Clone the repository: `git clone https://github.com/phara0n/ecarv1.git`
2. Navigate to the project directory: `cd ecarv1/frontend/flutter/ecar_app`
3. Run `flutter pub get` to install dependencies
4. Update the API base URL in `lib/services/auth_service.dart` to point to your API instance
5. Run the app using `flutter run`

## Project Structure

- `lib/models/` - Data models (Customer, Vehicle, Repair, Invoice)
- `lib/screens/` - UI screens for the application
- `lib/services/` - API communication and business logic
- `lib/widgets/` - Reusable UI components
- `assets/` - Images, icons, and fonts

## Design

The app follows a premium design inspired by luxury automotive brands with a clean, minimalist interface featuring:

- Black primary color inspired by the eCar logo
- Brand-specific accent colors for BMW, Mercedes, and VW sections
- Clean typography using Helvetica font family
- Modern UI elements with subtle shadows and rounded corners

## Localization

The app is available in three languages:
- English
- French
- Arabic (including support for right-to-left layouts)

## License

This project is proprietary software created for eCar Garage.
