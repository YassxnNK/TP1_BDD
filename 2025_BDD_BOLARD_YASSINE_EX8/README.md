1. Mettez à jour le modèle de données existant en ajoutant une nouvelle table "disponibilite" avec les colonnes suivantes : 

* ``id_disponibilite`` (clé primaire)
* ``id_materiel`` (clé étrangère référençant la table "materiel") 
* ``date_debut`` (date de début de la disponibilité) 
* ``date_fin`` (date de fin de la disponibilité) 

```sql
CREATE TABLE Disponibilite(
   id_disponibilite SERIAL,
   date_debut TIMESTAMP NOT NULL,
   date_fin TIMESTAMP NOT NULL,
   id_materiel INTEGER NOT NULL,
   PRIMARY KEY(id_disponibilite),
   FOREIGN KEY(id_materiel) REFERENCES Materiel(materialid)
);
```

2. Modifiez la table "reservation" en ajoutant une nouvelle colonne "id_disponibilite" (clé étrangère référençant la table "disponibilite").
```sql
ALTER TABLE reservation
ADD COLUMN id_disponibilite INTEGER,
ADD CONSTRAINT fk_disponibilite
    FOREIGN KEY (id_disponibilite) REFERENCES disponibilite(id_disponibilite);
```


3. Modifiez les contraintes SQL existantes pour prendre en compte les contraintes de disponibilité lors de la création et de la mise à jour des réservations. 
__Fait dans la requête de la question 2__

4. Implémentez une fonctionnalité permettant de vérifier la disponibilité d'un matériel pour une période donnée avant de permettre la réservation. Si le matériel n'est pas disponible, affichez un message d'erreur approprié. 
```sql
SELECT 
    m.materialid,
    m.nom,
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM Disponibilite d
            WHERE d.id_materiel = m.materialid
              AND '2025-05-20 09:00:00' >= d.date_debut -- Date début ici
              AND '2025-05-25 09:00:00' <= d.date_fin -- Date fin ici
              AND NOT EXISTS (
                  SELECT 1
                  FROM Reservation r
                  WHERE r.id_disponibilite = d.id_disponibilite
                    AND ('2025-05-20 09:00:00', '2025-05-25 09:00:00') OVERLAPS (r.date_debut, r.date_fin)  -- Première date = date début et Seconde date = date fin
              )
        )
        THEN 'OK'
        ELSE 'KO'
    END AS statut_disponibilite
FROM Materiel m
WHERE m.materialid = 9; -- Id matériel ici
```

5. Implémentez une fonctionnalité permettant de gérer les disponibilités du matériel. Les administrateurs doivent pouvoir ajouter, modifier et supprimer des périodes de disponibilité pour chaque matériel.
```sql
CREATE OR REPLACE FUNCTION ajouter_disponibilite(
    p_id_materiel INTEGER,
    p_date_debut TIMESTAMP,
    p_date_fin TIMESTAMP
) RETURNS VOID AS $$
BEGIN
    INSERT INTO Disponibilite (id_materiel, date_debut, date_fin)
    VALUES (p_id_materiel, p_date_debut, p_date_fin);
END;
$$ LANGUAGE plpgsql;
```

```sql
CREATE OR REPLACE FUNCTION modifier_disponibilite(
    p_id_disponibilite INTEGER,
    p_date_debut TIMESTAMP,
    p_date_fin TIMESTAMP
) RETURNS VOID AS $$
BEGIN
    UPDATE Disponibilite
    SET date_debut = p_date_debut,
        date_fin = p_date_fin
    WHERE id_disponibilite = p_id_disponibilite;
END;
$$ LANGUAGE plpgsql;
```

```sql
CREATE OR REPLACE FUNCTION supprimer_disponibilite(
    p_id_disponibilite INTEGER
) RETURNS VOID AS $$
BEGIN
    DELETE FROM Disponibilite
    WHERE id_disponibilite = p_id_disponibilite;
END;
$$ LANGUAGE plpgsql;
```

```sql
-- Ajouter une dispo
SELECT ajouter_disponibilite(1, '2025-06-01 08:00:00', '2025-06-10 18:00:00');

-- Modifier une dispo
SELECT modifier_disponibilite(5, '2025-06-02 09:00:00', '2025-06-11 17:00:00');

-- Supprimer une dispo
SELECT supprimer_disponibilite(5);
```

6. Testez votre application en effectuant des réservations avec différentes périodes pour vérifier que les contraintes de disponibilité sont correctement appliquées.
En ayant utilisé le Query ajouter_disponibilite au dessus et en executant le query ci dessous on obtient bien un retour OK
```sql
SELECT 
    m.materialid,
    m.nom,
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM Disponibilite d
            WHERE d.id_materiel = m.materialid
              AND '2025-06-02 09:00:00' >= d.date_debut -- Date début ici
              AND '2025-06-09 09:00:00' <= d.date_fin -- Date fin ici
              AND NOT EXISTS (
                  SELECT 1
                  FROM Reservation r
                  WHERE r.id_disponibilite = d.id_disponibilite
                    AND ('2025-06-02 09:00:00', '2025-06-09 09:00:00') OVERLAPS (r.date_debut, r.date_fin)  -- Première date = date début et Seconde date = date fin
              )
        )
        THEN 'OK'
        ELSE 'KO'
    END AS statut_disponibilite
FROM Materiel m
WHERE m.materialid = 1; -- Id matériel ici
```