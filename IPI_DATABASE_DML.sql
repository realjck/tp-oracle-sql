-- creation d'une procedure pour afficher d'autres procedures :
CREATE OR REPLACE PROCEDURE DBMS(i_message IN VARCHAR2 DEFAULT 'lorem ipsum') AS
BEGIN
    DBMS_OUTPUT.ENABLE;
    DBMS_OUTPUT.ENABLE(1000000);
    DBMS_OUTPUT.PUT_LINE(i_message);
END DBMS;

----------
-- Clients
----------

-- Procédure d'ajout d'un client
CREATE OR REPLACE PROCEDURE insert_client(
    i_client_email IN VARCHAR2,
    i_client_name IN VARCHAR2,
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
                        client_name,
                        client_prenom,
                        client_telephone,
                        client_adresse,
                        client_cp,
                        client_ville,
                        client_date_creation)
    VALUES (SYS_GUID(),
            SEQ_ID_CLIENT.nextval,
            i_client_email,
            i_client_name,
            i_client_prenom,
            i_client_telephone,
            i_client_adresse,
            i_client_cp,
            i_client_ville,
            SYSDATE);
    COMMIT;
END insert_client;


-- Appel de la procédure
BEGIN
    insert_client('jeanmartin@gmail.com', 'Martin', 'Jean', '0654123689',
                  '20 rue des Monts d''Or', '69009', 'Lyon');
    insert_client('benali.khaled@orange.fr', 'Benali', 'Khaled', '0785321476',
                  '32 Avenue du Maréchal Leclerc', '75015', 'Paris');
    insert_client('zhang.mei@free.fr', 'Zhang', 'Mei', '0643219876',
                  '12 Rue des Lilas', '33000', 'Bordeaux');
    insert_client('garcia.pedro@sfr.fr', 'Garcia', 'Pedro', '0245678901',
                  '45 Rue Victor Hugo', '44000', 'Nantes');
    insert_client('kowalski.anna@bouyguestelecom.fr', 'Kowalski', 'Anna', '0123456789',
                  '8 Rue Gambetta', '59000', 'Lille');
    insert_client('nguyen.thi@numericable.fr', 'Nguyen', 'Thi', '0356789123',
                  '10 Place de la République', '13000', 'Marseille');
    insert_client('popov.ivan@laposte.fr', 'Popov', 'Ivan', '0487654321',
                  '21 Boulevard des Alpes', '74000', 'Annecy');
    insert_client('smith.mary@orange.fr', 'Singh', 'Anjali', '0598765432',
                  '3 Allée des Bleuets', '80000', 'Amiens');
    insert_client('lopez.jose@free.fr', 'Lopez', 'Jose', '0612345678',
                  '4 Rue des Jardins', '94000', 'Créteil');
    insert_client('schmidt.hans@bouyguestelecom.fr', 'Schmidt', 'Hans', '0834567890',
                  '6 Avenue du Général Leclerc', '67000', 'Strasbourg');
END;

-- Création de types d'ingrédients
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
END;

-- Ajout des ingrédients
CALL insert_ingredient_par_type('Pita', 'Pain', 'Pc');
CALL insert_ingredient_par_type('Galette', 'Pain', 'Pc');
CALL insert_ingredient_par_type('Buns', 'Pain', 'Pc');
CALL insert_ingredient_par_type('Salade', 'Légume', 'g');
CALL insert_ingredient_par_type('Tomate', 'Légume', 'g');
CALL insert_ingredient_par_type('Oignons', 'Légume', 'g');
CALL insert_ingredient_par_type('Pommes de terre', 'Légume', 'g');
CALL insert_ingredient_par_type('Boeuf', 'Viande', 'g');
CALL insert_ingredient_par_type('Poulet', 'Viande', 'g');
CALL insert_ingredient_par_type('Ketchup', 'Sauce', 'ml');
CALL insert_ingredient_par_type('Mayonnaise', 'Sauce', 'ml');
CALL insert_ingredient_par_type('Huile', 'Ingrédient base', 'l');
CALL insert_ingredient_par_type('Sel', 'Ingrédient base', 'g');
CALL insert_ingredient_par_type('Coca', 'Boisson', 'l');
CALL insert_ingredient_par_type('Orangina', 'Boisson', 'l');


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


