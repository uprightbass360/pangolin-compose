#!/bin/sh
# Generate config.yml from environment variables

DOMAIN="${DOMAIN}"
DASHBOARD_URL="${DASHBOARD_URL}"
SERVER_SECRET="${SERVER_SECRET}"

cat > /app/config/config.yml <<EOF
app:
  dashboard_url: "${DASHBOARD_URL}"

domains:
  ${DOMAIN}:
    base_domain: "${DOMAIN}"
    cert_resolver: "letsencrypt"

server:
  secret: "${SERVER_SECRET}"
  port: 3001
  integration_port: ${PANGOLIN_INTEGRATION_PORT:-3003}

gerbil:
  base_endpoint: "${DOMAIN}"

flags:
  require_email_verification: ${REQUIRE_EMAIL_VERIFICATION}
  disable_signup_without_invite: ${DISABLE_SIGNUP_WITHOUT_INVITE}
  disable_user_create_org: ${DISABLE_USER_CREATE_ORG}
  enable_integration_api: ${ENABLE_INTEGRATION_API}
  allow_raw_resources: ${ALLOW_RAW_RESOURCES}

email:
  enabled: ${EMAIL_ENABLED}

rate_limit:
  enabled: ${RATE_LIMIT_ENABLED}
  max_requests_per_minute: ${RATE_LIMIT_MAX_REQUESTS_PER_MINUTE}
EOF

echo "Generated config.yml with domain: ${DOMAIN}"

# Execute the original entrypoint
exec "$@"
