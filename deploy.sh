#!/bin/bash
# eCar Garage Management Application Deployment Script
# This script automates the deployment of the complete application

# Exit on error
set -e

# Print commands before execution
set -x

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting eCar Garage deployment...${NC}"

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script with sudo privileges${NC}"
  exit 1
fi

# Create directories if they don't exist
mkdir -p /var/www/ecar-admin
mkdir -p /var/www/ecar-api
mkdir -p /home/ecar/backups

# Make sure necessary tools are installed
echo -e "${YELLOW}Installing necessary packages...${NC}"
apt update
apt install -y nginx postgresql postgresql-contrib redis-server curl gnupg2 build-essential libssl-dev \
               libreadline-dev zlib1g-dev autoconf bison libyaml-dev libncurses5-dev libffi-dev \
               libgdbm-dev certbot python3-certbot-nginx git

# Setup PostgreSQL
echo -e "${YELLOW}Setting up PostgreSQL...${NC}"
if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='ecar'" | grep -q 1; then
  sudo -u postgres psql -c "CREATE USER ecar WITH PASSWORD 'StrongPassword123!';"
fi

if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw ecar_production; then
  sudo -u postgres psql -c "CREATE DATABASE ecar_production OWNER ecar;"
fi

# Install RVM and Ruby if not already installed
echo -e "${YELLOW}Setting up Ruby...${NC}"
if ! command -v rvm &> /dev/null; then
  gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable
  source /etc/profile.d/rvm.sh
  rvm install 3.2.0
  rvm use 3.2.0 --default
fi

# Install Flutter if not already installed
echo -e "${YELLOW}Setting up Flutter...${NC}"
if ! command -v flutter &> /dev/null; then
  cd /tmp
  wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.7.0-stable.tar.xz
  tar xf flutter_linux_3.7.0-stable.tar.xz
  mv flutter /opt/
  echo 'export PATH="$PATH:/opt/flutter/bin"' >> /etc/profile.d/flutter.sh
  source /etc/profile.d/flutter.sh
  flutter doctor
fi

# Setup the Backend API
echo -e "${YELLOW}Deploying backend API...${NC}"
cd /home/ecar/ecar-garage-app/backend

# Generate Rails secret key if it doesn't exist
if [ ! -f .env.production ]; then
  SECRET_KEY=$(openssl rand -hex 64)
  JWT_SECRET=$(openssl rand -hex 32)
  
  cat > .env.production << EOF
DATABASE_URL=postgres://ecar:StrongPassword123!@localhost/ecar_production
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
SECRET_KEY_BASE=${SECRET_KEY}
JWT_SECRET=${JWT_SECRET}
REDIS_URL=redis://localhost:6379/1
EOF
fi

# Install dependencies and setup database
gem install bundler
bundle install --without development test
bundle exec rails db:migrate RAILS_ENV=production
bundle exec rails db:seed RAILS_ENV=production
bundle exec rails assets:precompile RAILS_ENV=production

# Configure Puma service
cat > /etc/systemd/system/ecar-backend.service << EOF
[Unit]
Description=eCar Garage Backend API
After=network.target postgresql.service redis-server.service

[Service]
Type=simple
User=ecar
WorkingDirectory=/home/ecar/ecar-garage-app/backend
Environment=RAILS_ENV=production
Environment=PATH=/home/ecar/.rvm/gems/ruby-3.2.0/bin:/home/ecar/.rvm/gems/ruby-3.2.0@global/bin:/home/ecar/.rvm/rubies/ruby-3.2.0/bin:/home/ecar/.rvm/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/home/ecar/.rvm/gems/ruby-3.2.0/bin/bundle exec puma -C config/puma.rb
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Configure Sidekiq service
cat > /etc/systemd/system/ecar-sidekiq.service << EOF
[Unit]
Description=eCar Garage Sidekiq
After=network.target redis-server.service postgresql.service

