------------------------
-- Creation table client
------------------------
CREATE TABLE client
(
    client_uid           VARCHAR2(255),
    client_id            NUMBER                         NOT NULL,
    client_email         VARCHAR(255) DEFAULT 'anonyme' NOT NULL,
    client_name          VARCHAR2(255),
    client_prenom        VARCHAR2(255),
    client_telephone     VARCHAR(255),
    client_adresse       VARCHAR2(255),
    client_cp            VARCHAR2(255),
    client_ville         VARCHAR2(255),
    client_date_creation DATE
);

-- Création sequence
CREATE SEQUENCE seq_id_client
    INCREMENT BY 1;
INSERT INTO client(client_id)
VALUES (seq_id_client.nextval);

-- Ajout clé primaire
ALTER TABLE client
    ADD CONSTRAINT client_pk PRIMARY KEY (client_uid)
        ENABLE;

--------------------------
-- Creation table commande
--------------------------
CREATE TABLE commande
(
    commande_uid     VARCHAR2(255),
    commande_id      NUMBER NOT NULL,
    client_uid       VARCHAR2(255),
    commande_date    DATE,
    commande_montant NUMBER
);

-- Création sequence
CREATE SEQUENCE seq_id_commande
    INCREMENT BY 1;
INSERT INTO commande(commande_id)
VALUES (seq_id_commande.nextval);

-- Ajout clé primaire
ALTER TABLE commande
    ADD CONSTRAINT commande_pk PRIMARY KEY (commande_uid)
        ENABLE;

--Creation d'une clé étrangère
ALTER TABLE commande
    ADD CONSTRAINT commande_client_fk FOREIGN KEY (client_uid)
        REFERENCES client (client_uid)
            ENABLE;

-------------------------
-- Creation table produit
-------------------------
CREATE TABLE produit
(
    produit_uid VARCHAR2(255),
    produit_id  NUMBER        NOT NULL,
    produit_nom VARCHAR2(255) NOT NULL
);

-- Création sequence
CREATE SEQUENCE seq_id_produit
    INCREMENT BY 1;
INSERT INTO produit(produit_id)
VALUES (seq_id_produit.nextval);

-- Ajout clé primaire
ALTER TABLE produit
    ADD CONSTRAINT produit_pk PRIMARY KEY (produit_uid)
        ENABLE;

----------------------------
-- Creation table ingredient
----------------------------
CREATE TABLE ingredient
(
    ingredient_uid   VARCHAR2(255),
    ingredient_id    NUMBER        NOT NULL,
    ingredient_nom   VARCHAR2(255) NOT NULL,
    ingredient_unite VARCHAR2(255) NOT NULL
);

-- Création sequence
CREATE SEQUENCE seq_id_ingredient
    INCREMENT BY 1;
INSERT INTO ingredient(ingredient_id)
VALUES (seq_id_ingredient.nextval);

-- Ajout clé primaire
ALTER TABLE ingredient
    ADD CONSTRAINT ingredient_pk PRIMARY KEY (ingredient_uid)
        ENABLE;

-----------------------------
-- Creation table fournisseur
-----------------------------
CREATE TABLE fournisseur
(
    fournisseur_uid           VARCHAR2(255),
    fournisseur_id            NUMBER        NOT NULL,
    fournisseur_nom           VARCHAR2(255) NOT NULL,
    fournisseur_email         VARCHAR2(255) NOT NULL,
    fournisseur_telephone     VARCHAR(255)  NOT NULL,
    fournisseur_adresse       VARCHAR(255)  NOT NULL,
    fournisseur_cp            VARCHAR(255)  NOT NULL,
    fournisseur_ville         VARCHAR(255)  NOT NULL,
    fournisseur_date_creation DATE          NOT NULL
);

-- Création sequence
CREATE SEQUENCE seq_id_fournisseur
    INCREMENT BY 1;
INSERT INTO fournisseur(fournisseur_id)
VALUES (seq_id_fournisseur.nextval);

-- Ajout clé primaire
ALTER TABLE fournisseur
    ADD CONSTRAINT fournisseur_pk PRIMARY KEY (fournisseur_uid)
        ENABLE;

