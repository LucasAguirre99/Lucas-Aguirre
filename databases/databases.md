# Bases de Datos - Referencia

---

# PostgreSQL

## Conexion

```bash
# Conectarse
psql -U usuario -h host -d base_de_datos
psql -U postgres                        # conectarse a localhost como superuser
psql -U usuario -h host -d db -p 5433  # puerto no estandar

# Conectarse con URL
psql postgresql://usuario:password@host:5432/base_de_datos

# Conectarse desde dentro de un pod de K8s
kubectl exec -it <pod-postgres> -n <namespace> -- psql -U postgres
```

## Comandos dentro de psql

```sql
-- Listar bases de datos
\l

-- Cambiar de base de datos
\c nombre_db

-- Listar tablas
\dt
\dt schema.*    -- tablas de un schema especifico

-- Describir tabla
\d nombre_tabla
\d+ nombre_tabla    -- con mas detalle (tamanio, etc)

-- Listar schemas
\dn

-- Listar usuarios/roles
\du

-- Ver configuracion activa
SHOW ALL;
SHOW max_connections;

-- Salir
\q

-- Ejecutar script SQL desde archivo
\i /ruta/script.sql

-- Output a archivo
\o /ruta/output.txt
SELECT * FROM tabla;
\o    -- desactivar output a archivo

-- Ver historial de comandos
\s

-- Modo de tabla expandida (vertical)
\x
```

## Administracion de bases de datos

```sql
-- Crear base de datos
CREATE DATABASE mi_db;
CREATE DATABASE mi_db OWNER mi_usuario ENCODING 'UTF8';

-- Eliminar base de datos
DROP DATABASE mi_db;

-- Crear usuario
CREATE USER mi_usuario WITH PASSWORD 'password';
CREATE USER mi_usuario WITH PASSWORD 'password' CREATEDB;

-- Cambiar password
ALTER USER mi_usuario WITH PASSWORD 'nuevo_password';

-- Dar permisos
GRANT ALL PRIVILEGES ON DATABASE mi_db TO mi_usuario;
GRANT CONNECT ON DATABASE mi_db TO mi_usuario;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO mi_usuario;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO mi_usuario;

-- Revocar permisos
REVOKE ALL ON DATABASE mi_db FROM mi_usuario;

-- Eliminar usuario
DROP USER mi_usuario;

-- Ver conexiones activas
SELECT pid, usename, application_name, client_addr, state, query
FROM pg_stat_activity
WHERE datname = 'mi_db';

-- Matar conexion especifica
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid = 12345;

-- Matar TODAS las conexiones a una base de datos (para poder droparla)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'mi_db' AND pid <> pg_backend_pid();
```

## Backup y Restore

```bash
# Backup de una base de datos (formato custom, recomendado)
pg_dump -U usuario -h host -d mi_db -Fc -f backup.dump

# Backup en formato SQL (texto plano)
pg_dump -U usuario -h host -d mi_db -f backup.sql

# Backup de todas las bases de datos
pg_dumpall -U postgres -h host -f all_databases.sql

# Backup solo del schema (sin datos)
pg_dump -U usuario -h host -d mi_db --schema-only -f schema.sql

# Backup solo de los datos (sin schema)
pg_dump -U usuario -h host -d mi_db --data-only -f data.sql

# Backup de una tabla especifica
pg_dump -U usuario -h host -d mi_db -t nombre_tabla -f tabla.dump

# Restore desde formato custom
pg_restore -U usuario -h host -d mi_db -c backup.dump
pg_restore -U usuario -h host -d mi_db -c --no-owner backup.dump

# Restore desde SQL
psql -U usuario -h host -d mi_db -f backup.sql

# Restore con verbose
pg_restore -U usuario -h host -d mi_db -c -v backup.dump

# Crear DB y hacer restore en un paso
createdb -U postgres mi_db_nueva
pg_restore -U postgres -d mi_db_nueva backup.dump
```

