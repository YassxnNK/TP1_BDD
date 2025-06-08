## Exercice 10: Full scan et index
### Contexte
Nous allons simuler les effets indésirables liés au traitement d'un grand volume de données. Dans le cadre de cet exercice, nous nous aurons à analyser et trouver une solution pour accélérer le traitement d'une requête SQL.

### Instructions

1. Modifiez et adaptez le script suivant dans pgAdmin le script suivant pour inclure:

Les noms des colonnes que vous aurez défini:

```sql
-- Suppression des contraintes de clés étrangères temporaires
ALTER TABLE Disponibilite DROP CONSTRAINT IF EXISTS disponibilite_materialid_fkey;
ALTER TABLE Reservation DROP CONSTRAINT IF EXISTS reservation_userid_fkey;
ALTER TABLE Reservation DROP CONSTRAINT IF EXISTS reservation_materialid_fkey;
ALTER TABLE Reservation DROP CONSTRAINT IF EXISTS reservation_disponibiliteid_fkey;

-- Réinitialisation des tables
TRUNCATE TABLE Reservation RESTART IDENTITY CASCADE;
TRUNCATE TABLE Disponibilite RESTART IDENTITY CASCADE;
TRUNCATE TABLE Materiel RESTART IDENTITY CASCADE;
TRUNCATE TABLE Utilisateur RESTART IDENTITY CASCADE;



-- Insert 100,000 rows into utilisateur
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100000 LOOP
        INSERT INTO Utilisateur(userid, nom, prenom, email, numetudiant)
        VALUES (
            i,
            'nom_' || i,
            'prenom_' || i,
            'user_' || i || '@example.com',
            LPAD(i::TEXT, 8, '0')
        );
    END LOOP;
END $$;


-- Insert 100,000 rows into materiel
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100000 LOOP
        INSERT INTO Materiel(materialid, nom, quantite)
        VALUES (
            i,
            'materiel_' || i,
            (random() * 20)::INT + 1
        );
    END LOOP;
END $$;


-- Insert 200,000 rows into disponibilite
DO $$
DECLARE
    i INT;
    start_date DATE;
    end_date DATE;
BEGIN
    FOR i IN 1..200000 LOOP
        start_date := DATE '2025-01-01' + (random() * 365)::INT;
        end_date := start_date + (random() * 30)::INT;

        INSERT INTO Disponibilite(disponibiliteid, materialid, date_debut, date_fin)
        VALUES (
            i,
            (random() * 99999)::INT + 1,
            start_date,
            end_date
        );
    END LOOP;
END $$;

-- Insert 200,000 rows into réservation
DO $$
DECLARE
    i INT;
    res_date DATE;
    ret_date DATE;
    ret_effective DATE;
BEGIN
    FOR i IN 1..200000 LOOP
        res_date := DATE '2025-01-01' + (random() * 365)::INT;
        ret_date := res_date + (random() * 15)::INT;
        ret_effective := res_date + (random() * 15)::INT;

        INSERT INTO Reservation(reservationid, date_debut, date_fin, materialid, userid, disponibiliteid, date_retour_effectif)
        VALUES (
            i,
            res_date,
            ret_date,
            (random() * 99999)::INT + 1,
            (random() * 99999)::INT + 1,
            (random() * 199999)::INT + 1,
            ret_effective
        );
    END LOOP;
END $$;

```

5. Exécutez une recherche impliquant des jointures entre les tables:
* Matériel
* Réservation
* Utilisateur
* Disponibilité

Faites une recherche en vous basant comme critère sur une des colonnes de la table de réservation (ex. la date de début de disponibilité).

```sql
SELECT 
    u.nom,
    u.prenom,
    m.nom AS nom_materiel,
    d.date_debut AS dispo_debut,
    d.date_fin AS dispo_fin,
    r.date_debut AS res_debut,
    r.date_fin AS res_fin
FROM Reservation r
JOIN Utilisateur u ON r.userid = u.userid
JOIN Materiel m ON r.materialid = m.materialid
JOIN Disponibilite d ON r.disponibiliteid = d.disponibiliteid
WHERE r.date_debut BETWEEN '2025-06-01' AND '2025-06-15';
```

