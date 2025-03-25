# eCar Garage Management API Documentation

This document provides comprehensive information about the eCar Garage Management API endpoints, request/response formats, and authentication methods.

## Base URL

```
http://localhost:3000/api/v1
```

In production, the base URL will be:
```
https://api.ecar.tn/api/v1
```

## Authentication

All API endpoints require JWT token authentication except for the login endpoint.

### Obtaining a JWT Token

**Endpoint:** `POST /login`

**Request Body:**
```json
{
  "email": "customer@example.com",
  "password": "your_password"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "exp": "2025-04-25T12:00:00Z"
}
```

### Using the JWT Token

Include the token in the Authorization header of all API requests:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

## API Endpoints

### Customers

#### Get Current Customer

**Endpoint:** `GET /customers/me`

**Response:**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john.doe@example.com",
  "phone": "+21612345678",
  "address": "123 Main St, Tunis"
}
```

### Vehicles

#### Get All Vehicles

**Endpoint:** `GET /vehicles`

**Response:**
```json
[
  {
    "id": 1,
    "customer_id": 1,
    "brand": "BMW",
    "model": "3 Series",
    "year": 2020,
    "license_plate": "123 TUN 4567",
    "vin": "WBA8E9C5XKB301928",
    "current_mileage": 25000,
    "average_daily_usage": 42.5,
    "next_service_due_date": "2025-06-15",
    "days_until_next_service": 45
  },
  {
    "id": 2,
    "customer_id": 1,
    "brand": "Mercedes-Benz",
    "model": "C-Class",
    "year": 2019,
    "license_plate": "456 TUN 7890",
    "vin": "WDDWF4KB2KR567890",
    "current_mileage": 35000,
    "average_daily_usage": 38.2,
    "next_service_due_date": "2025-05-10",
    "days_until_next_service": 15
  }
]
```

#### Get Vehicle by ID

**Endpoint:** `GET /vehicles/:id`

**Response:**
```json
{
  "id": 1,
  "customer_id": 1,
  "brand": "BMW",
  "model": "3 Series",
  "year": 2020,
  "license_plate": "123 TUN 4567",
  "vin": "WBA8E9C5XKB301928",
  "current_mileage": 25000,
  "average_daily_usage": 42.5,
  "next_service_due_date": "2025-06-15",
  "days_until_next_service": 45
}
```

#### Update Vehicle Mileage

**Endpoint:** `PATCH /vehicles/:id/update_mileage`

**Request Body:**
```json
{
  "current_mileage": 26500
}
```

**Response:**
```json
{
  "id": 1,
  "customer_id": 1,
  "brand": "BMW",
  "model": "3 Series",
  "year": 2020,
  "license_plate": "123 TUN 4567",
  "vin": "WBA8E9C5XKB301928",
  "current_mileage": 26500,
  "average_daily_usage": 42.5,
  "next_service_due_date": "2025-06-15",
  "days_until_next_service": 45
}
```

### Repairs

#### Get All Repairs

**Endpoint:** `GET /repairs`

**Response:**
```json
[
  {
    "id": 1,
    "vehicle_id": 1,
    "description": "Oil change and filter replacement",
    "date": "2025-01-15",
    "cost": 150.00,
    "status": "completed",
    "notes": "Used synthetic oil",
    "next_service_due_date": "2025-06-15",
    "next_service_description": "Full maintenance service"
  },
  {
    "id": 2,
    "vehicle_id": 1,
    "description": "Brake pad replacement",
    "date": "2025-03-10",
    "cost": 350.00,
    "status": "in progress",
    "notes": "Front and rear brake pads",
    "next_service_due_date": null,
    "next_service_description": null
  }
]
```

#### Get Repairs for a Vehicle

**Endpoint:** `GET /vehicles/:vehicle_id/repairs`

**Response:**
```json
[
  {
    "id": 1,
    "vehicle_id": 1,
    "description": "Oil change and filter replacement",
    "date": "2025-01-15",
    "cost": 150.00,
    "status": "completed",
    "notes": "Used synthetic oil",
    "next_service_due_date": "2025-06-15",
    "next_service_description": "Full maintenance service"
  },
  {
    "id": 2,
    "vehicle_id": 1,
    "description": "Brake pad replacement",
    "date": "2025-03-10",
    "cost": 350.00,
    "status": "in progress",
    "notes": "Front and rear brake pads",
    "next_service_due_date": null,
    "next_service_description": null
  }
]
```

#### Get Repair by ID

**Endpoint:** `GET /repairs/:id`

**Response:**
```json
{
  "id": 1,
  "vehicle_id": 1,
  "description": "Oil change and filter replacement",
  "date": "2025-01-15",
  "cost": 150.00,
  "status": "completed",
  "notes": "Used synthetic oil",
  "next_service_due_date": "2025-06-15",
  "next_service_description": "Full maintenance service"
}
```

### Invoices

#### Get All Invoices

**Endpoint:** `GET /invoices`

**Response:**
```json
[
  {
    "id": 1,
    "repair_id": 1,
    "amount": 178.50,
    "payment_status": "paid",
    "date": "2025-01-15",
    "due_date": "2025-01-30",
    "payment_date": "2025-01-20",
    "pdf_document": "https://storage.ecar.tn/invoices/invoice_1.pdf"
  },
  {
    "id": 2,
    "repair_id": 2,
    "amount": 416.50,
    "payment_status": "pending",
    "date": "2025-03-10",
    "due_date": "2025-03-25",
    "payment_date": null,
    "pdf_document": "https://storage.ecar.tn/invoices/invoice_2.pdf"
  }
]
```

#### Get Invoice by ID

**Endpoint:** `GET /invoices/:id`

**Response:**
```json
{
  "id": 1,
  "repair_id": 1,
  "amount": 178.50,
  "payment_status": "paid",
  "date": "2025-01-15",
  "due_date": "2025-01-30",
  "payment_date": "2025-01-20",
  "pdf_document": "https://storage.ecar.tn/invoices/invoice_1.pdf"
}
```

#### Download Invoice PDF

**Endpoint:** `GET /invoices/:id/download`

**Response:**
Binary PDF file with Content-Type: application/pdf

## Error Handling

The API follows standard HTTP status codes for error responses:

- **400 Bad Request**: Invalid request format or parameters
- **401 Unauthorized**: Authentication required or invalid credentials
- **403 Forbidden**: Authenticated user does not have permission
- **404 Not Found**: Requested resource not found
- **422 Unprocessable Entity**: Request validation failed
- **500 Internal Server Error**: Server-side error

Error responses have the following format:

```json
{
  "error": "Descriptive error message",
  "details": ["Optional array of specific error details"]
}
```

## Rate Limiting

API requests are rate-limited to prevent abuse. Current limits:

- **Authenticated endpoints**: 100 requests per minute
- **Login endpoint**: 10 requests per minute

When rate limits are exceeded, the API returns a 429 Too Many Requests status code.

## Pagination

List endpoints support pagination using the following query parameters:

- `page`: Page number (default: 1)
- `per_page`: Number of items per page (default: 20, max: 100)

Example: `GET /vehicles?page=2&per_page=50`

Paginated responses include metadata:

```json
{
  "data": [...],
  "meta": {
    "current_page": 2,
    "total_pages": 5,
    "total_count": 120,
    "per_page": 50
  }
}
``` 