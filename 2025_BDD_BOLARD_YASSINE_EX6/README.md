1. Requête de suppression d’une réservation existante
```sql
DELETE FROM reservation
WHERE reservationid=3;
```

2. Requête de suppression d'une réservation ou la date de retour prévue est passée.
```sql
DELETE FROM reservation
WHERE date_fin<CURRENT_DATE;
```