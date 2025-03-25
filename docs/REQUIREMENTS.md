# eCar Garage Management Application - Requirements

This document outlines the detailed requirements for the eCar Garage Management Application based on the project specification.

## 1. User Authentication

### Customer Authentication
- Customers will log in using credentials provided by the garage.
- Authentication will be secured with JWT tokens.
- Password reset functionality will be available.

### Admin Authentication
- Admins will log in via a secure web interface.
- Multi-factor authentication for admin accounts.
- Role-based access control for different admin functions.

## 2. Customer Interface (Mobile App - iOS & Android)

### Features
- View past service history with detailed repair information.
- Access and download invoices for completed repairs.
- Receive push notifications about repair status updates.
- Update current mileage (KM) to help track service needs.
- Schedule service appointments.
- View estimated time until next service based on mileage tracking.

### User Experience
- Multilingual support (Arabic, French, and Tunisian dialect).
- Premium, clean interface inspired by luxury automotive brands.
- Brand-specific sections for BMW, Mercedes, and VW AG vehicles.

## 3. Admin Interface (Web Platform)

### Customer Management
- Add, edit, and remove customer accounts.
- Search and filter customer database.
- Import customer lists from CSV/Excel files.
- View complete customer history and vehicle details.

### Repair Management
- Input and update repair details (description, parts, labor, costs).
- Assign mechanics to specific repairs.
- Track repair status and update customers automatically.
- Schedule future services and maintenance.

### Invoice Management
- Upload invoice PDFs with service details.
- Track payment status and send reminders.
- Generate reports on outstanding payments.

### Analytics & Reporting
- Monthly revenue reports.
- Most common repairs by vehicle brand/model.
- Customer statistics and retention metrics.
- Service history trends and seasonal patterns.
- Parts usage and inventory forecasting.

## 4. Data Structure

### Customers
- ID
- Name
- Contact Information
- Authentication Credentials
- Communication Preferences

### Vehicles
- ID
- Customer ID
- Brand
- Model
- Year
- License Plate
- VIN (Vehicle Identification Number)
- Current Mileage
- Average Daily Usage
- Service History
- Next Service Due Date/Mileage

### Repairs
- ID
- Vehicle ID
- Description
- Start Date
- Completion Date
- Parts Used
- Labor Hours
- Mechanic Assigned
- Cost
- Status
- Next Service Estimate

### Invoices
- ID
- Repair ID
- Total Amount
- Payment Status
- PDF Document
- VAT Amount (19%)
- Payment Method

## 5. Tunisian Market Specific Requirements

### Language & Regional Support
- Support for Arabic, French, and Tunisian dialect (Derja)
- Personalized communication style for local preferences
- Ramadan and local holiday scheduling adjustments

### Financial & Legal Compliance
- Tunisian VAT (TVA) at 19% on invoices
- Support for "Facturation Normalisée" format
- Cash payment tracking
- Installment payment options for larger repairs

### Vehicle & Service Customization
- Pre-populated database of common Tunisian vehicles
- Separate pricing for local and imported parts
- D17 technical inspection form generation
- Integration with Tunisian insurance companies

### Cultural Considerations
- Family vehicle sharing support
- Mechanic reputation tracking
- Detailed service history for resale value
- Local towing service partnerships

## 6. Brand & Design Specifications

### Brand Identity
- Prominent "eCar" logo throughout the application
- Black primary color (#000000)
- Brand-specific accent colors:
  - BMW Blue (#0066B1)
  - Mercedes Silver (#9A9A9A)
  - VW Blue (#003399)

### Typography
- Sans-serif font family (Helvetica, Arial, or Open Sans)
- Font weights: Light (body), Medium (subtitles), Bold (headings)

### UI Elements
- Clean, minimalist interface
- Precise spacing and alignment
- Subtle shadows for depth
- Rounded corners for buttons and cards
- Brand-specific design treatments

## 7. Technology Requirements

### Frontend
- Flutter for cross-platform development (iOS, Android, Web)
- State management with Provider or Bloc
- Responsive design for all screen sizes
- Offline capability for mobile app

### Backend
- Ruby on Rails API
- PostgreSQL database
- JWT authentication
- Background job processing with Sidekiq
- Redis for caching

### Infrastructure
- VPS hosting (4 vCPUs, 8GB RAM, 160GB SSD)
- Automated database backups
- Cloudinary or AWS S3 for file storage
- Firebase Cloud Messaging for push notifications
- Sentry for error tracking

## 8. Future Enhancements (Phase 2)
- Online payment integration
- QR code scanning for quick vehicle identification
- Integration with OBD-II diagnostic tools
- Predictive maintenance recommendations
- Customer loyalty program 