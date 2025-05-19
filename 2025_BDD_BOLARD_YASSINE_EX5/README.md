1. Requête de modification de la quantité disponible d’un matériel

```sql
UPDATE materiel
SET quantite=15
WHERE materialid=2;
```

Ici on modifie la quantité du materiel portant l'id 2 en le passant à 15 de quantite.

2. Requête de modification de la quantité de tous les matériels qui sont en cours d'emprunt et la date de retour prévue dans plus de 2 jours.
```sql
UPDATE materiel
SET quantite = quantite - 1
FROM reservation
WHERE materiel.materialid = reservation.materialid
AND CURRENT_DATE >= reservation.date_debut
-- Date de début est inférieur ou égale à la date du jour
AND CURRENT_DATE <= reservation.date_fin
-- Valide que le matériel est toujours en cours d'emprunt
AND reservation.date_fin > CURRENT_DATE + INTERVAL '2 days';
-- Date de fin est supérieur ou égale à date du jour + 2 jours
```

Ici on décrémente la quantité du matériel qui sont en cours d'emprunt et la date de retour est prévue dans plus de 2 jours