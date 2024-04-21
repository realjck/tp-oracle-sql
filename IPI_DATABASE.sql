-- Supprimer les tables si elles existent
BEGIN
FOR cur_rec IN (SELECT table_name FROM user_tables) LOOP
        IF cur_rec.table_name IS NOT NULL THEN
            EXECUTE IMMEDIATE 'DROP TABLE ' || cur_rec.table_name || ' CASCADE CONSTRAINTS';
END IF;
END LOOP;
END;
/

-- Supprimer les séquences si elles existent
BEGIN
FOR cur_rec IN (SELECT sequence_name FROM user_sequences) LOOP
        IF cur_rec.sequence_name IS NOT NULL THEN
            EXECUTE IMMEDIATE 'DROP SEQUENCE ' || cur_rec.sequence_name;
END IF;
END LOOP;
END;
/

-- Supprimer les procédures si elles existent
BEGIN
FOR cur_rec IN (SELECT object_name FROM user_objects WHERE object_type = 'PROCEDURE') LOOP
        IF cur_rec.object_name IS NOT NULL THEN
            EXECUTE IMMEDIATE 'DROP PROCEDURE ' || cur_rec.object_name;
END IF;
END LOOP;
END;
/


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
UPDATE client SET client_uid = 'valeur_par_defaut' WHERE client_uid IS NULL;
ALTER TABLE client
    MODIFY (client_uid VARCHAR2(255) NOT NULL);
ALTER TABLE client
    ADD CONSTRAINT client_pk PRIMARY KEY
        (
         client_uid
            )
    ENABLE;
DELETE FROM client WHERE client_uid = 'valeur_par_defaut';

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
UPDATE commande SET commande_uid = 'valeur_par_defaut' WHERE commande_uid IS NULL;
ALTER TABLE commande
    MODIFY (commande_uid NOT NULL);
ALTER TABLE commande
    ADD CONSTRAINT commande_pk PRIMARY KEY (commande_uid)
    ENABLE;
DELETE FROM commande WHERE commande_uid = 'valeur_par_defaut';

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
INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Nom du produit');

-- Ajout clé primaire
ALTER TABLE produit
    ADD CONSTRAINT produit_pk PRIMARY KEY (produit_uid)
    ENABLE;


----------------------------
-- Creation table type_ingredient
----------------------------
CREATE TABLE type_ingredient
(
    type_ingredient_uid   VARCHAR2(255),
    type_ingredient_id    NUMBER        NOT NULL,
    type_ingredient_nom   VARCHAR2(255) NOT NULL,
    type_ingredient_duree_peremption NUMBER
);

-- Création sequence
CREATE SEQUENCE seq_id_type_ingredient
    INCREMENT BY 1;
INSERT INTO type_ingredient(type_ingredient_id,type_ingredient_nom)
VALUES (seq_id_type_ingredient.nextval,'typeIngredientNom');

-- Ajout clé primaire
-- Attribuer une valeur par défaut à la colonne type_ingredient_uid
UPDATE type_ingredient SET type_ingredient_uid = 'valeur_par_defaut' WHERE type_ingredient_uid IS NULL;
ALTER TABLE type_ingredient
    ADD CONSTRAINT type_ingredient_pk PRIMARY KEY (type_ingredient_uid)
    ENABLE;

----------------------------
-- Creation table ingredient
----------------------------
CREATE TABLE ingredient
(
    type_ingredient_uid VARCHAR2(255),
    ingredient_uid   VARCHAR2(255),
    ingredient_id    NUMBER        NOT NULL,
    ingredient_nom   VARCHAR2(255) NOT NULL,
    ingredient_unite VARCHAR2(255) NOT NULL
);

-- Création sequence
CREATE SEQUENCE seq_id_ingredient
    INCREMENT BY 1;
INSERT INTO ingredient(ingredient_id,ingredient_nom,ingredient_unite)
VALUES (seq_id_ingredient.nextval, 'nom ingredient', 120);

----------------------
-- Ajout clé primaire
-- Vérifier s'il existe des valeurs NULL dans la colonne ingredient_uid
SELECT COUNT(*) FROM ingredient WHERE ingredient_uid IS NULL;

-- Mettre à jour les valeurs NULL avec des valeurs uniques
UPDATE ingredient SET ingredient_uid = SYS_GUID() WHERE ingredient_uid IS NULL;

-- Assurez-vous qu'il n'y a plus de valeurs NULL dans la colonne ingredient_uid
SELECT COUNT(*) FROM ingredient WHERE ingredient_uid IS NULL;

-- Ajouter la contrainte de clé primaire
ALTER TABLE ingredient MODIFY (ingredient_uid VARCHAR2(255) NOT NULL); -- Si nécessaire
ALTER TABLE ingredient ADD CONSTRAINT ingredient_pk PRIMARY KEY (ingredient_uid) ENABLE;




