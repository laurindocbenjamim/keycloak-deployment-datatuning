# ESTÁGIO 1: Build e Otimização
FROM quay.io/keycloak/keycloak:latest as builder

# Definições de build (otimizam o arranque no Render)
ENV KC_DB=postgres
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

WORKDIR /opt/keycloak

# Executa o build para pré-configurar o servidor com suporte a Postgres
RUN /opt/keycloak/bin/kc.sh build

# ESTÁGIO 2: Runtime
FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# --- Configurações de Rede e Proxy (Crucial para o Render) ---
# Informa o Keycloak que está atrás do balanceador de carga do Render
ENV KC_PROXY_HEADERS=xforwarded
ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=true

# --- Configurações da Base de Dados ---
ENV KC_DB=postgres

# A porta padrão do Keycloak
EXPOSE 8080

# Comando de inicialização otimizado
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]
