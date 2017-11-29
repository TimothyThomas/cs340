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
  `type` varchar(255),          -- (person, business, exchange)
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;


-- name - nickname for the wallet, a varchar of maximum length 255, cannot be null
CREATE TABLE `wallet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`name`)
) ENGINE=InnoDB;


-- wid - an integer which is a foreign key reference to wallet
-- cid - an integer which is a foreign key reference to currency
-- amount - amount of currency in the wallet, a decimal value with 8 digits before/after the decimal
-- The primary key is a combination of wid and cid
CREATE TABLE `wallet_currency` (
  `wid` int(11) NOT NULL,
  `cid` int(11) NOT NULL,
  `amount` DECIMAL(16,8) NOT NULL,
  PRIMARY KEY (`wid`, `cid`),
  FOREIGN KEY (`wid`) REFERENCES `wallet` (`id`),
  FOREIGN KEY (`cid`) REFERENCES `currency` (`id`)
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
  FOREIGN KEY (`wid`) REFERENCES `wallet` (`id`),
  FOREIGN KEY (`curid`) REFERENCES `currency` (`id`),
  FOREIGN KEY (`contid`) REFERENCES `contact` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

LOAD DATA LOCAL INFILE 'currency.csv' INTO TABLE currency
    FIELDS TERMINATED BY ',' 
    IGNORE 1 LINES
    (`name`,`ticker`);

LOAD DATA LOCAL INFILE 'contact.csv' INTO TABLE contact
    FIELDS TERMINATED BY ',' 
    IGNORE 1 LINES
    (`name`,`type`);


INSERT INTO wallet (name) VALUES ('Ledger Nano S');
INSERT INTO wallet (name) VALUES ('GDAX Wallet');
INSERT INTO wallet (name) VALUES ('Trezor');
INSERT INTO wallet (name) VALUES ('Exchange');

LOAD DATA LOCAL INFILE 'transaction.csv' INTO TABLE transaction
    FIELDS TERMINATED BY ',' 
    IGNORE 1 LINES
    (`date`,`curid`,`amount`,`contid`,`wid`,`notes`);

-- the wallet_currency table should have an intial value input by the user
-- and gets updated with each transaction
INSERT INTO wallet_currency (wid, cid, amount) VALUES (1,1,25.0);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (2,1,25.0);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (1,2,5.12345678);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (2,2,5.12345678);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (1,3,99.0);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (2,3,99.0);


select * from currency;
select * from contact;
select * from wallet;
select * from transaction;
select * from wallet_currency;