[Service]
Type=simple
User=ecar
WorkingDirectory=/home/ecar/ecar-garage-app/backend
Environment=RAILS_ENV=production
Environment=PATH=/home/ecar/.rvm/gems/ruby-3.2.0/bin:/home/ecar/.rvm/gems/ruby-3.2.0@global/bin:/home/ecar/.rvm/rubies/ruby-3.2.0/bin:/home/ecar/.rvm/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/home/ecar/.rvm/gems/ruby-3.2.0/bin/bundle exec sidekiq
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Start services
systemctl daemon-reload
systemctl enable ecar-backend.service ecar-sidekiq.service
systemctl start ecar-backend.service ecar-sidekiq.service

# Configure Nginx for backend API
cat > /etc/nginx/sites-available/ecar-backend << EOF
upstream puma {
  server unix:///home/ecar/ecar-garage-app/backend/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name api.ecar.tn;

  location / {
    proxy_pass http://puma;
    proxy_set_header Host \$host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-Port \$server_port;
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
EOF

# Build Flutter Web App
echo -e "${YELLOW}Building and deploying web admin interface...${NC}"
cd /home/ecar/ecar-garage-app/frontend/web
flutter build web --release
cp -r build/web/* /var/www/ecar-admin/

# Configure Nginx for admin web interface
cat > /etc/nginx/sites-available/ecar-admin << EOF
server {
  listen 80;
  server_name admin.ecar.tn;
  root /var/www/ecar-admin;
  index index.html;

  location / {
    try_files \$uri \$uri/ /index.html;
  }

  location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    expires 1y;
    add_header Cache-Control "public, max-age=31536000";
  }
}
EOF

# Enable the Nginx sites
ln -sf /etc/nginx/sites-available/ecar-backend /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/ecar-admin /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

# Setup SSL with Let's Encrypt
echo -e "${YELLOW}Setting up SSL certificates...${NC}"
certbot --nginx -d api.ecar.tn -d admin.ecar.tn --non-interactive --agree-tos --email admin@ecar.tn

# Setup backups
echo -e "${YELLOW}Setting up automated backups...${NC}"
cat > /etc/cron.daily/pg_backup << EOF
#!/bin/bash
BACKUP_DIR="/home/ecar/backups"
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
DB_NAME="ecar_production"
DB_USER="ecar"

mkdir -p \$BACKUP_DIR
pg_dump -U \$DB_USER \$DB_NAME | gzip > \$BACKUP_DIR/\$DB_NAME-\$TIMESTAMP.sql.gz

# Keep only last 30 days of backups
find \$BACKUP_DIR -type f -name "\$DB_NAME-*.sql.gz" -mtime +30 -delete
EOF

chmod +x /etc/cron.daily/pg_backup

# Setup maintenance script
cat > /etc/cron.weekly/ecar-maintenance << EOF
#!/bin/bash
cd /home/ecar/ecar-garage-app/backend
RAILS_ENV=production bundle exec rails log:clear
RAILS_ENV=production bundle exec rails tmp:clear
RAILS_ENV=production bundle exec rails db:sessions:trim

# Update SSL certificates
certbot renew

# Restart services
systemctl restart ecar-backend.service
systemctl restart ecar-sidekiq.service
systemctl restart nginx
EOF

chmod +x /etc/cron.weekly/ecar-maintenance

# Set proper ownership
chown -R ecar:ecar /var/www/ecar-admin
chown -R ecar:ecar /home/ecar/backups
chown -R ecar:ecar /home/ecar/ecar-garage-app

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}Backend API is now available at https://api.ecar.tn${NC}"
echo -e "${GREEN}Admin interface is now available at https://admin.ecar.tn${NC}"
echo -e "${YELLOW}Remember to update your DNS records to point to this server${NC}"
echo -e "${YELLOW}Make sure port 80 and 443 are open in your firewall${NC}" 