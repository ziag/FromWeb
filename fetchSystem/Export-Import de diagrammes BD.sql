-- ===========================================================================================================
-- Auteur original:	   		http://www.dotnetspider.com/resources/21180-Copy-or-move-database-digram-from-for.aspx		
-- Adaptation:				Christian Melan�on
-- Date de cr�ation:		2011-05-25
-- Description:				Ce script permet d'exporter un diagramme de base de donn�es d'une base de donn�es
--							� une autre.
--
-- Param�tres:				@DiagramID: ID du diagramme � exporter.
--							#DB_SOURCE#: Nom de la base de donn�es source.
--							#DB_TARGET#: Nom de la base de donn�es de destination.
--
-- Notes:					Les tables du diagramme � exporter doivent exister dans la base de donn�es de 
--							destination.
-- ===========================================================================================================

--------------------------------------------------------------------------------------------------------------
-- �tape 1: identifier le ID du diagramme � exporter (colonne diagram_id)
--------------------------------------------------------------------------------------------------------------
SELECT * FROM UDA_Axiant.dbo.sysdiagrams


--------------------------------------------------------------------------------------------------------------
-- �tape 2: exporter le diagramme en sp�cifiant son ID dans la base de donn�es source.
--------------------------------------------------------------------------------------------------------------
DECLARE @DiagramID AS INT
SET @DiagramID = 1

--INSERT INTO UDA_Axiant.dbo.sysdiagrams
SELECT diagram.name, diagram.principal_id, diagram.version, diagram.definition
FROM UDA_Axiant.dbo.sysdiagrams diagram
WHERE diagram.diagram_id = @DiagramID