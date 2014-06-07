-- Name: CreateDatabase
-- Description: An sql statement that creates a database 'bits'
-- Note: The EntityValue field allows for JSON data, 
--       with a size of maximum 5000 characters
-- ================ CUSTOM CONFIGURATIONS ======================================
SET @databaseName = LOWER('bits'); -- 'bits' is mandatory
SET @databaseSimpleEntities = '"Entity","Language","Schema","Individual","Name"'; -- Entity & Language & Schema are mandatory
SET @databaseComplexEntities = '"Membership","Whereabouts"'; -- Entities with fields other than the default fields, e.g. Membership
SET @databaseSimpleLinkedEntities = '"Entity-Name","Language-Name","Individual-Name"'; -- e.g. Entity-Name
SET @databaseComplexLinkedEntities = '';
SET @databaseSimpleLinkedEntitiesSeparator = '-';
SET @databaseLanguage = 'English'; -- 'English' is mandatory
-- ================ DO NOT CHANGE ANYTHING BELOW THIS LINE =====================
DROP DATABASE IF EXISTS `bits`;
CREATE DATABASE IF NOT EXISTS `bits` CHARACTER SET 'utf8' COLLATE 'utf8_bin';
USE bits; -- from now on all refers to this database
-- Name: SP_UPDATE_SCHEMA
-- Description: A stored procedure that updates the schema table,
-- for creation of a (JSON) Schema from SQL later on
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_UPDATE_SCHEMA`;
CREATE PROCEDURE `SP_UPDATE_SCHEMA` (
		IN `SCHEMA_ID` int(11), 
		IN `PARENT_ID` int(11),  
		IN `SCHEMA_KEY` varchar(255) CHARACTER SET 'utf8',  
		IN `SCHEMA_VALUE` varchar(5000) CHARACTER SET 'utf8',  
		IN `KIND_OF_SCHEMA` varchar(255) CHARACTER SET 'utf8'
	)
	BEGIN
	/*
		-- Set names
		SET NAMES utf8;
		-- Set foreign key checks to off
		SET FOREIGN_KEY_CHECKS = 0;	
		-- LINKED ENTITIES
		START TRANSACTION;
			-- TEMP: placeholder, still to do
			SET @query = CONCAT('
				SELECT * FROM DUAL; 
			');
			SELECT CONCAT(@query) AS Message;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		-- Set foreign key checks to on
		SET FOREIGN_KEY_CHECKS = 1;	
	*/
	END; 
$$
DELIMITER ;
-- Create stored procedure that gets and returns a required field value
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_GET_FIELD_VALUE`;
CREATE PROCEDURE `SP_GET_FIELD_VALUE` (
		IN `TABLE_ENTITY_NAME` varchar(255) CHARACTER SET 'utf8', 
		IN `REQUIRED_FIELD_NAME` varchar(255) CHARACTER SET 'utf8',
		OUT `REQUIRED_FIELD_VALUE` varchar(255) CHARACTER SET 'utf8',
		IN `WHERE_FIELD_NAME` varchar(255) CHARACTER SET 'utf8', 
		IN `WHERE_OPERATOR` varchar(255) CHARACTER SET 'utf8', 
		IN `WHERE_VALUE` varchar(255) CHARACTER SET 'utf8'
	)
	BEGIN
		START TRANSACTION;
			SET @tableEntityName = TABLE_ENTITY_NAME;
			SET @requiredFieldName = REQUIRED_FIELD_NAME;
			-- SET @requiredFieldValue = REQUIRED_FIELD_VALUE;
			SET @whereFieldName = WHERE_FIELD_NAME;
			SET @whereOperator = WHERE_OPERATOR;
			SET @whereValue = WHERE_VALUE;	
			SELECT CONCAT('Getting field value for: ', @requiredFieldName) AS SP_GET_FIELD_VALUE;
			-- Select required field		
			SET @query = CONCAT("
				SELECT `" , @requiredFieldName, "` FROM `", @tableEntityName, "` WHERE `", @whereFieldName, "` ", @whereOperator, " '", @whereValue, "' INTO @REQUIRED_FIELD_VALUE
			");
			SELECT @query AS SP_GET_FIELD_VALUE;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			SELECT @REQUIRED_FIELD_VALUE AS SP_GET_FIELD_VALUE; -- this works !!!
			DEALLOCATE PREPARE stmt;
		COMMIT;
	END; 
$$
DELIMITER ;
-- Create stored procedure to add types to schema
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_ADD_TYPES_TO_SCHEMA`;
CREATE PROCEDURE `SP_ADD_TYPES_TO_SCHEMA` (
		IN `DATABASE_NAME` varchar(255) CHARACTER SET 'utf8',
		IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8',
		IN `ENTITY_TYPE` varchar(255) CHARACTER SET 'utf8',
		IN `VIEW_ENTITY_NAME` varchar(255) CHARACTER SET 'utf8',
		IN `VIEW_KIND_OF_ENTITY_NAME` varchar(255) CHARACTER SET 'utf8',
		IN `TABLE_ENTITY_NAME` varchar(255) CHARACTER SET 'utf8',
		IN `FIELD_PRIMARY_KEY_ENTITY_ID` varchar(255) CHARACTER SET 'utf8',
		IN `SCHEMA_TYPES_ID` int(11)
	)
	BEGIN
		SET @databaseName = DATABASE_NAME;
		SET @entityName = ENTITY_NAME;
		SET @entityType = ENTITY_TYPE;
		SET @viewEntityName = VIEW_ENTITY_NAME;
		SET @viewKindOfEntityName = VIEW_KIND_OF_ENTITY_NAME;
		SET @tableEntityName = TABLE_ENTITY_NAME;
		SET @fieldPrimaryKeyEntityID = FIELD_PRIMARY_KEY_ENTITY_ID;
		SET @schemaTypesID = SCHEMA_TYPES_ID;
		-- Call stored procedure insert into table schema for type: kind of entity
		SELECT CONCAT('Entity for Schema: ', @entityName) AS SP_CREATE_TABLES_AND_VIEWS;
		SET @entityNameTEMP = @entityName; -- safe original value for entity name
		SET @tableEntityNameTEMP =  @tableEntityName; -- safe original value for table entity name
		SET @fieldPrimaryKeyEntityIDTEMP = @fieldPrimaryKeyEntityID; -- safe original value for field primary key entity id
		SET @entityName = 'Schema';
		-- entity
		SET @valueFieldPrimaryKeyEntityID = 0; -- auto-generated
		SET @valueFieldForeignKeyParentID = @schemaTypesID; -- links to types
		IF(@entityType = 'Entity') THEN -- an entity
			SET @entityKey = CONCAT('"', @viewEntityName, '"');
		ELSEIF(@entityType = 'KindOfEntity') THEN -- a kind of entity
			SET @entityKey = CONCAT('"', @viewKindOfEntityName, '"');			
		END IF;
		SET @entityValue = '{}';
		CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
		-- entity items
		SET @tableEntityName = 'tbl_Schema';
		SET @requiredFieldName = 'pk_SchemaID';
		SET @requiredFieldValue = '';			
		SET @whereFieldName = 'SchemaKey';
		SET @whereOperator = '=';
		SET @whereValue = @entityKey;		
		-- @REQUIRED_FIELD_VALUE is what we get back from the call to get field value
		CALL `SP_GET_FIELD_VALUE` (@tableEntityName, @requiredFieldName, @requiredFieldValue, @whereFieldName, @whereOperator, @whereValue);
		SET @requiredFieldValue = @REQUIRED_FIELD_VALUE;
		SET @schemaEntityID = @requiredFieldValue;
		-- properties
		SET @valueFieldForeignKeyParentID = @schemaEntityID; -- links to entity	
		SET @entityKey = '"properties"';
		SET @entityValue = '{}';	
		CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
		-- table name
		SET @valueFieldForeignKeyParentID = @schemaEntityID; -- links to entity			
		SET @entityKey = '"table_name"';
		IF (@entityType = 'Entity') THEN -- an entity
			SET @entityValue = CONCAT('"', @tableEntityNameTEMP, '"'); -- NOTE: is it better to query against a view than the table... perhaps
		ELSEIF (@entityType = 'KindOfEntity') THEN -- a kind of entity
			SET @entityValue = CONCAT('"', @tableKindOfEntityName, '"'); -- NOTE: is it better to query against a view than the table... perhaps			
		END IF;
		CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);			
		-- keys
		SET @valueFieldForeignKeyParentID = @schemaEntityID; -- links to entity			
		SET @entityKey = '"keys"';
		SET @entityValue = '{}';	
		CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);			
		---
		SET @entityName = @entityNameTEMP; -- re-assign saved original value for entity name
		SET @tableEntityName = @tableEntityNameTEMP; -- re-assign saved original value for table entity name
		SET @fieldPrimaryKeyEntityID = @fieldPrimaryKeyEntityIDTEMP; -- re-assign saved original value for field primary key entity id
	END; 
$$
DELIMITER ;
-- Name: sp_CreateTablesAndViews
-- Description: A stored procedure that creates tables and views
-- Parameters:
-- IN: ENTITY_NAME
-- Usage:
-- CALL SP_CREATE_TABLES_AND_VIEWS(Foo);
-- where Foo is the entity name 
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_CREATE_TABLES_AND_VIEWS`;
CREATE PROCEDURE `SP_CREATE_TABLES_AND_VIEWS` (
		IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8'
	)
	BEGIN
		SET @entityName = ENTITY_NAME;
		SET @tableEntityName = CONCAT('tbl_', LOWER(@entityName));
		SET @fieldPrimaryKeyEntityID = CONCAT('pk_', @entityName, 'ID');
		SET @fieldForeignKeyParentID = 'fk_ParentID';
		SET @fieldEntityKey = CONCAT(@entityName, 'Key');
		SET @fieldEntityValue = CONCAT(@entityName, 'Value');
		SET @fieldForeignKeyKindOfEntityID = CONCAT('fk_KindOf', @entityName, 'ID');
		SET @fieldForeignKeyLanguageID = 'fk_LanguageID';
		SET @fieldTimeStampCreated = 'ts_Created';
		SET @fieldTimeStampUpdated = 'ts_Updated';
		SET @tableKindOfEntityName = CONCAT('tbl_kind_of_', LOWER(@entityName));
		SET @fieldPrimaryKeyKindOfEntityID = CONCAT('pk_KindOf', @entityName, 'ID');
		SET @fieldPrimaryKeyLanguageID = CONCAT('pk_LanguageID');
		SET @tableLanguage = LOWER('tbl_language');
		SET @viewEntityName = LOWER(@entityName);
		SET @viewKindOfEntityName = CONCAT('kind_of_', LOWER(@entityName));
		SET @fieldKindOfEntityKey = CONCAT('KindOf', @entityName, 'Key');
		SET @fieldKindOfEntityValue = CONCAT('KindOf', @entityName, 'Value');
		-- Set boolean to true if entity is schema entity, else to false
		IF (@entityName = 'Schema') THEN
			SET @entityIsSchemaEntity = true;
		ELSE
			SET @entityIsSchemaEntity = false;
		END IF;
		SET NAMES utf8;
		SET FOREIGN_KEY_CHECKS = 0;	-- off
		-- KIND OF ENTITY
		SET @entityType = 'KindOfEntity';
		START TRANSACTION;
			SELECT CONCAT('Creating Kind of Entity table for: ', @entityName) AS SP_CREATE_TABLES_AND_VIEWS;
			-- Drop kind of entity table		
			SET @query = CONCAT('
				DROP TABLE IF EXISTS `' , @tableKindOfEntityName, '`;
			');
			SELECT @query AS SP_CREATE_TABLES_AND_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;	
			-- Create kind of entity table
			SET @query = CONCAT('
				CREATE TABLE IF NOT EXISTS `' , @tableKindOfEntityName, '` (
					`' , @fieldPrimaryKeyKindOfEntityID, '` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
					`' , @fieldForeignKeyParentID, '` INT(11) UNSIGNED NOT NULL,
					`' , @fieldKindOfEntityKey, '`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
					`' , @fieldKindOfEntityValue, '`  VARCHAR(5000) COLLATE utf8_bin NOT NULL,
					`' , @fieldForeignKeyLanguageID, '` INT(11) UNSIGNED NOT NULL DEFAULT 0,
					`' , @fieldTimeStampCreated, '` DATETIME DEFAULT NULL,
					`' , @fieldTimeStampUpdated, '` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
					PRIMARY KEY (`' , @fieldPrimaryKeyKindOfEntityID, '`),
					FOREIGN KEY (`' , @fieldForeignKeyParentID, '`) REFERENCES `' , @tableKindOfEntityName, '` (`' , @fieldPrimaryKeyKindOfEntityID, '`) ON DELETE CASCADE,
					FOREIGN KEY (`' , @fieldForeignKeyLanguageID, '`) REFERENCES `' , @tableLanguage, '` (`' , @fieldPrimaryKeyLanguageID, '`) ON DELETE CASCADE
				) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
			');
			SELECT @query AS SP_CREATE_TABLES_AND_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			-- Drop entity view		
			SET @query = CONCAT('
				DROP VIEW IF EXISTS `' , @viewKindOfEntityName, '`;
			');
			SELECT @query AS SP_CREATE_TABLES_AND_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			-- Create kind of entity view
			SELECT CONCAT('Creating Kind of Entity view for: ', @entityName) AS SP_CREATE_TABLES_AND_VIEWS;		
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
			SELECT @query AS SP_CREATE_TABLES_AND_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		-- Skip if entity is itself the schema
		IF(@entityIsSchemaEntity) THEN
			SELECT CONCAT('Entity is Schema Entity') AS SP_CREATE_TABLES_AND_VIEWS;
			-- Continue
		ELSE
	--		CALL SP_ADD_TYPES_TO_SCHEMA(@databaseName, @entityName, @entityType, @viewEntityName, @viewKindOfEntityName, @tableEntityName, @fieldPrimaryKeyEntityID, @schemaTypesID);
	
	/* MOVE TO SP_ADD_TYPES_TO_SCHEMA	 */	
			-- Call stored procedure insert into table schema for type: kind of entity
			SELECT CONCAT('Entity for Schema: Kind of ', @entityName) AS SP_CREATE_TABLES_AND_VIEWS;
			SET @entityNameTEMP = @entityName; -- safe original value for entity name
			SET @tableEntityNameTEMP =  @tableEntityName; -- safe original value for table entity name
			SET @fieldPrimaryKeyEntityIDTEMP = @fieldPrimaryKeyEntityID; -- safe original value for field primary key entity id
			SET @entityName = 'Schema';
			-- entity
			SET @valueFieldPrimaryKeyEntityID = 0; -- auto-generated
			SET @valueFieldForeignKeyParentID = @schemaTypesID; -- links to types
			SET @entityKey = CONCAT('"', @viewKindOfEntityName, '"');
			SET @entityValue = '{}';
			CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
			-- entity items
			SET @tableEntityName = 'tbl_Schema';
			SET @requiredFieldName = 'pk_SchemaID';
			SET @requiredFieldValue = '';			
			SET @whereFieldName = 'SchemaKey';
			SET @whereOperator = '=';
			SET @whereValue = @entityKey;		
			-- @REQUIRED_FIELD_VALUE is what we get back from the call to get field value
			CALL `SP_GET_FIELD_VALUE` (@tableEntityName, @requiredFieldName, @requiredFieldValue, @whereFieldName, @whereOperator, @whereValue);
			SET @requiredFieldValue = @REQUIRED_FIELD_VALUE;
			SET @schemaEntityID = @requiredFieldValue;
			-- properties
			SET @valueFieldForeignKeyParentID = @schemaEntityID; -- links to entity			
			SET @entityKey = '"properties"';
			SET @entityValue = '{}';	
			CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
			-- table name
			SET @valueFieldForeignKeyParentID = @schemaEntityID; -- links to entity			
			SET @entityKey = '"table_name"';
			SET @entityValue = CONCAT('"', @tableKindOfEntityName, '"'); -- NOTE: is it better to query against a view than the table... perhaps
			CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);			
			-- keys
			SET @valueFieldForeignKeyParentID = @schemaEntityID; -- links to entity			
			SET @entityKey = '"keys"';
			SET @entityValue = '{}';	
			CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);			
			SET @entityName = @entityNameTEMP; -- re-assign saved original value for entity name
			SET @tableEntityName = @tableEntityNameTEMP; -- re-assign saved original value for table entity name
			SET @fieldPrimaryKeyEntityID = @fieldPrimaryKeyEntityIDTEMP; -- re-assign saved original value for field primary key entity id	

		/* */
			
		END IF;
		START TRANSACTION;
			-- Alter kind of entity table to add indices
			SET @query = CONCAT('
				ALTER TABLE `' , @tableKindOfEntityName, '` ADD INDEX `' , @fieldKindOfEntityKey, '` (`' , @fieldKindOfEntityKey, '`);
			');
			SELECT @query AS SP_CREATE_TABLES_AND_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		-- ENTITY
		SET @entityType = 'Entity';
		START TRANSACTION;
			SELECT CONCAT('Creating Entity table for: ', @entityName) AS SP_CREATE_TABLES_AND_VIEWS;
			-- Drop entity table		
			SET @query = CONCAT('
				DROP TABLE IF EXISTS `' , @tableEntityName, '`;
			');
			SELECT @query AS SP_CREATE_TABLES_AND_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;	
			-- Create entity table
			SET @query = CONCAT('
				CREATE TABLE IF NOT EXISTS `' , @tableEntityName, '` (
					`' , @fieldPrimaryKeyEntityID, '` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
					`' , @fieldForeignKeyParentID, '` INT(11) UNSIGNED NOT NULL,			
					`' , @fieldEntityKey, '`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
					`' , @fieldEntityValue, '`  VARCHAR(5000) COLLATE utf8_bin NOT NULL,
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
			SELECT @query AS SP_CREATE_TABLES_AND_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			-- Drop entity view		
			SET @query = CONCAT('
				DROP VIEW IF EXISTS `' , @viewEntityName, '`;
			');
			SELECT @query AS SP_CREATE_TABLES_AND_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;		
			-- Create entity view
			SELECT CONCAT('Creating Entity view for: ', @entityName) AS SP_CREATE_TABLES_AND_VIEWS;
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
					FROM ' , LOWER(@tableEntityName), ';
			');
			SELECT @query AS SP_CREATE_TABLES_AND_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		-- Skip if entity is itself the schema
		IF(@entityIsSchemaEntity) THEN
			SELECT CONCAT('Entity is Schema Entity') AS SP_CREATE_TABLES_AND_VIEWS;
			-- Continue
		ELSE
	--		CALL SP_ADD_TYPES_TO_SCHEMA(@databaseName, @entityName, @entityType, @viewEntityName, @viewKindOfEntityName, @tableEntityName, @fieldPrimaryKeyEntityID, @schemaTypesID);
	
	/* MOVE TO SP_ADD_TYPES_TO_SCHEMA */
	
			-- Call stored procedure insert into table schema for type: entity
			SELECT CONCAT('Entity for Schema: ', @entityName) AS SP_CREATE_TABLES_AND_VIEWS;		
			SET @entityNameTEMP = @entityName; -- safe original value for entity name
			SET @tableEntityNameTEMP =  @tableEntityName; -- safe original value for table entity name
			SET @fieldPrimaryKeyEntityIDTEMP = @fieldPrimaryKeyEntityID; -- safe original value for field primary key entity id			
			SET @entityName = 'Schema';
			-- entity
			Set @valueFieldPrimaryKeyEntityID = 0; -- auto-generated
			Set @valueFieldForeignKeyParentID = @schemaTypesID; -- links to types
			SET @entityKey = CONCAT('"', @viewEntityName, '"');
			SET @entityValue = '{}';
			CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
			-- entity items
			SET @tableEntityName = 'tbl_Schema';
			SET @requiredFieldName = 'pk_SchemaID';
			SET @requiredFieldValue = '';			
			SET @whereFieldName = 'SchemaKey';
			SET @whereOperator = '=';
			SET @whereValue = @entityKey;		
			-- @REQUIRED_FIELD_VALUE is what we get back from the call to get field value
			CALL `SP_GET_FIELD_VALUE` (@tableEntityName, @requiredFieldName, @requiredFieldValue, @whereFieldName, @whereOperator, @whereValue);
			SET @requiredFieldValue = @REQUIRED_FIELD_VALUE;
			SET @schemaEntityID = @requiredFieldValue;
			-- properties
			SET @valueFieldForeignKeyParentID = @schemaEntityID; -- links to entity			
			SET @entityKey = '"properties"';
			SET @entityValue = '{}';	
			CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
			-- table name
			SET @valueFieldForeignKeyParentID = @schemaEntityID; -- links to entity			
			SET @entityKey = '"table_name"';
			SET @entityValue = CONCAT('"', @tableEntityNameTEMP, '"'); -- NOTE: WE NEED TO USE THE TEMP NAME HERE. And is it better to query against a view than the table... perhaps
			CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);			
			-- keys
			SET @valueFieldForeignKeyParentID = @schemaEntityID; -- links to entity			
			SET @entityKey = '"keys"';
			SET @entityValue = '{}';	
			CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
			SET @entityName = @entityNameTEMP; -- re-assign saved original value for entity name
			SET @tableEntityName = @tableEntityNameTEMP; -- re-assign saved original value for table entity name	
			SET @fieldPrimaryKeyEntityID = @fieldPrimaryKeyEntityIDTEMP; -- re-assign saved original value for field primary key entity id
			
	/* */		
		END IF;
		START TRANSACTION;
			-- Alter entity table to add indices
			SET @query = CONCAT('
				ALTER TABLE `' , @tableEntityName, '` ADD INDEX `' , @fieldEntityKey, '` (`' , @fieldEntityKey, '`);
			');
			SELECT @query AS SP_CREATE_TABLES_AND_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		SET FOREIGN_KEY_CHECKS = 1;	-- on
	END; 
$$
DELIMITER ;
-- Name: SP_MAIN
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
CREATE PROCEDURE `SP_MAIN` (
		IN `DATABASE_NAME` varchar(255) CHARACTER SET 'utf8', 
		IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8'
	)
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
	
	END; 
$$
DELIMITER ;	
-- Create procedure insert into table
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_INSERT_INTO_TABLE`;
CREATE PROCEDURE `SP_INSERT_INTO_TABLE` (
		IN `DATABASE_NAME` varchar(255) CHARACTER SET 'utf8', 
		IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8', 
		IN `PRIMARY_KEY_ENTITY_ID` int(11),
		IN `FOREIGN_KEY_PARENT_ID` int(11),
		IN `ENTITY_KEY` varchar(255) CHARACTER SET 'utf8', 
		IN `ENTITY_VALUE` varchar(5000) CHARACTER SET 'utf8'
	)
	BEGIN
		SET NAMES utf8;
		SET FOREIGN_KEY_CHECKS = 0;	-- off
		SET @tableEntityName = CONCAT('tbl_', LOWER(@entityName));
		SET @fieldPrimaryKeyEntityID = CONCAT('pk_', @entityName, 'ID');
		SET @valueFieldPrimaryKeyEntityID = PRIMARY_KEY_ENTITY_ID;
		SET @valueFieldForeignKeyParentID = FOREIGN_KEY_PARENT_ID;	
		SET @valueFieldEntityKey = ENTITY_KEY; -- e.g. "domains"
		SET @valueFieldEntityValue = ENTITY_VALUE; -- e.g. {}
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
			SELECT @query AS SP_INSERT_INTO_TABLE;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		SET FOREIGN_KEY_CHECKS = 1;	-- on
	END; 
$$
DELIMITER ;
-- Call stored procedure main, providing it with the database name and entity name
SET @entityName = 'Schema';
CALL SP_MAIN(@databaseName, @entityName);
-- Call stored procedure insert into table for: domains
SET @entityName = 'Schema';
Set @valueFieldPrimaryKeyEntityID = 1;
Set @valueFieldForeignKeyParentID = @valueFieldPrimaryKeyEntityID; -- links to itself
SET @entityKey = '"domains"';
SET @entityValue = '{}';
SET @schemaDomainsID = @valueFieldPrimaryKeyEntityID;
CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
-- Call stored procedure insert into table for: database
SET @entityName = 'Schema';
Set @valueFieldPrimaryKeyEntityID = @valueFieldPrimaryKeyEntityID + 1;
Set @valueFieldForeignKeyParentID = @schemaDomainsID; -- links to domains
SET @entityKey = CONCAT('"', LOWER(@databaseName), '"');
SET @entityValue = '{}';
SET @schemaDatabaseID = @valueFieldPrimaryKeyEntityID;
CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
-- Call stored procedure insert into table for: schema name
SET @entityName = 'Schema';
Set @valueFieldPrimaryKeyEntityID = @valueFieldPrimaryKeyEntityID + 1;
Set @valueFieldForeignKeyParentID = @schemaDatabaseID; -- links to database
SET @entityKey = '"schema_name"';
SET @entityValue = CONCAT('"', LOWER(@databaseName), '"');
CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
-- Call stored procedure insert into table for: types
SET @entityName = 'Schema';
Set @valueFieldPrimaryKeyEntityID = @valueFieldPrimaryKeyEntityID + 1;
Set @valueFieldForeignKeyParentID = @schemaDatabaseID; -- links to domains
SET @entityKey = '"types"';
SET @entityValue = '{}';
SET @schemaTypesID = @valueFieldPrimaryKeyEntityID;
CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
-- Call stored procedure main, providing it with the database name and entity name
SET @entityName = 'Language';
CALL SP_MAIN(@databaseName, @entityName);
-- Call stored procedure insert into table for: English
SET @entityName = 'Language';
Set @valueFieldPrimaryKeyEntityID = 1;
Set @valueFieldForeignKeyParentID = 1; -- links to itself
SET @entityKey = 'Language';
SET @entityValue = @databaseLanguage;
CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @entityKey, @entityValue);
-- Create stored procedure that inserts an array of values
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_INSERT_ARRAY_OF_VALUES`;
CREATE PROCEDURE `SP_INSERT_ARRAY_OF_VALUES` (
		IN `DATABASE_NAME` varchar(255) CHARACTER SET 'utf8', 
		IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8', 
		IN `VALUE_FIELD_ENTITY_KEY` varchar(255) CHARACTER SET 'utf8', 
		IN `VALUE_FIELD_ENTITY_VALUE_ARRAY` varchar(255) CHARACTER SET 'utf8', 
		IN `VALUE_FIELD_ENTITY_VALUE_ARRAY_SEPARATOR` varchar(1) CHARACTER SET 'utf8'
	)
	BEGIN
		SET @separator = VALUE_FIELD_ENTITY_VALUE_ARRAY_SEPARATOR;
        SET @separatorLength = CHAR_LENGTH(@separator);
		SET @entityName = ENTITY_NAME;
		SET @databaseName = DATABASE_NAME;
		SET @tableEntityName = CONCAT('tbl_', LOWER(@entityName));
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
		SET FOREIGN_KEY_CHECKS = 0;	-- off
		WHILE (LOCATE(@separator, @valueFieldEntityValueArray) > 0) DO
			SET @valueFieldEntityValue = SUBSTRING_INDEX(@valueFieldEntityValueArray, @separator, 1);
			SET @valueFieldEntityValue = REPLACE(@valueFieldEntityValue,'"',''); -- removes double quotes
			SET @valueFieldEntityValueArray = SUBSTRING(@valueFieldEntityValueArray, LOCATE(@separator,@valueFieldEntityValueArray) + 1);
			CALL `SP_INSERT_INTO_TABLE` (@databaseName, @entityName, @valueFieldPrimaryKeyEntityID, @valueFieldForeignKeyParentID, @valueFieldEntityKey, @valueFieldEntityValue);
			SET @valueFieldPrimaryKeyEntityID = @valueFieldPrimaryKeyEntityID + 1;
			SET @valueFieldForeignKeyParentID = @valueFieldPrimaryKeyEntityID;
		END WHILE;
		SET FOREIGN_KEY_CHECKS = 1; -- on
	END; 
$$
DELIMITER ;
-- Call stored procedure main, providing it with the database name and entity name	
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
CREATE PROCEDURE `SP_LOOP_FIELD_CALL_CREATE_TABLES_AND_VIEWS` (
		IN `DATABASE_NAME` varchar(255) CHARACTER SET 'utf8', 
		IN `TABLE_NAME` varchar(255) CHARACTER SET 'utf8', 
		IN `FIELD_KEY_NAME` varchar(255) CHARACTER SET 'utf8', 
		IN `KEY_VALUE` varchar(255) CHARACTER SET 'utf8', 
		IN `FIELD_VALUE_NAME` varchar(255) CHARACTER SET 'utf8'
	)
	BEGIN
		DECLARE findFinished INTEGER DEFAULT 0;
		DECLARE fieldValue varchar(5000) DEFAULT "";
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
			SELECT CONCAT('Found fieldValue: ', fieldValue) AS SP_LOOP_FIELD_CALL_CREATE_TABLES_AND_VIEWS;
			SET @entityName = fieldValue;
			CASE  
				WHEN @entityName = 'Schema' THEN
					SELECT CONCAT('Skipping: ', @entityName) AS SP_LOOP_FIELD_CALL_CREATE_TABLES_AND_VIEWS; 			
				WHEN @entityName = 'Entity' THEN     
					SELECT CONCAT('Skipping: ', @entityName) AS SP_LOOP_FIELD_CALL_CREATE_TABLES_AND_VIEWS;
				WHEN @entityName = 'Language' THEN
					SELECT CONCAT('Skipping: ', @entityName) AS SP_LOOP_FIELD_CALL_CREATE_TABLES_AND_VIEWS; 
				ELSE CALL `bits`.SP_CREATE_TABLES_AND_VIEWS(@entityName);
			END CASE;
		END LOOP getFieldValue;
		CLOSE fieldValueCursor;
	END; 
$$
DELIMITER ;
-- Call stored procedure loop field call create tables and views
SET @tableName = LOWER('tbl_entity');
SET @fieldKeyName = 'EntityKey';
SET @keyValue = 'Entity';
SET @fieldValueName = 'EntityValue';
CALL SP_LOOP_FIELD_CALL_CREATE_TABLES_AND_VIEWS(@databaseName, @tableName, @fieldKeyName, @keyValue, @fieldValueName);
-- By now all simple entity tables and views should have been created (excluding link tables)
-- Create procedure create link tables
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS`;
CREATE PROCEDURE `SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS` (
		IN `LINKED_ENTITIES_NAMES` varchar(255) CHARACTER SET 'utf8', 
		IN `LINKED_ENTITIES_NAMES_SEPARATOR` varchar(255) CHARACTER SET 'utf8'
	)
	BEGIN
		SET @linkedEntitiesNames = LINKED_ENTITIES_NAMES;
		SET @separator = LINKED_ENTITIES_NAMES_SEPARATOR;
		SET @firstEntityName = SUBSTRING_INDEX(@linkedEntitiesNames, @separator, 1);
		SET @secondEntityName = REPLACE(@linkedEntitiesNames,CONCAT(@firstEntityName, @separator),'');
		SELECT CONCAT('First Entity Name: ', @firstEntityName) AS SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS;
		SELECT CONCAT('Second Entity Name: ', @secondEntityName) AS SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS;
		SET @tableLinkedEntitiesNames = CONCAT('tbl_', LOWER(@firstEntityName), '_',  LOWER(@secondEntityName));
		SET @fieldPrimaryKeyLinkedEntitiesID = CONCAT('pk_', @firstEntityName, @secondEntityName, 'ID');
		SET @fieldForeignKeyFirstEntityID = CONCAT('fk_', @firstEntityName, 'ID');
		SET @fieldForeignKeySecondEntityID = CONCAT('fk_', @secondEntityName, 'ID');
		SET @fieldTimeStampCreated = 'ts_Created';
		SET @fieldTimeStampUpdated = 'ts_Updated';
		SET @tableFirstEntityName = CONCAT('tbl_', LOWER(@firstEntityName));
		SET @tableSecondEntityName = CONCAT('tbl_', LOWER(@secondEntityName));
		SET @viewLinkedEntitiesNames = CONCAT(LOWER(@firstEntityName), '_', LOWER(@secondEntityName));
		SET @fieldPrimaryKeyFirstEntityID = CONCAT('pk_', @firstEntityName, 'ID');
		SET @fieldPrimaryKeySecondEntityID = CONCAT('pk_', @secondEntityName, 'ID');
		SET NAMES utf8;
		SET FOREIGN_KEY_CHECKS = 0;	-- off
		-- LINKED ENTITIES
		START TRANSACTION;
			SELECT CONCAT('Creating Linked Entities table for: ', @linkedEntitiesNames) AS SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS;
			-- Drop entity table		
			SET @query = CONCAT('
				DROP TABLE IF EXISTS `' , @tableLinkedEntitiesNames, '`;
			');
			SELECT @query AS SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS;
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
			SELECT @query AS SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS;			
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			-- Drop linked entities view
			SET @query = CONCAT('
				DROP VIEW IF EXISTS `' , @viewLinkedEntitiesNames, '`;
			');
			SELECT @query AS SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			-- Create linked entities view
			SELECT CONCAT('Creating Linked Entities view for: ', @linkedEntitiesNames) AS SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS;
			SET @query = CONCAT('
				CREATE VIEW `' , @viewLinkedEntitiesNames, '` AS
					SELECT `' , @fieldPrimaryKeyLinkedEntitiesID, '`,		
					`' , @fieldForeignKeyFirstEntityID, '`,
					`' , @fieldForeignKeySecondEntityID, '`,
					`' , @fieldTimeStampCreated, '`,
					`' , @fieldTimeStampUpdated, '`
					FROM ' , @tableLinkedEntitiesNames, ';
			');
			SELECT @query AS SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		SET FOREIGN_KEY_CHECKS = 1;	-- on
	END; 
$$
DELIMITER ;
-- Create the split string function
DELIMITER $$
DROP FUNCTION IF EXISTS `FN_SPLIT_STRING`;
CREATE FUNCTION `FN_SPLIT_STRING` (
		str VARCHAR(5000), 
		delim VARCHAR(12), 
		pos INT
	)
	RETURNS VARCHAR(255)
	BEGIN
		RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(str, delim, pos),
		LENGTH(SUBSTRING_INDEX(str, delim, pos -1)) + 1),
		delim, '');
	END; 
$$
DELIMITER ;
-- Create procedure create multiple linked entities tables, for each entry in @databaseSimpleLinkedEntities
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_CREATE_MULTIPLE_LINKED_TABLES_AND_LINKED_VIEWS`;
CREATE PROCEDURE `SP_CREATE_MULTIPLE_LINKED_TABLES_AND_LINKED_VIEWS` (
		IN `MULTIPLE_LINKED_ENTITIES_NAMES` varchar(5000) CHARACTER SET 'utf8', 
		IN `LINKED_ENTITIES_NAMES_SEPARATOR` varchar(255) CHARACTER SET 'utf8'
	)
	BEGIN
		SET @multipleLinkedEntitiesNames = MULTIPLE_LINKED_ENTITIES_NAMES;
		SET @linkedEntitiesNamesSeparator = LINKED_ENTITIES_NAMES_SEPARATOR;
		SET @counter = 1;
		WHILE (@counter > 0) DO
			SET @delimiter = ',';
			SET @linkedEntitiesNames = FN_SPLIT_STRING(@multipleLinkedEntitiesNames, @delimiter, @counter);
			SET @linkedEntitiesNames = REPLACE(@linkedEntitiesNames,'"',''); -- removes double quotes
			SELECT 	CONCAT('Linked Entities Names: ', @linkedEntitiesNames) AS SP_CREATE_MULTIPLE_LINKED_TABLES_AND_LINKED_VIEWS;
			IF @linkedEntitiesNames = '' THEN
				SET @counter = 0;
			ELSE
				CALL SP_CREATE_LINKED_TABLES_AND_LINKED_VIEWS(@linkedEntitiesNames, @linkedEntitiesNamesSeparator);
				SET @counter = @counter + 1;
			END IF;
		END WHILE;
	END; 
$$
DELIMITER ;
-- Call procedure create multiple linked entities tables, for complete @databaseSimpleLinkedEntities and @databaseSimpleLinkedEntitiesSeparator
SET @multipleLinkedEntitiesNames = @databaseSimpleLinkedEntities;
SET @linkedEntitiesNamesSeparator = @databaseSimpleLinkedEntitiesSeparator;
CALL SP_CREATE_MULTIPLE_LINKED_TABLES_AND_LINKED_VIEWS(@multipleLinkedEntitiesNames, @linkedEntitiesNamesSeparator);
-- THIS MAY NEED TO BE BETTER INTEGRATED IN ABOVE CODE
-- UPDATING SCHEMA TABLE FOR CREATING JSON FROM SQL
-- Following http://technology.amis.nl/2011/06/14/creating-json-document-straight-from-sql-query-using-listagg-and-with-clause/
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_UPDATE_SCHEMA`;
CREATE PROCEDURE `SP_UPDATE_SCHEMA` (
		IN `SCHEMA_ID` int(11), 
		IN `PARENT_ID` int(11),  
		IN `SCHEMA_KEY` varchar(255) CHARACTER SET 'utf8',  
		IN `SCHEMA_VALUE` varchar(5000) CHARACTER SET 'utf8',  
		IN `KIND_OF_SCHEMA` varchar(255) CHARACTER SET 'utf8'
	)
	BEGIN
		SET NAMES utf8;
		SET FOREIGN_KEY_CHECKS = 0;	-- off
		-- LINKED ENTITIES
		START TRANSACTION;
			SET @query = CONCAT('
			
		--	CREATE TEMPORARY TABLE res_schema(pk_SchemaID int(11), fk_ParentID int(11), SchemaKey varchar(255), SchemaValue varchar(5000))engine=memory;
			
			
		--			WITH `EntityKey` AS
		--			(  SELECT * 
		--			   FROM `tbl_entity`	
		--			)
		--			SELECT \'{"company" :[\'
		--			||(SELECT * FROM DUAL)
		--			||\']}\'
		--			FROM DUAL;
			');
			SELECT CONCAT(@query) AS SP_UPDATE_SCHEMA;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		SET FOREIGN_KEY_CHECKS = 1;	-- on	
	END; 
$$
DELIMITER ;
-- Create procedure output (e.g. JSON) schema, that outputs a schema (in e.g. JSON) from the schema table
-- using parent-child relationship querying
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_OUTPUT_SCHEMA`;
CREATE PROCEDURE `SP_OUTPUT_SCHEMA` (
		IN `SCHEMA_ID` int(11)
	)
	BEGIN
		SET @childID = SCHEMA_ID;
		SET NAMES utf8;
		SET FOREIGN_KEY_CHECKS = 0;	-- off
		-- LINKED ENTITIES
		START TRANSACTION;
			-- child field is pk_SchemaID
			-- parent field is fk_ParentID
			-- query will get all siblings to child with @childID
			SET @query = CONCAT('
				SELECT parent.pk_SchemaID, parent.SchemaKey, parent.SchemaValue
				FROM `tbl_schema` child
				INNER JOIN `tbl_schema` p ON child.fk_ParentID = parent.fk_ParentID
				WHERE child.pk_SchemaID = ', @childID, '
				AND parent.pk_SchemaID <> ', @childID
			);
			SELECT CONCAT(@query) AS SP_OUTPUT_SCHEMA;
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		COMMIT;
		SET FOREIGN_KEY_CHECKS = 1;	-- on
	END; 
$$
DELIMITER ;
-- Call the output schema stored procedure
CALL SP_OUTPUT_SCHEMA(1);