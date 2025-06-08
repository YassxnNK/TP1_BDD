## Exercice 9 : Gestion des retours de matériel avec contrôle des retards
### Contexte
Nous souhaitons ajouter des fonctionnalités de gestion des retours de matériel avec contrôle des retards. Lorsqu'un étudiant rend du matériel emprunté, il doit signaler le retour dans la base de données. Si le matériel est rendu en retard, des pénalités peuvent être appliquées. Vous devez être en mesure de vérifier s'ils ont des retours en retard et le cas échéant, le montant des pénalités encourues.
### Instructions

1.	Mettez à jour le modèle de données existant en ajoutant une nouvelle table "RetourMatériel" avec les colonnes suivantes :
``id_retour`` (clé primaire)
``id_reservation`` (clé étrangère référençant la table "Reservation")
``date_retour`` (date à laquelle le matériel a été rendu)
``retard`` (indicateur de retard, par exemple, un booléen)

```sql
CREATE TABLE RetourMateriel(
   retourid SERIAL,
   reservationid INTEGER NOT NULL,
   date_retour DATE NOT NULL,
   retard BOOLEAN,
   PRIMARY KEY(retourid),
   FOREIGN KEY(reservationid) REFERENCES Reservation(reservationid)
);
```

2.	Modifiez la table "Reservation" en ajoutant une nouvelle colonne "date_retour_effectif" pour enregistrer la date à laquelle le matériel a été rendu.
```sql
ALTER TABLE Reservation
ADD COLUMN date_retour_effectif DATE;
```

3.	Modifiez les contraintes SQL existantes pour prendre en compte les retours de matériel et les retards éventuels lors de la mise à jour des réservations.
```sql
CREATE OR REPLACE FUNCTION calcul_retard()
RETURNS TRIGGER AS $$
BEGIN
   DECLARE date_retour_prevue DATE;
   BEGIN
      SELECT date_fin INTO date_retour_prevue
      FROM Reservation
      WHERE reservationid = NEW.reservationid;

      IF NEW.date_retour > date_retour_prevue THEN
         NEW.retard := TRUE;
      ELSE
         NEW.retard := FALSE;
      END IF;

      RETURN NEW;
   END;
END;
$$ LANGUAGE plpgsql;
```

4.	Implémentez une fonctionnalité permettant de calculer automatiquement le retard sur le retour du matériel, si applicable.
```sql
CREATE TRIGGER trig_calcul_retard
BEFORE INSERT ON RetourMateriel
FOR EACH ROW
EXECUTE FUNCTION calcul_retard();
```

5.	Implémentez une fonctionnalité permettant de vérifier si un retour est en retard et d'afficher le montant des pénalités, le cas échéant.
Testez votre application en effectuant des retours de matériel, certains à l'heure et d'autres en retard, pour vérifier que les contraintes sont correctement appliquées et que les pénalités sont calculées de manière appropriée.

```sql
-- Exemple d’insertion d’un retour (le retard est calculé automatiquement)
-- INSERT INTO RetourMateriel (reservationid, date_retour) VALUES (1, CURRENT_DATE);

-- Mise à jour de Reservation avec la date de retour effective
-- UPDATE Reservation SET date_retour_effectif = CURRENT_DATE WHERE reservationid = 1;

-- Requête pour calculer les pénalités (5€/jour de retard)
-- Affiche les pénalités uniquement pour les retards
SELECT 
   rm.retourid,
   u.nom,
   u.prenom,
   r.date_fin AS date_prevue,
   rm.date_retour AS date_effective,
   (rm.date_retour - r.date_fin) AS jours_retard,
   (rm.date_retour - r.date_fin) * 5 AS montant_penalite
FROM RetourMateriel rm
JOIN Reservation r ON rm.reservationid = r.reservationid
JOIN Utilisateur u ON r.userid = u.userid
WHERE rm.retard = TRUE;
```