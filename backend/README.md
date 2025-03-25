# eCar Garage Management Backend API

## Overview
This is the backend API for the eCar Garage Management Application, built with Ruby on Rails. It provides RESTful endpoints for managing customers, vehicles, repairs, and invoices for the garage.

## Repository
- **GitHub:** [https://github.com/phara0n/ecarv1](https://github.com/phara0n/ecarv1)

## Technology Stack
- **Ruby version:** 3.2.2
- **Rails version:** 7.1.0
- **Database:** PostgreSQL
- **Authentication:** JWT
- **API Serialization:** Active Model Serializers

## Features
- RESTful API endpoints for all resources
- JWT-based authentication
- PostgreSQL database with models and associations
- CORS support for cross-origin requests
- Active Storage for file uploads

## Getting Started
1. Install Ruby 3.2.2 (using rbenv, rvm, or asdf)
2. Install PostgreSQL
3. Clone the repository: `git clone https://github.com/phara0n/ecarv1.git`
4. Navigate to the backend directory: `cd ecarv1/backend`
5. Install dependencies: `bundle install`
6. Create and setup the database:
   ```
   rails db:create
   rails db:migrate
   rails db:seed # if you have seed data
   ```
7. Start the server: `rails server`

## API Endpoints
- `/api/v1/auth` - Authentication endpoints
- `/api/v1/customers` - Customer management
- `/api/v1/vehicles` - Vehicle management
- `/api/v1/repairs` - Repair management
- `/api/v1/invoices` - Invoice management

## Development
- Run tests: `rspec`
- Check code style: `rubocop`
