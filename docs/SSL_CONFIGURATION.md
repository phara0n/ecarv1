# SSL Configuration with Let's Encrypt

This document details how SSL certificates are implemented in the eCar Garage Management Application using Let's Encrypt.

## Overview

Let's Encrypt is used to provide free, automated, and trusted SSL certificates for the application. This ensures secure HTTPS communication between clients and the application servers.

## Implementation Details

### In Docker Deployment

The `docker-deploy.sh` script handles Let's Encrypt certificate acquisition and renewal:

1. **Certificate Acquisition**:
   ```bash
   certbot certonly --standalone -d api.ecar.tn -d admin.ecar.tn --non-interactive --agree-tos --email admin@ecar.tn
   ```
   This command obtains certificates for both the API and admin domains in non-interactive mode.

2. **Automatic Renewal**:
   ```bash
   echo "0 3 * * * certbot renew --quiet" > /etc/cron.d/certbot-renewal
   ```
   This creates a cron job that runs daily at 3 AM to check for and renew certificates that are close to expiration.

3. **Container Restart After Renewal**:
   ```bash
   echo "#!/bin/bash
   docker-compose -f /home/ecar/ecar-garage-app/docker-compose.yml restart nginx" > /etc/letsencrypt/renewal-hooks/post/restart-docker.sh
   chmod +x /etc/letsencrypt/renewal-hooks/post/restart-docker.sh
   ```
   This script ensures that the Nginx container is restarted after certificate renewal to load the new certificates.

### In Standard Deployment

The `deploy.sh` script also implements Let's Encrypt:

1. **Certificate Acquisition**:
   ```bash
   certbot --nginx -d api.ecar.tn -d admin.ecar.tn --non-interactive --agree-tos --email admin@ecar.tn
   ```
   This command obtains certificates and automatically configures Nginx to use them.

2. **Automatic Renewal**:
   ```bash
   # In /etc/cron.weekly/ecar-maintenance
   certbot renew
   ```
   The maintenance script includes certificate renewal as part of weekly maintenance.

## Certificate Storage

Let's Encrypt certificates are stored in the following locations:

- **Certificate Files**: `/etc/letsencrypt/live/[domain]/`
- **Archive Directory**: `/etc/letsencrypt/archive/[domain]/`
- **Renewal Configuration**: `/etc/letsencrypt/renewal/[domain].conf`

## Nginx Configuration

Both deployment methods configure Nginx to use the SSL certificates:

1. **In Docker**:
   The Nginx configuration mounts the Let's Encrypt certificates into the container and configures the virtual hosts to use them.

2. **In Standard Deployment**:
   Certbot automatically modifies the Nginx configuration to include SSL settings.

## Security Considerations

The SSL implementation includes:

- **Modern TLS Protocols**: TLS 1.2 and 1.3 only
- **Strong Cipher Suites**: ECDHE with AES-GCM and ChaCha20-Poly1305
- **HTTP Strict Transport Security (HSTS)**: Enforced with a long max-age
- **Automatic Redirects**: HTTP requests are automatically redirected to HTTPS

## Troubleshooting

If SSL certificate issues occur:

1. **Check Certificate Status**:
   ```bash
   sudo certbot certificates
   ```

2. **Force Renewal**:
   ```bash
   sudo certbot renew --force-renewal
   ```

3. **Verify Nginx Configuration**:
   ```bash
   sudo nginx -t
   ```

4. **Check Let's Encrypt Logs**:
   ```bash
   sudo cat /var/log/letsencrypt/letsencrypt.log
   ```

## DNS Configuration

For Let's Encrypt to work properly, ensure that:

1. DNS records for `api.ecar.tn` and `admin.ecar.tn` point to your server's IP address
2. Port 80 is open during certificate issuance and renewal
3. Port 443 is open for HTTPS traffic 