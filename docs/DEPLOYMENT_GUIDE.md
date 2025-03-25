# eCar Garage Deployment Guide

This document provides step-by-step instructions for deploying the eCar Garage Management Application in production environments.

## System Requirements

### Backend Server (Rails API)
- Ubuntu 20.04 LTS or newer
- Ruby 3.2.0 or newer
- PostgreSQL 13.0 or newer
- Redis (for background jobs)
- Nginx (web server)
- Let's Encrypt (SSL certificates)

### Mobile App Deployment
- Google Play Console account
- Apple Developer account
- Flutter SDK 3.7.0 or newer

### Web Admin Deployment
- Nginx web server
- Domain name
- SSL certificate

## Backend Deployment

### Step 1: Server Setup

1. Provision a VPS with at least 2GB RAM and 2 vCPUs
2. Set up a non-root user with sudo privileges:

```bash
sudo adduser ecar
sudo usermod -aG sudo ecar
su - ecar
```

3. Update and install essential packages:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential libssl-dev libreadline-dev \
                   zlib1g-dev autoconf bison libyaml-dev \
                   libncurses5-dev libffi-dev libgdbm-dev \
                   nginx git curl gnupg2 postgresql postgresql-contrib redis-server
```

### Step 2: Install Ruby using RVM

```bash
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 3.2.0
rvm use 3.2.0 --default
```

### Step 3: Configure PostgreSQL

```bash
sudo -u postgres psql
```

In the PostgreSQL prompt:
```sql
CREATE USER ecar WITH PASSWORD 'StrongPassword123!';
CREATE DATABASE ecar_production OWNER ecar;
\q
```

### Step 4: Deploy Rails Application

1. Clone the repository:

```bash
cd ~
git clone https://github.com/phara0n/ecarv1.git
cd ecarv1/backend
```

2. Configure production environment variables:

```bash
nano .env.production
```

Add the following variables:
```
DATABASE_URL=postgres://ecar:StrongPassword123!@localhost/ecar_production
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
SECRET_KEY_BASE=[generated key]
JWT_SECRET=[secure random string]
REDIS_URL=redis://localhost:6379/1
```

Generate a secret key:
```bash
bundle exec rails secret
```

3. Install dependencies and setup the database:

```bash
bundle install --without development test
bundle exec rails db:create db:migrate db:seed RAILS_ENV=production
```

4. Precompile assets:

```bash
bundle exec rails assets:precompile
```

5. Setup Puma service:

Create a systemd service file:
```bash
sudo nano /etc/systemd/system/ecar-backend.service
```

Add the following content:
```
[Unit]
Description=eCar Garage Backend API
After=network.target postgresql.service redis-server.service

[Service]
Type=simple
User=ecar
WorkingDirectory=/home/ecar/ecarv1/backend
Environment=RAILS_ENV=production
Environment=PATH=/home/ecar/.rvm/gems/ruby-3.2.0/bin:/home/ecar/.rvm/gems/ruby-3.2.0@global/bin:/home/ecar/.rvm/rubies/ruby-3.2.0/bin:/home/ecar/.rvm/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/home/ecar/.rvm/gems/ruby-3.2.0/bin/bundle exec puma -C config/puma.rb
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Start the service:
```bash
sudo systemctl enable ecar-backend.service
sudo systemctl start ecar-backend.service
```

### Step 5: Configure Nginx for the Backend API

Create a new Nginx configuration:
```bash
sudo nano /etc/nginx/sites-available/ecar-backend
```

Add the following configuration:
```nginx
upstream puma {
  server unix:///home/ecar/ecarv1/backend/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name api.ecar.tn;

  location / {
    proxy_pass http://puma;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Port $server_port;
    proxy_redirect off;
  }

  location ~* ^/assets/ {
    expires 1y;
    add_header Cache-Control public;
    add_header ETag "";
    break;
  }

  client_max_body_size 20M;
  keepalive_timeout 70;
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/ecar-backend /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

### Step 6: Set Up SSL with Let's Encrypt

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.ecar.tn
```

