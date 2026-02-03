# ESTÁGIO 1: Build e Otimização
FROM quay.io/keycloak/keycloak:latest as builder

# Definições de build (otimizam o arranque no Render)
ENV KC_DB=postgres
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=false

WORKDIR /opt/keycloak

# Executa o build para pré-configurar o servidor com suporte a Postgres
RUN /opt/keycloak/bin/kc.sh build --cache=local --db=postgres

# ESTÁGIO 2: Runtime
FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# --- Configurações de Rede e Proxy (Crucial para o Render) ---
# Configurações específicas para Render.com
ENV KC_PROXY=edge
ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=false
ENV KC_CACHE=local

# --- Configurações da Base de Dados ---
# O Keycloak vai buscar estas variáveis automaticamente
# DB_URL, DB_USERNAME, DB_PASSWORD são lidas automaticamente

# Variáveis de administração
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=Feti2030

# Porta que o Render usa
EXPOSE 8080

# Comando de inicialização otimizado
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]