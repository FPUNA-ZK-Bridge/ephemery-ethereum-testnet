# Nodo de la Red de Pruebas Ethereum Ephemery

Una configuración basada en Docker para ejecutar un nodo completo de Ethereum en la red de pruebas Ephemery usando Geth (capa de ejecución) y Nimbus (capa de consenso).

## 🌟 ¿Qué es Ephemery?

Ephemery es una red de pruebas de Ethereum de corta duración que se reinicia periódicamente (aproximadamente cada 28 días). Está diseñada para:

- Probar aplicaciones de Ethereum y contratos inteligentes
- Aprender desarrollo en Ethereum sin costos de la red principal
- Experimentar con operaciones de validadores
- Proyectos de investigación académica y tesis

## 🏗️ Arquitectura

Esta configuración ejecuta dos clientes de Ethereum sincronizados:

- **Capa de Ejecución**: Geth (Go Ethereum) - Maneja transacciones y ejecución de contratos inteligentes
- **Capa de Consenso**: Nimbus - Gestiona el consenso de prueba de participación y la cadena de baliza

Ambos clientes se comunican a través de la API Engine usando autenticación JWT.

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Al menos 4GB de RAM disponible
- 20GB+ de espacio libre en disco
- Conexión a Internet para la sincronización inicial

## 🚀 Inicio Rápido

1. **Clonar y configurar**:

   ```bash
   git clone <url-del-repositorio>
   cd ephemery-ethereum-testnet
   chmod +x setup.sh
   ```

2. **Ejecutar el script de configuración**:

   ```bash
   ./setup.sh
   ```

   Este script:

   - Descargará la configuración más reciente de la red de pruebas Ephemery
   - Generará el secreto JWT para autenticación de clientes
   - Iniciará los contenedores de Geth y Nimbus

3. **Verificar que el nodo está funcionando**:

   ```bash
   # Verificar versión del nodo
   curl http://localhost:5052/eth/v1/node/version

   # Verificar estado de sincronización
   curl http://localhost:5052/eth/v1/node/syncing
   ```

## 🔧 Configuración

### Puertos

- **5052**: API Beacon (cliente de consenso Nimbus)
- **8545**: API JSON-RPC (cliente de ejecución Geth)
- **8551**: API Engine (comunicación interna)
- **30303**: Red P2P (Geth)
- **9001**: Red P2P (Nimbus)

### Persistencia de Datos

Los datos del nodo se almacenan en volúmenes de Docker:

- `geth_data`: Datos de blockchain de la capa de ejecución
- `nimbus_data`: Datos de la cadena de baliza de la capa de consenso

## 📊 Monitoreo y Uso

### Verificar Estado del Nodo

```bash
# Estado de la cadena de baliza
curl http://localhost:5052/eth/v1/beacon/headers/head

# Estado de la capa de ejecución
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545
```

### Ver Logs

```bash
# Logs de Nimbus
docker logs ephemery-nimbus -f

# Logs de Geth
docker logs ephemery-geth-snap -f
```

### Detener/Iniciar Servicios

```bash
# Detener todos los servicios
docker compose down

# Iniciar servicios
docker compose up -d

# Reiniciar con datos nuevos
docker compose down -v
./setup.sh
```

## 🔄 Reinicios de la Red de Pruebas

Ephemery se reinicia aproximadamente cada 28 días. Cuando esto suceda:

1. Detener la configuración actual: `docker compose down -v`
2. Ejecutar el script de configuración nuevamente: `./setup.sh`
3. El script descargará automáticamente la nueva configuración de la red de pruebas

## 🛠️ Uso para Desarrollo

### Conectar MetaMask

- **Nombre de la Red**: Ephemery Testnet
- **URL RPC**: `http://localhost:8545`
- **ID de Cadena**: `39438151`
- **Símbolo de Moneda**: `ETH`

### Usar con Librerías Web3

```javascript
// Ejemplo con ethers.js
const provider = new ethers.JsonRpcProvider("http://localhost:8545");

// Ejemplo con web3.js
const web3 = new Web3("http://localhost:8545");
```

## 📁 Estructura del Proyecto

```
.
├── docker-compose.yml          # Configuración de servicios Docker
├── setup.sh                   # Script de configuración automatizada
├── config/ephemery/           # Archivos de configuración de la red de pruebas
│   ├── config.yaml            # Configuración del cliente de consenso
│   ├── genesis.json           # Definición del bloque génesis
│   └── ...                    # Otros parámetros de red
└── jwt/                       # Autenticación JWT
    └── jwt.hex                # Secreto compartido para comunicación de clientes
```

## 🐛 Solución de Problemas

### Problemas Comunes

**La sincronización toma demasiado tiempo**:

- Ephemery es una red de pruebas pequeña, la sincronización inicial debería completarse en minutos
- Revisar los logs por problemas de conexión: `docker logs ephemery-nimbus -f`

**Conflictos de puertos**:

- Asegurarse de que los puertos 5052, 8545, 8551, 30303, 9001 estén disponibles
- Modificar `docker-compose.yml` si es necesario

**Espacio en disco insuficiente**:

- Limpiar datos antiguos: `docker compose down -v`
- Asegurarse de tener al menos 20GB de espacio libre

**Errores de autenticación JWT**:

- Reiniciar servicios: `docker compose restart`
- Regenerar JWT: `openssl rand -hex 32 > jwt/jwt.hex`

### Resetear Todo

```bash
# Reseteo completo (elimina todos los datos de blockchain)
docker compose down -v
docker system prune -f
./setup.sh
```

## 🎓 Uso Educativo

Esta configuración es perfecta para:

- **Desarrollo de Blockchain**: Probar contratos inteligentes sin costos de la red principal
- **Investigación Académica**: Estudiar mecánicas de Ethereum y consenso
- **Aprendizaje**: Entender cómo funcionan juntos los clientes de Ethereum
- **Proyectos de Tesis**: Experimentar con aplicaciones de blockchain

## 🔗 Enlaces Útiles

- [Red de Pruebas Ephemery](https://ephemery.dev/)
- [Documentación de Geth](https://geth.ethereum.org/docs)
- [Documentación de Nimbus](https://nimbus.guide/)
- [Ethereum.org](https://ethereum.org/developers/)
