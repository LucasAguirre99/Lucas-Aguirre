# Docker - Referencia completa

## Imagenes

```bash
# Construir imagen
docker build -t nombre:tag .
docker build -t nombre:tag -f Dockerfile.prod .   # Dockerfile especifico
docker build --no-cache -t nombre:tag .            # sin cache

# Listar imagenes
docker images
docker image ls

# Eliminar imagenes
docker rmi nombre:tag
docker image prune                # imagenes huerfanas
docker image prune -a             # TODAS las imagenes no usadas

# Subir / bajar imagenes
docker push nombre:tag
docker pull nombre:tag

# Inspeccionar imagen
docker inspect nombre:tag

# Ver historial de capas
docker history nombre:tag

# Guardar y cargar imagen como archivo
docker save nombre:tag | gzip > imagen.tar.gz
docker load < imagen.tar.gz

# Taggear imagen
docker tag nombre:tag nuevo-registro/nombre:tag
```

---

## Contenedores

```bash
# Correr contenedor
docker run -d --name mi-app -p 8080:80 imagen:tag
docker run -it --name debug imagen:tag /bin/bash      # interactivo
docker run --rm imagen:tag comando                     # auto-eliminar al salir
docker run -e VAR=valor imagen:tag                     # variable de entorno
docker run -v /ruta/local:/ruta/contenedor imagen:tag  # montar volumen
docker run --network mi-red imagen:tag                 # red especifica

# Flags comunes de docker run
# -d          background (detached)
# -it         interactivo + TTY
# --rm        eliminar al parar
# -p          mapeo de puertos host:contenedor
# -e          variable de entorno
# -v          volumen host:contenedor
# --name      nombre del contenedor
# --network   red a usar
# --restart   politica de restart (no, always, on-failure, unless-stopped)
# --cpus      limitar CPU (ej: --cpus="1.5")
# --memory    limitar RAM (ej: --memory="512m")

# Listar contenedores
docker ps                   # solo activos
docker ps -a                # todos (incluidos parados)

# Conectarse a un contenedor corriendo
docker exec -it <id/nombre> /bin/bash
docker exec -it <id/nombre> /bin/sh

# Ejecutar un comando sin entrar
docker exec <id/nombre> cat /etc/resolv.conf

# Logs
docker logs <id/nombre>
docker logs <id/nombre> -f          # follow
docker logs <id/nombre> --tail=100  # ultimas 100 lineas

# Parar y eliminar
docker stop <id/nombre>
docker kill <id/nombre>             # forzar (SIGKILL)
docker rm <id/nombre>
docker rm -f <id/nombre>            # forzar (stop + rm)

# Eliminar todos los contenedores parados
docker container prune

# Ver stats en tiempo real
docker stats
docker stats <id/nombre> --no-stream  # una sola lectura

# Inspeccionar contenedor
docker inspect <id/nombre>
docker inspect <id/nombre> | jq '.[0].NetworkSettings.IPAddress'

# Ver puertos expuestos
docker port <id/nombre>

# Actualizar recursos sin recrear
docker update --cpus="1.0" --memory="512m" <id/nombre>

# Copiar archivos
docker cp archivo.txt <id/nombre>:/ruta/destino
docker cp <id/nombre>:/ruta/origen ./archivo-local.txt
```

---

## Limpieza total (usa con cuidado)

```bash
# Limpiar todo lo que no esta en uso
docker system prune
docker system prune -a              # incluye imagenes no usadas
docker system prune --volumes       # incluye volumenes

# Ver uso de espacio
docker system df
```

---

## Volumenes

```bash
# Crear volumen
docker volume create mi-volumen

# Listar volumenes
docker volume ls

# Inspeccionar volumen
docker volume inspect mi-volumen

# Eliminar volumen
docker volume rm mi-volumen
docker volume prune               # todos los no usados

# Usar volumen en contenedor
docker run -v mi-volumen:/data imagen:tag
docker run -v /ruta/host:/data imagen:tag   # bind mount
```

---

