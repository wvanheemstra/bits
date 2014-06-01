-- Name: CreateDatabase
-- Description: An sql statement that creates a database 'bits' 
SET @DATABASE_NAME ="bits";
DROP DATABASE IF EXISTS `bits`;
CREATE DATABASE IF NOT EXISTS `bits` 
CHARACTER SET 'utf8'
COLLATE 'utf8_bin';
-- Name: sp_CreateTablesAndViews
-- Description: A stored procedure that creates tables and views
-- Parameters:
-- IN: ENTITY_NAME
-- Usage:
-- CALL SP_CREATE_TABLES_AND_VIEWS(Foo);
-- where Foo is the entity name 
DELIMITER $$
DROP PROCEDURE IF EXISTS `bits`.`SP_CREATE_TABLES_AND_VIEWS`;
CREATE PROCEDURE `bits`.`SP_CREATE_TABLES_AND_VIEWS` (IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8')
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
					FOREIGN KEY (`' , @fieldForeignKeyParentID, '`) REFERENCES `' , @tableKindOfEntityName, '` (`' , @fieldPrimaryKeyKindOfEntityID, '`) ON DELETE CASCADE,
					FOREIGN KEY (`' , @fieldForeignKeyLanguageID, '`) REFERENCES `' , @tableLanguage, '` (`' , @fieldPrimaryKeyLanguageID, '`) ON DELETE CASCADE
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
					FOREIGN KEY (`' , @fieldForeignKeyParentID, '`) REFERENCES `' , @tableEntityName, '` (`' , @fieldPrimaryKeyEntityID, '`) ON DELETE CASCADE,					
					FOREIGN KEY (`' , @fieldForeignKeyKindOfEntityID, '`) REFERENCES `' , @tableKindOfEntityName, '` (`' , @fieldPrimaryKeyKindOfEntityID, '`),
					FOREIGN KEY (`' , @fieldForeignKeyLanguageID, '`) REFERENCES `' , @tableLanguage, '` (`' , @fieldPrimaryKeyLanguageID, '`) ON DELETE CASCADE	
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
	END $$
DELIMITER ;
-- Name: sp_Main
-- Description: A stored procedure that contains the main procedures, 
-- run this first after having created the empty database and required stored procedures
-- Parameters:
-- IN: DATABASE_NAME, ENTITY_NAME
-- Usage:
-- CALL SP_MAIN(Foo, Bar);
-- where Foo is the database name
-- and Bar is the entity name 
DELIMITER $$
DROP PROCEDURE IF EXISTS `bits`.`SP_MAIN`;
CREATE PROCEDURE `bits`.`SP_MAIN` (IN `DATABASE_NAME` varchar(255) CHARACTER SET 'utf8', IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8')
	BEGIN
		-- Create the table that will contain all entities, for which individual tables will be created later on
		CALL `bits`.SP_CREATE_TABLES_AND_VIEWS(@ENTITY_NAME);
		-- Insert all entities
		
/* 		SET @myArrayOfValue = '2,5,2,23,6,';
		SET @myArrayOfValueCOmplex = '3,17';

		INSERT INTO `bits`.`tbl_kind_of_entity` VALUES(1,1,'Kind of Entity','Simple', 0, '', '');
		INSERT INTO `bits`.`tbl_kind_of_entity` VALUES(2,2,'Kind of Entity','Complex', 0, '', '');
		
		WHILE (LOCATE(',', @myArrayOfValue) > 0)
		DO
			SET @value = ELT(1, @myArrayOfValue);
			SET @value = SUBSTRING(@myArrayOfValue, LOCATE(',',@myArrayOfValue) + 1);
			SET @count = 1;
			INSERT INTO `bits`.`tbl_entity` VALUES(@count,@count,'Entity',@value, 1, 0, '', '');
			SET @count = @count + 1;
		END WHILE; */
		
		
		-- TO DO
	
	END $$
DELIMITER ;	
-- Call stored procedure main, proving it with the database name and entity name
SET @ENTITY_NAME = 'Language';
CALL `bits`.SP_MAIN(@DATABASE_NAME, @ENTITY_NAME);
	-- Set names
	SET NAMES utf8;
	-- Set foreign key checks to off
	SET FOREIGN_KEY_CHECKS = 0;	
	SET @entityName = @ENTITY_NAME;
	SET @databaseName = @DATABASE_NAME;
	SET @tableEntityName = CONCAT('tbl_', @entityName);
	SET @fieldPrimaryKeyEntityID = CONCAT('pk_', @entityName, 'ID');
	SET @valueFieldPrimaryKeyEntityID = 1;
	SET @valueFieldForeignKeyParentID = @valueFieldPrimaryKeyEntityID;	
	SET @valueFieldEntityKey = 'Language';
	SET @valueFieldEntityValue = 'English';
	SET @valueForeignKeyKindOfEntityID = 0;
	SET @valueForeignKeyLanguageID = 1;
	SET @valueTimeStampCreated = CAST('0000-00-00 00:00:00' AS DATETIME);
	SET @valueTimeStampUpdated = CAST('0000-00-00 00:00:00' AS DATETIME);
	START TRANSACTION;
		SET @query = CONCAT('
			INSERT INTO `',@databaseName,'`.`',@tableEntityName,'` 
			VALUES(
			 ',@valueFieldPrimaryKeyEntityID,',
			 ',@valueFieldForeignKeyParentID,',
			"',@valueFieldEntityKey,'",
			"',@valueFieldEntityValue,'",
			 ',@valueForeignKeyKindOfEntityID,',
			 ',@valueForeignKeyLanguageID,',
			"',@valueTimeStampCreated,'",
			"',@valueTimeStampUpdated,'");
		');
		SELECT @query AS Message;
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	COMMIT;	
	-- Set foreign key checks to on
	SET FOREIGN_KEY_CHECKS = 1;
-- Create stored procedure that inserts an array of values
DELIMITER $$
DROP PROCEDURE IF EXISTS `bits`.`SP_INSERT_ARRAY_OF_VALUES`;
CREATE PROCEDURE `bits`.`SP_INSERT_ARRAY_OF_VALUES` (IN `DATABASE_NAME` varchar(255) CHARACTER SET 'utf8', IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8', IN `VALUE_FIELD_ENTITY_KEY` varchar(255) CHARACTER SET 'utf8', IN `VALUE_FIELD_ENTITY_VALUE_ARRAY` varchar(255) CHARACTER SET 'utf8')
	BEGIN
		SET @entityName = @ENTITY_NAME;
		SET @databaseName = @DATABASE_NAME;
		SET @tableEntityName = CONCAT('tbl_', @entityName);
		SET @fieldPrimaryKeyEntityID = CONCAT('pk_', @entityName, 'ID');
		SET @valueFieldPrimaryKeyEntityID = 1;
		SET @valueFieldForeignKeyParentID = @valueFieldPrimaryKeyEntityID;	
		SET @valueFieldEntityKey = @VALUE_FIELD_ENTITY_KEY;
		SET @valueFieldEntityValueArray = @VALUE_FIELD_ENTITY_VALUE_ARRAY;
		SET @valueForeignKeyKindOfEntityID = 0;
		SET @valueForeignKeyLanguageID = 1;
		SET @valueTimeStampCreated = CAST('0000-00-00 00:00:00' AS DATETIME);
		SET @valueTimeStampUpdated = CAST('0000-00-00 00:00:00' AS DATETIME);
		SET NAMES utf8;
		SET FOREIGN_KEY_CHECKS = 0;	
		SET @iterator = 5; -- Make this actually a count of the number of items in the entity value array
		WHILE @iterator > 0 DO
		    -- NOTE: For some reason variables are not being recognized, 
			-- also apparently variables within a while loop should not start with an @
			START TRANSACTION;
				SET @query = CONCAT('
					INSERT INTO `',@databaseName,'`.`',@tableEntityName,'` 
					VALUES(
					 ',@valueFieldPrimaryKeyEntityID,',
					 ',@valueFieldForeignKeyParentID,',
					"',@valueFieldEntityKey,'",
					"',@valueFieldEntityValue,'",
					 ',@valueForeignKeyKindOfEntityID,',
					 ',@valueForeignKeyLanguageID,',
					"',@valueTimeStampCreated,'",
					"',@valueTimeStampUpdated,'");
				');
				SELECT @query AS Message;
				PREPARE stmt FROM @query;
				EXECUTE stmt;
				DEALLOCATE PREPARE stmt;
			COMMIT;
			SET @valueFieldPrimaryKeyEntityID = @valueFieldPrimaryKeyEntityID + 1;
			SET @valueFieldForeignKeyParentID = @valueFieldPrimaryKeyEntityID;

			SET @iterator = @iterator - 1;
		END WHILE;
		SET FOREIGN_KEY_CHECKS = 1;
	END $$
DELIMITER ;
-- Call stored procedure main, proving it with the database name and entity name	
SET @ENTITY_NAME = 'Entity';
CALL `bits`.SP_MAIN(@DATABASE_NAME, @ENTITY_NAME);
-- Set values for entity table, then call stored procedure insert array of values, providing it with the key and array of values
SET @VALUE_FIELD_ENTITY_KEY = 'Entity';
SET @VALUE_FIELD_ENTITY_VALUE_ARRAY = 'Entity|Language|Individual|Name';
CALL `bits`.SP_INSERT_ARRAY_OF_VALUES(@DATABASE_NAME, @ENTITY_NAME, @VALUE_FIELD_ENTITY_KEY, @VALUE_FIELD_ENTITY_VALUE_ARRAY);

	
/*	
	SET @separator = '|';
	SET @separatorLength = CHAR_LENGTH(@separator);
	
	DECLARE i INT DEFAULT 1;
	
	WHILE (i<=2) DO
		SET @valueFieldEntityValue = SUBSTRING_INDEX(@valueFieldEntityValueArray, @separator, 1);
		
		-- DO WORK
		SELECT @valueFieldEntityValue AS Message_valueFieldEntityValue;
		
		SET @valueFieldEntityValueArray = SUBSTRING(@valueFieldEntityValueArray, CHAR_LENGTH(@valueFieldEntityValue) + @separatorLength + 1);
		SET i=i+1;
	END WHILE;
	
	
	
--	WHILE (@valueFieldEntityValueArray != '') > 0 DO
--		SET @currentValue = SUBSTRING_INDEX(@valueFieldEntityValueArray, @separator, 1);
	 
		-- DO WORK
--		SELECT @currentValue AS Message_CurrentValue;
	 
--		SET @valueFieldEntityValueArray = SUBSTRING(@valueFieldEntityValueArray, CHAR_LENGTH(@currentValue) + @separatorLength + 1);
--	END WHILE;
	
*/	
	
	
/*	
	WHILE (LOCATE('|', @valueFieldEntityValueArray) > 0) DO
	
		SELECT LOCATE('|', @valueFieldEntityValueArray) AS Message_Locate;
	
		SET @valueFieldEntityValue = ELT(1, @valueFieldEntityValueArray);
		
		SELECT @valueFieldEntityValueArray AS Message_valueFieldEntityValueArray;
		SELECT @valueFieldEntityValue AS Message_valueFieldEntityValue;
		
		SET @valueFieldEntityValue = SUBSTRING(@valueFieldEntityValueArray, LOCATE('|',@valueFieldEntityValueArray) + 1);
		START TRANSACTION;
			SET @query = CONCAT('
				INSERT INTO `',@databaseName,'`.`',@tableEntityName,'` 
				VALUES(
				 ',@valueFieldPrimaryKeyEntityID,',
				 ',@valueFieldForeignKeyParentID,',
				"',@valueFieldEntityKey,'",
				"',@valueFieldEntityValue,'",
				 ',@valueForeignKeyKindOfEntityID,',
				 ',@valueForeignKeyLanguageID,',
				"',@valueTimeStampCreated,'",
				"',@valueTimeStampUpdated,'");
			');
			SELECT @query AS Message;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		SET @valueFieldPrimaryKeyEntityID = @valueFieldPrimaryKeyEntityID + 1;
		SET @valueFieldForeignKeyParentID = @valueFieldPrimaryKeyEntityID;
	END WHILE;	
*/	
	
	-- Set foreign key checks to on
--	SET FOREIGN_KEY_CHECKS = 1;