## Consultas de diagnostico

```sql
-- Tamanio de cada base de datos
SELECT datname, pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database ORDER BY pg_database_size(datname) DESC;

-- Tamanio de tablas
SELECT table_name, pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) AS size
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY pg_total_relation_size(quote_ident(table_name)) DESC;

-- Consultas lentas (necesita pg_stat_statements)
SELECT query, calls, total_exec_time/calls AS avg_ms, rows
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- Locks activos
SELECT pid, query, wait_event_type, wait_event, state
FROM pg_stat_activity
WHERE wait_event IS NOT NULL;

-- Ver indexes de una tabla
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'mi_tabla';

-- Estadisticas de replicacion
SELECT * FROM pg_stat_replication;

-- Ver numero de conexiones actuales vs maximas
SELECT count(*) as total, max_conn
FROM pg_stat_activity, (SELECT setting::int AS max_conn FROM pg_settings WHERE name='max_connections') t
GROUP BY max_conn;
```

## Configuracion importante

```bash
# Archivo de configuracion
/etc/postgresql/<version>/main/postgresql.conf

# Control de acceso (que IPs pueden conectarse)
/etc/postgresql/<version>/main/pg_hba.conf

# Parametros utiles en postgresql.conf
max_connections = 100
shared_buffers = 256MB          # ~25% de RAM
effective_cache_size = 768MB    # ~75% de RAM
work_mem = 4MB
maintenance_work_mem = 64MB
log_slow_queries = 2000ms       # logear queries > 2 segundos

# Recargar configuracion sin reiniciar
SELECT pg_reload_conf();
# o
sudo systemctl reload postgresql
```

---

# MySQL / MariaDB

## Conexion y comandos basicos

```bash
# Conectarse
mysql -u root -p
mysql -u usuario -h host -p nombre_db
mysql -u root -p -e "SHOW DATABASES;"   # ejecutar comando directo
```

```sql
-- Ver bases de datos
SHOW DATABASES;

-- Usar una base de datos
USE nombre_db;

-- Ver tablas
SHOW TABLES;

-- Describir tabla
DESCRIBE nombre_tabla;
SHOW CREATE TABLE nombre_tabla;

-- Ver usuarios
SELECT user, host FROM mysql.user;

-- Ver variables de servidor
SHOW VARIABLES LIKE 'max_connections';
SHOW STATUS;
```

## Administracion

```sql
-- Crear base de datos
CREATE DATABASE mi_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Crear usuario
CREATE USER 'usuario'@'%' IDENTIFIED BY 'password';
CREATE USER 'usuario'@'localhost' IDENTIFIED BY 'password';

-- Dar permisos
GRANT ALL PRIVILEGES ON mi_db.* TO 'usuario'@'%';
GRANT SELECT, INSERT, UPDATE ON mi_db.* TO 'usuario'@'%';
FLUSH PRIVILEGES;

-- Cambiar password
ALTER USER 'usuario'@'%' IDENTIFIED BY 'nuevo_password';

-- Ver procesos activos
SHOW PROCESSLIST;

-- Matar query
KILL <process_id>;

-- Matar conexion
KILL CONNECTION <process_id>;
```

## Backup y Restore

```bash
# Backup
mysqldump -u root -p mi_db > backup.sql
mysqldump -u root -p --all-databases > all_databases.sql
mysqldump -u root -p mi_db tabla1 tabla2 > tablas.sql

# Backup comprimido
mysqldump -u root -p mi_db | gzip > backup.sql.gz

# Restore
mysql -u root -p mi_db < backup.sql
gunzip < backup.sql.gz | mysql -u root -p mi_db
```

---

# Redis

## Conexion y comandos basicos

```bash
# Conectarse
redis-cli
redis-cli -h host -p 6379
redis-cli -h host -p 6379 -a password
redis-cli -h host -n 1     # base de datos 1

# Ping
redis-cli ping             # deberia responder PONG

# Info del servidor
redis-cli info
redis-cli info memory
redis-cli info replication
```

