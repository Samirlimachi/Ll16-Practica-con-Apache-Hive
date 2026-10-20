-- LI16 - Práctica con Apache Hive
-- Base de datos, tabla, carga y consultas ejecutadas en el cliente hive (contenedor hive-server)

set hive.cli.print.header=true;

CREATE DATABASE db_samir;

CREATE TABLE db_samir.fb_samir(
  id int, age int, day int, year int, month int,
  gender string, tenure int, friends int, friends_init int,
  likes int, likes_recd int, mlikes int, mlikes_rcd int,
  wlikes int, wlikes_rcd int
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

DESCRIBE FORMATTED db_samir.fb_samir;

-- hive-server no tiene core-site.xml de Hadoop: se usa la URI completa de HDFS
LOAD DATA INPATH 'hdfs://yarn-resourcemanager:9000/user/hive/warehouse/pseudo_facebook_samir.csv'
INTO TABLE db_samir.fb_samir;

USE db_samir;
SELECT * FROM fb_samir LIMIT 10;

-- La tabla se creó con numRows = 0: obliga a contar los datos reales
set hive.compute.query.using.stats=false;

-- 1. Número total de usuarios (99003)
SELECT COUNT(*) AS total_usuarios FROM fb_samir;

-- 2. Usuarios mayores de 25 años (56676)
SELECT COUNT(*) AS mayores_25 FROM fb_samir WHERE age > 25;

-- 3. ¿Hombres o mujeres tienen más amigos?
SELECT gender, COUNT(*) AS usuarios, SUM(friends) AS total_amigos,
       ROUND(AVG(friends), 2) AS promedio_amigos
FROM fb_samir
WHERE gender IN ('male', 'female')
GROUP BY gender;

-- 4. "Me gusta" recibidos: jóvenes (13-25) frente a mayores de 35
SELECT grupo, COUNT(*) AS usuarios, SUM(likes_recd) AS total_likes_recibidos,
       ROUND(AVG(likes_recd), 2) AS promedio_likes
FROM (
  SELECT CASE WHEN age BETWEEN 13 AND 25 THEN 'jovenes_13_25' ELSE 'mayores_35' END AS grupo,
         likes_recd
  FROM fb_samir
  WHERE age BETWEEN 13 AND 25 OR age > 35
) t
GROUP BY grupo;

-- 5. Usuarios por mes de cumpleaños
SELECT month AS mes, COUNT(*) AS usuarios FROM fb_samir GROUP BY month ORDER BY mes;

-- 6. Jóvenes (13-25): ¿celular (mobile_*) o computadora (www_*)?
SELECT SUM(mlikes) AS likes_celular, SUM(wlikes) AS likes_computadora,
       SUM(mlikes_rcd) AS recibidos_celular, SUM(wlikes_rcd) AS recibidos_computadora
FROM fb_samir WHERE age BETWEEN 13 AND 25;

-- 7. Adultos (mayores de 25): ¿celular o computadora?
SELECT SUM(mlikes) AS likes_celular, SUM(wlikes) AS likes_computadora,
       SUM(mlikes_rcd) AS recibidos_celular, SUM(wlikes_rcd) AS recibidos_computadora
FROM fb_samir WHERE age > 25;
