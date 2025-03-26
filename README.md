# eCar Garage Management Application

A comprehensive garage management system for a Tunisian auto repair shop specializing in BMW, Mercedes-Benz, and Volkswagen Group vehicles.

## Overview

This application allows garage administrators to manage customers, vehicles, repairs, and invoices through a web-based admin interface. Customers can access their vehicle history and invoices through a mobile app available on both iOS and Android.

## Quick Start

The easiest way to run both the backend and frontend for development is to use the provided startup script:

```bash
# From the project root
chmod +x start_apps.sh  # Make sure the script is executable
./start_apps.sh
```

This script:
1. Cleans up any existing processes on ports 3000 and 8090
2. Fixes necessary permissions for log and tmp directories
3. Starts the Rails backend on port 3000
4. Builds and serves the Flutter web admin interface on port 8090

After running the script, you can access:
- Backend API: http://localhost:3000
- Admin Interface: http://localhost:8090

Admin login credentials:
- Email: admin@ecar.tn
- Password: password123

## Manual Setup

If you prefer to run each component separately, follow these steps:

### Backend (Rails API)

```bash
cd backend
bundle install
rails db:create db:migrate db:seed
rails s -p 3000
```

### Admin Interface (Flutter Web)

```bash
cd frontend/web/admin_interface
flutter pub get
flutter run -d web-server --web-port 8090
```

## Project Structure

- `backend/`: Ruby on Rails API backend
- `frontend/flutter/ecar_app/`: Flutter mobile app for customers
- `frontend/web/admin_interface/`: Flutter web app for admin interface
- `docs/`: Project documentation
  - `PROJECT_TIMELINE.md`: Development timeline and milestones
  - `PROGRESS_SUMMARY.md`: Summary of completed features
  - `TEST_IMPLEMENTATION.md`: Testing strategy and guidelines

## Development Status

See [PROGRESS_SUMMARY.md](docs/PROGRESS_SUMMARY.md) for the latest updates on completed features and development status.

## License

© 2025 eCar Garage. All rights reserved. 