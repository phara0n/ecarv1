# eCar Garage App

A complete garage management system with a Rails API backend and Flutter frontend.

## Project Structure

- `/backend`: Ruby on Rails API
- `/frontend/flutter/ecar_app`: Flutter mobile application
- `/frontend/web/admin_interface`: Flutter web admin interface

## Backend (Rails API)

The backend is a Ruby on Rails API that provides endpoints for managing:

- Customers and authentication
- Vehicles
- Repairs
- Invoices and payments
- Push notifications

### Authentication

The application uses JWT tokens for authentication. Customers can have either an 'admin' or 'customer' role.

### Testing

Run the backend tests with:

```bash
cd backend
RAILS_ENV=test rails test
```

## Frontend (Flutter Mobile App)

The Flutter app provides a mobile interface for:

- Authentication (login/logout)
- Customer dashboard
- Vehicle management
- Repair tracking
- Invoice viewing and payment
- Push notification preferences

### Testing

Run the Flutter tests with:

```bash
cd frontend/flutter/ecar_app
flutter test
```

## Admin Web Interface

The web-based admin interface allows garage administrators to:

- Manage customers and their vehicles
- Track and update repair status
- Create and manage invoices
- View statistics and reports
- Send push notifications to customers

### Features

- Responsive design for desktop and mobile
- Dashboard with key business metrics
- Complete repair management system
- Invoice generation and management
- Customer management

### Running the Web Interface

```bash
cd frontend/web/admin_interface
flutter pub get
flutter run -d chrome
```

## Push Notifications

The application implements push notifications using Firebase Cloud Messaging (FCM) to:

- Alert customers about repair status changes
- Send reminders for scheduled maintenance
- Notify about invoice generation and payment due dates
- Deliver promotional offers

## Development Setup

### Backend

1. Install Ruby and Rails
2. Install PostgreSQL
3. Set up the database:

```bash
cd backend
bundle install
rails db:create db:migrate db:seed
```

4. Start the server:

```bash
rails s
```

### Mobile App

1. Install Flutter SDK
2. Install dependencies:

```bash
cd frontend/flutter/ecar_app
flutter pub get
```

3. Run the app:

```bash
flutter run
```

### Web Admin Interface

1. Install Flutter SDK with web support
2. Install dependencies:

```bash
cd frontend/web/admin_interface
flutter pub get
```

3. Run the web app:

```bash
flutter run -d chrome
```

## API Documentation

For API documentation, see the OpenAPI specification in `/backend/docs/api.yaml`. 