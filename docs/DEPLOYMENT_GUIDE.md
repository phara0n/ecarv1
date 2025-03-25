# eCar Garage Management Application - Deployment Guide

This guide explains how to deploy the eCar Garage Management Application using either the standard deployment script or Docker.

## Prerequisites

- Linux server (Ubuntu 18.04 or newer recommended)
- Root or sudo access
- Domain names configured in DNS (api.ecar.tn and admin.ecar.tn)
- Open ports: 80, 443

## SSL Certificates with Let's Encrypt

Both deployment methods use **Let's Encrypt** to automatically obtain and renew SSL certificates. This ensures:
- Free, trusted SSL certificates
- Automatic renewal every 90 days
- HTTPS for secure communication between clients and servers

Let's Encrypt is integrated into the deployment scripts, so no manual certificate management is required.

## Option 1: Docker Deployment

The Docker deployment method is recommended for most environments as it ensures consistent setup across different servers.

### Steps for Docker Deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/phara0n/ecarv1.git ecar-garage-app
   cd ecar-garage-app
   ```

2. Create a `.env.docker` file:
   ```bash
   cp .env.docker.example .env.docker
   # Edit the file to update passwords and secrets
   nano .env.docker
   ```

3. Make the deployment script executable:
   ```bash
   chmod +x docker-deploy.sh
   ```

4. Run the deployment script with sudo:
   ```bash
   sudo ./docker-deploy.sh
   ```

The script will:
- Check for and install Docker if needed
- Set up Nginx configuration
- Obtain SSL certificates using Let's Encrypt
- Generate secure keys
- Build and start Docker containers
- Set up the database
- Configure automatic certificate renewal

### Maintenance

- View logs: `docker-compose logs -f`
- Restart services: `docker-compose restart`
- Update application: 
  ```bash
  git pull
  sudo docker-compose down
  sudo docker-compose up -d --build
  ```

## Option 2: Standard Deployment

This method is suitable for servers where you prefer to install services directly on the host.

### Prerequisites for Standard Deployment

- Ruby 3.2.2
- Rails 7.0.4
- PostgreSQL 14+
- Redis
- Node.js 18+
- Yarn
- Nginx

### Steps for Standard Deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/phara0n/ecarv1.git ecar-garage-app
   cd ecar-garage-app
   ```

2. Make the deployment script executable:
   ```bash
   chmod +x deploy.sh
   ```

3. Run the deployment script with sudo:
   ```bash
   sudo ./deploy.sh
   ```

The script will:
- Install required dependencies
- Set up the database
- Compile assets
- Configure Nginx
- Obtain SSL certificates
- Start the application with Puma

## Verifying Deployment

After deployment, verify that the application is running:

1. Backend API: https://api.ecar.tn/api/v1/health
2. Admin Interface: https://admin.ecar.tn

## Troubleshooting

### Common Issues

1. **Nginx Configuration Issues**
   - Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`
   - Validate configuration: `sudo nginx -t`

2. **Database Connection Issues**
   - Verify database credentials in `.env` or `.env.docker`
   - Check database logs

3. **SSL Certificate Issues**
   - Ensure domains point to your server
   - Check Certbot logs: `sudo certbot certificates`

### Getting Help

If you encounter issues, please:
1. Check the application logs
2. Refer to the project wiki
3. Open an issue in the GitHub repository

## Security Considerations

- The `.env.docker` file contains sensitive information and should not be committed to the repository
- Regularly update your server and Docker images
- Implement a firewall (e.g., UFW) and only allow necessary ports
- Set up monitoring and alerts for your production environment 