### Step 7: Set Up Background Jobs with Sidekiq

Create a systemd service file:
```bash
sudo nano /etc/systemd/system/ecar-sidekiq.service
```

Add the following content:
```
[Unit]
Description=eCar Garage Sidekiq
After=network.target redis-server.service postgresql.service

[Service]
Type=simple
User=ecar
WorkingDirectory=/home/ecar/ecarv1/backend
Environment=RAILS_ENV=production
Environment=PATH=/home/ecar/.rvm/gems/ruby-3.2.0/bin:/home/ecar/.rvm/gems/ruby-3.2.0@global/bin:/home/ecar/.rvm/rubies/ruby-3.2.0/bin:/home/ecar/.rvm/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/home/ecar/.rvm/gems/ruby-3.2.0/bin/bundle exec sidekiq
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Start the service:
```bash
sudo systemctl enable ecar-sidekiq.service
sudo systemctl start ecar-sidekiq.service
```

## Web Admin Interface Deployment

### Step 1: Build the Flutter Web Application

On your development machine:
```bash
cd ~/ecarv1/frontend/web
flutter build web --release
```

### Step 2: Set Up Nginx for Web Admin

On your server:
```bash
sudo mkdir -p /var/www/ecar-admin
sudo chown -R ecar:ecar /var/www/ecar-admin
```

Transfer the build files to your server:
```bash
scp -r build/web/* ecar@your-server-ip:/var/www/ecar-admin/
```

Create a new Nginx configuration:
```bash
sudo nano /etc/nginx/sites-available/ecar-admin
```

Add the following configuration:
```nginx
server {
  listen 80;
  server_name admin.ecar.tn;
  root /var/www/ecar-admin;
  index index.html;

  location / {
    try_files $uri $uri/ /index.html;
  }

  location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    expires 1y;
    add_header Cache-Control "public, max-age=31536000";
  }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/ecar-admin /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

### Step 3: Set Up SSL for Web Admin

```bash
sudo certbot --nginx -d admin.ecar.tn
```

## Mobile App Deployment

### Android Deployment

1. Prepare the app for release:

   ```bash
   cd ~/ecarv1/frontend/mobile
   flutter clean
   flutter build apk --release
   ```

2. Generate a signing key if you don't have one:

   ```bash
   keytool -genkey -v -keystore ~/ecar-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ecar
   ```

3. Configure signing in `android/app/build.gradle`:

   ```gradle
   android {
       // ...
       signingConfigs {
           release {
               keyAlias 'ecar'
               keyPassword 'your-key-password'
               storeFile file('path/to/ecar-key.jks')
               storePassword 'your-store-password'
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

4. Build the signed APK:

   ```bash
   flutter build apk --release
   ```

5. The signed APK will be at `build/app/outputs/flutter-apk/app-release.apk`

6. Create an account on the Google Play Console and follow the instructions to upload your APK.

### iOS Deployment

1. Prepare the app for release:

   ```bash
   cd ~/ecarv1/frontend/mobile
   flutter clean
   flutter build ios --release
   ```

2. Open the iOS project in Xcode:

   ```bash
   open ios/Runner.xcworkspace
   ```

3. In Xcode:
   - Sign in with your Apple Developer account
   - Configure the bundle identifier
   - Set up code signing with your provisioning profile
   - Configure app capabilities

4. Archive the app in Xcode:
   - Select `Product > Archive` from the menu
   - Once the archive is complete, click `Distribute App`
   - Follow the on-screen instructions to upload to the App Store

5. Log in to App Store Connect to complete the submission process.

## Monitoring and Maintenance

### Setting Up Monitoring

1. Install monitoring tools:

```bash
sudo apt install -y prometheus node-exporter
```

2. Configure Prometheus:

```bash
sudo nano /etc/prometheus/prometheus.yml
```

3. Add monitoring targets:

```yaml
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
  
  - job_name: 'rails'
    static_configs:
      - targets: ['localhost:3000']
```

4. Restart Prometheus:

```bash
sudo systemctl restart prometheus
```

### Backup Strategy

1. Set up automatic PostgreSQL backups:

```bash
sudo nano /etc/cron.daily/pg_backup
```

Add the following script:
```bash
#!/bin/bash
BACKUP_DIR="/home/ecar/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_NAME="ecar_production"
DB_USER="ecar"

mkdir -p $BACKUP_DIR
pg_dump -U $DB_USER $DB_NAME | gzip > $BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql.gz

# Keep only last 7 days of backups
find $BACKUP_DIR -type f -name "$DB_NAME-*.sql.gz" -mtime +7 -delete
```

Make the script executable:
```bash
sudo chmod +x /etc/cron.daily/pg_backup
```

2. Set up file system backups:

```bash
sudo apt install -y restic

# Configure restic (adjust repository path as needed)
restic init --repo /home/ecar/restic-repo

# Add to crontab
echo "0 2 * * * restic -r /home/ecar/restic-repo backup /home/ecar/ecarv1 --exclude=*.log --exclude=tmp" | sudo tee -a /etc/cron.d/ecar-backup
```

### Maintenance Tasks

Set up a maintenance script:

```bash
sudo nano /etc/cron.weekly/ecar-maintenance
```

Add the following:
```bash
#!/bin/bash
cd /home/ecar/ecarv1/backend
RAILS_ENV=production bundle exec rails log:clear
RAILS_ENV=production bundle exec rails tmp:clear
RAILS_ENV=production bundle exec rails db:sessions:trim

# Update SSL certificates
certbot renew

# Restart services
systemctl restart ecar-backend.service
systemctl restart ecar-sidekiq.service
systemctl restart nginx
```

Make the script executable:
```bash
sudo chmod +x /etc/cron.weekly/ecar-maintenance
```

## Scaling Considerations

As the application grows, consider these scaling options:

1. **Database Scaling**:
   - Set up PostgreSQL replication with a read replica
   - Consider database partitioning for large tables

2. **Application Scaling**:
   - Deploy multiple backend instances behind a load balancer
   - Configure Puma for multi-threading and multi-process modes

3. **Caching Layer**:
   - Implement Redis caching for frequently accessed data
   - Set up CDN for static assets

## Troubleshooting

### Common Issues and Solutions

1. **Application Not Starting**:
   - Check logs: `journalctl -u ecar-backend.service`
   - Verify environment variables
   - Ensure database is running: `sudo systemctl status postgresql`

2. **Database Connection Issues**:
   - Check PostgreSQL logs: `sudo tail -f /var/log/postgresql/postgresql-13-main.log`
   - Verify connection settings in `.env.production`
   - Ensure the database is running: `sudo systemctl status postgresql`

3. **Nginx Issues**:
   - Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`
   - Test configuration: `sudo nginx -t`
   - Restart Nginx: `sudo systemctl restart nginx`

4. **SSL Certificate Issues**:
   - Renew certificates: `sudo certbot renew`
   - Check certificate status: `sudo certbot certificates`

## Appendix

### Environment Variables Reference

Backend (`.env.production`):
```
DATABASE_URL=postgres://ecar:StrongPassword123!@localhost/ecar_production
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
SECRET_KEY_BASE=[generated key]
JWT_SECRET=[secure random string]
REDIS_URL=redis://localhost:6379/1
SMTP_USERNAME=your-email@example.com
SMTP_PASSWORD=your-email-password
SMTP_DOMAIN=ecar.tn
SMTP_ADDRESS=smtp.example.com
SMTP_PORT=587
```

Flutter Web (`.env.production`):
```
API_URL=https://api.ecar.tn/api/v1
```

Flutter Mobile (`.env.production`):
```
API_URL=https://api.ecar.tn/api/v1
```

### Important File Locations

- Backend logs: `/home/ecar/ecarv1/backend/log/production.log`
- Nginx access logs: `/var/log/nginx/access.log`
- Nginx error logs: `/var/log/nginx/error.log`
- Systemd logs: `journalctl -u ecar-backend.service`
- Database backups: `/home/ecar/backups/` 