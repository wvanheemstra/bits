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
		SET @tableEntityName = CONCAT('tbl_', @entityName);
		SET @tablePrimaryKeyEntityID = CONCAT('kp_', @entityName, 'ID');
		SET @tableEntityKey = CONCAT(@entityName, 'Key');
		SET @tableEntityValue = CONCAT(@entityName, 'Value');
		SET @tableForeignKeyKindOfEntityID = CONCAT('kf_KindOf', @entityName, 'ID');
		SET @tableForeignKeyLanguageID = CONCAT('kf_LanguageID');	
		SET @tableTimeStampCreated = 'ts_Created';
		SET @tableTimeStampUpdated = 'ts_Updated';
		SET @tableKindOfEntityName = CONCAT('tbl_kind_of_', @entityName);
		SET @tablePrimaryKeyKindOfEntityID = CONCAT('kp_KindOf', @entityName, 'ID');		
		SET @viewEntityName = @entityName;
		SET @viewKindOfEntityName = CONCAT('kind_of_', @entityName);		
		-- Drop table		
		SET @query = CONCAT('
			DROP TABLE IF EXISTS `' , @tableEntityName, '`;
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
			CREATE TABLE IF NOT EXISTS `' , @tableEntityName, '` (
				`' , @tablePrimaryKeyEntityID, '` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`' , @tableEntityKey, '`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
				`' , @tableEntityValue, '`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
				`' , @tableForeignKeyKindOfEntityID, '` INT(11) NOT NULL DEFAULT 0,		
				`' , @tableTimeStampCreated, '` DATETIME DEFAULT NULL,
				`' , @tableTimeStampUpdated, '` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
				PRIMARY KEY (`' , @tablePrimaryKeyEntityID, '`),
				FOREIGN KEY (`' , @tableForeignKeyKindOfEntityID, '`) REFERENCES `' , @tableKindOfEntityName, '` (`' , @tablePrimaryKeyKindOfEntityID, '`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
		');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
-- START: NOT YET SUPPORTED		
--		-- Create trigger
--		SET @query = CONCAT('
--			CREATE TRIGGER `' , @entityName, '.' , @tableTimeStampCreated, '` BEFORE INSERT ON `' , @tableEntityName, '` FOR EACH ROW BEGIN
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
			DROP VIEW IF EXISTS `' , @viewEntityName, '`;
		');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;		
		-- Create view
		SET @query = CONCAT('
			CREATE VIEW `' , @viewEntityName, '` AS
				SELECT `' , @tablePrimaryKeyEntityID, '`,
				`' , @tableEntityKey, '`,
				`' , @tableEntityValue, '`,
				`' , @tableForeignKeyKindOfEntityID, '`,			
				`' , @tableTimeStampCreated, '`,
				`' , @tableTimeStampUpdated, '`
				FROM ' , @tableEntityName, ';
		');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END;
delimiter ;