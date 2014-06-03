-- Name: CreateDatabase
-- Description: An sql statement that creates a database 'bits'
-- ================ CUSTOM CONFIGURATIONS ======================================
SET @databaseName ='bits'; -- 'bits' is mandatory
SET @databaseSimpleEntities = '"Entity","Language","Individual","Name"'; -- Entity & Language are mandatory
SET @databaseComplexEntities = '"Membership","Whereabouts"'; -- Entities with fields other than the default fields, e.g. Membership
SET @databaseSimpleLinkedEntities = '"Entity-Name","Language-Name","Individual-Name"'; -- e.g. Entity-Name
SET @databaseComplexLinkedEntities = '';
SET @databaseSimpleLinkedEntitiesSeparator = '-';
SET @databaseLanguage = 'English'; -- 'English' is mandatory
-- ================ DO NOT CHANGE ANYTHING BELOW THIS LINE =====================
DROP DATABASE IF EXISTS `bits`;
CREATE DATABASE IF NOT EXISTS `bits` CHARACTER SET 'utf8' COLLATE 'utf8_bin';
-- Name: sp_CreateTablesAndViews
-- Description: A stored procedure that creates tables and views
-- Parameters:
-- IN: ENTITY_NAME
-- Usage:
-- CALL SP_CREATE_TABLES_AND_VIEWS(Foo);
-- where Foo is the entity name 
DELIMITER $$
USE bits; -- from now on all refers to this database
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
	END; $$
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
DROP PROCEDURE IF EXISTS `SP_MAIN`;
CREATE PROCEDURE `SP_MAIN` (IN `DATABASE_NAME` varchar(255) CHARACTER SET 'utf8', IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8')
	BEGIN
	    SET @entityName = ENTITY_NAME;
		-- Create the table that will contain all entities, for which individual tables will be created later on
		CALL `bits`.SP_CREATE_TABLES_AND_VIEWS(@entityName);
		-- Insert all entities
		
/* 		SET @myArrayOfValue = '2,5,2,23,6,';
		SET @myArrayOfValueComplex = '3,17';

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
	
	END; $$
DELIMITER ;	
-- Call stored procedure main, proving it with the database name and entity name
SET @entityName = 'Language';
CALL SP_MAIN(@databaseName, @entityName);
	-- Set names
	SET NAMES utf8;
	-- Set foreign key checks to off
	SET FOREIGN_KEY_CHECKS = 0;	
	SET @tableEntityName = CONCAT('tbl_', @entityName);
	SET @fieldPrimaryKeyEntityID = CONCAT('pk_', @entityName, 'ID');
	SET @valueFieldPrimaryKeyEntityID = 1;
	SET @valueFieldForeignKeyParentID = @valueFieldPrimaryKeyEntityID;	
	SET @valueFieldEntityKey = 'Language';
	SET @valueFieldEntityValue = @databaseLanguage;
	SET @valueForeignKeyKindOfEntityID = 0;
	SET @valueForeignKeyLanguageID = 1;
	SET @valueTimeStampCreated = CAST('0000-00-00 00:00:00' AS DATETIME);
	SET @valueTimeStampUpdated = CAST('0000-00-00 00:00:00' AS DATETIME);
	START TRANSACTION;
		SET @query = CONCAT("
			INSERT INTO `",@databaseName,"`.`",@tableEntityName,"` 
			VALUES(
			 ",@valueFieldPrimaryKeyEntityID,",
			 ",@valueFieldForeignKeyParentID,",
			'",@valueFieldEntityKey,"',
			'",@valueFieldEntityValue,"',
			 ",@valueForeignKeyKindOfEntityID,",
			 ",@valueForeignKeyLanguageID,",
			'",@valueTimeStampCreated,"',
			'",@valueTimeStampUpdated,"');
		");
		SELECT @query AS Message;
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	COMMIT;	
	-- Set foreign key checks to on
	SET FOREIGN_KEY_CHECKS = 1;
-- Create stored procedure that inserts an array of values
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_INSERT_ARRAY_OF_VALUES`;
CREATE PROCEDURE `SP_INSERT_ARRAY_OF_VALUES` (IN `DATABASE_NAME` varchar(255) CHARACTER SET 'utf8', IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8', IN `VALUE_FIELD_ENTITY_KEY` varchar(255) CHARACTER SET 'utf8', IN `VALUE_FIELD_ENTITY_VALUE_ARRAY` varchar(255) CHARACTER SET 'utf8', IN `VALUE_FIELD_ENTITY_VALUE_ARRAY_SEPARATOR` varchar(1) CHARACTER SET 'utf8')
	BEGIN
		SET @separator = VALUE_FIELD_ENTITY_VALUE_ARRAY_SEPARATOR;
        SET @separatorLength = CHAR_LENGTH(@separator);
		SET @entityName = ENTITY_NAME;
		SET @databaseName = DATABASE_NAME;
		SET @tableEntityName = CONCAT('tbl_', @entityName);
		SET @fieldPrimaryKeyEntityID = CONCAT('pk_', @entityName, 'ID');
		SET @valueFieldPrimaryKeyEntityID = 1;
		SET @valueFieldForeignKeyParentID = @valueFieldPrimaryKeyEntityID;	
		SET @valueFieldEntityKey = VALUE_FIELD_ENTITY_KEY;
		SET @valueFieldEntityValueArray = CONCAT(VALUE_FIELD_ENTITY_VALUE_ARRAY, @separator); -- LOCATE requires the array to end with a separator
		SET @valueForeignKeyKindOfEntityID = 0;
		SET @valueForeignKeyLanguageID = 1;
		SET @valueTimeStampCreated = CAST('0000-00-00 00:00:00' AS DATETIME);
		SET @valueTimeStampUpdated = CAST('0000-00-00 00:00:00' AS DATETIME);
		SET NAMES utf8;
		SET FOREIGN_KEY_CHECKS = 0;	
		WHILE (LOCATE(@separator, @valueFieldEntityValueArray) > 0) DO
			SET @valueFieldEntityValue = SUBSTRING_INDEX(@valueFieldEntityValueArray, @separator, 1);
			SET @valueFieldEntityValue = REPLACE(@valueFieldEntityValue,'"',''); -- removes double quotes
			SET @valueFieldEntityValueArray = SUBSTRING(@valueFieldEntityValueArray, LOCATE(@separator,@valueFieldEntityValueArray) + 1);
			START TRANSACTION;
				SET @query = CONCAT("
					INSERT INTO `",@databaseName,"`.`",@tableEntityName,"` 
					VALUES(
					 ",@valueFieldPrimaryKeyEntityID,",
					 ",@valueFieldForeignKeyParentID,",
					'",@valueFieldEntityKey,"',
					'",@valueFieldEntityValue,"',
					 ",@valueForeignKeyKindOfEntityID,",
					 ",@valueForeignKeyLanguageID,",
					'",@valueTimeStampCreated,"',
					'",@valueTimeStampUpdated,"');
				");
				SELECT @query AS Message;
				PREPARE stmt FROM @query;
				EXECUTE stmt;
				DEALLOCATE PREPARE stmt;
			COMMIT;
			SET @valueFieldPrimaryKeyEntityID = @valueFieldPrimaryKeyEntityID + 1;
			SET @valueFieldForeignKeyParentID = @valueFieldPrimaryKeyEntityID;
		END WHILE;
		SET FOREIGN_KEY_CHECKS = 1;
	END; $$
DELIMITER ;
-- Call stored procedure main, proving it with the database name and entity name	
SET @entityName = 'Entity';
CALL SP_MAIN(@databaseName, @entityName);
-- Set values for entity table, then call stored procedure insert array of values, providing it with the key and array of values
SET @valueFieldEntityKey = 'Entity';
SET @valueFieldEntityValueArray = @databaseSimpleEntities;
SET @valueFieldEntityValueArraySeparator = ',';
CALL `bits`.SP_INSERT_ARRAY_OF_VALUES(@databaseName, @entityName, @valueFieldEntityKey, @valueFieldEntityValueArray, @valueFieldEntityValueArraySeparator);
-- Create a stored procedure that creates tables based on the entity names stored in tbl_entity.EntityValue
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_LOOP_FIELD_CALL_CREATE_TABLES_AND_VIEWS`;
CREATE PROCEDURE `SP_LOOP_FIELD_CALL_CREATE_TABLES_AND_VIEWS` (IN `DATABASE_NAME` varchar(255) CHARACTER SET 'utf8', IN `TABLE_NAME` varchar(255) CHARACTER SET 'utf8', IN `FIELD_KEY_NAME` varchar(255) CHARACTER SET 'utf8', IN `KEY_VALUE` varchar(255) CHARACTER SET 'utf8', IN `FIELD_VALUE_NAME` varchar(255) CHARACTER SET 'utf8')
	BEGIN
		DECLARE findFinished INTEGER DEFAULT 0;
		DECLARE fieldValue varchar(255) DEFAULT "";
		-- Declare cursor for field value
		DECLARE fieldValueCursor CURSOR FOR
			SELECT `EntityValue` FROM `bits`.`tbl_entity` WHERE `EntityKey` = 'Entity';	
		-- Declare NOT FOUND handler
		DECLARE CONTINUE HANDLER 
			FOR NOT FOUND SET findFinished = 1;	
		OPEN fieldValueCursor;
		getFieldValue: LOOP
			FETCH fieldValueCursor INTO fieldValue;
			IF findFinished = 1 THEN 
				LEAVE getFieldValue;
			END IF;
			SELECT CONCAT('Found: ', fieldValue) AS Message_FieldValue;
			SET @entityName = fieldValue;
			CASE  
				WHEN @entityName = 'Entity' THEN     
					SELECT CONCAT('Skipping: ', @entityName) AS Message;
				WHEN @entityName = 'Language' THEN
					SELECT CONCAT('Skipping: ', @entityName) AS Message; 
				ELSE CALL `bits`.SP_CREATE_TABLES_AND_VIEWS(@entityName);
			END CASE;
		END LOOP getFieldValue;
		CLOSE fieldValueCursor;
	END; $$
DELIMITER ;
-- Call stored procedure loop field call create tables and views, 
-- proving it with the database name, table name, 
SET @tableName = 'tbl_entity';
SET @fieldKeyName = 'EntityKey';
SET @keyValue = 'Entity';
SET @fieldValueName = 'EntityValue';
CALL SP_LOOP_FIELD_CALL_CREATE_TABLES_AND_VIEWS(@databaseName, @tableName, @fieldKeyName, @keyValue, @fieldValueName);
-- By now all simple entity tables and views should have been created (excluding link tables)
-- Create procedure create link tables
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS`;
CREATE PROCEDURE `SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS` (IN `LINKED_ENTITIES_NAMES` varchar(255) CHARACTER SET 'utf8', IN `LINKED_ENTITIES_NAMES_SEPARATOR` varchar(255) CHARACTER SET 'utf8')
	BEGIN
		SET @linkedEntitiesNames = LINKED_ENTITIES_NAMES;
		SET @separator = LINKED_ENTITIES_NAMES_SEPARATOR;
		SET @firstEntityName = SUBSTRING_INDEX(@linkedEntitiesNames, @separator, 1);
		SET @secondEntityName = REPLACE(@linkedEntitiesNames,CONCAT(@firstEntityName, @separator),'');
		SELECT @firstEntityName AS Message_FirstEntityName;
		SELECT @secondEntityName AS Message_SecondEntityName;
		SET @tableLinkedEntitiesNames = CONCAT('tbl_', @firstEntityName, '_',  @secondEntityName);
		SET @fieldPrimaryKeyLinkedEntitiesID = CONCAT('pk_', @firstEntityName, @secondEntityName, 'ID');
		SET @fieldForeignKeyFirstEntityID = CONCAT('fk_', @firstEntityName, 'ID');
		SET @fieldForeignKeySecondEntityID = CONCAT('fk_', @secondEntityName, 'ID');
		SET @fieldTimeStampCreated = 'ts_Created';
		SET @fieldTimeStampUpdated = 'ts_Updated';
		SET @tableFirstEntityName = CONCAT('tbl_', @firstEntityName);
		SET @tableSecondEntityName = CONCAT('tbl_', @secondEntityName);
		SET @viewLinkedEntitiesNames = CONCAT(@firstEntityName, '_', @secondEntityName);
		SET @fieldPrimaryKeyFirstEntityID = CONCAT('pk_', @firstEntityName, 'ID');
		SET @fieldPrimaryKeySecondEntityID = CONCAT('pk_', @secondEntityName, 'ID');
		-- Set names
		SET NAMES utf8;
		-- Set foreign key checks to off
		SET FOREIGN_KEY_CHECKS = 0;	
		-- LINKED ENTITIES
		START TRANSACTION;
			SELECT CONCAT('Creating Linked Entities table for: ', @linkedEntitiesNames) AS Message;
			-- Drop entity table		
			SET @query = CONCAT('
				DROP TABLE IF EXISTS `' , @tableLinkedEntitiesNames, '`;
			');
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;	
			-- Create linked entities table
			SET @query = CONCAT('
				CREATE TABLE IF NOT EXISTS `' , @tableLinkedEntitiesNames, '` (
					`' , @fieldPrimaryKeyLinkedEntitiesID, '` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
					`' , @fieldForeignKeyFirstEntityID, '` INT(11) UNSIGNED NOT NULL,
					`' , @fieldForeignKeySecondEntityID, '` INT(11) UNSIGNED NOT NULL,			
					`' , @fieldTimeStampCreated, '` DATETIME DEFAULT NULL,
					`' , @fieldTimeStampUpdated, '` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
					PRIMARY KEY (`' , @fieldPrimaryKeyLinkedEntitiesID, '`),
					FOREIGN KEY (`' , @fieldForeignKeyFirstEntityID, '`) REFERENCES `' , @tableFirstEntityName, '` (`' , @fieldPrimaryKeyFirstEntityID, '`) ON DELETE CASCADE,
					FOREIGN KEY (`' , @fieldForeignKeySecondEntityID, '`) REFERENCES `' , @tableSecondEntityName, '` (`' , @fieldPrimaryKeySecondEntityID, '`) ON DELETE CASCADE					
				) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
			');
			SELECT CONCAT(@query) AS Message;			
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			-- Drop linked entities view
			SET @query = CONCAT('
				DROP VIEW IF EXISTS `' , @viewLinkedEntitiesNames, '`;
			');
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			-- Create entity view
			SELECT CONCAT('Creating Linked Entities view for: ', @linkedEntitiesNames) AS Message;
			SET @query = CONCAT('
				CREATE VIEW `' , @viewLinkedEntitiesNames, '` AS
					SELECT `' , @fieldPrimaryKeyLinkedEntitiesID, '`,		
					`' , @fieldForeignKeyFirstEntityID, '`,
					`' , @fieldForeignKeySecondEntityID, '`,
					`' , @fieldTimeStampCreated, '`,
					`' , @fieldTimeStampUpdated, '`
					FROM ' , @tableLinkedEntitiesNames, ';
			');
			SELECT CONCAT(@query) AS Message;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		-- Set foreign key checks to on
		SET FOREIGN_KEY_CHECKS = 1;	
	END; $$
DELIMITER ;
-- Create the split string function
DELIMITER $$
DROP FUNCTION IF EXISTS `FN_SPLIT_STRING`;
CREATE FUNCTION `FN_SPLIT_STRING` (str VARCHAR(255), delim VARCHAR(12), pos INT)
	RETURNS VARCHAR(255)
	BEGIN
		RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(str, delim, pos),
		LENGTH(SUBSTRING_INDEX(str, delim, pos -1)) + 1),
		delim, '');
	END; $$
DELIMITER ;
-- Create procedure create multiple linked entities tables, for each entry in @databaseSimpleLinkedEntities
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_CREATE_MULTIPLE_LINKED_TABLES_AND_LINKED_VIEWS`;
CREATE PROCEDURE `SP_CREATE_MULTIPLE_LINKED_TABLES_AND_LINKED_VIEWS` (IN `MULTIPLE_LINKED_ENTITIES_NAMES` varchar(255) CHARACTER SET 'utf8', IN `LINKED_ENTITIES_NAMES_SEPARATOR` varchar(255) CHARACTER SET 'utf8')
	BEGIN
		SET @multipleLinkedEntitiesNames = MULTIPLE_LINKED_ENTITIES_NAMES;
		SET @linkedEntitiesNamesSeparator = LINKED_ENTITIES_NAMES_SEPARATOR;
		SET @counter = 1;
		WHILE (@counter > 0) DO
			SET @delimiter = ',';
			SET @linkedEntitiesNames = SELECT FN_SPLIT_STRING(@multipleLinkedEntitiesNames, @delimiter, @counter);
			
		--	SET @linkedEntitiesNames = ''; -- TEMP, for testing only!!
			
			IF @linkedEntitiesNames = '' THEN
				SET @counter = 0;
			ELSE
				-- to do: CALL SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS(@linkedEntitiesNames, @linkedEntitiesNamesSeparator)
				SET @counter = @counter + 1;
			END IF;
		END WHILE;
	END; $$
DELIMITER ;
-- Call procedure create multiple linked entities tables, for complete @databaseSimpleLinkedEntities and @databaseSimpleLinkedEntitiesSeparator
SET @multipleLinkedEntitiesNames = @databaseSimpleLinkedEntities;
SET @linkedEntitiesNamesSeparator = @databaseSimpleLinkedEntitiesSeparator;
CALL SP_CREATE_MULTIPLE_LINKED_TABLES_AND_LINKED_VIEWS(@multipleLinkedEntitiesNames, @linkedEntitiesNamesSeparator);

