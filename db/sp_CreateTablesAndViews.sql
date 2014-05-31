-- Name: sp_CreateTablesAndViews
-- Description: A stored procedure that creates tables and views
-- Parameters:
-- IN: ENTITY_NAME
-- Usage:
-- CALL SP_CREATE_TABLES_AND_VIEWS(Foo);
-- where Foo is the entity name 
DELIMITER //
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
		SET @fieldKindOfEntityKey = CONCAT('KindOf', @entityName, 'Key');
		SET @fieldKindOfEntityValue = CONCAT('KindOf', @entityName, 'Value');
		-- Set names
		SET NAMES utf8;
		-- Set foreign key checks to off
		SET FOREIGN_KEY_CHECKS = 0;	
		-- KIND OF ENTITY
		START TRANSACTION;
			SELECT CONCAT('Creating Kind of Entity table for: ', @entityName) AS Message;
			-- Drop kind of entity table		
			SET @query = CONCAT('
				DROP TABLE IF EXISTS `' , @tableKindOfEntityName, '`;
			');
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;	
			-- Create kind of entity table
			SET @query = CONCAT('
				CREATE TABLE IF NOT EXISTS `' , @tableKindOfEntityName, '` (
					`' , @fieldPrimaryKeyKindOfEntityID, '` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
					`' , @fieldForeignKeyParentID, '` INT(11) UNSIGNED NOT NULL,
					`' , @fieldKindOfEntityKey, '`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
					`' , @fieldKindOfEntityValue, '`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
					`' , @fieldForeignKeyLanguageID, '` INT(11) UNSIGNED NOT NULL DEFAULT 0,
					`' , @fieldTimeStampCreated, '` DATETIME DEFAULT NULL,
					`' , @fieldTimeStampUpdated, '` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
					PRIMARY KEY (`' , @fieldPrimaryKeyKindOfEntityID, '`),
					FOREIGN KEY (`' , @fieldForeignKeyParentID, '`) REFERENCES `' , @tableKindOfEntityName, '` (`' , @fieldPrimaryKeyKindOfEntityID, '`),
					FOREIGN KEY (`' , @fieldForeignKeyLanguageID, '`) REFERENCES `' , @tableLanguage, '` (`' , @fieldPrimaryKeyLanguageID, '`)
				) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
			');
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			-- Drop entity view		
			SET @query = CONCAT('
				DROP VIEW IF EXISTS `' , @viewKindOfEntityName, '`;
			');
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;		
			-- Create kind of entity view
			SELECT CONCAT('Creating Kind of Entity view for: ', @entityName) AS Message;		
			SET @query = CONCAT('
				CREATE VIEW `' , @viewKindOfEntityName, '` AS
					SELECT `' , @fieldPrimaryKeyKindOfEntityID, '`,		
					`' , @fieldForeignKeyParentID, '`,
					`' , @fieldKindOfEntityKey, '`,
					`' , @fieldKindOfEntityValue, '`,
					`' , @fieldForeignKeyLanguageID, '`,
					`' , @fieldTimeStampCreated, '`,
					`' , @fieldTimeStampUpdated, '`
					FROM ' , @tableKindOfEntityName, ';
			');
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		-- ENTITY
		START TRANSACTION;
			SELECT CONCAT('Creating Entity table for: ', @entityName) AS Message;
			-- Drop entity table		
			SET @query = CONCAT('
				DROP TABLE IF EXISTS `' , @tableEntityName, '`;
			');
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;	
			-- Create entity table
			SET @query = CONCAT('
				CREATE TABLE IF NOT EXISTS `' , @tableEntityName, '` (
					`' , @fieldPrimaryKeyEntityID, '` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
					`' , @fieldForeignKeyParentID, '` INT(11) UNSIGNED NOT NULL,			
					`' , @fieldEntityKey, '`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
					`' , @fieldEntityValue, '`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
					`' , @fieldForeignKeyKindOfEntityID, '` INT(11) UNSIGNED NOT NULL DEFAULT 0,
					`' , @fieldForeignKeyLanguageID, '` INT(11) UNSIGNED NOT NULL DEFAULT 0,			
					`' , @fieldTimeStampCreated, '` DATETIME DEFAULT NULL,
					`' , @fieldTimeStampUpdated, '` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
					PRIMARY KEY (`' , @fieldPrimaryKeyEntityID, '`),
					FOREIGN KEY (`' , @fieldForeignKeyParentID, '`) REFERENCES `' , @tableEntityName, '` (`' , @fieldPrimaryKeyEntityID, '`),					
					FOREIGN KEY (`' , @fieldForeignKeyKindOfEntityID, '`) REFERENCES `' , @tableKindOfEntityName, '` (`' , @fieldPrimaryKeyKindOfEntityID, '`),
					FOREIGN KEY (`' , @fieldForeignKeyLanguageID, '`) REFERENCES `' , @tableLanguage, '` (`' , @fieldPrimaryKeyLanguageID, '`)	
				) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
			');
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			-- Drop entity view		
			SET @query = CONCAT('
				DROP VIEW IF EXISTS `' , @viewEntityName, '`;
			');
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;		
			-- Create entity view
			SELECT CONCAT('Creating Entity view for: ', @entityName) AS Message;
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
		COMMIT;		
		-- Set foreign key checks to on
		SET FOREIGN_KEY_CHECKS = 1;	
	END
//