--Creation d'une clé étrangère entre ingredient et type_ingredient
UPDATE ingredient SET type_ingredient_uid = 'valeur_par_defaut' WHERE type_ingredient_uid IS NULL;
ALTER TABLE ingredient
    ADD CONSTRAINT ingredient_type_ingredient_fk FOREIGN KEY (type_ingredient_uid)
        REFERENCES type_ingredient (type_ingredient_uid)
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
INSERT INTO fournisseur(fournisseur_id,fournisseur_nom,fournisseur_email,fournisseur_telephone,fournisseur_adresse,fournisseur_cp,fournisseur_ville,fournisseur_date_creation)
VALUES (seq_id_fournisseur.nextval,'valeur par defaut','valeur@pardeaaut','valeur par defaut','valeur par defaut','valeur par defaut','valeur par defaut',SYSDATE);

-- Ajout clé primaire
-- Mettre à jour les valeurs NULL dans la colonne fournisseur_uid avec une valeur par défaut
UPDATE fournisseur SET fournisseur_uid = 'nouvelle_valeur' WHERE fournisseur_uid IS NULL;

-- Une fois que toutes les valeurs NULL sont mises à jour, ajoutez la contrainte de clé primaire
ALTER TABLE fournisseur
    MODIFY (fournisseur_uid VARCHAR2(255) NOT NULL); -- Assurez-vous que la colonne n'accepte plus de valeurs NULL

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
    achat_date                 DATE   NOT NULL,
    achat_quantite             NUMBER NOT NULL,
    achat_prix                 NUMBER,
    fournisseur_ingredient_uid VARCHAR(255)
);

-- Création sequence
CREATE SEQUENCE seq_id_achat
    INCREMENT BY 1;
INSERT INTO achat(achat_id,achat_date,achat_quantite,achat_prix)
VALUES (seq_id_achat.nextval,SYSDATE,5,24);

-- Ajout clé primaire
-- Vérifiez s'il y a des valeurs NULL dans la colonne achat_uid
SELECT COUNT(*) FROM achat WHERE achat_uid IS NULL;

-- Si le résultat est supérieur à zéro, mettez à jour les valeurs NULL avec des valeurs appropriées ou supprimez les lignes concernées.
DELETE FROM achat WHERE achat_uid IS NULL;
-- Une fois que toutes les valeurs NULL sont traitées, ajoutez la contrainte de clé primaire
ALTER TABLE achat
    MODIFY (achat_uid VARCHAR2(255) NOT NULL); -- Assurez-vous que la colonne n'accepte plus de valeurs NULL

ALTER TABLE achat
    ADD CONSTRAINT achat_pk PRIMARY KEY (achat_uid)
    ENABLE;




-------------------------------------------------------
-- Création table de jointure entre commande et produit
-------------------------------------------------------
CREATE TABLE commande_produit
(
    commande_produit_uid             VARCHAR2(255),
    commande_produit_quantite_vendue NUMBER,
    commande_uid                     VARCHAR2(255),
    produit_uid                      VARCHAR2(255)
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
    produit_ingredient_quantite_utilisee NUMBER,
    produit_uid                          VARCHAR2(255),
    ingredient_uid                       VARCHAR2(255)
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
    fournisseur_ingredient_uid  VARCHAR2(255),
    fournisseur_uid             VARCHAR2(255),
    ingredient_uid              VARCHAR2(255)
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

--Creation d'une clé étrangere entre la table achat et fournisseur_ingredient_uid
ALTER TABLE achat
    ADD CONSTRAINT achat_fournisseur_ingredient_fk FOREIGN KEY (fournisseur_ingredient_uid)
        REFERENCES fournisseur_ingredient (fournisseur_ingredient_uid)
    ENABLE;


-- creation d'une procedure pour afficher d'autres procedures :
CREATE OR REPLACE PROCEDURE DBMS(i_message IN VARCHAR2 DEFAULT 'Test') AS
BEGIN
    DBMS_OUTPUT.ENABLE;
    DBMS_OUTPUT.ENABLE(1000000);
    DBMS_OUTPUT.PUT_LINE(i_message);
END DBMS;
/
-- Appel de la procédure
BEGIN
    DBMS('mon message');
END;
/

-- Affichage d'un message :
SET SERVEROUTPUT ON;
DECLARE
v_message VARCHAR2(100) := 'Bonjour, monde !';
BEGIN
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/



-------------------------------------------------------
-- obj 1 : Créer des accesseurs (GET/SET) aux tables --
-- (procédure/fonction pour créer, supprimer, mettre--
-- à jour, afficher des informations)
-------------------------------------------------------
-- Procédure pour insérer un client
CREATE OR REPLACE PROCEDURE insert_client(
    i_client_uid           IN VARCHAR2,
    i_client_id            IN NUMBER DEFAULT NULL,
    i_client_email         IN VARCHAR2,
    i_client_name          IN VARCHAR2,
    i_client_prenom        IN VARCHAR2,
    i_client_telephone     IN VARCHAR2,
    i_client_adresse       IN VARCHAR2,
    i_client_cp            IN VARCHAR2,
    i_client_ville         IN VARCHAR2,
    i_client_date_creation IN DATE
)
AS
BEGIN

INSERT INTO client (
    client_uid,
    client_id,
    client_email,
    client_name,
    client_prenom,
    client_telephone,
    client_adresse,
    client_cp,
    client_ville,
    client_date_creation
) VALUES (
             COALESCE(i_client_uid, 'valeur_par_defaut'),
             i_client_id,
             i_client_email,
             i_client_name,
             i_client_prenom,
             i_client_telephone,
             i_client_adresse,
             i_client_cp,
             i_client_ville,
             i_client_date_creation
         );
END insert_client;
/

-- Appel de la procédure
BEGIN
    insert_client(
        i_client_uid => NULL,
        i_client_id => seq_id_client.nextval,
        i_client_email => 'client@example.com',
        i_client_name => 'John',
        i_client_prenom => 'Doe',
        i_client_telephone => '0623243546',
        i_client_adresse => '2 rue ipi',
        i_client_cp => '38720',
        i_client_ville => 'Lyon',
        i_client_date_creation => SYSDATE
    );
END;
/
-------------------
-- Fin objectif 1--
-------------------


-- Création de types d'ingredients viande/legumes/sauces/pain
INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom, type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Pain', 1);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom, type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Légume', 2);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom, type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Viande', 3);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom, type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Sauce', 20);

