DROP TABLE IF EXISTS `transaction`;
DROP TABLE IF EXISTS `wallet_currency`;
DROP TABLE IF EXISTS `wallet`;
DROP TABLE IF EXISTS `contact`;
DROP TABLE IF EXISTS `currency`;

CREATE TABLE `currency` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `ticker` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`ticker`),
  UNIQUE (`name`)
) ENGINE=InnoDB;


CREATE TABLE `contact` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `type` varchar(255),          -- (person, retailer, exchange)
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;


CREATE TABLE `wallet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`name`)
) ENGINE=InnoDB;


CREATE TABLE `wallet_currency` (
  `wid` int(11) NOT NULL,
  `cid` int(11) NOT NULL,
  `amount` DECIMAL(16,8) NOT NULL,
  PRIMARY KEY (`wid`, `cid`),
  FOREIGN KEY (`wid`) REFERENCES `wallet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`cid`) REFERENCES `currency` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE `transaction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `curid` int(11) NOT NULL,
  `wid` int(11) NOT NULL,
  `contid` int(11) NOT NULL,
  `date` date NOT NULL,
  `amount` DECIMAL(16,8) NOT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`wid`) REFERENCES `wallet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`curid`) REFERENCES `currency` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`contid`) REFERENCES `contact` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

LOAD DATA LOCAL INFILE 'data/currency.csv' INTO TABLE currency
    FIELDS TERMINATED BY ',' 
    IGNORE 1 LINES
    (`name`,`ticker`);

LOAD DATA LOCAL INFILE 'data/wallet.csv' INTO TABLE wallet
    FIELDS TERMINATED BY ',' 
    IGNORE 1 LINES
    (`name`);

LOAD DATA LOCAL INFILE 'data/contact.csv' INTO TABLE contact
    FIELDS TERMINATED BY ',' 
    IGNORE 1 LINES
    (`name`,`type`);

LOAD DATA LOCAL INFILE 'data/transaction.csv' INTO TABLE transaction
    FIELDS TERMINATED BY ',' 
    IGNORE 1 LINES
    (`wid`, `curid`, `contid`, `amount`, `date`,`notes`);

LOAD DATA LOCAL INFILE 'data/wallet_currency.csv' INTO TABLE wallet_currency
    FIELDS TERMINATED BY ',' 
    IGNORE 1 LINES
    (`wid`, `cid`, `amount`);
