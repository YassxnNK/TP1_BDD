1. Une requête de jointure sur les utilisateurs ayant effectué une réservation

```sql
SELECT (nom, prenom) FROM utilisateur AS u 
INNER JOIN reservation AS r ON u.userid=r.userid;
```

Cette requête nous sort le nom et prénom de tous les utilisateurs ayant effectués une réservation

2. Une requête de jointure pour récupérer les informations sur le matériel emprunté par un utilisateur donné

```sql
SELECT m.nom FROM materiel AS m 
INNER JOIN reservation AS r ON m.materialid=r.materialid
INNER JOIN utilisateur as u ON u.userid=r.userid
WHERE u.nom='Bolard' AND u.prenom='Yassine';
```

Cette requête nous sort le nom du matériel emprunté par l'utilisateur donné (nom et prénom et pas userid)

