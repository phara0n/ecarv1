#!/bin/bash
# eCar Garage Management Application Docker Deployment Script

# Exit on error
set -e

# Print commands before execution
set -x

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting eCar Garage Docker deployment...${NC}"

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script with sudo privileges${NC}"
  exit 1
fi

# Create necessary directories
echo -e "${YELLOW}Creating necessary directories...${NC}"
mkdir -p ./nginx/conf
mkdir -p ./nginx/ssl
mkdir -p ./nginx/logs
mkdir -p /var/www/certbot

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
    apt-get update
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Docker Compose not found. Installing Docker Compose...${NC}"
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Copy nginx configuration if it doesn't exist
if [ ! -f ./nginx/conf/default.conf ]; then
    echo -e "${YELLOW}Copying nginx configuration...${NC}"
    cp -f ./nginx/conf/default.conf ./nginx/conf/
fi

# Generate secrets if .env.docker doesn't have real secrets
if grep -q "your_generated_secret_key_replace_this_in_production" .env.docker; then
    echo -e "${YELLOW}Generating secure secrets...${NC}"
    SECRET_KEY=$(openssl rand -hex 64)
    JWT_SECRET=$(openssl rand -hex 32)
    
    # Replace placeholder secrets with real ones
    sed -i "s/your_generated_secret_key_replace_this_in_production/$SECRET_KEY/g" .env.docker
    sed -i "s/your_generated_jwt_secret_replace_this_in_production/$JWT_SECRET/g" .env.docker
fi

# Setup SSL certificates if not already present
echo -e "${YELLOW}Setting up SSL certificates...${NC}"
if [ ! -d "/etc/letsencrypt/live/api.ecar.tn" ] || [ ! -d "/etc/letsencrypt/live/admin.ecar.tn" ]; then
    echo -e "${YELLOW}SSL certificates not found. Running certbot to obtain certificates...${NC}"
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
    
    # Stop nginx if it's running to free up port 80
    systemctl stop nginx || true
    
    # Get SSL certificates
    certbot certonly --standalone -d api.ecar.tn -d admin.ecar.tn --non-interactive --agree-tos --email admin@ecar.tn
    
    # Create renewal hook to restart containers
    echo "#!/bin/bash
docker-compose -f /home/ecar/ecar-garage-app/docker-compose.yml restart nginx" > /etc/letsencrypt/renewal-hooks/post/restart-docker.sh
    chmod +x /etc/letsencrypt/renewal-hooks/post/restart-docker.sh
fi

# Set proper permissions
echo -e "${YELLOW}Setting proper permissions...${NC}"
chown -R 1000:1000 ./backend
chmod +x ./backend/bin/docker-entrypoint

# Build and start the containers
echo -e "${YELLOW}Building and starting Docker containers...${NC}"
docker-compose --env-file .env.docker build
docker-compose --env-file .env.docker up -d

# Setup database if this is first run
if [ ! -f ./.db_setup_done ]; then
    echo -e "${YELLOW}Setting up database for first run...${NC}"
    sleep 10  # Give containers time to fully start
    docker-compose exec api bundle exec rails db:setup RAILS_ENV=production
    touch ./.db_setup_done
fi

# Create cron job for certificate renewal
echo -e "${YELLOW}Setting up automatic certificate renewal...${NC}"
echo "0 3 * * * certbot renew --quiet" > /etc/cron.d/certbot-renewal

echo -e "${GREEN}Docker deployment completed successfully!${NC}"
echo -e "${GREEN}Backend API is now available at https://api.ecar.tn${NC}"
echo -e "${GREEN}Admin interface is now available at https://admin.ecar.tn${NC}"
echo -e "${YELLOW}Remember to update your DNS records to point to this server${NC}"
echo -e "${YELLOW}Make sure port 80 and 443 are open in your firewall${NC}"

# Show container status
docker-compose ps 