-- Supprimer les tables si elles existent
BEGIN
    FOR cur_rec IN (SELECT table_name FROM user_tables)
        LOOP
            IF cur_rec.table_name IS NOT NULL THEN
                EXECUTE IMMEDIATE 'DROP TABLE ' || cur_rec.table_name || ' CASCADE CONSTRAINTS';
            END IF;
        END LOOP;
END;

-- Supprimer les séquences si elles existent
BEGIN
    FOR cur_rec IN (SELECT sequence_name FROM user_sequences)
        LOOP
            IF cur_rec.sequence_name IS NOT NULL THEN
                EXECUTE IMMEDIATE 'DROP SEQUENCE ' || cur_rec.sequence_name;
            END IF;
        END LOOP;
END;

-- Supprimer les procédures si elles existent
BEGIN
    FOR cur_rec IN (SELECT object_name FROM user_objects WHERE object_type = 'PROCEDURE')
        LOOP
            IF cur_rec.object_name IS NOT NULL THEN
                EXECUTE IMMEDIATE 'DROP PROCEDURE ' || cur_rec.object_name;
            END IF;
        END LOOP;
END;


------------------------
-- Creation table client
------------------------
CREATE TABLE client
(
    client_uid           VARCHAR2(255) PRIMARY KEY,
    client_id            NUMBER,
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


--------------------------
-- Creation table commande
--------------------------
CREATE TABLE commande
(
    commande_uid     VARCHAR2(255) PRIMARY KEY,
    commande_id      NUMBER NOT NULL,
    client_uid       VARCHAR2(255),
    commande_date    DATE
);

-- Création sequence
CREATE SEQUENCE seq_id_commande
    INCREMENT BY 1;

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
    produit_uid  VARCHAR2(255) PRIMARY KEY,
    produit_id   NUMBER        NOT NULL,
    produit_nom  VARCHAR2(255) NOT NULL,
    produit_prix NUMBER        NOT NULL
);

-- Création sequence
CREATE SEQUENCE seq_id_produit
    INCREMENT BY 1;

---------------------------------
-- Creation table type_ingredient
---------------------------------
CREATE TABLE type_ingredient
(
    type_ingredient_uid              VARCHAR2(255) PRIMARY KEY,
    type_ingredient_id               NUMBER        NOT NULL,
    type_ingredient_nom              VARCHAR2(255) NOT NULL,
    type_ingredient_duree_peremption NUMBER
);

-- Création sequence
CREATE SEQUENCE seq_id_type_ingredient
    INCREMENT BY 1;


----------------------------
-- Creation table ingredient
----------------------------
CREATE TABLE ingredient
(
    ingredient_uid      VARCHAR2(255) PRIMARY KEY,
    type_ingredient_uid VARCHAR2(255),
    ingredient_id       NUMBER        NOT NULL,
    ingredient_nom      VARCHAR2(255) NOT NULL,
    ingredient_unite    VARCHAR2(2)
);

-- Création sequence
CREATE SEQUENCE seq_id_ingredient
    INCREMENT BY 1;

--Creation d'une clé étrangère entre ingredient et type_ingredient
ALTER TABLE ingredient
    ADD CONSTRAINT ingredient_type_ingredient_fk FOREIGN KEY (type_ingredient_uid)
        REFERENCES type_ingredient (type_ingredient_uid)
            ENABLE;


-----------------------------
-- Creation table fournisseur
-----------------------------
CREATE TABLE fournisseur
(
    fournisseur_uid           VARCHAR2(255) PRIMARY KEY,
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


-----------------------
-- Creation table achat
-----------------------
CREATE TABLE achat
(
    achat_uid                  VARCHAR2(255) PRIMARY KEY,
    achat_id                   NUMBER,
    achat_date                 DATE   NOT NULL,
    achat_quantite             NUMBER NOT NULL,
    achat_prix                 NUMBER,
    fournisseur_ingredient_uid VARCHAR(255)
);

-- Création sequence
CREATE SEQUENCE seq_id_achat
    INCREMENT BY 1;


-------------------------------------------------------
-- Création table de jointure entre commande et produit
-------------------------------------------------------
CREATE TABLE commande_produit
(
    commande_produit_uid             VARCHAR2(255) PRIMARY KEY,
    commande_produit_quantite_vendue NUMBER,
    commande_uid                     VARCHAR2(255),
    produit_uid                      VARCHAR2(255)
);

-- Création clés étrangères entre les trois tables
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
    produit_ingredient_uid    VARCHAR2(255) PRIMARY KEY,
    produit_ingredient_volume NUMBER,
    produit_uid               VARCHAR2(255),
    ingredient_uid            VARCHAR2(255)
);

-- Création clefs étrangères entre les trois tables
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
    fournisseur_ingredient_uid VARCHAR2(255) PRIMARY KEY,
    fournisseur_uid            VARCHAR2(255),
    ingredient_uid             VARCHAR2(255)
);

-- Création clés étrangères entre les trois tables
ALTER TABLE fournisseur_ingredient
    ADD CONSTRAINT fournisseur_ingredient_fk FOREIGN KEY (fournisseur_uid)
        REFERENCES fournisseur (fournisseur_uid)
            ENABLE;

ALTER TABLE fournisseur_ingredient
    ADD CONSTRAINT ingredient_fournisseur_fk FOREIGN KEY (ingredient_uid)
        REFERENCES ingredient (ingredient_uid)
            ENABLE;

--Creation d'une clé étrangère entre la table achat et fournisseur_ingredient_uid
ALTER TABLE achat
    ADD CONSTRAINT achat_fournisseur_ingredient_fk FOREIGN KEY (fournisseur_ingredient_uid)
        REFERENCES fournisseur_ingredient (fournisseur_ingredient_uid)
            ENABLE;
