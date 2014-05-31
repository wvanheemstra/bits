delimiter //
CREATE PROCEDURE `SP_CREATE_TABLES_AND_VIEWS` (IN `ENTITY_NAME` varchar(255) CHARACTER SET 'utf8')
	BEGIN
		SET @entityName = ENTITY_NAME;
		SET @tableName = CONCAT('tbl_', @entityName);
		SET @tablePrimaryKey = CONCAT('kp_', @entityName, 'ID');
		SET @query = CONCAT('
			CREATE TABLE IF NOT EXISTS `' , @tableName, '` (
				`' , @tablePrimaryKey, '` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				PRIMARY KEY (`' , @tablePrimaryKey, '`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8
		');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		-- and you're done. Table is created.
		-- process it here if you like (INSERT etc)
	END //
delimiter ;

-- Call this stored procedure like so, where Foo is the entity name:
-- CALL SP_CREATE_TABLES_AND_VIEWS(Foo);
