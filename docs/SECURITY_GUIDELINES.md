# eCar Garage Security Guidelines

This document outlines security best practices and implementations for the eCar Garage Management Application to ensure data protection, user privacy, and system integrity.

## Authentication & Authorization

### JWT Token Implementation

The system uses JWT (JSON Web Tokens) for authentication with the following security measures:

1. **Short-lived tokens**: Access tokens expire after 2 hours
2. **Refresh token mechanism**: Secure token rotation strategy
3. **Secret key protection**: Using environment variables for JWT secrets
4. **Claims validation**: Validating issuer, audience, and expiration
5. **HMAC with SHA-256 (HS256) algorithm**: For token signing

Example backend implementation:

```ruby
# config/initializers/jwt.rb
require 'jwt'

module JwtAuth
  SECRET_KEY = ENV['JWT_SECRET'] || Rails.application.secrets.secret_key_base

  def self.encode(payload, exp = 2.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
    nil
  end
end
```

### Role-Based Access Control

The application implements a role-based access control system:

1. **Admin**: Full access to all system features
2. **Technician**: Access to vehicle repairs and service records
3. **Receptionist**: Customer management and appointment scheduling
4. **Customer**: Limited access to their own vehicles and service history

Permissions are enforced at the API level in the backend:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_request
  
  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JwtAuth.decode(token)
    
    if decoded
      @current_user = User.find(decoded[:user_id])
      @current_user_role = decoded[:role]
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
  
  def authorize_admin
    unless @current_user_role == 'admin'
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end
  
  # Other role-based authorization methods
end
```

## Data Protection

### Sensitive Data Encryption

1. **Database-level encryption**: 
   - Vehicle identification numbers (VINs)
   - Customer personal information
   - Payment details

2. **Implementation using Rails Active Record Encryption**:

```ruby
# app/models/customer.rb
class Customer < ApplicationRecord
  encrypts :phone_number, :address
  encrypts :national_id, deterministic: true
end

# app/models/vehicle.rb
class Vehicle < ApplicationRecord
  encrypts :vin, deterministic: true
end
```

### HTTPS Implementation

All communication between clients and the server is secured with HTTPS:

1. **TLS 1.3**: Using the latest secure protocol
2. **Strong cipher suites**: Implementing modern encryption standards
3. **HSTS (HTTP Strict Transport Security)**: Enforced via Nginx configuration

Nginx configuration example:

```nginx
server {
  listen 443 ssl http2;
  server_name api.ecar.tn;
  
  ssl_certificate /etc/letsencrypt/live/api.ecar.tn/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/api.ecar.tn/privkey.pem;
  
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305';
  
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
  
  # Other configuration...
}
```

### Secure Data Storage on Mobile Devices

For the Flutter mobile application, sensitive data is stored securely using:

1. **flutter_secure_storage**: For storing JWT tokens
2. **Encrypted Shared Preferences**: For user preferences

Implementation example:

```dart
// lib/services/auth_service.dart
class AuthService {
  final _storage = FlutterSecureStorage();
  
