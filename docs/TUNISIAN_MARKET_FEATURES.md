# Tunisian Market-Specific Features

This document outlines the features and customizations specific to the Tunisian market in the eCar Garage Management Application.

## Language & Regional Support

### Multilingual Support
- **Arabic**: Primary language with full RTL (Right-to-Left) support
- **French**: Secondary language widely used in Tunisian business contexts
- **Tunisian Dialect (Derja)**: Local dialect implementation for improved user experience and customer engagement

### Tunisian Cultural Calendar
- **Ramadan Adjustments**: 
  - Automatic scheduling adjustments during Ramadan
  - Modified working hours notification
  - Special maintenance packages for pre-Ramadan period
  
- **National Holidays**: 
  - Integration of Tunisian national holidays in the schedule
  - Automatic notification for garage closure days
  - Reminder system adjusted around holiday periods

## Financial & Legal Compliance

### Tunisian Tax System
- **TVA (VAT) Implementation**: 
  - Automatic calculation of 19% VAT on all invoices
  - Clear separation of pre-tax and tax amounts
  - Tax exemption handling for eligible business customers

### Facturation Normalisée
- **Compliance with Tunisian tax requirements**:
  - Sequential invoice numbering system
  - Required fields according to Tunisian fiscal law
  - QR code generation for digital verification

### Payment Methods
- **Cash Payment Tracking**:
  - Receipts for cash payments (common in Tunisia)
  - Cash payment reports for accounting purposes
  
- **Installment Payment Support**:
  - Tunisian-style installment plan creation
  - Payment schedule tracking
  - Notification system for upcoming installments

## Vehicle & Service Customization

### Tunisian Vehicle Market
- **Pre-populated Common Vehicles**:
  - European brands common in Tunisia:
    - Volkswagen (Golf, Passat, Polo)
    - Renault (Clio, Symbol, Mégane)
    - Peugeot (208, 301, 3008)
  - Asian brands popular in Tunisia:
    - Hyundai (i10, i20, Accent)
    - Kia (Picanto, Rio, Sportage)
    - Toyota (Yaris, Corolla, RAV4)

- **Vehicle Age and Type Distribution**:
  - Focus on vehicles 5-15 years old (common in Tunisian market)
  - Special handling for popular taxi models (Hyundai Accent, Kia Rio)
  - Support for commercial vehicles common in Tunisia

### Parts and Service Management
- **Imported vs. Local Parts Tracking**:
  - Differentiation between locally available and imported parts
  - Lead time indicators for imported parts
  - Alternative part suggestions for faster repairs

- **Technical Inspection Support**:
  - D17 technical inspection form generation
  - Pre-inspection checklist tailored to Tunisian standards
  - Reminder system for inspection renewal

### Insurance Integration
- **Tunisian Insurance Companies**:
  - Support for documentation for major Tunisian insurers:
    - STAR Assurances
    - COMAR
    - GAT Assurances
    - Lloyd Tunisien
  - Claim form generation for insurance purposes
  - Accident repair documentation formatted for insurance requirements

## Cultural Considerations

### Family Vehicle Usage
- **Multiple Users Per Vehicle**:
  - Support for family-shared vehicles (common in Tunisia)
  - Multiple contact options for a single vehicle
  - Permission management for family members

### Mechanic Reputation
- **Technician Profile and Ratings**:
  - Mechanic specialization tracking
  - Customer feedback system
  - Reputation metrics displayed to customers

### Digital Service History
- **Enhanced Documentation for Resale Value**:
  - Complete digital service history
  - Mileage verification system
  - Certification for well-maintained vehicles

### Local Partnerships
- **Towing Service Integration**:
  - Integration with local towing services
  - Coverage map for all regions of Tunisia
  - One-click towing request

## Business Operations

### Parts Procurement
- **Import Lead Time Tracking**:
  - Expected arrival tracking for imported parts
  - Notification system for parts availability
  - Alternative sourcing suggestions

### Multi-Currency Support
- **Currency Handling**:
  - Primary currency: Tunisian Dinar (TND)
  - Secondary tracking in EUR/USD for imported parts
  - Dynamic currency conversion based on Central Bank of Tunisia rates

### Seasonal Maintenance
- **Climate-Specific Service Packages**:
  - Pre-summer AC system check packages
  - Winter preparation service packages
  - Seasonal promotions automatically scheduled

## UI/UX Adaptations

### Regional Design Elements
- **Visual Elements**:
  - Color scheme aligned with Tunisian preferences
  - Interface patterns familiar to Tunisian users
  - Icons and symbols adapted to local context

### Terminology Adaptation
- **Automotive Terminology**:
  - Local terminology for vehicle parts
  - Repair descriptions in accessible language
  - Technical terms with Tunisian dialect alternatives

### Notification Style
- **Communication Preferences**:
  - SMS notifications (widely used in Tunisia)
  - WhatsApp integration (popular in Tunisia)
  - Appropriately timed notifications based on local customs

## Marketing & Customer Engagement

### Local Promotions
- **Tunisian Holiday Specials**:
  - Eid promotions
  - Back-to-school vehicle check offers
  - Summer vacation preparation packages

### Loyalty Program
- **Locally Customized Rewards**:
  - Point system with culturally appealing rewards
  - Family account benefits
  - Partnerships with local businesses

## Implementation Checklist

- [ ] Complete Arabic, French, and Tunisian dialect translations
- [ ] Implement Tunisian tax calculations
- [ ] Add Tunisian vehicle database
- [ ] Set up Tunisian holiday calendar
- [ ] Configure multi-currency support
- [ ] Implement Facturation Normalisée
- [ ] Create D17 form templates
- [ ] Add Tunisian insurance company integrations
- [ ] Set up installment payment tracking
- [ ] Implement WhatsApp notification integration 