-- création de produits burger et tacos poulet et viande
INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Burger poulet');

INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Burger viande');

INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Tacos poulet');

INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Tacos viande');

-- création de 20 clients de manière aléatoire (avec nom1/prenom1)

BEGIN
FOR i IN 1..20 LOOP
        DECLARE
v_cp VARCHAR2(5);
            v_ville VARCHAR2(50);
BEGIN
            -- Choix aléatoire d'un code postal parmi les valeurs spécifiées
CASE DBMS_RANDOM.VALUE(1, 5)
                WHEN 1 THEN v_cp := '69001';
WHEN 2 THEN v_cp := '69002';
WHEN 3 THEN v_cp := '38780';
WHEN 4 THEN v_cp := '38200';
ELSE v_cp := '69003';
END CASE;

            -- Attribuer la ville en fonction du code postal
CASE
                WHEN v_cp LIKE '69%' THEN v_ville := 'Lyon';
WHEN v_cp = '38200' THEN v_ville := 'Vienne';
WHEN v_cp = '38780' THEN v_ville := 'Estrablin';
ELSE v_ville := 'Autre';
END CASE;

INSERT INTO client(client_uid, client_id, client_email, client_name, client_prenom, client_telephone, client_adresse, client_cp, client_ville, client_date_creation)
VALUES (SYS_GUID(), seq_id_client.nextval, 'client' || i || '@example.com', 'Nom' || i, 'Prenom' || i, '06' || LPAD(dbms_random.value(10000000, 99999999), 8, '0'), 'Rue' || i, v_cp, v_ville, SYSDATE);
EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Une erreur est survenue lors de la création du client ' || i || ' : ' || SQLERRM);
END;
END LOOP;
COMMIT;
DBMS_OUTPUT.PUT_LINE('Les 20 clients ont été créés avec succès.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Une erreur est survenue lors de la création des clients : ' || SQLERRM);
END;
/

-- Generation de 20 comandes aléatoires depuis 10 jours
BEGIN
FOR i IN 1..20 LOOP
        DECLARE
v_client_name VARCHAR2(255);
            v_montant NUMBER;
            v_commande_date DATE;
BEGIN
            -- Sélection aléatoire d'un numéro de client entre 1 et 20
SELECT 'Nom' || TRUNC(DBMS_RANDOM.VALUE(1, 20))
INTO v_client_name
FROM dual;

-- Génération aléatoire d'un montant entre 7 et 150
v_montant := ROUND(DBMS_RANDOM.VALUE(7, 150), 2);

            -- Génération aléatoire d'une date entre aujourd'hui et il y a 10 jours
            v_commande_date := TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 10));

            -- Insertion de la commande avec le client correspondant, le montant aléatoire et la date aléatoire
INSERT INTO commande (commande_uid, commande_id, client_uid, commande_date, commande_montant)
SELECT
    SYS_GUID(),
    seq_id_commande.NEXTVAL,
    client_uid,
    v_commande_date,
    v_montant
FROM
    client
WHERE
    client_name = v_client_name;
EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Aucun client trouvé.');
END;
END LOOP;
COMMIT;
END;

--
-- STATISTIQUES À EXTRAIRE ;

-- Quel stock j’ai dans tel produit

-- Quand ai-je acheté de la viande pour la dernière fois

-- Le nom du client qui a mangé le plus de poulet entre le 19 mars et le 8 mai


-- Insérer une nouvelle commande avec le client_uid correspondant à celui du client avec client_name = 'Nom1'

