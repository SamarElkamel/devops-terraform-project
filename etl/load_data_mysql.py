import mysql.connector
import requests
import json
import os

conn = mysql.connector.connect(
    host=os.getenv("MYSQL_HOST", "db"),
    user=os.getenv("MYSQL_USER", "root"),
    password=os.getenv("MYSQL_PASSWORD", ""),
    database=os.getenv("MYSQL_DATABASE", "tourismdb")
)
cursor = conn.cursor()

url = "https://opendata.paris.fr/api/explore/v2.1/catalog/datasets/accessibilite-des-hebergements-en-ile-de-france-paris-je-t-aime/records?limit=100"
response = requests.get(url).json()

for record in response['results']:

    nom = record.get('etablissement', None)
    adresse = record.get('adresse', None)
    commune = record.get('ville', None)
    code_postal = record.get('code_postal', None)
    latitude = record.get('latitude', None)
    longitude = record.get('longitude', None)

  
    chambres_adaptees = record.get('chambres_adapees', [])
    accessibilite = "Oui" if chambres_adaptees else "Non"

    
    source = json.dumps(record, ensure_ascii=False)

    cursor.execute("""
        INSERT INTO hebergements
        (nom, adresse, commune, code_postal, accessibilite, latitude, longitude, source)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, (nom, adresse, commune, code_postal, accessibilite, latitude, longitude, source))

conn.commit()
cursor.close()
conn.close()

print("Données insérées correctement")
