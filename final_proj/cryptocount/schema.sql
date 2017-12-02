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

INSERT INTO currency (name, ticker) VALUES ("Bitcoin", "BTC");
INSERT INTO currency (name, ticker) VALUES ("Ethereum", "ETH");
INSERT INTO currency (name, ticker) VALUES ("Bitcoin Cash", "BCH");
INSERT INTO currency (name, ticker) VALUES ("Ripple", "XRP");
INSERT INTO currency (name, ticker) VALUES ("Dash", "DASH");
INSERT INTO currency (name, ticker) VALUES ("Litecoin", "LTC");
INSERT INTO currency (name, ticker) VALUES ("Monero", "XMR");
INSERT INTO currency (name, ticker) VALUES ("Zcash", "ZEC");

INSERT INTO wallet (name) VALUES ("Ledger Nano S Hardware Wallet");
INSERT INTO wallet (name) VALUES ("Trezor Hardware Wallet");
INSERT INTO wallet (name) VALUES ("GDAX Exchange Wallet");

INSERT INTO contact (name, type) VALUES ("Bob Smith", "person");
INSERT INTO contact (name, type) VALUES ("Alice Johnson", "person");
INSERT INTO contact (name, type) VALUES ("GDAX", "exchange");
INSERT INTO contact (name, type) VALUES ("Poloniex", "exchange");
INSERT INTO contact (name, type) VALUES ("Overstock", "retailer");
INSERT INTO contact (name, type) VALUES ("Steam", "retailer");

INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (1,4,4,240000., "2017-11-01", "Bought Ripple from Poloniex exchange");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (1,5,4,10., "2017-11-02", "Bought Dash from Poloniex exchange");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (1,8,1,17., "2017-11-03", "Received ZCash for sale of Goods ");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (2,1,2,2.0, "2017-11-02", "Sold some stuff");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (2,1,5,1.3, "2017-11-02", "Bought Christmas presents");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (2,1,6,0.59, "2017-11-03", "Bought video game");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,1,3,100.0, "2017-11-01", "Bought Bitcoin");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,1,3,-20., "2017-11-02", "Sold Bitcoin");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,1,3,150., "2017-11-03", "Bought Bitcoin");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,1,3,50., "2017-11-04", "Bought Bitcoin ");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,1,3,-200., "2017-11-05", "Sold Bitcoin");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,1,3,100., "2017-11-06", "Bought Bitcoin");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,6,3,1000.0, "2017-11-02", "Bought Litecoin");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,6,3,-200., "2017-11-03", "Sold Litecoin");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,6,3,1500., "2017-11-04", "Bought Litecoin");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,6,3,500., "2017-11-05", "Bought Litecoin ");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,6,3,-2000., "2017-11-06", "Sold Litecoin");
INSERT INTO transaction (wid, curid, contid, amount, date, notes) VALUES (3,6,3,1000., "2017-11-07", "Bought Litecoin");

INSERT INTO wallet_currency (wid, cid, amount) VALUES (1,4,240000.00);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (1,5,10.00);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (1,8,17.00);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (2,1,0.110);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (3,1,180.00);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (3,2,0.00);
INSERT INTO wallet_currency (wid, cid, amount) VALUES (3,6,1800.00);
