# eCar Garage Management Application

## Overview
This application is designed for a garage in Tunisia to manage customer vehicle repairs, invoices, and service history. It provides a mobile app for customers (iOS & Android) and a web interface for administrators.

## Project Structure
- `backend/` - Ruby on Rails API server
  - RESTful API endpoints for managing customers, vehicles, repairs, and invoices
  - Authentication using JWT tokens
  - PostgreSQL database with models for all business entities
  - Serializers for structured API responses
  - CORS support for cross-origin requests

- `frontend/` - Frontend applications
  - `flutter/` - Flutter application for both mobile and web
    - `ecar_app/` - Mobile application for customers with vehicle management, service history, and invoices
  - `web/` - Web admin interface (planned)

- `docs/` - Project documentation
  - `REQUIREMENTS.md` - Detailed requirements based on the project specification
  - `PROJECT_TIMELINE.md` - Project timeline with phases and milestones

## Features
- User authentication for customers and administrators
- Customer mobile app for viewing service history, invoices, and repair status
- Admin web interface for managing customers, repairs, invoices, and service scheduling
- Tunisian market-specific adaptations (language, tax requirements, vehicle types)
- Premium branding focused on high-end European automotive brands

## Technology Stack
- **Frontend:** Flutter (mobile & web)
- **Backend:** Ruby on Rails
- **Database:** PostgreSQL
- **Authentication:** JWT-based authentication
- **Storage:** Active Storage for file uploads
- **Internationalization:** Support for English, French, and Arabic

## Current Progress
- [x] Set up project structure
- [x] Create requirements and timeline documentation
- [x] Set up Rails API with PostgreSQL
- [x] Create data models and migrations
- [x] Implement authentication system
- [x] Create API controllers for resources
- [x] Set up CORS for cross-origin requests
- [x] Create basic Flutter project structure
- [x] Implement Flutter models and services
- [x] Design app theme based on brand specifications
- [x] Create basic screens for the mobile app

## Next Steps
- [ ] Complete customer mobile app screens
- [ ] Implement vehicle management features
- [ ] Add repair history viewing
- [ ] Create invoice download functionality
- [ ] Implement mileage update feature
- [ ] Add multilingual support
- [ ] Develop admin web interface
- [ ] Create deployment scripts
- [ ] Set up CI/CD pipeline
- [ ] Prepare for App Store and Google Play submission

## Getting Started
### Backend
1. Navigate to the `backend` directory
2. Run `bundle install` to install dependencies
3. Set up the database with `rails db:setup`
4. Start the server with `rails server`

### Flutter Mobile App
1. Navigate to the `frontend/flutter/ecar_app` directory
2. Run `flutter pub get` to install dependencies
3. Update the API base URL in the configuration
4. Run the app with `flutter run`

## License
Proprietary software for eCar Garage. 