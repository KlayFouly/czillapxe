#!/bin/bash

source /opt/czillapxe/scripts/logger
source /etc/czillapxe/czillapxe.cfg
source /opt/czillapxe/scripts/czillapxe_tools

if [ ! -f "$czillaPxeMenu" ]; then
    do_log "ERROR Le fichier de configuration $czillaPxeMenu n'existe pas."
    exit 1
fi

addImage=false
imagePath="/srv/partage/clonezilla/"


add() {
    # Parsing des options pour la sous-commande add
    OPTIONS=$(getopt -o i:n: --long image:,name: -- "$@")
    if [ $? -ne 0 ]; then
        echo "Erreur dans les paramètres de la sous-commande add."
        exit 1
    fi
    eval set -- "$OPTIONS"
    imageName=""
    menuName=""
    while true; do
        case "$1" in
            -i|--image)
                if [ -z "$2" ]; then
                    echo "Erreur: l'option -i/--image nécessite un argument."
                    exit 1
                fi
                if [ ! -d "$imagePath/$2" ]; then
                    do_log "ERROR 4x001 le répertoire $imagePath/$2 n'existe pas."
                    exit 1
                fi
                imageName="$2"
                shift 2
                ;;
            -n|--name)
                menuName="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                break
                ;;
        esac
    done
    # Vérification des options
    if [ -z "$imageName" ] || [ -z "$menuName" ]; then
        echo "Erreur : les options --image <nom_image_à_ajouter> et --name <nom_dans_menu_pxe> sont obligatoires."
        exit 1
    fi
    # Process to Add image to pxe menu start here
    do_log "INFO 4x000 => Ajout de l'image '$imageName' avec le nom de menu '$menuName'."
}

autoconfig() {
    do_log "INFO 5x => Génération de la configuration..."
    # Ici, tu peux ajouter le code pour générer la configuration
    /opt/czillapxe/scripts/autoconfig
    if [ $? -ne 0 ]; then
        do_log "ERROR 5x001 => Échec de l'appelle du script autoconfig."
        exit 1
    fi
}

help() {
    # Affichage de l'aide
    echo "Usage: $0 {add|autoconfig|help|version}"
    echo
    echo "Sous-commandes disponibles:"
    echo "  add         Ajouter une image au menu PXE."
    echo "  autoconfig  Générer la configuration PXE automatiquement."
    echo "  help        Afficher cette aide."
    echo "  version     Afficher la version de czillapxe."
    echo
    echo "Options pour la sous-commande add:"
    echo "  -i, --image <nom_image_à_ajouter>  Spécifier le nom de l'image à ajouter."
    echo "  -n, --name <nom_dans_menu_pxe>     Spécifier le nom de l'entrée dans le menu PXE."
    echo
    echo "Exemples:"
    echo "  $0 add -i clonezilla -n '/srv/partage/Clonezilla Live'"
}

version() {
    echo "Version 1.0"
}

case "$1" in
    add)
        shift
        add "$@"
        ;;
    autoconfig)
        shift
        autoconfig
        ;;
    help)
        help
        ;;
    version)
        version
        ;;
    *)
        echo "Usage: $0 {add|autoconfig|help|version}"
        exit 1
        ;;
esac


# Vérification des dépendances d'options
if $addImage; then
    if [ -z "$imageName" ] || [ -z "$menuName" ]; then
        echo "Erreur : les options -i <nom_de_l'image> et -n <nom_de_l'entrée> sont obligatoires avec -a."
        exit 1
    fi
    # Ici, tu peux ajouter le code pour ajouter l'image
    do_log "INFO Ajout de l'image '$imageName' avec le nom de menu '$menuName'."
fi




# --- IGNORE ---

# AUTOUPDATE
# check for images in /srv/partage

# Create a copy of /tftp/pxelinux.cfg/clonezilla


# Add Image -imageName <imageName> -menuName <menuName>




# Written By KLF for LaCapsule