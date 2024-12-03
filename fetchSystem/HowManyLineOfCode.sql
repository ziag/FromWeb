
SELECT DB_NAME(DB_ID()) [DB_Name],
       type,
       COUNT(*) AS Object_Count,
       SUM(LinesOfCode) AS LinesOfCode
FROM
(
    SELECT type,
           LEN(definition) - LEN(REPLACE(definition, CHAR(10), '')) AS LinesOfCode,
           OBJECT_NAME(object_id) AS NameOfObject
    FROM sys.all_sql_modules a
        JOIN sysobjects  AS s
            ON a.object_id = s.id
    -- AND xtype IN('TR', 'P', 'FN', 'IF', 'TF', 'V')
    WHERE OBJECTPROPERTY(object_id, 'IsMSShipped') = 0
) SubQuery
GROUP BY type;



/*
Dans SQL Server, la colonne `xtype` de la table syst�me `sysobjects` (ou `sys.sysobjects` pour les versions plus r�centes) indique le type d'objet dans la base de donn�es. Voici les principaux types de `xtype` que vous pouvez rencontrer[1](https://learn.microsoft.com/en-us/sql/relational-databases/system-compatibility-views/sys-sysobjects-transact-sql?view=sql-server-ver16)[2](https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver16) :

- **AF** : Fonction d'agr�gat (CLR)
- **C** : Contrainte CHECK
- **D** : D�faut ou contrainte DEFAULT
- **F** : Contrainte de cl� �trang�re
- **FN** : Fonction scalaire
- **FS** : Fonction scalaire d'assembly (CLR)
- **FT** : Fonction table d'assembly (CLR)
- **IF** : Fonction table en ligne
- **IT** : Table interne
- **P** : Proc�dure stock�e
- **PC** : Proc�dure stock�e d'assembly (CLR)
- **PK** : Contrainte de cl� primaire
- **RF** : Proc�dure stock�e de filtre de r�plication
- **S** : Table syst�me
- **SN** : Synonyme
- **SO** : S�quence
- **SQ** : File d'attente de service
- **TA** : D�clencheur DML d'assembly (CLR)
- **TF** : Fonction table
- **TR** : D�clencheur DML SQL
- **TT** : Type de table
- **U** : Table utilisateur
- **UQ** : Contrainte UNIQUE
- **V** : Vue
- **X** : Proc�dure stock�e �tendue

Ces types permettent de cat�goriser les diff�rents objets cr��s dans une base de donn�es SQL Server[1](https://learn.microsoft.com/en-us/sql/relational-databases/system-compatibility-views/sys-sysobjects-transact-sql?view=sql-server-ver16)[2](https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver16).

Avez-vous besoin d'informations suppl�mentaires sur un type sp�cifique ou sur la mani�re d'utiliser ces informations dans vos requ�tes SQL ?
[1](https://learn.microsoft.com/en-us/sql/relational-databases/system-compatibility-views/sys-sysobjects-transact-sql?view=sql-server-ver16): [sys.sysobjects (Transact-SQL) - SQL Server | Microsoft Learn](https://learn.microsoft.com/en-us/sql/relational-databases/system-compatibility-views/sys-sysobjects-transact-sql?view=sql-server-ver16)
[2](https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver16): [sys.objects (Transact-SQL) - SQL Server | Microsoft Learn](https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver16)
*/
