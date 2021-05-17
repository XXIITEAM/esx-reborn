CREATE TABLE `owned_vehicles` (
	`id`INT(11) NOT NULL,
	`identifier` VARCHAR(40) NOT NULL,
	`plate` VARCHAR(8) NOT NULL,
	`model` VARCHAR(12) NOT NULL,
	`sell_price` INT(11) NOT NULL,
	`vehicle` LONGTEXT,
	`type` VARCHAR(20) NOT NULL DEFAULT 'car',
	`stored` TINYINT NOT NULL DEFAULT '0',
	`sold` TINYINT NOT NULL DEFAULT '0',
	`container_id` LONGTEXT,

	PRIMARY KEY (`plate`)
);
