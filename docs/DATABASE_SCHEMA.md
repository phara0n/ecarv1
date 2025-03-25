# eCar Garage Database Schema

This document describes the database schema for the eCar Garage Management Application, including tables, relationships, and key constraints.

## Database Overview

The application uses PostgreSQL as its primary database. The schema is designed to support the core business processes of a garage including customer management, vehicle tracking, repair services, invoicing, and inventory management.

## Entity Relationship Diagram

```
                       ┌───────────────┐
                       │    Users      │
                       └───────┬───────┘
                               │
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
  ┌────────▼─────────┐ ┌───────▼────────┐ ┌────────▼─────────┐
  │    Customers     │ │     Staff      │ │   Technicians    │
  └────────┬─────────┘ └────────────────┘ └────────┬─────────┘
           │                                       │
           │                                       │
  ┌────────▼─────────┐                   ┌─────────▼────────┐
  │     Vehicles     │◄─────────────────►│     Repairs      │
  └────────┬─────────┘                   └─────────┬────────┘
           │                                       │
           │                                       │
           │                                       │
           │                             ┌─────────▼────────┐
           └────────────────────────────►│     Invoices     │
                                         └─────────┬────────┘
                                                   │
                                                   │
                                         ┌─────────▼────────┐
                                         │  InvoiceItems    │
                                         └──────────────────┘
                                                   ▲
                                                   │
                                         ┌─────────┴────────┐
                                         │  InventoryItems  │
                                         └──────────────────┘
```

## Table Definitions

### Users

Base table for all user types in the system.

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_digest VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL, -- 'customer', 'admin', 'technician', 'receptionist'
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

### Customers

Extends the Users table with customer-specific information.

```sql
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    national_id VARCHAR(50), -- Encrypted in application layer
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customers_user_id ON customers(user_id);
CREATE INDEX idx_customers_names ON customers(last_name, first_name);
```

### Staff

Extends the Users table with staff-specific information.

```sql
CREATE TABLE staff (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    hire_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_staff_user_id ON staff(user_id);
CREATE INDEX idx_staff_position ON staff(position);
```

### Technicians

Extends the Staff table with technician-specific information.

```sql
CREATE TABLE technicians (
    id SERIAL PRIMARY KEY,
    staff_id INTEGER NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    specialization VARCHAR(100) NOT NULL,
    certification_level VARCHAR(50),
    available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_technicians_staff_id ON technicians(staff_id);
CREATE INDEX idx_technicians_specialization ON technicians(specialization);
```

### Vehicles

Stores information about customer vehicles.

```sql
CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    vin VARCHAR(17) UNIQUE, -- Encrypted in application layer
    color VARCHAR(50),
    current_mileage INTEGER NOT NULL,
    last_service_date DATE,
    next_service_due_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vehicles_customer_id ON vehicles(customer_id);
CREATE INDEX idx_vehicles_brand_model ON vehicles(brand, model);
CREATE INDEX idx_vehicles_license_plate ON vehicles(license_plate);
```

### Repairs

Records of repair services performed on vehicles.

```sql
CREATE TABLE repairs (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    technician_id INTEGER REFERENCES technicians(id),
    description TEXT NOT NULL,
    diagnosis TEXT,
    start_date DATE NOT NULL,
    completion_date DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'in progress', 'completed', 'cancelled'
    mileage_at_repair INTEGER NOT NULL,
    estimated_hours DECIMAL(5,2),
    actual_hours DECIMAL(5,2),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_repairs_vehicle_id ON repairs(vehicle_id);
CREATE INDEX idx_repairs_technician_id ON repairs(technician_id);
CREATE INDEX idx_repairs_status ON repairs(status);
CREATE INDEX idx_repairs_dates ON repairs(start_date, completion_date);
```

### Invoices

Financial records for completed repairs.

```sql
CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    repair_id INTEGER NOT NULL REFERENCES repairs(id) ON DELETE RESTRICT,
    amount DECIMAL(10,2) NOT NULL,
    tax_rate DECIMAL(5,2) NOT NULL DEFAULT 19.0, -- Tunisian VAT rate
    total_amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'paid', 'overdue'
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    payment_date DATE,
    payment_method VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invoices_repair_id ON invoices(repair_id);
CREATE INDEX idx_invoices_payment_status ON invoices(payment_status);
CREATE INDEX idx_invoices_dates ON invoices(issue_date, due_date, payment_date);
```

### InvoiceItems

Detailed line items for invoices.

```sql
CREATE TABLE invoice_items (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    inventory_item_id INTEGER REFERENCES inventory_items(id),
    description VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    is_labor BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invoice_items_invoice_id ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_items_inventory_item_id ON invoice_items(inventory_item_id);
```

### InventoryItems

Parts and supplies used for repairs.

```sql
CREATE TABLE inventory_items (
    id SERIAL PRIMARY KEY,
    part_number VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    quantity_in_stock INTEGER NOT NULL DEFAULT 0,
    reorder_level INTEGER NOT NULL DEFAULT 5,
    supplier VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_items_part_number ON inventory_items(part_number);
CREATE INDEX idx_inventory_items_category ON inventory_items(category);
```

