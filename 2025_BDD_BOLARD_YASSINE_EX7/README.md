1. Afficher tous les utilisateurs ayant emprunté au moins un équipement

```sql
SELECT * FROM utilisateur as u
INNER JOIN reservation as r ON u.userid=r.userid;
```

2. Afficher les équipements n’ayant jamais été empruntés
```sql
SELECT * FROM materiel 
WHERE materialid NOT IN (
    SELECT materialid FROM reservation
);
```

3. Afficher les équipements ayant été emprunté plus de 3 fois
```sql
SELECT 
    m.materialid, 
    m.nom, 
    COUNT(r.materialid) AS nombre_emprunts
FROM materiel as m
INNER JOIN reservation as r ON m.materialid = r.materialid
GROUP BY m.materialid, m.nom
HAVING COUNT(r.materialid) > 3;
```

4. Afficher le nombre d’emprunts pour chaque utilisateur, ordonné par numéro d'étudiant. Les utilisateurs n'ayant pas de réservations en cours doivent également être affichés avec la valeur 0 dans le nombre d'emprunts.
```sql
SELECT 
    u.userid,
    u.nom,
    u.prenom,
    u.numetudiant,
    COUNT(r.reservationid) AS nombre_emprunts
FROM utilisateur as u
LEFT JOIN reservation r ON u.userid = r.userid
GROUP BY u.userid, u.nom, u.prenom, u.numetudiant
ORDER BY u.numetudiant;
```