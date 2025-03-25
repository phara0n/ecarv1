# eCar Garage App

A complete garage management system with a Rails API backend and Flutter frontend.

## Project Structure

- `/backend`: Ruby on Rails API
- `/frontend/flutter/ecar_app`: Flutter mobile application

## Backend (Rails API)

The backend is a Ruby on Rails API that provides endpoints for managing:

- Customers and authentication
- Vehicles
- Repairs
- Invoices and payments

### Authentication

The application uses JWT tokens for authentication. Customers can have either an 'admin' or 'customer' role.

### Testing

Run the backend tests with:

```bash
cd backend
RAILS_ENV=test rails test
```

## Frontend (Flutter)

The Flutter app provides a mobile interface for:

- Authentication (login/logout)
- Customer dashboard
- Vehicle management
- Repair tracking
- Invoice viewing and payment

### Testing

Run the Flutter tests with:

```bash
cd frontend/flutter/ecar_app
flutter test
```

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

### Frontend

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

## API Documentation

For API documentation, see the OpenAPI specification in `/backend/docs/api.yaml`. 