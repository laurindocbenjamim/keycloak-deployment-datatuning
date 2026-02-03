# Use versão específica
FROM quay.io/keycloak/keycloak:22.0.5 

# Config básica
ENV KC_PROXY=edge
ENV KC_HOSTNAME_STRICT=false

EXPOSE 8080

# IMPORTANTE: Iniciar em modo dev para criar admin
CMD ["/opt/keycloak/bin/kc.sh", "start-dev"]