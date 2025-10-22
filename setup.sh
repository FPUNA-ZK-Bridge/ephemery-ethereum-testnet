#!/usr/bin/env bash
set -euo pipefail

# Script de Configuración de la Red de Pruebas Ethereum Ephemery
# Este script descarga la última configuración de la red de pruebas Ephemery e inicia el nodo

# Colores para la salida
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # Sin Color

# Configuración
readonly EPHEMERY_RELEASE_URL="https://github.com/ephemery-testnet/ephemery-genesis/releases/latest/download/testnet-all.tar.gz"
readonly CONFIG_DIR="config/ephemery"
readonly JWT_DIR="jwt"

# Funciones de registro
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}>>> $1${NC}"
}

# Verificar si las herramientas requeridas están instaladas
check_dependencies() {
    log_step "Verificando dependencias..."
    
    local missing_deps=()
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v openssl &> /dev/null; then
        missing_deps+=("openssl")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Faltan dependencias requeridas: ${missing_deps[*]}"
        log_error "Por favor instala las dependencias faltantes e intenta nuevamente."
        exit 1
    fi
    
    log_info "Todas las dependencias están instaladas ✓"
}

# Crear directorios necesarios
create_directories() {
    log_step "Creando directorios..."
    mkdir -p "${CONFIG_DIR}" "${JWT_DIR}"
    log_info "Directorios creados ✓"
}

# Descargar y extraer la configuración de Ephemery
download_ephemery_config() {
    log_step "Descargando la última configuración de la red de pruebas Ephemery..."
    
    local temp_file="${CONFIG_DIR}/testnet-all.tar.gz"
    
    if curl -L --fail --show-error --silent -o "${temp_file}" "${EPHEMERY_RELEASE_URL}"; then
        log_info "Configuración descargada ✓"
    else
        log_error "Fallo al descargar la configuración de Ephemery"
        exit 1
    fi
    
    log_step "Extrayendo configuración..."
    if tar -xzf "${temp_file}" -C "${CONFIG_DIR}"; then
        rm "${temp_file}"
        log_info "Configuración extraída ✓"
    else
        log_error "Fallo al extraer la configuración"
        exit 1
    fi
}

# Generar secreto JWT para autenticación de clientes
generate_jwt_secret() {
    log_step "Generando secreto JWT..."
    
    if openssl rand -hex 32 | tr -d "\n" > "${JWT_DIR}/jwt.hex"; then
        log_info "Secreto JWT generado ✓"
    else
        log_error "Fallo al generar el secreto JWT"
        exit 1
    fi
}

# Iniciar contenedores Docker
start_containers() {
    log_step "Iniciando contenedores del nodo Ethereum..."
    
    # Verificar si docker-compose o docker compose está disponible
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        log_error "Ni docker-compose ni 'docker compose' están disponibles"
        exit 1
    fi
    
    if ${COMPOSE_CMD} up -d; then
        log_info "Contenedores iniciados exitosamente ✓"
    else
        log_error "Fallo al iniciar los contenedores"
        exit 1
    fi
}

# Mostrar mensaje de éxito e información útil
show_completion_info() {
    echo
    log_info "🎉 ¡El nodo de la red de pruebas Ethereum Ephemery está funcionando!"
    echo
    echo -e "${BLUE}📊 Endpoints disponibles:${NC}"
    echo "  • API Beacon (Nimbus):     http://localhost:5052"
    echo "  • API JSON-RPC (Geth):     http://localhost:8545"
    echo "  • API Engine (interno):    http://localhost:8551"
    echo
    echo -e "${BLUE}🔍 Verificaciones rápidas de salud:${NC}"
    echo "  • Versión del nodo:   curl http://localhost:5052/eth/v1/node/version"
    echo "  • Estado de sync:     curl http://localhost:5052/eth/v1/node/syncing"
    echo "  • Último bloque:      curl http://localhost:5052/eth/v1/beacon/headers/head"
    echo
    echo -e "${BLUE}📋 Comandos útiles:${NC}"
    echo "  • Ver logs:           docker logs ephemery-nimbus -f"
    echo "  • Detener nodo:       ${COMPOSE_CMD} down"
    echo "  • Reiniciar:          ${COMPOSE_CMD} restart"
    echo
    log_warn "Nota: La sincronización inicial puede tomar unos minutos. Revisa los logs si es necesario."
}

# Función de limpieza para manejo de errores
cleanup() {
    if [ $? -ne 0 ]; then
        log_error "La configuración falló. Limpiando..."
        rm -f "${CONFIG_DIR}/testnet-all.tar.gz" 2>/dev/null || true
    fi
}

# Ejecución principal
main() {
    trap cleanup EXIT
    
    echo -e "${BLUE}🚀 Configuración de la Red de Pruebas Ethereum Ephemery${NC}"
    echo "========================================================"
    echo
    
    check_dependencies
    create_directories
    download_ephemery_config
    generate_jwt_secret
    start_containers
    show_completion_info
}

# Ejecutar función principal
main "$@"