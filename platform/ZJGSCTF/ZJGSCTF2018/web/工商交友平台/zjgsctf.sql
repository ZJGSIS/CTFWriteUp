# Host: localhost  (Version: 5.5.47)
# Date: 2018-04-17 21:36:50
# Generator: MySQL-Front 5.3  (Build 4.234)

/*!40101 SET NAMES utf8 */;

#
# Structure for table "flag"
#

DROP TABLE IF EXISTS `flag`;
CREATE TABLE `flag` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `flag` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

#
# Data for table "flag"
#

/*!40000 ALTER TABLE `flag` DISABLE KEYS */;
INSERT INTO `flag` VALUES (1,'ZJGSCTF{lovely_sql_LOVELY_GIRL}');
/*!40000 ALTER TABLE `flag` ENABLE KEYS */;

#
# Structure for table "users"
#

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT '',
  `age` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

#
# Data for table "users"
#

/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

CREATE user 'zjgsctf'@'%' IDENTIFIED BY 'zjgsctf233';
GRANT SELECT,INSERT ON zjgsctf.users TO 'zjgsctf'@'%';
GRANT SELECT ON zjgsctf.flag TO 'zjgsctf'@'%';