-----------------------
-- Creation table achat
-----------------------
CREATE TABLE achat
(
    achat_uid                  VARCHAR2(255),
    achat_id                   NUMBER,
    fournisseur_ingredient_uid VARCHAR2(255),
    achat_date                 DATE   NOT NULL,
    achat_quantité             NUMBER NOT NULL,
    achat_prix                 NUMBER
);

-- Création sequence
CREATE SEQUENCE seq_id_achat
    INCREMENT BY 1;
INSERT INTO achat(achat_id)
VALUES (seq_id_achat.nextval);

-- Ajout clé primaire
ALTER TABLE achat
    ADD CONSTRAINT achat_pk PRIMARY KEY (achat_uid)
        ENABLE;

--Creation d'une clé étrangere
ALTER TABLE achat
    ADD CONSTRAINT achat_fournisseur_ingredient_fk FOREIGN KEY (fournisseur_ingredient_uid)
        REFERENCES fournisseur_ingredient (fournisseur_ingredient_uid)
            ENABLE;

-------------------------------------------------------
-- Création table de jointure entre commande et produit
-------------------------------------------------------
CREATE TABLE commande_produit
(
    commande_produit_uid             VARCHAR2(255),
    commande_uid                     VARCHAR2(255),
    produit_uid                      VARCHAR2(255),
    commande_produit_quantite_vendue NUMBER
);

-- Création clé primaire de la table de jointure
ALTER TABLE commande_produit
    ADD CONSTRAINT commande_produit_pk PRIMARY KEY (commande_produit_uid)
        ENABLE;

-- Création clés étangères entre les trois tables
ALTER TABLE commande_produit
    ADD CONSTRAINT commande_produit_fk FOREIGN KEY (commande_uid)
        REFERENCES commande (commande_uid)
            ENABLE;

ALTER TABLE commande_produit
    ADD CONSTRAINT produit_commande_fk FOREIGN KEY (produit_uid)
        REFERENCES produit (produit_uid)
            ENABLE;

---------------------------------------------------------
-- Création table de jointure entre produit et ingredient
---------------------------------------------------------
CREATE TABLE produit_ingredient
(
    produit_ingredient_uid               VARCHAR2(255),
    produit_uid                          VARCHAR2(255),
    ingredient_uid                       VARCHAR2(255),
    produit_ingredient_quantite_utilisee NUMBER
);

-- Création cléf primaire de la table de jointure
ALTER TABLE produit_ingredient
    ADD CONSTRAINT produit_ingredient_pk PRIMARY KEY (produit_ingredient_uid)
        ENABLE;

-- Création clés étangères entre les trois tables
ALTER TABLE produit_ingredient
    ADD CONSTRAINT produit_ingredient_fk FOREIGN KEY (produit_uid)
        REFERENCES produit (produit_uid)
            ENABLE;

ALTER TABLE produit_ingredient
    ADD CONSTRAINT ingredient_produit_fk FOREIGN KEY (ingredient_uid)
        REFERENCES ingredient (ingredient_uid)
            ENABLE;

-------------------------------------------------------------
-- Création table de jointure entre fournisseur et ingredient
-------------------------------------------------------------
CREATE TABLE fournisseur_ingredient
(
    fournisseur_ingredient_uid VARCHAR2(255),
    fournisseur_uid            VARCHAR2(255),
    ingredient_uid             VARCHAR2(255)
);

-- Création cléf primaire de la table de jointure
ALTER TABLE fournisseur_ingredient
    ADD CONSTRAINT fournisseur_ingredient_pk PRIMARY KEY (fournisseur_ingredient_uid)
        ENABLE;

-- Création clés étangères entre les trois tables
ALTER TABLE fournisseur_ingredient
    ADD CONSTRAINT fournisseur_ingredient_fk FOREIGN KEY (fournisseur_uid)
        REFERENCES fournisseur (fournisseur_uid)
            ENABLE;

ALTER TABLE fournisseur_ingredient
    ADD CONSTRAINT ingredient_fournisseur_fk FOREIGN KEY (ingredient_uid)
        REFERENCES ingredient (ingredient_uid)
            ENABLE;



-- STATISTIQUES À EXTRAIRE ;

-- Quel stock j’ai dans tel produit

-- Quand ai-je acheté de la viande pour la dernière fois

-- Le nom du client qui a mangé le plus de poulet entre le 19 mars et le 8 mai
