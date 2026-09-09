#!/bin/bash
set -e

echo "Initialisation de l'API Crédit Agricole..."

#############################################
# 1. Vérifier la présence du fichier .env
#############################################
if [ ! -f "/app/.env" ]; then
    echo "❌ ERREUR : Aucun fichier .env trouvé dans /app"
    echo "➡️  Fournissez un fichier .env via docker-compose :"
    echo "    env_file:"
    echo "      - .env"
    exit 1
fi

#############################################
# 2. Vérifier les variables essentielles
#############################################
required_vars=("CA_USERNAME" "CA_PASSWORD" "CA_API_KEY" "CA_BASE_PATH")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ ERREUR : La variable d'environnement $var n'est pas définie."
        echo "➡️  Vérifiez votre fichier .env ou docker-compose.yml"
        exit 1
    fi
done

#############################################
# 3. Créer les dossiers nécessaires dans /data
#############################################
mkdir -p "$CA_BASE_PATH/output"
mkdir -p "$CA_BASE_PATH/logs"
mkdir -p "$CA_BASE_PATH/downloads"

#############################################
# 4. Mode API / CLI
#############################################
case "$1" in
    api)
        echo "Démarrage en mode API..."
        exec uvicorn ca_api:app --host 0.0.0.0 --port 8000
        ;;
    download)
        echo "Téléchargement des relevés..."
        exec python get_credit_agricole.py "${@:2}"
        ;;
    process)
        echo "Traitement des relevés..."
        exec python process_ca_pdf.py "${@:2}"
        ;;
    *)
        echo "Démarrage de l'API Crédit Agricole..."
        exec uvicorn ca_api:app --host 0.0.0.0 --port 8000
        ;;
esac
