FROM quay.io/keycloak/keycloak:22.0.5

# Config básica
ENV KC_PROXY=edge
ENV KC_HOSTNAME_STRICT=false

EXPOSE 8080

# Script wrapper para garantir execução
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]