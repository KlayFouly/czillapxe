#!/bin/bash

source /etc/czillapxe/czillapxe.cfg

using=/opt/czilla/scripts/autoconfig
if [ ! -f "$czillaPxeMenu" ]; then
    echo "Le fichier de configuration $czillaPxeMenu n'existe pas."
    exit 1
fi

addImage=false
imagePath="/srv/partage/clonezilla/"


# AUTOCOMPLETION add this to ~/.bashrc
# if you want to use autocompletion for czillapxe.sh
# Put this function in your .bashrc file or any other script that is sourced by your shell.
# Then move this script to a directory in your PATH, e.g., /usr/local/bin or ~/bin.

# _czilla_completions() {
#     local cur prev opts
#     COMPREPLY=()
#     cur="${COMP_WORDS[COMP_CWORD]}"
#     prev="${COMP_WORDS[COMP_CWORD-1]}"
#     opts="add autoconfig help version"

#     if [[ ${cur} == -* ]]; then
#         COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
#     else
#         case "${prev}" in
#             add)
#                 COMPREPLY=( $(compgen -W "--image --name" -- ${cur}) )
#                 ;;
#             autoconfig|help|version)
#                 COMPREPLY=()
#                 ;;
#             *)
#                 COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
#                 ;;
#         esac
#     fi
#     return 0
# }
#
# complete -F _czilla_completions czillapxe.sh



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
                    echo "Erreur: le répertoire $imagePath/$2 n'existe pas."
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
    echo "Ajout de l'image '$imageName' avec le nom de menu '$menuName'."
}

autoconfig() {
    echo "Génération de la configuration..."
    # Ici, tu peux ajouter le code pour générer la configuration
    /opt/czillapxe/scripts/autoconfig
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
    echo "Ajout de l'image '$imageName' avec le nom de menu '$menuName'."
fi




# --- IGNORE ---

# AUTOUPDATE
# check for images in /srv/partage

# Create a copy of /tftp/pxelinux.cfg/clonezilla


# Add Image -imageName <imageName> -menuName <menuName>




# Written By KLF for LaCapsule