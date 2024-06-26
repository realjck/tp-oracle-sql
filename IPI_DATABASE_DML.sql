-- Procédure de raccourci d'affichage terminal
CREATE OR REPLACE PROCEDURE DBMS(i_message IN VARCHAR2 DEFAULT 'lorem ipsum') AS
BEGIN
    DBMS_OUTPUT.ENABLE;
    DBMS_OUTPUT.ENABLE(1000000);
    DBMS_OUTPUT.PUT_LINE(i_message);
END DBMS;
/

----------
-- Clients
----------

-- Procédure d'ajout d'un client
--------------------------------
CREATE OR REPLACE PROCEDURE insert_client(
    i_client_email IN VARCHAR2,
    i_client_nom IN VARCHAR2,
    i_client_prenom IN VARCHAR2,
    i_client_telephone IN VARCHAR2,
    i_client_adresse IN VARCHAR2,
    i_client_cp IN VARCHAR2,
    i_client_ville IN VARCHAR2
) AS
BEGIN
    INSERT INTO client (client_uid,
                        client_id,
                        client_email,
                        client_nom,
                        client_prenom,
                        client_telephone,
                        client_adresse,
                        client_cp,
                        client_ville,
                        client_date_creation,
                        client_point_carte)
    VALUES (SYS_GUID(),
            SEQ_ID_CLIENT.nextval,
            i_client_email,
            i_client_nom,
            i_client_prenom,
            i_client_telephone,
            i_client_adresse,
            i_client_cp,
            i_client_ville,
            SYSDATE,
            0);
    COMMIT;
END insert_client;
/

-- Appel de la procédure d'ajout des clients
CALL insert_client('jeanmartin@gmail.com', 'Martin', 'Jean', '0654123689',
                  '20 rue des Monts d''Or', '69009', 'Lyon');
CALL insert_client('benali.khaled@orange.fr', 'Benali', 'Khaled', '0785321476',
                  '32 Avenue du Maréchal Leclerc', '75015', 'Paris');
CALL insert_client('zhang.mei@free.fr', 'Zhang', 'Mei', '0643219876',
                  '12 Rue des Lilas', '33000', 'Bordeaux');
CALL insert_client('garcia.pedro@sfr.fr', 'Garcia', 'Pedro', '0245678901',
                  '45 Rue Victor Hugo', '44000', 'Nantes');
CALL insert_client('kowalski.anna@bouyguestelecom.fr', 'Kowalski', 'Anna', '0123456789',
                  '8 Rue Gambetta', '59000', 'Lille');
CALL insert_client('nguyen.thi@numericable.fr', 'Nguyen', 'Thi', '0356789123',
                  '10 Place de la République', '13000', 'Marseille');
CALL insert_client('popov.ivan@laposte.fr', 'Popov', 'Ivan', '0487654321',
                  '21 Boulevard des Alpes', '74000', 'Annecy');
CALL insert_client('smith.mary@orange.fr', 'Singh', 'Anjali', '0598765432',
                  '3 Allée des Bleuets', '80000', 'Amiens');
CALL insert_client('lopez.jose@free.fr', 'Lopez', 'Jose', '0612345678',
                  '4 Rue des Jardins', '94000', 'Créteil');
CALL insert_client('schmidt.hans@bouyguestelecom.fr', 'Schmidt', 'Hans', '0834567890',
                  '6 Avenue du Général Leclerc', '67000', 'Strasbourg');

-- Procédure de mise à jour d'un client
---------------------------------------
CREATE OR REPLACE PROCEDURE update_client(
    p_client_id IN client.client_id%TYPE,
    p_client_email IN client.client_email%TYPE,
    p_client_nom IN client.client_nom%TYPE,
    p_client_prenom IN client.client_prenom%TYPE,
    p_client_telephone IN client.client_telephone%TYPE,
    p_client_adresse IN client.client_adresse%TYPE,
    p_client_cp IN client.client_cp%TYPE,
    p_client_ville IN client.client_ville%TYPE
)
    IS
    v_rows_affected NUMBER;
BEGIN
    UPDATE client
    SET client_email     = p_client_email,
        client_nom       = p_client_nom,
        client_prenom    = p_client_prenom,
        client_telephone = p_client_telephone,
        client_adresse   = p_client_adresse,
        client_cp        = p_client_cp,
        client_ville     = p_client_ville
    WHERE client_id = p_client_id;
    COMMIT;

    -- Vérifier le nombre de lignes affectées
    SELECT COUNT(*)
    INTO v_rows_affected
    FROM client
    WHERE client_id = p_client_id;

    IF v_rows_affected = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Aucun client trouvé avec l''ID ' || p_client_id);
    ELSE
        DBMS('Client ' || p_client_id || ' mis à jour avec succès.');
    END IF;

    COMMIT;
END update_client;
/

-- Appel de la mise à jour d'un client
CALL update_client(9, 'lopez.jose@gmail.com', 'Lopez', 'Jose', '0612345678',
                   '4 Rue des Jardins', '94000', 'Créteil');


-- Procédure de suppression d'un client
---------------------------------------
CREATE OR REPLACE PROCEDURE supprimer_client(
    p_client_id IN client.client_id%TYPE
)
    IS
    v_rows_affected NUMBER;
