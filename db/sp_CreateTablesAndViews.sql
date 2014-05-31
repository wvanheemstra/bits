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
		SET @fieldPrimaryKeyEntityID = CONCAT('pk_', @entityName, 'ID');
		SET @fieldForeignKeyParentID = 'fk_ParentID';
		SET @fieldEntityKey = CONCAT(@entityName, 'Key');
		SET @fieldEntityValue = CONCAT(@entityName, 'Value');
		SET @fieldForeignKeyKindOfEntityID = CONCAT('fk_KindOf', @entityName, 'ID');
		SET @fieldForeignKeyLanguageID = 'fk_LanguageID';
		SET @fieldTimeStampCreated = 'ts_Created';
		SET @fieldTimeStampUpdated = 'ts_Updated';
		SET @tableKindOfEntityName = CONCAT('tbl_kind_of_', @entityName);
		SET @fieldPrimaryKeyKindOfEntityID = CONCAT('pk_KindOf', @entityName, 'ID');
		SET @fieldPrimaryKeyLanguageID = CONCAT('pk_LanguageID');
		SET @tableLanguage = 'tbl_language';
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
				`' , @fieldPrimaryKeyEntityID, '` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`' , @fieldForeignKeyParentID, '` INT(11) NOT NULL REFERENCES `' , @tableEntityName, '` (`' , @fieldPrimaryKeyEntityID, '`),			
				`' , @fieldEntityKey, '`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
				`' , @fieldEntityValue, '`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
				`' , @fieldForeignKeyKindOfEntityID, '` INT(11) NOT NULL DEFAULT 0,
				`' , @fieldForeignKeyLanguageID, '` INT(11) NOT NULL DEFAULT 0,			
				`' , @fieldTimeStampCreated, '` DATETIME DEFAULT NULL,
				`' , @fieldTimeStampUpdated, '` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
				PRIMARY KEY (`' , @fieldPrimaryKeyEntityID, '`),			
				FOREIGN KEY (`' , @fieldForeignKeyKindOfEntityID, '`) REFERENCES `' , @tableKindOfEntityName, '` (`' , @fieldPrimaryKeyKindOfEntityID, '`),
				FOREIGN KEY (`' , @fieldForeignKeyLanguageID, '`) REFERENCES `' , @tableLanguage, '` (`' , @fieldPrimaryKeyLanguageID, '`)	
			) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
		');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
-- START: NOT YET SUPPORTED		
--		-- Create trigger
--		SET @query = CONCAT('
--			CREATE TRIGGER `' , @entityName, '.' , @fieldTimeStampCreated, '` BEFORE INSERT ON `' , @tableEntityName, '` FOR EACH ROW BEGIN
--				SET NEW.' , @fieldTimeStampCreated, ' = CURRENT_TIMESTAMP();
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
				SELECT `' , @fieldPrimaryKeyEntityID, '`,		
				`' , @fieldForeignKeyParentID, '`,
				`' , @fieldEntityKey, '`,
				`' , @fieldEntityValue, '`,
				`' , @fieldForeignKeyKindOfEntityID, '`,
				`' , @fieldForeignKeyLanguageID, '`,
				`' , @fieldTimeStampCreated, '`,
				`' , @fieldTimeStampUpdated, '`
				FROM ' , @tableEntityName, ';
		');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END;
delimiter ;