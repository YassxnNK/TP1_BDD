1. Requête d’aggrégation pour calculer le nombre total de réservations effectuées sur une période donnée

```sql
SELECT COUNT(*) FROM reservation
WHERE date_debut BETWEEN '2025-05-21' AND '2025-05-23 23:59:59';
```

Cette requête calcul le nombre total de réservation effectué entre le 21 mai 2025 et le 23 mai 2025 inclus

2. Requête d’aggrégation pour calculer le nombre d’utilisateur ayant emprunté du matériel

```sql
SELECT COUNT(DISTINCT userid) FROM reservation;
```
Cette requête retourne le nombre d'utilisateur distinct (ne compte pas les doublons) qui ont effectué au moins une réservation.