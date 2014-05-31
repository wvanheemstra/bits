-- Name: sp_CreateTablesAndViews
-- Description: A stored procedure that creates tables and views
-- Parameters:
-- IN: ENTITY_NAME
-- Usage:
-- CALL SP_CREATE_TABLES_AND_VIEWS(Foo);
-- where Foo is the entity name 
delimiter //
DROP PROCEDURE IF EXISTS `SP_CREATE_TABLES_AND_VIEWS`;
CREATE PROCEDURE `SP_CREATE_TABLES_AND_VIEWS` (IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8')
	BEGIN
		SET @entityName = ENTITY_NAME;
		SET @tableName = CONCAT('tbl_', @entityName);
		SET @tablePrimaryKey = CONCAT('kp_', @entityName, 'ID');
		SET @tableEntityKey = CONCAT(@entityName, 'Key');
		SET @tableEntityValue = CONCAT(@entityName, 'Value');
		SET @tableTimeStampCreated = 'ts_Created';
		SET @tableTimeStampUpdated = 'ts_Updated';
		SET @viewName = @entityName;		
		-- Drop table		
		SET @query = CONCAT('
			DROP TABLE IF EXISTS `' , @tableName, '`;
		');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		-- Set names
		SET NAMES utf8;
		-- Set foreign key checks to off
		SET FOREIGN_KEY_CHECKS = 0;		
		-- Create table
		SET @query = CONCAT('
			CREATE TABLE IF NOT EXISTS `' , @tableName, '` (
				`' , @tablePrimaryKey, '` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`' , @tableEntityKey, '`  varchar(255) COLLATE utf8_bin NOT NULL,
				`' , @tableEntityValue, '`  varchar(255) COLLATE utf8_bin NOT NULL,
				`' , @tableTimeStampCreated, '` datetime DEFAULT NULL,
				`' , @tableTimeStampUpdated, '` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
				PRIMARY KEY (`' , @tablePrimaryKey, '`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
		');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
-- START: NOT YET SUPPORTED		
--		-- Create trigger
--		SET @query = CONCAT('
--			CREATE TRIGGER `' , @entityName, '.' , @tableTimeStampCreated, '` BEFORE INSERT ON `' , @tableName, '` FOR EACH ROW BEGIN
--				SET NEW.' , @tableTimeStampCreated, ' = CURRENT_TIMESTAMP();
--			END;
--		');
--		PREPARE stmt FROM @query;
--		EXECUTE stmt;
--		DEALLOCATE PREPARE stmt;
-- END: NOT YET SUPPORTED			
		-- Set foreign key checks to on
		SET FOREIGN_KEY_CHECKS = 1;	
		-- Drop view		
		SET @query = CONCAT('
			DROP VIEW IF EXISTS `' , @viewName, '`;
		');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;		
		-- Create view
		SET @query = CONCAT('
			CREATE VIEW `' , @viewName, '` AS
				SELECT `' , @tablePrimaryKey, '`,
				`' , @tableEntityKey, '`,
				`' , @tableEntityValue, '`,
				`' , @tableTimeStampCreated, '`,
				`' , @tableTimeStampUpdated, '`
				FROM ' , @tableName, ';
		');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END;
delimiter ;