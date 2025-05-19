Faisons une requête qui nous retourne la quantité de Casque audio dans la table materiel
```sql
SELECT quantite FROM materiel WHERE nom='Casque audio';
```

Faisons une requête qui nous retourne les informations (nom, prénom et email) de l'utilisateur portant l'id numéro 4
```sql
SELECT (nom, prenom, email) FROM utilisateur WHERE userid=4;
``` 

Faisons une requête pour obtenir l'id du matériel et de l'utilisateur de chaque réservation initiées entre le 21 mai 2025 et 23 mai 2025 INCLUS (raison de pourquoi l'heure est mise)
```sql
SELECT (materialid, userid) FROM reservation WHERE date_debut BETWEEN '2025-05-21' AND '2025-05-23 23:59:59';
```