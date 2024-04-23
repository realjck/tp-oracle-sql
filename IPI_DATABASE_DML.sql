-- creation d'une procedure pour afficher d'autres procedures :
CREATE OR REPLACE PROCEDURE DBMS(i_message IN VARCHAR2 DEFAULT 'Test') AS
BEGIN
    DBMS_OUTPUT.ENABLE;
    DBMS_OUTPUT.ENABLE(1000000);
    DBMS_OUTPUT.PUT_LINE(i_message);
END DBMS;

-- Appel de la procédure
BEGIN
    DBMS('mon message');
END;


-- Affichage d'un message :
--SET SERVEROUTPUT ON;
DECLARE
    v_message VARCHAR2(100) := 'Bonjour, monde !';
BEGIN
    DBMS_OUTPUT.PUT_LINE(v_message);
END;


-------------------------------------------------------
-- obj 1 : Créer des accesseurs (GET/SET) aux tables --
-- (procédure/fonction pour créer, supprimer, mettre--
-- à jour, afficher des informations)
-------------------------------------------------------
-- Procédure pour insérer un client
CREATE OR REPLACE PROCEDURE insert_client(
    i_client_uid IN VARCHAR2,
    i_client_id IN NUMBER DEFAULT NULL,
    i_client_email IN VARCHAR2,
    i_client_name IN VARCHAR2,
    i_client_prenom IN VARCHAR2,
    i_client_telephone IN VARCHAR2,
    i_client_adresse IN VARCHAR2,
    i_client_cp IN VARCHAR2,
    i_client_ville IN VARCHAR2,
    i_client_date_creation IN DATE
) AS
BEGIN

    INSERT INTO client (client_uid,
                        client_id,
                        client_email,
                        client_name,
                        client_prenom,
                        client_telephone,
                        client_adresse,
                        client_cp,
                        client_ville,
                        client_date_creation)
    VALUES (COALESCE(i_client_uid, 'valeur_par_defaut'),
            i_client_id,
            i_client_email,
            i_client_name,
            i_client_prenom,
            i_client_telephone,
            i_client_adresse,
            i_client_cp,
            i_client_ville,
            i_client_date_creation);
END insert_client;


-- Appel de la procédure
BEGIN
    insert_client(
            i_client_uid => SYS_GUID(),
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

-------------------
-- Fin objectif 1--
-------------------

-- Création de types d'ingrédients viande/legumes/sauces/pain
INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom,
                            type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Pain', 1);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom,
                            type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Légume', 2);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom,
                            type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Viande', 3);

INSERT INTO type_ingredient(type_ingredient_uid, type_ingredient_id, type_ingredient_nom,
                            type_ingredient_duree_peremption)
VALUES (SYS_GUID(), seq_id_type_ingredient.nextval, 'Sauce', 20);

-- Procédure d'ajout d'ingrédient en fonction de leurs types
CREATE OR REPLACE PROCEDURE insert_ingredient_by_type(
    p_ingredient_name IN VARCHAR2,
    p_type_ingredient_name IN VARCHAR2
)
AS
    v_type_ingredient_uid VARCHAR2(255);
BEGIN
    SELECT type_ingredient_uid
    INTO v_type_ingredient_uid
    FROM type_ingredient
    WHERE type_ingredient_nom = p_type_ingredient_name;

    IF v_type_ingredient_uid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Ingredient not found: ' || p_ingredient_name);
    END IF;

    INSERT INTO ingredient (
        ingredient_uid,
        type_ingredient_uid,
        ingredient_id,
        ingredient_nom
    )
    VALUES (
               SYS_GUID(),
               v_type_ingredient_uid,
               seq_id_ingredient.nextval,
               p_ingredient_name
           );
END insert_ingredient_by_type;

-- Ajout des ingrédients
CALL insert_ingredient_by_type('Pita', 'Pain');
CALL insert_ingredient_by_type('Galette', 'Pain');
CALL insert_ingredient_by_type('Buns', 'Pain');
CALL insert_ingredient_by_type('Salade', 'Légume');
CALL insert_ingredient_by_type('Tomate', 'Légume');
CALL insert_ingredient_by_type('Oignons', 'Légume');
CALL insert_ingredient_by_type('Boeuf', 'Viande');
CALL insert_ingredient_by_type('Poulet', 'Viande');
CALL insert_ingredient_by_type('Ketchup', 'Sauce');
CALL insert_ingredient_by_type('Mayonnaise', 'Sauce');


-- Insertion des produits
INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Burger mayonnaise');

INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Burger ketchup');

INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Tacos');

INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Galette poulet');

INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Kebab mayonnaise');

INSERT INTO produit(produit_uid, produit_id, produit_nom)
VALUES (SYS_GUID(), seq_id_produit.nextval, 'Kebab ketchup');


-- création de le jointure produit_ingredient (recettes des produits)

-- procédure ajoute un ingrédient à un produit selon un certain volume
CREATE OR REPLACE PROCEDURE add_ingredient_to_produit(
    p_ingredient_name IN VARCHAR2,
    p_produit_name IN VARCHAR2,
    p_volume IN NUMBER
)
    IS
    v_ingredient_uid  VARCHAR2(255);
    v_produit_uid    VARCHAR2(255);
BEGIN
    -- Check if ingredient exists
    SELECT ingredient_uid
    INTO v_ingredient_uid
    FROM ingredient
    WHERE ingredient_nom = p_ingredient_name;

    IF v_ingredient_uid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Ingredient not found: ' || p_ingredient_name);
    END IF;

    -- Check if product exists
    SELECT produit_uid
    INTO v_produit_uid
    FROM produit
    WHERE produit_nom = p_produit_name;

    IF v_produit_uid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Product not found: ' || p_produit_name);
    END IF;

    -- Insert ingredient with volume into product_ingredient table
    INSERT INTO produit_ingredient (
        produit_ingredient_uid,
        produit_ingredient_volume,
        produit_uid,
        ingredient_uid
    )
    VALUES (
               SYS_GUID(),
               p_volume,
               v_produit_uid,
               v_ingredient_uid
           );
END;


BEGIN
    add_ingredient_to_produit('Pita', 'Kebab mayonnaise', 100);
END;


---------------------------------------------------------------------
-- création de 20 clients de manière aléatoire (avec nom1/prenom1)
---------------------------------------------------------------------
BEGIN
    FOR i IN 1..2000
        LOOP
            DECLARE
                v_cp    VARCHAR2(5);
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

                INSERT INTO client(client_uid, client_id, client_email, client_name, client_prenom, client_telephone,
                                   client_adresse, client_cp, client_ville, client_date_creation)
                VALUES (SYS_GUID(), seq_id_client.nextval, 'client' || i || '@example.com', 'Nom' || i, 'Prenom' || i,
                        '06' || LPAD(dbms_random.value(10000000, 99999999), 8, '0'), 'Rue' || i, v_cp, v_ville,
                        SYSDATE);
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Une erreur est survenue lors de la création du client ' || i || ' : ' ||
                                         SQLERRM);
            END;
        END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Les 20 clients ont été créés avec succès.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Une erreur est survenue lors de la création des clients : ' || SQLERRM);
END;
/

-- Generation de 20 commandes aléatoires depuis 10 jours
BEGIN
    FOR i IN 1..20000
        LOOP
            DECLARE
                v_client_name   VARCHAR2(255);
                v_montant       NUMBER;
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
                SELECT SYS_GUID(),
                       seq_id_commande.NEXTVAL,
                       client_uid,
                       v_commande_date,
                       v_montant
                FROM client
                WHERE client_name = v_client_name;
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
