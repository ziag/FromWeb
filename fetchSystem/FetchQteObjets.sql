/*
Ce script utilise la table syst�me sys.objects pour compter le nombre d�objets dans une base de donn�es. 
Les types d�objets pris en compte sont les tables (U), les vues (V), les proc�dures stock�es (P), 
les fonctions scalaires (FN), les fonctions en ligne (IF), et les fonctions de table (TF) 1.
*/

SELECT  

		CASE type	
			WHEN 'U'  THEN 'Tables'
			WHEN 'V'  THEN 'Vues'
			WHEN 'P'  THEN 'Proc�dures stock�es'
			WHEN 'FN' THEN 'Fonctions'  --'Fonctions Scalaires'
			WHEN 'IF' THEN 'Fonctions'  --'Fonctions en ligne'
			WHEN 'TF' THEN 'Fonctions'  --'Fonctions de table'
			
		END TypeObjet,

		COUNT(*) AS 'Nombre d''objets'

FROM sys.objects
WHERE type IN ('U', 'V', 'P', 'FN', 'IF', 'TF')

GROUP BY CASE type	
			WHEN 'U'  THEN 'Tables'
			WHEN 'V'  THEN 'Vues'
			WHEN 'P'  THEN 'Proc�dures stock�es'
			WHEN 'FN' THEN 'Fonctions'  --'Fonctions Scalaires'
			WHEN 'IF' THEN 'Fonctions'  --'Fonctions en ligne'
			WHEN 'TF' THEN 'Fonctions'  --'Fonctions de table'
			
		END  