### RepairParts

Tracks parts used in each repair.

```sql
CREATE TABLE repair_parts (
    id SERIAL PRIMARY KEY,
    repair_id INTEGER NOT NULL REFERENCES repairs(id) ON DELETE CASCADE,
    inventory_item_id INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_repair_parts_repair_id ON repair_parts(repair_id);
CREATE INDEX idx_repair_parts_inventory_item_id ON repair_parts(inventory_item_id);
```

### Appointments

Scheduling system for future repairs.

```sql
CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    service_type VARCHAR(100) NOT NULL,
    preferred_date DATE NOT NULL,
    preferred_time TIME NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'scheduled', -- 'scheduled', 'confirmed', 'completed', 'cancelled'
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_appointments_customer_id ON appointments(customer_id);
CREATE INDEX idx_appointments_vehicle_id ON appointments(vehicle_id);
CREATE INDEX idx_appointments_date_time ON appointments(preferred_date, preferred_time);
CREATE INDEX idx_appointments_status ON appointments(status);
```

### MaintenanceSchedules

Predefined maintenance schedules for different vehicle models.

```sql
CREATE TABLE maintenance_schedules (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year_start INTEGER NOT NULL,
    year_end INTEGER NOT NULL,
    service_interval_months INTEGER NOT NULL,
    service_interval_km INTEGER NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_maintenance_schedules_brand_model ON maintenance_schedules(brand, model);
CREATE INDEX idx_maintenance_schedules_year_range ON maintenance_schedules(year_start, year_end);
```

### Notifications

System for sending alerts to users.

```sql
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'appointment', 'service_due', 'invoice', 'general'
    read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(read);
CREATE INDEX idx_notifications_type ON notifications(type);
```

## Database Views

### VehicleDueForService

A view that shows vehicles due for service.

```sql
CREATE VIEW vehicle_due_for_service AS
SELECT 
    v.id, 
    v.license_plate, 
    v.brand, 
    v.model, 
    v.year,
    c.id AS customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    v.last_service_date,
    v.next_service_due_date,
    v.current_mileage,
    CASE 
        WHEN v.next_service_due_date <= CURRENT_DATE THEN 'overdue'
        WHEN v.next_service_due_date <= (CURRENT_DATE + INTERVAL '30 days') THEN 'upcoming'
        ELSE 'future'
    END AS service_status
FROM 
    vehicles v
JOIN 
    customers c ON v.customer_id = c.id
WHERE 
    v.next_service_due_date IS NOT NULL;
```

### RevenueByMonth

A view that shows monthly revenue.

```sql
CREATE VIEW revenue_by_month AS
SELECT 
    DATE_TRUNC('month', i.payment_date) AS month,
    SUM(i.total_amount) AS total_revenue,
    COUNT(i.id) AS invoice_count,
    AVG(i.total_amount) AS average_invoice_amount
FROM 
    invoices i
WHERE 
    i.payment_status = 'paid'
GROUP BY 
    DATE_TRUNC('month', i.payment_date)
ORDER BY 
    month DESC;
```

### TechnicianPerformance

A view that shows technician performance metrics.

```sql
CREATE VIEW technician_performance AS
SELECT 
    t.id AS technician_id,
    s.first_name || ' ' || s.last_name AS technician_name,
    COUNT(r.id) AS total_repairs,
    AVG(r.actual_hours) AS avg_repair_time,
    SUM(i.total_amount) AS total_revenue_generated,
    COUNT(CASE WHEN r.status = 'completed' THEN 1 END) AS completed_repairs,
    COUNT(CASE WHEN r.status = 'in progress' THEN 1 END) AS in_progress_repairs
FROM 
    technicians t
JOIN 
    staff s ON t.staff_id = s.id
LEFT JOIN 
    repairs r ON r.technician_id = t.id
LEFT JOIN 
    invoices i ON i.repair_id = r.id
GROUP BY 
    t.id, s.first_name, s.last_name;
```

## Indexes and Performance Considerations

1. **Compound Indexes**: Created for frequently joined columns
2. **Foreign Key Indexes**: All foreign key columns are indexed
3. **Search Optimization**: Indexes on frequently queried columns
4. **Date Range Queries**: Special indexes for date range queries

## Data Backups and Recovery

1. **Daily Backups**: Full database backup every 24 hours
2. **Point-in-Time Recovery**: WAL archiving enabled
3. **Backup Retention**: 30 days of backups retained
4. **Encrypted Backups**: All backup files are encrypted

## Database Migration Strategy

Database migrations are handled through Rails Active Record migrations, ensuring:

1. **Version Control**: All schema changes tracked in Git
2. **Repeatable Deployments**: Consistent schema updates across environments
3. **Rollback Capability**: Migrations can be reversed if needed
4. **Data Integrity**: Constraints enforced during migrations

## Schema Evolution

As the application evolves, the following principles guide schema changes:

1. **Backward Compatibility**: Schema changes must not break existing functionality
2. **Data Migration**: Plans for migrating existing data with schema changes
3. **Performance Testing**: Testing impact of schema changes on query performance
4. **Documentation**: All schema changes documented in changelog 