```redis
-- Keys
KEYS *                  -- todas las keys (cuidado en prod: lento!)
KEYS "usuario:*"        -- keys con patron
SCAN 0 MATCH "user:*" COUNT 100   -- scan incremental (mejor que KEYS)

SET clave valor
GET clave
DEL clave
EXISTS clave
EXPIRE clave 300        -- TTL en segundos
TTL clave               -- ver TTL restante
PERSIST clave           -- quitar TTL

-- Strings
SET contador 0
INCR contador
INCRBY contador 5
DECR contador

-- Hashes
HSET usuario:1 nombre "lucas" edad 30
HGET usuario:1 nombre
HGETALL usuario:1
HMSET usuario:2 nombre "maria" rol "devops"

-- Listas
LPUSH lista "valor1"
RPUSH lista "valor2"
LRANGE lista 0 -1      -- todos los elementos
LLEN lista

-- Sets
SADD etiquetas "devops" "linux" "k8s"
SMEMBERS etiquetas
SISMEMBER etiquetas "linux"

-- Sorted Sets
ZADD ranking 100 "lucas"
ZADD ranking 200 "maria"
ZRANGE ranking 0 -1 WITHSCORES

-- Pub/Sub
SUBSCRIBE canal
PUBLISH canal "mensaje"
```

```bash
# Administracion
redis-cli FLUSHDB           # limpiar base de datos actual
redis-cli FLUSHALL          # limpiar TODAS las bases
redis-cli BGSAVE            # guardar snapshot (background)
redis-cli CONFIG GET maxmemory
redis-cli CONFIG SET maxmemory 512mb
redis-cli CONFIG SET maxmemory-policy allkeys-lru

# Monitorear comandos en tiempo real
redis-cli MONITOR

# Ver estadisticas en tiempo real
redis-cli --stat

# Ver las keys mas grandes
redis-cli --bigkeys

# Ver memoria de una key
redis-cli MEMORY USAGE clave
```

---

# MongoDB

## Conexion y comandos basicos

```bash
# Conectarse
mongosh
mongosh "mongodb://usuario:password@host:27017/mi_db"
mongosh --host host --port 27017 -u usuario -p password --authenticationDatabase admin
```

```javascript
// Ver bases de datos
show dbs

// Usar base de datos
use mi_db

// Ver colecciones
show collections

// CRUD
db.usuarios.insertOne({ nombre: "lucas", rol: "devops" })
db.usuarios.insertMany([{ nombre: "a" }, { nombre: "b" }])

db.usuarios.find()
db.usuarios.find({ rol: "devops" })
db.usuarios.findOne({ nombre: "lucas" })
db.usuarios.find({ edad: { $gt: 25 } })      // mayor a 25
db.usuarios.find().sort({ nombre: 1 })        // ordenar ASC
db.usuarios.find().limit(10)

db.usuarios.updateOne({ nombre: "lucas" }, { $set: { rol: "admin" } })
db.usuarios.updateMany({ activo: false }, { $set: { eliminado: true } })

db.usuarios.deleteOne({ nombre: "lucas" })
db.usuarios.deleteMany({ activo: false })

// Contar documentos
db.usuarios.countDocuments()
db.usuarios.countDocuments({ rol: "devops" })

// Indexes
db.usuarios.createIndex({ email: 1 }, { unique: true })
db.usuarios.getIndexes()
db.usuarios.dropIndex("email_1")
```

```bash
# Backup y restore
mongodump -u usuario -p password --host host --db mi_db --out ./backup/
mongorestore -u usuario -p password --host host --db mi_db ./backup/mi_db/

# Backup comprimido
mongodump --uri "mongodb://user:pass@host/db" --gzip --out ./backup/

# Exportar a JSON/CSV
mongoexport --uri "mongodb://user:pass@host/db" --collection usuarios --out usuarios.json
```