6. Affichez le plan d' exécution de la requête à l'aide de l'instruction ``EXPLAIN ANALYZE``. Analysez et indiquez la cause du ralentissement.

Vous pouvez également consulter l'onglet `Explain`` pour avoir une représentation graphique.

```sql
EXPLAIN ANALYZE
SELECT 
    u.nom,
    u.prenom,
    m.nom AS nom_materiel,
    d.date_debut AS dispo_debut,
    d.date_fin AS dispo_fin,
    r.date_debut AS res_debut,
    r.date_fin AS res_fin
FROM Reservation r
JOIN Utilisateur u ON r.userid = u.userid
JOIN Materiel m ON r.materialid = m.materialid
JOIN Disponibilite d ON r.disponibiliteid = d.disponibiliteid
WHERE r.date_debut BETWEEN '2025-06-01' AND '2025-06-15';
```

Exemple de cause de lenteur:
```
Seq Scan on reservation r  (cost=0.00..15000.00 rows=500 width=...)
  Filter: (date_debut >= '2025-06-01' AND date_debut <= '2025-06-15')
```
Cela signifie que PostgreSQL scanne toutes les lignes de la table pour filtrer les dates, au lieu d'utiliser un index.

7. Créer des index pour le champ en question ainsi que les clés étrangères impliquées

```sql
-- Index sur Reservation.date_debut
CREATE INDEX idx_reservation_date_debut
ON Reservation(date_debut);

-- Index sur Reservation.userid
CREATE INDEX idx_reservation_userid
ON Reservation(userid);

-- Index sur Reservation.materialid
CREATE INDEX idx_reservation_materialid
ON Reservation(materialid);

-- Index sur Reservation.disponibiliteid
CREATE INDEX idx_reservation_disponibiliteid
ON Reservation(disponibiliteid);
```

8. Relancez la requête et affichez une nouvelle fois le plan d'exécution.
```sql
EXPLAIN ANALYZE
SELECT 
    u.nom,
    u.prenom,
    m.nom AS nom_materiel,
    d.date_debut AS dispo_debut,
    d.date_fin AS dispo_fin,
    r.date_debut AS res_debut,
    r.date_fin AS res_fin
FROM Reservation r
JOIN Utilisateur u ON r.userid = u.userid
JOIN Materiel m ON r.materialid = m.materialid
JOIN Disponibilite d ON r.disponibiliteid = d.disponibiliteid
WHERE r.date_debut BETWEEN '2025-06-01' AND '2025-06-15';
```

9. Création des index pour l'opérateur ``like``

Créer un index pour le nom d'utilisateur et exécuter une recherche impliquant un opérateur ``like`` sur le nom (ex. ``like %nom%1%``). Pour cela, il vous faudra activer l'extension ``gin``

Activez l'extension :

```sql
CREATE EXTENSION pg_trgm;
```

Puis indiquez dans la création de l'index, l'extension ``gin``: 

```sql
CREATE INDEX .... USING gin (nom gin_trgm_ops);
```

Affichez une nouvelle fois le plan d'exécution

Creation index GIN sur la colonne nom
```sql
CREATE INDEX idx_utilisateur_nom_trgm
ON Utilisateur
USING gin (nom gin_trgm_ops);
```

Execution requête LIKE
```sql
EXPLAIN ANALYZE
SELECT *
FROM Utilisateur
WHERE nom LIKE '%nom%1%';
```

Plan d'execution
```sql
EXPLAIN ANALYZE
SELECT 
    u.nom,
    u.prenom,
    m.nom AS nom_materiel,
    d.date_debut AS dispo_debut,
    d.date_fin AS dispo_fin,
    r.date_debut AS res_debut,
    r.date_fin AS res_fin
FROM Reservation r
JOIN Utilisateur u ON r.userid = u.userid
JOIN Materiel m ON r.materialid = m.materialid
JOIN Disponibilite d ON r.disponibiliteid = d.disponibiliteid
WHERE r.date_debut BETWEEN '2025-06-01' AND '2025-06-15';
```