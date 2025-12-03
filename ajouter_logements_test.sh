#!/bin/bash

# Script pour ajouter rapidement des logements de test
# Usage: ./ajouter_logements_test.sh

echo "🏠 Script d'ajout de logements de test pour iOS"
echo "================================================"
echo ""

# Configuration
BACKEND_URL="http://192.168.137.185:3007"
echo "📡 Backend URL: $BACKEND_URL"
echo ""

# Demander les credentials
echo "🔐 Veuillez entrer vos identifiants:"
read -p "Email: " USER_EMAIL
read -sp "Mot de passe: " USER_PASSWORD
echo ""
echo ""

# Se connecter et obtenir le token
echo "🔑 Connexion au backend..."
LOGIN_RESPONSE=$(curl -s -X POST "$BACKEND_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$USER_EMAIL\",\"password\":\"$USER_PASSWORD\"}")

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ Erreur: Impossible de se connecter"
    echo "Réponse: $LOGIN_RESPONSE"
    exit 1
fi

echo "✅ Connecté avec succès!"
echo ""

# Function pour ajouter un logement
add_property() {
    local title="$1"
    local description="$2"
    local price=$3
    local location="$4"
    local type="$5"
    local max_coloc=$6
    local current_coloc=$7
    
    echo "➕ Ajout de: $title..."
    
    RESPONSE=$(curl -s -X POST "$BACKEND_URL/annonces" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"title\": \"$title\",
        \"description\": \"$description\",
        \"price\": $price,
        \"location\": \"$location\",
        \"type\": \"$type\",
        \"nbrCollocateurMax\": $max_coloc,
        \"nbrCollocateurActuel\": $current_coloc,
        \"startDate\": \"2025-01-01T00:00:00.000Z\",
        \"endDate\": \"2025-12-31T23:59:59.000Z\",
        \"images\": []
      }")
    
    # Vérifier si succès
    if echo "$RESPONSE" | grep -q "_id"; then
        PROPERTY_ID=$(echo $RESPONSE | grep -o '"_id":"[^"]*' | cut -d'"' -f4)
        echo "   ✅ Créé avec ID: $PROPERTY_ID"
    else
        echo "   ❌ Erreur: $RESPONSE"
    fi
    echo ""
}

echo "📦 Ajout des logements de test..."
echo ""

# Ajouter 4 logements de test
add_property \
    "Appartement 3 pièces Centre Ville" \
    "Spacieux appartement de 3 pièces situé en plein centre ville, idéal pour la colocation étudiante. Proche de toutes commodités." \
    650 \
    "Tunis Centre-Ville" \
    "Appartement" \
    3 \
    1

add_property \
    "Studio meublé Ariana" \
    "Studio entièrement meublé et équipé, proche des transports en commun et des universités. Wi-Fi inclus." \
    450 \
    "Ariana" \
    "Studio" \
    1 \
    0

add_property \
    "Chambre dans T4 La Marsa" \
    "Chambre disponible dans un grand appartement T4 partagé avec d'autres étudiants. Ambiance conviviale." \
    380 \
    "La Marsa" \
    "Chambre" \
    4 \
    2

add_property \
    "Studio moderne Manouba" \
    "Studio moderne et meublé, proche du centre ville et des commerces. Parking disponible." \
    480 \
    "Manouba" \
    "Studio" \
    1 \
    0

add_property \
    "Appartement 2 pièces Lac" \
    "Bel appartement de 2 pièces au Lac avec vue dégagée. Résidence sécurisée." \
    750 \
    "Lac 2" \
    "Appartement" \
    2 \
    0

echo "================================================"
echo "✨ Terminé!"
echo ""
echo "📱 Vous pouvez maintenant:"
echo "   1. Relancer l'app iOS"
echo "   2. Aller dans 'Réserver une visite'"
echo "   3. Cliquer sur 'Choisir un logement'"
echo "   4. Voir les $((5)) logements ajoutés!"
echo ""
echo "🔍 Pour vérifier dans le backend:"
echo "   curl $BACKEND_URL/annonces"
echo ""
