# Pangolin Reverse Proxy Docker Compose Setup

This repository contains a complete Docker Compose setup for running Pangolin reverse proxy with PostgreSQL backend.

## Overview

Pangolin is a secure reverse proxy and VPN solution that provides:
- Secure tunneling through WireGuard
- HTTP/HTTPS reverse proxy capabilities
- Web-based management dashboard
- PostgreSQL database backend
- Traefik load balancer integration

## Architecture

The setup includes four main services:

- **PostgreSQL** - Database backend for Pangolin
- **Pangolin** - Main reverse proxy service with web interface
- **Gerbil** - Network tunnel controller with WireGuard
- **Traefik** - Load balancer and reverse proxy frontend

## Quick Start

1. **Clone and setup**
   ```bash
   git clone <your-repo>
   cd pangolin-compose
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env and configure:
   # - DOMAIN (your domain name)
   # - POSTGRES_PASSWORD (secure database password)
   # - SERVER_SECRET (secure random string, at least 32 characters)
   ```

3. **Start the stack**
   ```bash
   docker compose up -d
   ```

4. **Access the web interface**
   - Open http://localhost:3002 (or https://your-domain.com in production)
   - Use the setup token from the logs: `docker logs pangolin | grep "Token:"`

## Configuration

All configuration is managed through environment variables in the `.env` file. The `config/config.yml` file is automatically generated on container startup from these environment variables.

### Environment Variables (.env)

```bash
# Domain Configuration
DOMAIN=your-domain.com
DASHBOARD_SCHEME=https

# Pangolin Configuration
SERVER_SECRET=change-this-to-a-secure-random-string-at-least-32-chars

# PostgreSQL Configuration
POSTGRES_PASSWORD=your_secure_password_here

# API key for Pangolin integration API (generate in dashboard or .env)
API_KEY=your_pangolin_api_key_here
```

### Key Configuration Variables

- **DOMAIN**: Your domain name (e.g., `proxy.example.com` or `localhost` for local development)
- **DASHBOARD_SCHEME**: URL scheme for dashboard (`http` or `https`)
- **SERVER_SECRET**: Secure random string for session encryption (minimum 32 characters)
- **POSTGRES_PASSWORD**: Database password
- **API_KEY**: Optional API key for integration API

### Auto-Generated Configuration

The `bin/generate-config.sh` script automatically creates `config/config.yml` based on your environment variables. You don't need to manually edit configuration files.

## Service Ports

| Service | Port | Description |
|---------|------|-------------|
| Pangolin Web | 3002 | Main web interface |
| Pangolin API | 3001 | Internal API |
| Pangolin API | 3000 | Public API |
| PostgreSQL | 5432 | Database |
| HTTP | 80 | Web traffic via Gerbil/Traefik |
| HTTPS | 443 | Secure web traffic |
| WireGuard | 51820/UDP | VPN tunnel |
| Gerbil UDP | 21820/UDP | Tunnel control |

## Initial Setup

1. **Access the dashboard**
   ```
   http://localhost:3002
   ```

2. **Get the setup token**
   ```bash
   docker logs pangolin | grep "Token:"
   ```

3. **Complete initial configuration**
   - Create your organization
   - Set up sites and resources
   - Configure domain routing

## Management Commands

### View service status
```bash
docker-compose ps
```

### View logs
```bash
# All services
docker-compose logs

# Specific service
docker logs pangolin
docker logs gerbil
docker logs traefik
docker logs pangolin_postgres
```

### Restart services
```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart pangolin
```

### Stop and remove
```bash
docker-compose down
```

### Stop and remove with volumes
```bash
docker-compose down -v
```

## Verification

To verify the stack is working correctly:

```bash
# Check container status
docker-compose ps

# Test API endpoints
curl http://localhost:3001/api/v1/
curl http://localhost:3000/api/v1/

# Test web interface
curl -I http://localhost:3002/

# Test database connectivity
nc -z localhost 5432
```

Expected responses:
- API endpoints: `{"message":"Healthy"}`
- Web interface: HTTP 200 OK
- Database: Connection successful

## Troubleshooting

### Common Issues

1. **Pangolin fails to start**
   - Check all required environment variables are set in `.env`
   - Verify PostgreSQL is healthy before Pangolin starts
   - Check logs: `docker compose logs pangolin`

2. **Database connection errors**
   - Verify POSTGRES_PASSWORD is set in `.env`
   - Ensure PostgreSQL container is healthy
   - Database connection is managed via DATABASE_URL environment variable

3. **Permission errors**
   - Check Docker has permissions to mount volumes
   - The `config/` directory is auto-created by Docker

4. **Port conflicts**
   - Ensure ports 80, 443, 3000-3002, 5432, 51820, 21820 are available
   - Modify port mappings in docker-compose.yml if needed

### Logs and Debugging

```bash
# View detailed logs
docker-compose logs -f

# Check specific service health
docker inspect pangolin --format='{{.State.Health.Status}}'

# Access container shell
docker exec -it pangolin sh
```

## Security Considerations

1. **Change default passwords**
   - Set a strong `POSTGRES_PASSWORD` in `.env`
   - Set a secure `SERVER_SECRET` (minimum 32 characters)
   - Generate random secrets: `openssl rand -base64 32`

2. **Network security**
   - Configure firewall rules for exposed ports
   - Use HTTPS in production with proper certificates
   - Traefik automatically handles Let's Encrypt certificates

3. **Access control**
   - Set up proper authentication in Pangolin dashboard
   - Restrict administrative access
   - Use strong passwords for all accounts

## Production Deployment

For production use:

1. **Configure your domain**
   ```bash
   # In .env file
   DOMAIN=proxy.example.com
   DASHBOARD_SCHEME=https
   ```

2. **Set up DNS records**
   - Point your domain A record to your server IP
   - Wait for DNS propagation

3. **Generate secure secrets**
   ```bash
   # Generate SERVER_SECRET
   openssl rand -base64 32

   # Generate POSTGRES_PASSWORD
   openssl rand -base64 24
   ```

4. **Enable HTTPS**
   - Traefik automatically obtains Let's Encrypt certificates
   - Configure email in `config/traefik/traefik.yml` for certificate notifications

5. **Database backup**
   - Set up regular PostgreSQL backups
   - PostgreSQL data is stored in the `postgres_data` Docker volume

## Resources

- [Pangolin Documentation](https://docs.pangolin.net/)
- [Pangolin GitHub](https://github.com/fosrl/pangolin)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## License

This setup is provided as-is. Pangolin itself is licensed under AGPL-3 (Community Edition) or Fossorial Commercial License (Enterprise Edition).