-- MySQL dump 10.13  Distrib 8.0.17, for Win64 (x86_64)
--
-- Host: saramarlop.com    Database: nell_cooking
-- ------------------------------------------------------
-- Server version	5.5.52-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ingredients`
--

DROP TABLE IF EXISTS `ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredients`
--

LOCK TABLES `ingredients` WRITE;
/*!40000 ALTER TABLE `ingredients` DISABLE KEYS */;
INSERT INTO `ingredients` VALUES (4,'Acelgas'),(3,'Garbanzos'),(2,'Gluten de trigo'),(29,'Habichuelas blancas'),(1,'Lentejas');
/*!40000 ALTER TABLE `ingredients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recipes`
--

DROP TABLE IF EXISTS `recipes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recipes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `id_sources` int(11) NOT NULL,
  `url` varchar(100) NOT NULL,
  `minutes` int(11) NOT NULL,
  `temperature` enum('caliente','frio') NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sources_recipes_idx` (`id_sources`),
  CONSTRAINT `sources_recipes` FOREIGN KEY (`id_sources`) REFERENCES `sources` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recipes`
--

LOCK TABLES `recipes` WRITE;
/*!40000 ALTER TABLE `recipes` DISABLE KEYS */;
INSERT INTO `recipes` VALUES (1,'Guiso de lentejas ',1,'https://danzadefogones.com/guiso-lentejas-vegano/',60,'caliente'),(2,'Seitan esponjoso',2,'https://jamarinveganmeal.com/seitan-esponjoso/',60,'caliente'),(3,'Garbanzos con acelgas',2,'https://jamarinveganmeal.com/garbanzos-con-acelgas/',40,'caliente'),(33,'Fabada ',27,'https://www.creativegan.net/archives/fabada-con-verduras/',25,'caliente');
/*!40000 ALTER TABLE `recipes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `recipes_per_ingredients`
--

DROP TABLE IF EXISTS `recipes_per_ingredients`;
/*!50001 DROP VIEW IF EXISTS `recipes_per_ingredients`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `recipes_per_ingredients` AS SELECT 
 1 AS `name`,
 1 AS `url`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `rel_ingredients_recipes`
--

DROP TABLE IF EXISTS `rel_ingredients_recipes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rel_ingredients_recipes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_ingredients` int(11) NOT NULL,
  `id_recipes` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ingredients_rel_ingredients_recipes_idx` (`id_ingredients`),
  KEY `recipes_rel_ingredients_recipes_idx` (`id_recipes`),
  CONSTRAINT `ingredients_rel_ingredients_recipes` FOREIGN KEY (`id_ingredients`) REFERENCES `ingredients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recipes_rel_ingredients_recipes` FOREIGN KEY (`id_recipes`) REFERENCES `recipes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rel_ingredients_recipes`
--

LOCK TABLES `rel_ingredients_recipes` WRITE;
/*!40000 ALTER TABLE `rel_ingredients_recipes` DISABLE KEYS */;
INSERT INTO `rel_ingredients_recipes` VALUES (38,1,1),(39,2,2),(40,3,3),(41,4,3),(46,29,33);
/*!40000 ALTER TABLE `rel_ingredients_recipes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sources`
--

DROP TABLE IF EXISTS `sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sources`
--

LOCK TABLES `sources` WRITE;
/*!40000 ALTER TABLE `sources` DISABLE KEYS */;
INSERT INTO `sources` VALUES (27,'CreatiVegan'),(1,'Danza de Fogones'),(2,'Jamarin Vegan Meal');
/*!40000 ALTER TABLE `sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `recipes_per_ingredients`
--

/*!50001 DROP VIEW IF EXISTS `recipes_per_ingredients`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`nell_cooking`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `recipes_per_ingredients` AS select `recipes`.`name` AS `name`,`recipes`.`url` AS `url` from ((`recipes` join `rel_ingredients_recipes` on((`recipes`.`id` = `rel_ingredients_recipes`.`id_recipes`))) join `ingredients` on((`ingredients`.`id` = `rel_ingredients_recipes`.`id_ingredients`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-09-30 13:31:37