## Redes

```bash
# Listar redes
docker network ls

# Crear red
docker network create mi-red
docker network create --driver bridge mi-red
docker network create --driver overlay mi-red   # Swarm

# Conectar contenedor a una red
docker network connect mi-red <id/nombre>
docker network disconnect mi-red <id/nombre>

# Inspeccionar red
docker network inspect mi-red

# Eliminar red
docker network rm mi-red

# Los contenedores en la misma red se comunican por nombre
docker run -d --name app1 --network mi-red imagen1
docker run -d --name app2 --network mi-red imagen2
# app2 puede hacer ping a app1 por hostname "app1"
```

---

## Docker Compose

```bash
# Levantar servicios
docker compose up -d
docker compose up -d --build       # rebuild antes de levantar
docker compose up --force-recreate # recrear aunque no haya cambios

# Bajar servicios
docker compose down
docker compose down -v             # tambien elimina volumenes

# Ver estado
docker compose ps
docker compose logs -f             # logs de todos los servicios
docker compose logs -f <servicio>  # logs de un servicio

# Ejecutar comando en un servicio
docker compose exec <servicio> bash
docker compose exec <servicio> sh

# Escalar un servicio
docker compose up -d --scale <servicio>=3

# Rebuildar solo un servicio
docker compose build <servicio>
docker compose up -d --build <servicio>

# Ver la configuracion final (con variables expandidas)
docker compose config
```

### Estructura basica de docker-compose.yml

```yaml
version: "3.9"

services:
  app:
    build: .
    image: mi-app:latest
    container_name: mi-app
    ports:
      - "8080:80"
    environment:
      - ENV=production
      - DB_HOST=db
    volumes:
      - ./data:/app/data
    networks:
      - mi-red
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:15
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - mi-red

volumes:
  db-data:

networks:
  mi-red:
    driver: bridge
```

---

## Dockerfile - Buenas practicas

```dockerfile
# Base: usar imagen especifica, no :latest
FROM node:20-alpine

# Metadatos
LABEL maintainer="lucas@ejemplo.com"

# Crear y usar directorio de trabajo
WORKDIR /app

# Copiar solo lo necesario para instalar dependencias (aprovechar cache)
COPY package*.json ./
RUN npm ci --only=production

# Copiar el resto del codigo
COPY . .

# Usuario no-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Documentar el puerto
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -f http://localhost:3000/health || exit 1

# Comando de inicio
CMD ["node", "server.js"]
```

### Multi-stage build (imagen final mas liviana)

```dockerfile
# Stage 1: build
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: produccion (imagen limpia sin dev dependencies)
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

---

## Troubleshooting

```bash
# Contenedor que no arranca - ver logs
docker logs <id> 2>&1 | tail -50

# Entrar a contenedor que crashea inmediatamente
docker run -it --entrypoint /bin/sh imagen:tag

# Ver todos los eventos de Docker
docker events

# Diagnosticar red entre contenedores
docker run --rm --network <red> nicolaka/netshoot curl http://servicio:puerto

# Ver los procesos dentro del contenedor
docker top <id/nombre>

# Ver las capas y tamanio de la imagen
docker history --no-trunc imagen:tag

# Imagen que no hace pull: limpiar y volver a intentar
docker pull imagen:tag --disable-content-trust

# Disco lleno: ver cuanto ocupa Docker
docker system df -v
```

---

## Registro privado

```bash
# Login en un registro
docker login registro.ejemplo.com
docker login -u usuario -p password registro.ejemplo.com

# Logout
docker logout registro.ejemplo.com

# Taggear y subir a registro privado
docker tag mi-app:latest registro.ejemplo.com/proyecto/mi-app:latest
docker push registro.ejemplo.com/proyecto/mi-app:latest
```

---

## lazydocker (TUI para Docker)

Instalacion y uso:
```bash
# Instalacion (script)
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# Uso
lazydocker
```
- Navegar con flechas, `[` / `]` para cambiar panel, `q` para salir, `e` para exec.
