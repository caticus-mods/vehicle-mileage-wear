
CREATE TABLE IF NOT EXISTS `calticus_mileage` (
  `plate` varchar(50) NOT NULL,
  `miles` float NOT NULL DEFAULT 0,
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


