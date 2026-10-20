# LI16 - Práctica con Apache Hive

**Materia:** Tecnologías Emergentes · **Gestión:** 2026 · **Docente:** Ing. Efraín Luna Mamani
**Estudiante:** Samir Limachi Lopez

Carga y análisis del dataset *pseudo_facebook* (Kaggle) con Apache Hive 3.1.3 sobre HDFS, usando el clúster
Docker del grupo: [Bigdata-Dockerspark-Transnochados](https://github.com/Jhael-Elisa/Bigdata-Dockerspark-Transnochados)
(Hadoop 3.3.5, Spark 3.4.1, Hive 3.1.3).

## Contenido

| Ruta | Descripción |
|---|---|
| `informe/` | Informe con portada, evidencias (capturas) y análisis de cada punto |
| `sql/consultas.sql` | Creación de la base y la tabla, carga del CSV y las 7 consultas |

## Contenedores usados

En el repositorio del grupo los nombres difieren de los del enunciado:

| Enunciado | Contenedor equivalente |
|---|---|
| `docker-hive_namenode_1` | `bigdata-dockerspark-transnochados-yarn-resourcemanager-1` (NameNode + ResourceManager) |
| `docker-hive_hive-server_1` | `hive-server` |

## Pasos

```bash
# 1. Levantar el clúster (dentro del repo del grupo)
docker compose up -d
docker ps

# 2. Preparar el dataset (descargado de Kaggle en ~/Descargas)
mkdir -p ~/Descargas/lab16 && cd ~/Descargas/lab16
unzip ~/Descargas/pseudo_facebook.csv.zip
tail -n +2 pseudo_facebook.csv > pseudo_facebook_samir.csv   # quitar el encabezado

# 3. Copiar al NameNode y subir a HDFS
docker cp pseudo_facebook_samir.csv bigdata-dockerspark-transnochados-yarn-resourcemanager-1:/tmp/
docker exec -it bigdata-dockerspark-transnochados-yarn-resourcemanager-1 /bin/bash
hdfs dfs -put /tmp/pseudo_facebook_samir.csv /user/hive/warehouse/
hdfs dfs -ls /user/hive/warehouse/

# 4. Entrar a Hive y ejecutar sql/consultas.sql
docker exec -it hive-server /bin/bash
hive
```

Interfaz web del NameNode: `http://<IP-del-host>:9870` → *Utilities → Browse the file system*.

## Resultados

| # | Consulta | Resultado |
|---|---|---|
| 1 | Total de usuarios | 99 003 |
| 2 | Mayores de 25 años | 56 676 (57,2 %) |
| 3 | Promedio de amigos por género | Mujeres 241,97 · Hombres 165,04 |
| 4 | Promedio de "me gusta" recibidos | 13-25 años: 200,29 · Mayores de 35: 104,7 |
| 5 | Usuarios por mes de cumpleaños | Entre 7 205 y 8 476 por mes; enero destaca con 11 772 |
| 6 | Jóvenes (13-25): celular vs computadora | 5 248 117 vs 2 349 153 "me gusta" dados → celular (69 %) |
| 7 | Adultos (>25): celular vs computadora | 5 257 715 vs 2 597 277 "me gusta" dados → celular (67 %) |

El dataset no se incluye en el repositorio; se descarga de
[Kaggle](https://www.kaggle.com/code/youssefabdelghfar/facebook-data-analysis/input).