-- Création de la jointure produit_ingredient (recettes des produits)

-- Procédure ajoute un ingrédient à un produit selon un certain volume
CREATE OR REPLACE PROCEDURE ajoute_ingredient_produit(
    p_ingredient_nom IN VARCHAR2,
    p_produit_nom IN VARCHAR2,
    p_volume IN NUMBER
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

    -- Check if product exists
    SELECT produit_uid
    INTO v_produit_uid
    FROM produit
    WHERE produit_nom = p_produit_nom;

    IF v_produit_uid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Produit non trouvé : ' || p_produit_nom);
    END IF;

    -- Insert ingredient with volume into product_ingredient table
    INSERT INTO produit_ingredient (produit_ingredient_uid,
                                    produit_ingredient_volume,
                                    produit_uid,
                                    ingredient_uid)
    VALUES (SYS_GUID(),
            p_volume,
            v_produit_uid,
            v_ingredient_uid);
    COMMIT;
END;


CALL ajoute_ingredient_produit('Buns', 'Burger mayonnaise', 150);
CALL ajoute_ingredient_produit('Salade', 'Burger mayonnaise', 25);
CALL ajoute_ingredient_produit('Tomate', 'Burger mayonnaise', 25);
CALL ajoute_ingredient_produit('Oignons', 'Burger mayonnaise', 25);
CALL ajoute_ingredient_produit('Boeuf', 'Burger mayonnaise', 150);
CALL ajoute_ingredient_produit('Mayonnaise', 'Burger mayonnaise', 25);

CALL ajoute_ingredient_produit('Buns', 'Burger ketchup', 150);
CALL ajoute_ingredient_produit('Salade', 'Burger ketchup', 25);
CALL ajoute_ingredient_produit('Tomate', 'Burger ketchup', 25);
CALL ajoute_ingredient_produit('Oignons', 'Burger ketchup', 25);
CALL ajoute_ingredient_produit('Boeuf', 'Burger ketchup', 150);
CALL ajoute_ingredient_produit('Ketchup', 'Burger ketchup', 25);

CALL ajoute_ingredient_produit('Galette', 'Tacos', 100);
CALL ajoute_ingredient_produit('Salade', 'Tacos', 25);
CALL ajoute_ingredient_produit('Tomate', 'Tacos', 25);
CALL ajoute_ingredient_produit('Oignons', 'Tacos', 25);
CALL ajoute_ingredient_produit('Boeuf', 'Tacos', 75);
CALL ajoute_ingredient_produit('Poulet', 'Tacos', 75);
CALL ajoute_ingredient_produit('Mayonnaise', 'Tacos', 25);
CALL ajoute_ingredient_produit('Ketchup', 'Tacos', 25);

CALL ajoute_ingredient_produit('Galette', 'Galette poulet', 100);
CALL ajoute_ingredient_produit('Salade', 'Galette poulet', 25);
CALL ajoute_ingredient_produit('Tomate', 'Galette poulet', 25);
CALL ajoute_ingredient_produit('Oignons', 'Galette poulet', 25);
CALL ajoute_ingredient_produit('Poulet', 'Galette poulet', 150);
CALL ajoute_ingredient_produit('Mayonnaise', 'Galette poulet', 25);

CALL ajoute_ingredient_produit('Pita', 'Kebab mayonnaise', 150);
CALL ajoute_ingredient_produit('Salade', 'Kebab mayonnaise', 25);
CALL ajoute_ingredient_produit('Tomate', 'Kebab mayonnaise', 25);
CALL ajoute_ingredient_produit('Oignons', 'Kebab mayonnaise', 25);
CALL ajoute_ingredient_produit('Boeuf', 'Kebab mayonnaise', 75);
CALL ajoute_ingredient_produit('Poulet', 'Kebab mayonnaise', 75);
CALL ajoute_ingredient_produit('Mayonnaise', 'Kebab mayonnaise', 25);

CALL ajoute_ingredient_produit('Pita', 'Kebab ketchup', 150);
CALL ajoute_ingredient_produit('Salade', 'Kebab ketchup', 25);
CALL ajoute_ingredient_produit('Tomate', 'Kebab ketchup', 25);
CALL ajoute_ingredient_produit('Oignons', 'Kebab ketchup', 25);
CALL ajoute_ingredient_produit('Boeuf', 'Kebab ketchup', 75);
CALL ajoute_ingredient_produit('Poulet', 'Kebab ketchup', 75);
CALL ajoute_ingredient_produit('Ketchup', 'Kebab ketchup', 25);

CALL ajoute_ingredient_produit('Pommes de terre', 'Frites', 150);
CALL ajoute_ingredient_produit('Huile', 'Frites', 20);
CALL ajoute_ingredient_produit('Sel', 'Frites', 2);

CALL ajoute_ingredient_produit('Coca', 'Cannette Coca', 330);

CALL ajoute_ingredient_produit('Orangina', 'Cannette Orangina', 330);


-------------------------
-- création des commandes
-------------------------

--Procédure d'insert d'une commande-produit en fonction de l'id de la commande, de l'email d'un client, du produit et de sa quantité :
CREATE OR REPLACE PROCEDURE insert_commande (
    p_commande_id               IN NUMBER,
    p_client_email              IN VARCHAR2,
    p_commande_date             IN DATE,
    p_produit_nom               IN VARCHAR2,
    p_quantite_produit_vendue   IN NUMBER
)
    IS
    v_client_uid                VARCHAR2(255);
    v_produit_uid               VARCHAR2(255);
    v_commande_uid              VARCHAR2(255);
BEGIN

    -- Récupérer l'UID du client en fonction de son email
    IF p_client_email IS NOT NULL THEN
        SELECT client_uid INTO v_client_uid
        FROM client
        WHERE client_email = p_client_email;
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

    SELECT commande_uid INTO v_commande_uid
    FROM commande
    WHERE commande_id = p_commande_id;

    -- Récupérer l'UID du produit en fonction de son nom
    SELECT produit_uid INTO v_produit_uid
    FROM produit
    WHERE produit_nom = p_produit_nom;
    IF v_produit_uid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'Produit non trouvé pour le nom spécifié.');
    END IF;

    -- Insérer l'entrée dans la table commande_produit
    INSERT INTO commande_produit (commande_produit_uid, commande_produit_quantite_vendue, commande_uid, produit_uid)
    VALUES (SYS_GUID(), p_quantite_produit_vendue, v_commande_uid, v_produit_uid);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;

