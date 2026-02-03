# Keycloak Deployment Data Tuning

This project contains a Dockerfile for deploying Keycloak with data tuning configurations. The Dockerfile is designed to create a containerized environment for Keycloak, allowing for easy deployment and management of the Keycloak server.

## Overview
- **Keycloak**: An open-source identity and access management solution.
- **Docker**: A platform for developing, shipping, and running applications in containers.

## Purpose
The purpose of this Dockerfile is to facilitate the deployment of Keycloak with optimized settings for data handling and performance tuning. This ensures that the Keycloak server runs efficiently and can handle the expected load.

## Usage
1. Build the Docker image:
   ```bash
   docker build -t keycloak-datatuning .
   ```
2. Run the Docker container:
   ```bash
   docker run -d -p 8080:8080 keycloak-datatuning
   ```

## Configuration
- Modify the Dockerfile as needed to adjust configurations for your specific deployment requirements.

## Complete and Optimized Dockerfile for Render

Here is the complete and optimized multistage Dockerfile for Render. This template includes support for the database, proxy security, and the necessary hostname configurations to avoid redirection errors in the frontend.

```dockerfile
# STAGE 1: Build and Optimization
FROM quay.io/keycloak/keycloak:latest as builder

# Build definitions (optimize startup on Render)
ENV KC_DB=postgres
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

WORKDIR /opt/keycloak

# Run the build to pre-configure the server with Postgres support
RUN /opt/keycloak/bin/kc.sh build

# STAGE 2: Runtime
FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# --- Network and Proxy Configurations (Crucial for Render) ---
# Informs Keycloak that it is behind Render's load balancer
ENV KC_PROXY_HEADERS=xforwarded
ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=true

# --- Database Configurations ---
ENV KC_DB=postgres

# The default port for Keycloak
EXPOSE 8080

# Optimized startup command
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]
```

### Environment Variable Configuration on Render
To ensure this Dockerfile works, add the following variables in the Render Dashboard:
- **KC_DB_URL**: Should be in JDBC format: `jdbc:postgresql://<POSTGRES_HOST>:5432/<DB_NAME>`
- **KC_DB_USERNAME**: Your Postgres username.
- **KC_DB_PASSWORD**: Your Postgres password.
- **KC_HOSTNAME**: Your domain (e.g., `my-keycloak.onrender.com`).
- **KEYCLOAK_ADMIN**: Master username.
- **KEYCLOAK_ADMIN_PASSWORD**: Master user password.

### Allowing Authentication (Frontend/Backend)
After deployment, access the dashboard and configure your Client:
- **Web Origins**: Add your frontend URL (e.g., `https://my-app.com`) to enable CORS.
- **Valid Redirect URIs**: Add `https://my-app.com*`.

**Extra Tip**: If Render fails the "Health Check", ensure the selected plan has at least 2GB of RAM, as Keycloak consumes about 1GB just to start the JVM. You can find more details about the requirements in the Official Keycloak Documentation.

### Final Checklist for Successful Deployment
1. **Repository**: Ensure the Dockerfile is at the root.
2. **Web Service**: Select the repository and ensure the Runtime is set to Docker.
3. **Database**: PostgreSQL must be active before the Web Service starts.
4. **Environment Variables**: Copy the Internal Database URL from your Postgres on Render and adapt it to JDBC format:
   - Render URL: `postgres://user:password@host/dbname`
   - JDBC Format: `jdbc:postgresql://host:5432/dbname` (Note that user and password go in separate fields on Render: **KC_DB_USERNAME** and **KC_DB_PASSWORD**).
5. **Memory Plan**: Choose a plan with at least 2GB of RAM (Starter or higher). The free plan of 512MB will cause an Out of Memory error during Java startup.

You can monitor progress in the Render Logs. If you see the message "Keycloak started in Xms", your authentication server is ready to use!

### Accessing the Dashboard for Configurations
To access the Admin Panel after deployment on Render, use the URL of your Web Service (e.g., `https://your-app.onrender.com`).

#### Access Paths
- **Homepage**: `https://your-app.onrender.com`
- **Admin Console**: `https://your-app.onrender.com`

#### Login Credentials
Use the values you set in the Render Environment Variables:
- **Username**: The value of the **KEYCLOAK_ADMIN** variable.
- **Password**: The value of the **KEYCLOAK_ADMIN_PASSWORD** variable.

#### Recommended Initial Steps
1. **Create a Realm**: Do not use the master realm for your application. Click on the realm name (top left corner) and select "Create Realm".
2. **Create a Client**: In the new Realm, go to Clients -> Create Client to configure the connection with your Frontend.
3. **Configure CORS**: Within the Client settings, ensure the "Web Origins" field contains your frontend URL to avoid browser blocks, as detailed in the Keycloak security documentation.

**Security Tip**: If the dashboard does not load or shows an "HTTPS" error, confirm that the **KC_HOSTNAME** variable is correct and does not start with https:// (it should just be `app-name.onrender.com`).

Do you already have your custom domain set up on Render, or will you use the default .onrender.com subdomain?

## License
This project is licensed under the MIT License.