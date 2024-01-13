CREATE TABLE IF NOT EXISTS `crafting` (
  `job` varchar(45) NOT NULL,
  `unlocked_recipes` longtext DEFAULT '[]',
  `level` int(11) DEFAULT 1,
  `experience` int(11) DEFAULT 0,
  `actions` int(11) DEFAULT 0,
  PRIMARY KEY (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