-- Commandes
CALL insert_commande(1,'jeanmartin@gmail.com',
                     TO_DATE('2024-04-27 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger mayonnaise', 1);
CALL insert_commande(1,'jeanmartin@gmail.com',
                     TO_DATE('2024-04-27 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 1);
CALL insert_commande(1,'jeanmartin@gmail.com',
                     TO_DATE('2024-04-27 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Coca', 1);

CALL insert_commande(2,NULL,
                     TO_DATE('2024-04-27 12:10:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger ketchup', 2);
CALL insert_commande(2,NULL,
                     TO_DATE('2024-04-27 12:10:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 2);
CALL insert_commande(2,NULL,
                     TO_DATE('2024-04-27 12:10:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Orangina', 2);

CALL insert_commande(3,'benali.khaled@orange.fr',
                     TO_DATE('2024-04-27 12:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Tacos', 4);
CALL insert_commande(3,'benali.khaled@orange.fr',
                     TO_DATE('2024-04-27 12:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 2);

CALL insert_commande(4,NULL,
                     TO_DATE('2024-04-27 12:20:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Galette poulet', 3);

CALL insert_commande(5,'zhang.mei@free.fr',
                     TO_DATE('2024-04-27 12:25:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Kebab mayonnaise', 2);
CALL insert_commande(5,'zhang.mei@free.fr',
                     TO_DATE('2024-04-27 12:25:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Orangina', 2);

CALL insert_commande(6,NULL,
                     TO_DATE('2024-04-27 12:30:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 3);

CALL insert_commande(7,'nguyen.thi@numericable.fr',
                     TO_DATE('2024-04-27 12:35:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Galette poulet', 5);
CALL insert_commande(7,'nguyen.thi@numericable.fr',
                     TO_DATE('2024-04-27 12:35:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 3);

CALL insert_commande(8,'kowalski.anna@bouyguestelecom.fr',
                     TO_DATE('2024-04-27 12:40:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger mayonnaise', 1);
CALL insert_commande(8,'kowalski.anna@bouyguestelecom.fr',
                     TO_DATE('2024-04-27 12:40:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 1);
CALL insert_commande(8,'kowalski.anna@bouyguestelecom.fr',
                     TO_DATE('2024-04-27 12:40:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Orangina', 1);

CALL insert_commande(9,'garcia.pedro@sfr.fr',
                     TO_DATE('2024-04-27 12:45:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Kebab mayonnaise', 1);
CALL insert_commande(9,'garcia.pedro@sfr.fr',
                     TO_DATE('2024-04-27 12:45:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Orangina', 1);

CALL insert_commande(10,NULL,
                     TO_DATE('2024-04-27 12:50:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Burger ketchup', 2);
CALL insert_commande(10,NULL,
                     TO_DATE('2024-04-27 12:50:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Coca', 2);

CALL insert_commande(11,'schmidt.hans@bouyguestelecom.fr',
                     TO_DATE('2024-04-27 12:55:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Galette poulet', 1);
CALL insert_commande(11,'schmidt.hans@bouyguestelecom.fr',
                     TO_DATE('2024-04-27 12:55:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Cannette Coca', 1);

CALL insert_commande(12,'lopez.jose@free.fr',
                     TO_DATE('2024-04-27 13:00:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Kebab ketchup', 1);

CALL insert_commande(13,'smith.mary@orange.fr',
                     TO_DATE('2024-04-27 13:05:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Tacos', 6);
CALL insert_commande(13,'smith.mary@orange.fr',
                     TO_DATE('2024-04-27 13:05:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 6);

CALL insert_commande(14,NULL,
                     TO_DATE('2024-04-27 13:10:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Galette poulet', 3);

CALL insert_commande(15,'popov.ivan@laposte.fr',
                     TO_DATE('2024-04-27 13:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Kebab mayonnaise', 1);
CALL insert_commande(15,'popov.ivan@laposte.fr',
                     TO_DATE('2024-04-27 13:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Kebab ketchup', 1);
CALL insert_commande(15,'popov.ivan@laposte.fr',
                     TO_DATE('2024-04-27 13:15:00', 'YYYY-MM-DD HH24:MI:SS'),
                     'Frites', 2);


-------------------------
-- création des fournisseur
-------------------------

-- Procédure pour insérer un fournisseur
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



-- Test d'appel de la procédure
BEGIN
    insert_fournisseur(
            p_fournisseur_nom => 'Le grand marché',
            p_fournisseur_email => 'Le_grand_marche@email.com',
            p_fournisseur_telephone => '0836656565',
            p_fournisseur_adresse => '12 place du marché',
            p_fournisseur_cp => '69001',
            p_fournisseur_ville => 'Lyon'
    );
END;

CALL insert_fournisseur('Le fermier local', 'fermierlocal@email.com', '0625485621', '4 rue du marché', '69100','Villeurbanne');

--
-- STATISTIQUES À EXTRAIRE ;

-- Quel stock j’ai dans tel produit

-- Quand ai-je acheté de la viande pour la dernière fois

-- Le nom du client qui a mangé le plus de poulet entre le 19 mars et le 8 mai


-- Insérer une nouvelle commande avec le client_uid correspondant à celui du client avec client_name = 'Nom1'nouvelle commande avec le client_uid correspondant à celui du client avec client_name = 'Nom1'
