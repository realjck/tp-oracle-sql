# TP Oracle SQL

### IPI - CDEV 2024

- Rémi Perez
- Alvin Kita
- JC Kleinbourg
- Frédéric Porcheron

Évaluateur : Sofiane Soltani

---

## KitchenStockPro
 
### Application de gestion des produits alimentaires destinée aux restaurateurs

Diagramme visuel :

https://lucid.app/lucidchart/35bc2b55-560e-4cce-b7c2-7049e6a05031/edit?docId=35bc2b55-560e-4cce-b7c2-7049e6a05031

Lancement d'une base Oracle via Docker :

```bash
docker run -d --name oracle-db -p 1521:1521 -e ORACLE_PWD=Pass12345 container-registry.oracle.com/database/free:latest
```

Créer une connexion SYS dans Intellij :

- Host : localhost
- Port : 1521
- SID : (laisser vide)
- User : `sys as sysdba`
- Password : `Pass12345` (défini dans la commande Docker)

Exécuter le contenu de IPI_SYS.sql pour créer IPIDATABASE, puis faire la seconde connection :

- Host : localhost
- Port : 1521
- User : `IPIDATABASE`
- Password : `MDPIPIDATABASE`
