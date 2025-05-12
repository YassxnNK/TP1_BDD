CREATE TABLE Utilisateur(
   userid SERIAL,
   nom VARCHAR(50)  NOT NULL,
   prenom VARCHAR(50)  NOT NULL,
   email VARCHAR(60)  NOT NULL,
   PRIMARY KEY(userid)
);

CREATE TABLE Materiel(
   materialid SERIAL,
   nombre_emprunt INTEGER NOT NULL,
   quantite INTEGER,
   PRIMARY KEY(materialid)
);

CREATE TABLE Reservation(
   reservationid SERIAL,
   date_debut TIMESTAMP NOT NULL,
   date_fin TIMESTAMP NOT NULL,
   materialid INTEGER NOT NULL,
   userid INTEGER NOT NULL,
   PRIMARY KEY(reservationid),
   FOREIGN KEY(materialid) REFERENCES Materiel(materialid),
   FOREIGN KEY(userid) REFERENCES Utilisateur(userid)
);