BEGIN
    -- Vérifier le nombre de lignes affectées
    SELECT COUNT(*)
    INTO v_rows_affected
    FROM client
    WHERE client_id = p_client_id;

    IF v_rows_affected = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Aucun client trouvé avec l''ID ' || p_client_id);
    ELSE
        -- Mise à NULL de la référence des commandes passées
        UPDATE commande
        SET client_uid = NULL
        WHERE client_uid = (SELECT client_uid FROM client WHERE client_id = p_client_id);

        -- Suppression du client
        DELETE
        FROM client
        WHERE client_id = p_client_id;

        COMMIT;
        DBMS('Client ' || p_client_id || ' supprimé avec succès.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END supprimer_client;
/


--------------------------------------
-- Trigger d'ajout de point de fidélité au compte client après une commande
--------------------------------------
CREATE OR REPLACE TRIGGER ajout_point_fidelite_trigger
    BEFORE INSERT OR UPDATE ON commande
    FOR EACH ROW
BEGIN
    UPDATE client
    SET client_point_carte = client_point_carte + 1
    WHERE client_uid = :NEW.client_uid;
END;
/

--------------
-- Ingrédients
--------------

-- Insertion des types d'ingrédients
INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom,
                            type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Pain', 5);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom,
                            type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Légume', 10);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom,
                            type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Viande', 3);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom,
                            type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Sauce', 10);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom,
                            type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Ingrédient base', 60);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom,
                            type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Boisson', 300);


-- Procédure d'ajout d'ingrédient en fonction de leurs types
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_ingredient_par_type(
    p_ingredient_nom IN VARCHAR2,
    p_type_ingredient_nom IN VARCHAR2,
    p_ingredient_unite IN VARCHAR2
)
AS
    v_type_ingredient_uid VARCHAR2(255);
BEGIN
    SELECT type_ingredient_uid
    INTO v_type_ingredient_uid
    FROM type_ingredient
    WHERE type_ingredient_nom = p_type_ingredient_nom;

    IF v_type_ingredient_uid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Ingredient non trouvé : ' || p_ingredient_nom);
    END IF;

    INSERT INTO ingredient (ingredient_uid,
                            type_ingredient_uid,
                            ingredient_id,
                            ingredient_nom,
                            ingredient_unite)
    VALUES (SYS_GUID(),
            v_type_ingredient_uid,
            seq_id_ingredient.nextval,
            p_ingredient_nom,
            p_ingredient_unite);
END insert_ingredient_par_type;
/

-- Ajout des ingrédients
CALL insert_ingredient_par_type('Pita', 'Pain', 'Pc');
CALL insert_ingredient_par_type('Galette', 'Pain', 'Pc');
CALL insert_ingredient_par_type('Buns', 'Pain', 'Pc');
CALL insert_ingredient_par_type('Salade', 'Légume', 'kg');
CALL insert_ingredient_par_type('Tomate', 'Légume', 'kg');
CALL insert_ingredient_par_type('Oignons', 'Légume', 'kg');
CALL insert_ingredient_par_type('Pommes de terre', 'Légume', 'kg');
CALL insert_ingredient_par_type('Boeuf', 'Viande', 'kg');
CALL insert_ingredient_par_type('Poulet', 'Viande', 'kg');
CALL insert_ingredient_par_type('Ketchup', 'Sauce', 'L');
CALL insert_ingredient_par_type('Mayonnaise', 'Sauce', 'L');
CALL insert_ingredient_par_type('Huile', 'Ingrédient base', 'L');
CALL insert_ingredient_par_type('Sel', 'Ingrédient base', 'kg');
CALL insert_ingredient_par_type('Coca', 'Boisson', 'Pc');
CALL insert_ingredient_par_type('Orangina', 'Boisson', 'Pc');


-- Insertion des produits
INSERT INTO produit(produit_uid, produit_id, produit_nom, produit_prix)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Burger mayonnaise', 9);

INSERT INTO produit(produit_uid, produit_id, produit_nom, produit_prix)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Burger ketchup', 9);

INSERT INTO produit(produit_uid, produit_id, produit_nom, produit_prix)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Tacos', 11.50);

INSERT INTO produit(produit_uid, produit_id, produit_nom, produit_prix)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Galette poulet', 7.50);

INSERT INTO produit(produit_uid, produit_id, produit_nom, produit_prix)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Kebab mayonnaise', 7.50);

INSERT INTO produit(produit_uid, produit_id, produit_nom, produit_prix)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Kebab ketchup', 7.50);

INSERT INTO produit(produit_uid, produit_id, produit_nom, produit_prix)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Frites', 3.80);

INSERT INTO produit(produit_uid, produit_id, produit_nom, produit_prix)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Cannette Coca', 2.50);

INSERT INTO produit(produit_uid, produit_id, produit_nom, produit_prix)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Cannette Orangina', 2.50);


-- Procédure ajoute un ingrédient à un produit selon une certaine quantité utilisée
-----------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ajoute_ingredient_produit(
    p_ingredient_nom IN VARCHAR2,
    p_produit_nom IN VARCHAR2,
    p_quantite_utilise IN NUMBER
) IS
    v_ingredient_uid VARCHAR2(255);
    v_produit_uid    VARCHAR2(255);
BEGIN
    SELECT ingredient_uid
    INTO v_ingredient_uid
    FROM ingredient
    WHERE ingredient_nom = p_ingredient_nom;

    IF v_ingredient_uid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Ingredient non trouvé : ' || p_ingredient_nom);
    END IF;

    -- Vérifie si produit existe
    SELECT produit_uid
    INTO v_produit_uid
    FROM produit
    WHERE produit_nom = p_produit_nom;

    IF v_produit_uid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Produit non trouvé : ' || p_produit_nom);
    END IF;

    -- Insert ingrédient avec quantité utilisée dans la table produit_ingredient
    INSERT INTO produit_ingredient (produit_ingredient_uid,
                                    produit_ingredient_quantite_utilise,
                                    produit_uid,
                                    ingredient_uid)
    VALUES (SYS_GUID(),
            p_quantite_utilise,
            v_produit_uid,
            v_ingredient_uid);
    COMMIT;
END ajoute_ingredient_produit;
/

-- Ajout des recettes d'ingrédients pour les produits
-----------------------------------------------------
-- Pour info : SQL Developper provoque une erreur lors de valeurs décimales dans les appels de procédures pour les OS français.
-- Changer le NILS séparateur de virgule en point dans les préférences ne résout pas ce problème.
-- La solution trouvée est de passer les valeurs dans TO_NUMBER.
-- Ce dysfonctionnement n'est pas présent sur les autres IDE comme Jetbrains.
CALL ajoute_ingredient_produit('Buns', 'Burger mayonnaise', 1);
CALL ajoute_ingredient_produit('Salade', 'Burger mayonnaise', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Tomate', 'Burger mayonnaise', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Oignons', 'Burger mayonnaise', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Boeuf', 'Burger mayonnaise', TO_NUMBER('0,15'));
CALL ajoute_ingredient_produit('Mayonnaise', 'Burger mayonnaise', TO_NUMBER('0,025'));

CALL ajoute_ingredient_produit('Buns', 'Burger ketchup', 1);
CALL ajoute_ingredient_produit('Salade', 'Burger ketchup', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Tomate', 'Burger ketchup', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Oignons', 'Burger ketchup', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Boeuf', 'Burger ketchup', TO_NUMBER('0,15'));
CALL ajoute_ingredient_produit('Ketchup', 'Burger ketchup', TO_NUMBER('0,025'));

CALL ajoute_ingredient_produit('Galette', 'Tacos', 1);
CALL ajoute_ingredient_produit('Pommes de terre', 'Tacos', TO_NUMBER('0,1'));
CALL ajoute_ingredient_produit('Salade', 'Tacos', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Tomate', 'Tacos', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Oignons', 'Tacos', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Boeuf', 'Tacos', TO_NUMBER('0,2'));
CALL ajoute_ingredient_produit('Poulet', 'Tacos', TO_NUMBER('0,2'));
CALL ajoute_ingredient_produit('Mayonnaise', 'Tacos', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Ketchup', 'Tacos', TO_NUMBER('0,025'));

CALL ajoute_ingredient_produit('Galette', 'Galette poulet', 1);
CALL ajoute_ingredient_produit('Salade', 'Galette poulet', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Tomate', 'Galette poulet', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Oignons', 'Galette poulet', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Poulet', 'Galette poulet', TO_NUMBER('0,25'));
CALL ajoute_ingredient_produit('Mayonnaise', 'Galette poulet', TO_NUMBER('0,025'));

CALL ajoute_ingredient_produit('Pita', 'Kebab mayonnaise', 1);
CALL ajoute_ingredient_produit('Salade', 'Kebab mayonnaise', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Tomate', 'Kebab mayonnaise', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Oignons', 'Kebab mayonnaise', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Boeuf', 'Kebab mayonnaise', TO_NUMBER('0,1'));
CALL ajoute_ingredient_produit('Poulet', 'Kebab mayonnaise', TO_NUMBER('0,1'));
CALL ajoute_ingredient_produit('Mayonnaise', 'Kebab mayonnaise', TO_NUMBER('0,025'));

CALL ajoute_ingredient_produit('Pita', 'Kebab ketchup', 1);
CALL ajoute_ingredient_produit('Salade', 'Kebab ketchup', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Tomate', 'Kebab ketchup', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Oignons', 'Kebab ketchup', TO_NUMBER('0,025'));
CALL ajoute_ingredient_produit('Boeuf', 'Kebab ketchup', TO_NUMBER('0,1'));
CALL ajoute_ingredient_produit('Poulet', 'Kebab ketchup', TO_NUMBER('0,1'));
CALL ajoute_ingredient_produit('Ketchup', 'Kebab ketchup', TO_NUMBER('0,025'));

CALL ajoute_ingredient_produit('Pommes de terre', 'Frites', TO_NUMBER('0,15'));
CALL ajoute_ingredient_produit('Huile', 'Frites', TO_NUMBER('0,020'));
CALL ajoute_ingredient_produit('Sel', 'Frites', TO_NUMBER('0,002'));

CALL ajoute_ingredient_produit('Coca', 'Cannette Coca', 1);

CALL ajoute_ingredient_produit('Orangina', 'Cannette Orangina', 1);


-------------------------
-- Création des commandes
-------------------------

--Procédure d'insert d'une commande-produit en fonction de l'id de la commande,
-- de l'email d'un client, du produit et de sa quantité :
---------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_commande(
    p_commande_id IN NUMBER,
    p_client_email IN VARCHAR2,
    p_commande_date IN DATE,
    p_produit_nom IN VARCHAR2,
    p_quantite_produit_vendue IN NUMBER
)
    IS
    v_client_uid   VARCHAR2(255);
    v_produit_uid  VARCHAR2(255);
    v_commande_uid VARCHAR2(255);
    v_rows_found   NUMBER;
BEGIN

    -- Récupérer l'UID du client en fonction de son email
    IF p_client_email IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_rows_found
        FROM client
        WHERE client_email = p_client_email;
        IF v_rows_found = 0 THEN
            RAISE_APPLICATION_ERROR(-20000, 'Aucun client trouvé avec l''email ' || p_client_email);
        ELSE
            SELECT client_uid
            INTO v_client_uid
            FROM client
            WHERE client_email = p_client_email;
        END IF;
    ELSE
        v_client_uid := NULL;
    END IF;

    -- Commande existante ? on récupère l'UID
    MERGE INTO commande c
    USING dual d
    ON (c.commande_id = p_commande_id)
    WHEN NOT MATCHED THEN
        INSERT (commande_uid, commande_id, client_uid, commande_date)
        VALUES (SYS_GUID(), p_commande_id, v_client_uid, p_commande_date);

    SELECT commande_uid
    INTO v_commande_uid
    FROM commande
    WHERE commande_id = p_commande_id;

    -- Récupérer l'UID du produit en fonction de son nom
    SELECT COUNT(*)
    INTO v_rows_found
    FROM produit
    WHERE produit_nom = p_produit_nom;
    IF v_rows_found = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Produit non valide: ' || p_produit_nom);
    ELSE
        SELECT produit_uid
        INTO v_produit_uid
        FROM produit
        WHERE produit_nom = p_produit_nom;
    END IF;

    -- Insérer l'entrée dans la table commande_produit
    INSERT INTO commande_produit (commande_produit_uid, commande_produit_quantite_vendue, commande_uid, produit_uid)
    VALUES (SYS_GUID(), p_quantite_produit_vendue, v_commande_uid, v_produit_uid);
    COMMIT;
END insert_commande;
/

-- Insertion des commandes
--------------------------
CALL insert_commande(1, 'jeanmartin@gmail.com',
                     TO_DATE('2024-04-27 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger mayonnaise', 1);
CALL insert_commande(1, 'jeanmartin@gmail.com',
                     TO_DATE('2024-04-27 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 1);
CALL insert_commande(1, 'jeanmartin@gmail.com',
                     TO_DATE('2024-04-27 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Coca', 1);

CALL insert_commande(2, NULL,
                     TO_DATE('2024-04-27 12:10:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger ketchup', 2);
CALL insert_commande(2, NULL,
                     TO_DATE('2024-04-27 12:10:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 2);
CALL insert_commande(2, NULL,
                     TO_DATE('2024-04-27 12:10:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Orangina', 2);

CALL insert_commande(3, 'benali.khaled@orange.fr',
                     TO_DATE('2024-04-27 12:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Tacos', 4);
CALL insert_commande(3, 'benali.khaled@orange.fr',
                     TO_DATE('2024-04-27 12:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 2);

CALL insert_commande(4, NULL,
                     TO_DATE('2024-04-27 12:20:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Galette poulet', 3);

CALL insert_commande(5, 'zhang.mei@free.fr',
                     TO_DATE('2024-04-27 12:25:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Kebab mayonnaise', 2);
CALL insert_commande(5, 'zhang.mei@free.fr',
                     TO_DATE('2024-04-27 12:25:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Orangina', 2);

CALL insert_commande(6, NULL,
                     TO_DATE('2024-04-27 12:30:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Tacos', 1);
CALL insert_commande(6, NULL,
                     TO_DATE('2024-04-27 12:30:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 3);

CALL insert_commande(7, 'nguyen.thi@numericable.fr',
                     TO_DATE('2024-04-27 12:35:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Galette poulet', 5);
CALL insert_commande(7, 'nguyen.thi@numericable.fr',
                     TO_DATE('2024-04-27 12:35:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 3);

CALL insert_commande(8, 'kowalski.anna@bouyguestelecom.fr',
                     TO_DATE('2024-04-27 12:40:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger mayonnaise', 1);
CALL insert_commande(8, 'kowalski.anna@bouyguestelecom.fr',
                     TO_DATE('2024-04-27 12:40:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 1);
CALL insert_commande(8, 'kowalski.anna@bouyguestelecom.fr',
                     TO_DATE('2024-04-27 12:40:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Orangina', 1);

CALL insert_commande(9, 'garcia.pedro@sfr.fr',
                     TO_DATE('2024-04-27 12:45:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Kebab mayonnaise', 1);
CALL insert_commande(9, 'garcia.pedro@sfr.fr',
                     TO_DATE('2024-04-27 12:45:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Orangina', 1);

CALL insert_commande(10, NULL,
                     TO_DATE('2024-04-27 12:50:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger ketchup', 2);
CALL insert_commande(10, NULL,
                     TO_DATE('2024-04-27 12:50:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Coca', 2);

CALL insert_commande(11, 'schmidt.hans@bouyguestelecom.fr',
                     TO_DATE('2024-04-27 12:55:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Galette poulet', 1);
CALL insert_commande(11, 'schmidt.hans@bouyguestelecom.fr',
                     TO_DATE('2024-04-27 12:55:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Coca', 1);

CALL insert_commande(12, 'lopez.jose@gmail.com',
                     TO_DATE('2024-04-27 13:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Kebab ketchup', 1);

CALL insert_commande(13, 'smith.mary@orange.fr',
                     TO_DATE('2024-04-27 13:05:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Tacos', 6);
CALL insert_commande(13, 'smith.mary@orange.fr',
                     TO_DATE('2024-04-27 13:05:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 6);

CALL insert_commande(14, NULL,
                     TO_DATE('2024-04-27 13:10:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Galette poulet', 3);

CALL insert_commande(15, 'popov.ivan@laposte.fr',
                     TO_DATE('2024-04-27 13:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Kebab mayonnaise', 1);
CALL insert_commande(15, 'popov.ivan@laposte.fr',
                     TO_DATE('2024-04-27 13:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Kebab ketchup', 1);
CALL insert_commande(15, 'popov.ivan@laposte.fr',
                     TO_DATE('2024-04-27 13:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 2);

CALL insert_commande(16, 'jeanmartin@gmail.com',
                     TO_DATE('2024-04-28 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger mayonnaise', 1);

CALL insert_commande(17, 'jeanmartin@gmail.com',
                     TO_DATE('2024-04-28 14:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger mayonnaise', 1);

CALL insert_commande(18, 'kowalski.anna@bouyguestelecom.fr',
                     TO_DATE('2024-04-28 18:40:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger mayonnaise', 1);
CALL insert_commande(18, 'kowalski.anna@bouyguestelecom.fr',
                     TO_DATE('2024-04-28 18:40:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 1);
CALL insert_commande(18, 'kowalski.anna@bouyguestelecom.fr',
                     TO_DATE('2024-04-28 18:40:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Orangina', 1);

CALL insert_commande(19, 'benali.khaled@orange.fr',
                     TO_DATE('2024-04-28 12:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Tacos', 1);
CALL insert_commande(19, 'benali.khaled@orange.fr',
                     TO_DATE('2024-04-28 12:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 1);

CALL insert_commande(20, 'jeanmartin@gmail.com',
                     TO_DATE('2024-04-29 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger mayonnaise', 1);



----------------------------
-- Création des fournisseurs
----------------------------

-- Procédure pour insérer un fournisseur
----------------------------------------
CREATE OR REPLACE PROCEDURE insert_fournisseur(
    p_fournisseur_nom IN VARCHAR2,
    p_fournisseur_email IN VARCHAR2,
    p_fournisseur_telephone IN VARCHAR,
    p_fournisseur_adresse IN VARCHAR,
    p_fournisseur_cp IN VARCHAR,
    p_fournisseur_ville IN VARCHAR
) AS
BEGIN
    -- Insertion du nouveau fournisseur dans la table
    INSERT INTO fournisseur (fournisseur_uid,
                             fournisseur_id,
                             fournisseur_nom,
                             fournisseur_email,
                             fournisseur_telephone,
                             fournisseur_adresse,
                             fournisseur_cp,
                             fournisseur_ville,
                             fournisseur_date_creation)
    VALUES (SYS_GUID(),
            seq_id_fournisseur.nextval,
            p_fournisseur_nom,
            p_fournisseur_email,
            p_fournisseur_telephone,
            p_fournisseur_adresse,
            p_fournisseur_cp,
            p_fournisseur_ville,
            SYSDATE);
    COMMIT;
END insert_fournisseur;
/

-- Test d'appel de la procédure, insertion des fournisseurs
CALL
    insert_fournisseur(
            p_fournisseur_nom => 'Le grand marché',
            p_fournisseur_email => 'Le_grand_marche@email.com',
            p_fournisseur_telephone => '0836656565',
            p_fournisseur_adresse => '12 place du marché',
            p_fournisseur_cp => '69001',
            p_fournisseur_ville => 'Lyon'
    );


CALL insert_fournisseur('Le champs des possible' , 'lechampdespossible@hotmail.fr'
        , '0643545625', '2 chemin de l''alouette'
        , '42100', 'Saint Etienne');

CALL insert_fournisseur('Le fermier local', 'fermierlocal@free.fr',
                        '0625485621', '4 rue du marché',
                        '69100', 'Villeurbanne');

CALL insert_fournisseur('Miam et Cie', 'miametcie@lycos.fr',
                        '0625434321', '453 rue plantée',
                        '69101', 'Lyon');

CALL insert_fournisseur('L''agriculteur de demain', 'agriculteurdedemain@yahoo.com',
                        '0645543793', '4098 rue de l''avenir',
                        '69101', 'Lyon');

CALL insert_fournisseur('Le campagnard de l''amour', 'campagnarddelamour@sfr.fr',
                        '0625434321', '43 rue du coeur',
                        '69101', 'Lyon');

CALL insert_fournisseur('Aqua Soda', 'cepadelo@aquasoda.com',
                        '0658473849', '853 rue des cyprès',
                        '38200', 'Vienne');


----------------------------------------------
-- Création de la table fournisseur_ingredient
----------------------------------------------

CREATE OR REPLACE PROCEDURE insert_fournisseur_ingredient(
    p_fournisseur_nom IN VARCHAR2,
    p_ingredient_nom IN VARCHAR2
) IS
    v_fournisseur_uid VARCHAR2(255);
    v_ingredient_uid  VARCHAR2(255);
BEGIN
    -- Récupérer l'UID du fournisseur en fonction de son nom
    SELECT fournisseur_uid
    INTO v_fournisseur_uid
    FROM fournisseur
    WHERE fournisseur_nom = p_fournisseur_nom;

    -- Récupérer l'UID de l'ingrédient en fonction de son nom
    SELECT ingredient_uid
    INTO v_ingredient_uid
    FROM ingredient
    WHERE ingredient_nom = p_ingredient_nom;

    -- Insérer dans la table fournisseur_ingredient
    INSERT INTO fournisseur_ingredient (fournisseur_ingredient_uid, fournisseur_uid, ingredient_uid)
    VALUES (SYS_GUID(), v_fournisseur_uid, v_ingredient_uid);

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nom de fournisseur ou d''ingrédient invalide.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS('Erreur: ' || SQLERRM);
END insert_fournisseur_ingredient;
/

-- Insertion de valeurs dans la table fournisseur_ingredients
CALL insert_fournisseur_ingredient('Le grand marché', 'Pita');
CALL insert_fournisseur_ingredient('Le grand marché', 'Galette');
CALL insert_fournisseur_ingredient('Le grand marché', 'Buns');
CALL insert_fournisseur_ingredient('Le grand marché', 'Salade');
CALL insert_fournisseur_ingredient('Le grand marché', 'Tomate');
CALL insert_fournisseur_ingredient('Le fermier local', 'Oignons');
CALL insert_fournisseur_ingredient('Le fermier local', 'Pommes de terre');
CALL insert_fournisseur_ingredient('Miam et Cie', 'Pita');
CALL insert_fournisseur_ingredient('Miam et Cie', 'Galette');
CALL insert_fournisseur_ingredient('Miam et Cie', 'Buns');
CALL insert_fournisseur_ingredient('Miam et Cie', 'Salade');
CALL insert_fournisseur_ingredient('Miam et Cie', 'Ketchup');
CALL insert_fournisseur_ingredient('Miam et Cie', 'Mayonnaise');
CALL insert_fournisseur_ingredient('Miam et Cie', 'Huile');
CALL insert_fournisseur_ingredient('Miam et Cie', 'Sel');
CALL insert_fournisseur_ingredient('L''agriculteur de demain', 'Boeuf');
CALL insert_fournisseur_ingredient('L''agriculteur de demain', 'Poulet');
CALL insert_fournisseur_ingredient('L''agriculteur de demain', 'Ketchup');
CALL insert_fournisseur_ingredient('L''agriculteur de demain', 'Mayonnaise');
CALL insert_fournisseur_ingredient('Aqua Soda', 'Coca');
CALL insert_fournisseur_ingredient('Aqua Soda', 'Orangina');


----------------------
-- création des achats
----------------------

-- Procédure pour insérer un achat en fonction du fournisseur, de l'ingrédient, de la quantité et du prix d'achat
CREATE OR REPLACE PROCEDURE insert_achat(
    p_fournisseur_nom IN VARCHAR2,
    p_ingredient_nom IN VARCHAR2,
    p_quantite IN NUMBER,
    p_prix IN NUMBER
) AS
    v_fournisseur_uid VARCHAR2(255);
    v_ingredient_uid  VARCHAR2(255);
BEGIN
    -- Récupérer l'identifiant du fournisseur en fonction de son nom
    SELECT fournisseur_uid
    INTO v_fournisseur_uid
    FROM fournisseur
    WHERE fournisseur_nom = p_fournisseur_nom;

    -- Récupérer l'identifiant du produit en fonction de son nom
    SELECT ingredient_uid
    INTO v_ingredient_uid
    FROM ingredient
    WHERE ingredient_nom = p_ingredient_nom;

    -- Insérer l'achat dans la table achat
    INSERT INTO achat (achat_uid, achat_id, achat_date, achat_quantite, achat_prix_unite, fournisseur_ingredient_uid)
    VALUES (SYS_GUID(), seq_id_achat.NEXTVAL, SYSDATE, p_quantite, p_prix,
            (SELECT fournisseur_ingredient_uid
             FROM fournisseur_ingredient
             WHERE fournisseur_uid = v_fournisseur_uid
               AND ingredient_uid = v_ingredient_uid));

    COMMIT;
END insert_achat;
/

-- Insertion des achats
CALL insert_achat('Le grand marché', 'Pita', 20, TO_NUMBER('0,6'));
CALL insert_achat('Le grand marché', 'Galette', 30, TO_NUMBER('0,4'));
CALL insert_achat('Miam et Cie', 'Buns', 30, TO_NUMBER('1,2'));
CALL insert_achat('Le grand marché', 'Salade', 5, TO_NUMBER('2,50'));
CALL insert_achat('Le grand marché', 'Tomate', 5, TO_NUMBER('3,20'));
CALL insert_achat('Le fermier local', 'Oignons', 5, TO_NUMBER('2,80'));
CALL insert_achat('Le fermier local', 'Pommes de terre', 20, TO_NUMBER('1,10'));
CALL insert_achat('L''agriculteur de demain', 'Boeuf', 10, TO_NUMBER('25,80'));
CALL insert_achat('L''agriculteur de demain', 'Poulet', 8, TO_NUMBER('18,50'));
CALL insert_achat('Miam et Cie', 'Ketchup', 3, TO_NUMBER('3,50'));
CALL insert_achat('Miam et Cie', 'Mayonnaise', 3, TO_NUMBER('3,20'));
CALL insert_achat('Miam et Cie', 'Huile', 8, TO_NUMBER('2,80'));
CALL insert_achat('Miam et Cie', 'Sel', 2, TO_NUMBER('0,80'));
CALL insert_achat('Aqua Soda', 'Coca', 12, TO_NUMBER('0,40'));
CALL insert_achat('Aqua Soda', 'Orangina', 12, TO_NUMBER('0,45'));


--------------------
-- création des Vues
--------------------

---------------------------------------------------------------------------
-- Vues Commande par client avec ingrédients utilisé pour faire la commande
---------------------------------------------------------------------------
CREATE OR REPLACE VIEW vue_commande_client_produit AS
SELECT c.client_nom,
       c.client_prenom,
       co.commande_id,
       co.commande_date,
       LISTAGG(p.produit_nom, ', ')                              AS produits,
       SUM(p.produit_prix * cp.COMMANDE_PRODUIT_QUANTITE_VENDUE) AS total_prix
FROM commande co
         LEFT JOIN client c ON co.client_uid = c.client_uid
         LEFT JOIN commande_produit cp ON co.commande_uid = cp.commande_uid
         LEFT JOIN produit p ON cp.produit_uid = p.produit_uid
GROUP BY c.client_nom,
         c.client_prenom,
         co.commande_id,
         co.commande_date
ORDER BY co.commande_id;


-----------------------------------------
-- Vue de l'état du stock des ingrédients
-----------------------------------------
CREATE OR REPLACE VIEW vue_ingredients_stock AS
SELECT i.ingredient_id,
       i.ingredient_nom,
       i.ingredient_unite,
       COALESCE(achete.quantite_achetee, 0)                                          AS quantite_achetee,
       COALESCE(utilise.quantite_utilisee, 0)                                        AS quantite_utilisee,
       COALESCE(achete.quantite_achetee, 0) - COALESCE(utilise.quantite_utilisee, 0) AS stock_restant,
       ROUND(
               CASE
                   WHEN COALESCE(achete.quantite_achetee, 0) <> 0 THEN
                       (COALESCE(achete.quantite_achetee, 0) - COALESCE(utilise.quantite_utilisee, 0)) /
                       COALESCE(achete.quantite_achetee, 0) * 100
                   END, 2)                                                           AS pourcentage_stock_restant
FROM ingredient i
         LEFT JOIN (SELECT pi.ingredient_uid,
                           SUM(pi.produit_ingredient_quantite_utilise *
                               cp.commande_produit_quantite_vendue) AS quantite_utilisee
                    FROM produit_ingredient pi
                             JOIN commande_produit cp ON pi.produit_uid = cp.produit_uid
                             JOIN commande c ON cp.commande_uid = c.commande_uid
                    GROUP BY pi.ingredient_uid) utilise ON i.ingredient_uid = utilise.ingredient_uid
         LEFT JOIN (SELECT fi.ingredient_uid,
                           SUM(a.achat_quantite) AS quantite_achetee
                    FROM fournisseur_ingredient fi
                             JOIN achat a ON fi.fournisseur_ingredient_uid = a.fournisseur_ingredient_uid
                    GROUP BY fi.ingredient_uid) achete ON i.ingredient_uid = achete.ingredient_uid
ORDER BY i.ingredient_id;


----------------------------------------------------------------
-- Vue des ingredient utilisés en fonction des commandes passées
----------------------------------------------------------------

-- Vue du total des produits utilisés
CREATE OR REPLACE VIEW vue_ingredients_consommes_total AS
SELECT *
FROM (SELECT ingredient_nom,
             SUM(pi.produit_ingredient_quantite_utilise * cp.commande_produit_quantite_vendue) as quantite_utilisee
      FROM ingredient i
               LEFT JOIN produit_ingredient pi ON pi.ingredient_uid = i.ingredient_uid
               LEFT JOIN produit p ON p.produit_uid = pi.produit_uid
               LEFT JOIN commande_produit cp ON cp.produit_uid = p.produit_uid
               LEFT JOIN commande c on c.commande_uid = cp.commande_uid
      GROUP BY ingredient_nom) PIVOT (
    SUM(quantite_utilisee)
    FOR ingredient_nom IN (
        'Pita',
        'Galette',
        'Buns',
        'Salade',
        'Tomate',
        'Oignons',
        'Pommes de terre',
        'Boeuf',
        'Poulet',
        'Ketchup',
        'Mayonnaise',
        'Huile',
        'Sel',
        'Coca',
        'Orangina'
        )
    );


-- Vue du détail des produits par commandes
CREATE OR REPLACE VIEW vue_ingredients_consommes_par_commande AS
SELECT c.commande_id,
       SUM(CASE
               WHEN i.ingredient_nom = 'Pita' THEN pi.produit_ingredient_quantite_utilise *
                                                   cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Pita,
       SUM(CASE
               WHEN i.ingredient_nom = 'Galette' THEN pi.produit_ingredient_quantite_utilise *
                                                      cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Galette,
       SUM(CASE
               WHEN i.ingredient_nom = 'Buns' THEN pi.produit_ingredient_quantite_utilise *
                                                   cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Buns,
       SUM(CASE
               WHEN i.ingredient_nom = 'Salade' THEN pi.produit_ingredient_quantite_utilise *
                                                     cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Salade,
       SUM(CASE
               WHEN i.ingredient_nom = 'Tomate' THEN pi.produit_ingredient_quantite_utilise *
                                                     cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Tomate,
       SUM(CASE
               WHEN i.ingredient_nom = 'Oignons' THEN pi.produit_ingredient_quantite_utilise *
                                                      cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Oignons,
       SUM(CASE
               WHEN i.ingredient_nom = 'Pommes de terre' THEN pi.produit_ingredient_quantite_utilise *
                                                              cp.commande_produit_quantite_vendue
               ELSE 0 END) AS "Pommes de terre",
       SUM(CASE
               WHEN i.ingredient_nom = 'Boeuf' THEN pi.produit_ingredient_quantite_utilise *
                                                    cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Boeuf,
       SUM(CASE
               WHEN i.ingredient_nom = 'Poulet' THEN pi.produit_ingredient_quantite_utilise *
                                                     cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Poulet,
       SUM(CASE
               WHEN i.ingredient_nom = 'Ketchup' THEN pi.produit_ingredient_quantite_utilise *
                                                      cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Ketchup,
       SUM(CASE
               WHEN i.ingredient_nom = 'Mayonnaise' THEN pi.produit_ingredient_quantite_utilise *
                                                         cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Mayonnaise,
       SUM(CASE
               WHEN i.ingredient_nom = 'Huile' THEN pi.produit_ingredient_quantite_utilise *
                                                    cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Huile,
       SUM(CASE
               WHEN i.ingredient_nom = 'Sel' THEN pi.produit_ingredient_quantite_utilise *
                                                  cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Sel,
       SUM(CASE
               WHEN i.ingredient_nom = 'Coca' THEN pi.produit_ingredient_quantite_utilise *
                                                   cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Coca,
       SUM(CASE
               WHEN i.ingredient_nom = 'Orangina' THEN pi.produit_ingredient_quantite_utilise *
                                                       cp.commande_produit_quantite_vendue
               ELSE 0 END) AS Orangina
FROM ingredient i
         LEFT JOIN produit_ingredient pi ON pi.ingredient_uid = i.ingredient_uid
         LEFT JOIN produit p ON p.produit_uid = pi.produit_uid
         LEFT JOIN commande_produit cp ON cp.produit_uid = p.produit_uid
         LEFT JOIN commande c on c.commande_uid = cp.commande_uid
GROUP BY c.commande_id;


--------------------------------------
-- Vues du nombre de produit commandés
--------------------------------------
CREATE OR REPLACE VIEW vue_produits_par_commande AS
SELECT commande_id,
       SUM(NVL(burger_mayonnaise, 0)) AS burger_mayonnaise,
       SUM(NVL(burger_ketchup, 0))    AS burger_ketchup,
       SUM(NVL(tacos, 0))             AS tacos,
       SUM(NVL(galette_poulet, 0))    AS galette_poulet,
       SUM(NVL(kebab_mayonnaise, 0))  AS kebab_mayonnaise,
       SUM(NVL(kebab_ketchup, 0))     AS kebab_ketchup,
       SUM(NVL(frites, 0))            AS frites,
       SUM(NVL(cannette_coca, 0))     AS cannette_coca,
       SUM(NVL(cannette_orangina, 0)) AS cannette_orangina
FROM (SELECT c.commande_id,
             cp.commande_uid,
             cp.produit_uid,
             cp.commande_produit_quantite_vendue,
             p.produit_nom
      FROM commande_produit cp
               LEFT JOIN produit p ON p.produit_uid = cp.produit_uid
               LEFT JOIN commande c ON c.commande_uid = cp.commande_uid)
    PIVOT (
    SUM(nvl(commande_produit_quantite_vendue, 0))
    FOR produit_nom IN (
        'Burger mayonnaise' AS burger_mayonnaise,
        'Burger ketchup' AS burger_ketchup,
        'Tacos' AS tacos,
        'Galette poulet' AS galette_poulet,
        'Kebab mayonnaise' AS kebab_mayonnaise,
        'Kebab ketchup' AS kebab_ketchup,
        'Frites' AS frites,
        'Cannette Coca' AS cannette_coca,
        'Cannette Orangina' AS cannette_orangina
        )
    )
GROUP BY commande_id;


--------------------------------------
-- Vue de la somme des ventes / achats
--------------------------------------
CREATE OR REPLACE VIEW vue_ventes_achats AS
SELECT v.commande_id,
       v.vente,
       a.achats,
       ROUND(v.vente / a.achats, 2) AS ratio_vente
FROM (SELECT commande.commande_id,
             commande.commande_uid,
             SUM(produit.produit_prix * commande_produit.commande_produit_quantite_vendue) AS vente
      FROM commande
               JOIN commande_produit ON commande.commande_uid = commande_produit.commande_uid
               JOIN produit ON commande_produit.produit_uid = produit.produit_uid
      GROUP BY commande.commande_uid, commande.commande_id) v
         JOIN (SELECT commande.commande_uid,
                      ROUND(SUM(achat.achat_prix_unite * commande_produit.commande_produit_quantite_vendue *
                                produit_ingredient.produit_ingredient_quantite_utilise), 2) AS achats
               FROM commande
                        JOIN commande_produit ON commande.commande_uid = commande_produit.commande_uid
                        JOIN produit ON commande_produit.produit_uid = produit.produit_uid
                        JOIN produit_ingredient ON produit.produit_uid = produit_ingredient.produit_uid
                        JOIN ingredient ON produit_ingredient.ingredient_uid = ingredient.ingredient_uid
                        JOIN fournisseur_ingredient ON ingredient.ingredient_uid = fournisseur_ingredient.ingredient_uid
                        JOIN achat
                             ON fournisseur_ingredient.fournisseur_ingredient_uid = achat.fournisseur_ingredient_uid
               GROUP BY commande.commande_uid, commande.commande_id) a ON v.commande_uid = a.commande_uid
ORDER BY v.commande_id;