  Future<void> storeToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }
}
```

## API Security

### Input Validation & Sanitization

All user inputs are validated and sanitized:

1. **Strong parameter filtering** in Rails controllers
2. **Type validation** for all incoming data
3. **Data sanitization** to prevent XSS and injection attacks

Example in Rails controller:

```ruby
# app/controllers/vehicles_controller.rb
class VehiclesController < ApplicationController
  def create
    @vehicle = Vehicle.new(vehicle_params)
    
    if @vehicle.save
      render json: @vehicle, status: :created
    else
      render json: { errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def vehicle_params
    params.require(:vehicle).permit(:brand, :model, :year, :license_plate, :vin, :current_mileage)
  end
end
```

### Rate Limiting

API rate limiting protects against DoS attacks and API abuse:

1. **Request throttling**: 100 requests per minute for authenticated users
2. **IP-based rate limiting**: 30 requests per minute for unauthenticated requests
3. **Login attempt limiting**: 5 attempts per 15 minutes

Implementation using Rack::Attack:

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle login attempts
  throttle('login/ip', limit: 5, period: 15.minutes) do |req|
    req.ip if req.path == '/api/v1/login' && req.post?
  end
  
  # Throttle API requests
  throttle('api/ip', limit: 30, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/v1/')
  end
  
  # Throttle authenticated API requests by user ID
  throttle('api/user', limit: 100, period: 1.minute) do |req|
    if req.path.start_with?('/api/v1/') && req.env['current_user_id']
      req.env['current_user_id']
    end
  end
end
```

### CORS Configuration

Cross-Origin Resource Sharing is properly configured:

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'admin.ecar.tn', 'app.ecar.tn'
    resource '/api/v1/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

## Security Monitoring & Incident Response

### Logging Strategy

The application implements comprehensive security logging:

1. **Authentication events**: Login attempts, successes, and failures
2. **Authorization events**: Access attempts to restricted resources
3. **Data access logs**: Tracking who accessed sensitive data
4. **Admin actions**: Logging all administrative actions

Implementation example:

```ruby
# app/controllers/application_controller.rb
def log_authentication(status, user_id = nil, ip = request.remote_ip)
  SecurityLog.create(
    event_type: 'authentication',
    status: status,
    user_id: user_id,
    ip_address: ip,
    details: {
      user_agent: request.user_agent,
      path: request.path
    }
  )
end
```

### Vulnerability Scanning

Regular security assessments include:

1. **Dependency scanning**: Weekly checks for vulnerable dependencies
2. **Static code analysis**: Using tools like Brakeman for Rails
3. **Dynamic application scanning**: Monthly OWASP ZAP scans

### Incident Response Plan

In case of a security incident:

1. **Containment**: Immediate steps to isolate affected systems
2. **Investigation**: Forensic analysis to determine the cause and impact
3. **Remediation**: Implementing fixes and patches
4. **Notification**: Informing affected users as required by law
5. **Post-incident review**: Learning from the incident to improve security

## Mobile Application Security

### Certificate Pinning

The mobile app implements certificate pinning to prevent MITM attacks:

```dart
// lib/utils/http_client.dart
class SecureHttpClient extends IOClient {
  @override
  Future<IOStreamedResponse> send(BaseRequest request) async {
    var httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        final pinned = 'sha256/EXPECTED_CERTIFICATE_FINGERPRINT';
        final fingerprint = sha256.convert(cert.der).toString();
        return fingerprint == pinned;
      };
    
    // Rest of the implementation
  }
}
```

### App Security Features

1. **Jailbreak/root detection**: Preventing use on compromised devices
2. **Screenshot prevention**: For sensitive screens
3. **App inactivity timeout**: Automatic logout after 10 minutes
4. **Secure clipboard handling**: Preventing sensitive data in clipboard

## Database Security

### Database Access Controls

1. **Least privilege principle**: Database users have only necessary permissions
2. **Connection encryption**: SSL/TLS for all database connections
3. **Database firewall**: Restricting database access to application servers only

### Backup Encryption

All database backups are encrypted:

```bash
#!/bin/bash
BACKUP_DIR="/home/ecar/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_NAME="ecar_production"
DB_USER="ecar"

mkdir -p $BACKUP_DIR
pg_dump -U $DB_USER $DB_NAME | \
  gpg --encrypt --recipient backup@ecar.tn \
  > $BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql.gpg
```

## Security Updates & Patching

The following schedule is maintained for security updates:

1. **Critical vulnerabilities**: Patched within 24 hours
2. **High severity**: Patched within 1 week
3. **Medium severity**: Patched within 2 weeks
4. **Low severity**: Patched within 1 month

## Compliance Considerations

The application is designed to comply with:

1. **GDPR**: For handling European customer data
2. **Tunisian Data Protection Law**: Local legal compliance
3. **PCI DSS**: For handling payment information securely

## Security Checklist for Developers

- [ ] Use parameterized queries to prevent SQL injection
- [ ] Validate and sanitize all user inputs
- [ ] Implement proper error handling without leaking information
- [ ] Apply the principle of least privilege for all operations
- [ ] Use secure hashing functions (bcrypt) for passwords
- [ ] Keep all dependencies up to date
- [ ] Review code for security vulnerabilities
- [ ] Follow secure coding standards and guidelines
- [ ] Use HTTPS for all communications
- [ ] Implement proper session management

## Security Training

All team members receive regular security training:

1. **Secure coding practices**: For developers
2. **Social engineering awareness**: For all staff
3. **Data handling procedures**: For staff with access to customer data
4. **Incident response drills**: For IT and management

## Contact Information

For reporting security vulnerabilities:

- Email: security@ecar.tn
- Responsible disclosure policy: https://ecar.tn/security