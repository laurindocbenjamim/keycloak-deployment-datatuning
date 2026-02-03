FROM quay.io/keycloak/keycloak:22.0.5

# Config básica
ENV KC_PROXY=edge
ENV KC_HOSTNAME_STRICT=false

EXPOSE 8080

# Use ENTRYPOINT para o comando base e CMD para argumentos
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev"]