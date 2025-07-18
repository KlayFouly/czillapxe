#!/bin/bash

source /etc/czillapxe/czillapxe.cfg
source /opt/czillapxe/scripts/logger
source /opt/czillapxe/scripts/czillapxe_tools


# Checks

local imagePath="$1"
local imageName="$2"
local menuName="$3"

if [ -z "$imagePath" ] || [ -z "$imageName" ] || [ -z "$menuName" ]; then
    do_log "ERROR $0 6x001 => Les paramètres imagePath, imageName et menuName sont obligatoires."
    exit 1

elif [ ! -d "$imagePath/$imageName" ]; then
    do_log "ERROR $0 6x002 => Aucune image trouvé : $imagePath/$imageName n'existe pas. Veuillez vérifier le chemin."
    exit 1
fi

function CreateTempPxeMenu() {
    > "$entriesFile"
    cat >> $entriesFile << EOF

LABEL $menuName
    MENU LABEL $menuName
    TEXT HELP
        Clonage de l'image $menuName sur le disque dur de votre choix.
    ENDTEXT
    KERNEL Clonezilla-live-vmlinuz
    APPEND initrd=Clonezilla-live-initrd.img username=user boot=live union=overlay locales=fr_FR.UTF-8 keyboard-layouts=fr root=/dev/nfs netboot=nfs nfsroot=$czillaNfsIp:/tftpboot/node_root/clonezilla-live/ ocs_repository=smb://clonezilla:clonezilla@$czillaSmbIp/$czillaSmbShare/ ocs_live_run=ocs-sr -batch -scr -r -g auto -e1 auto -e2 -j2 -k1 -p poweroff restoredisk $menuName ask_user

EOF
    if [ $? -ne 0 ]; then
        do_log "ERROR 2x001 Échec de l'ajout de l'image $menuName au fichier d'entrées."
        return 1
    fi
}

function add_image() {
    awk '
        /# CUSTOM IMAGES/ {
            print
            while ((getline line < "/opt/czillapxe/tmp/clonezilla_entries.tmp") > 0) print line
            inblock=1
            next
        }
        /# END CUSTOM IMAGES/ {inblock=0; print; next}
        !inblock
    ' "$czillaPxeMenu" | tee "$czillaTmpMenu"  > /dev/null
    mv $czillaTmpMenu "$czillaPxeMenu"
    if [ $? -ne 0 ]; then
        do_log "ERROR $0 3x001 Échec Lors de la modification du fichier $czillaPxeMenu."
        return 1
    fi
    if [ $? -ne 0 ]; then
        do_log "WARNING $0 3x002 Échec de la suppression du fichier temporaire $entriesFile."
    fi
    do_log "INFO $0 Le fichier $czillaPxeMenu a été mis à jour avec succès."
}





PxeBackup
if [ $? -ne 0 ]; then
    do_log "FATAL $0 1x111 Échec de la sauvegarde du répertoire de configuration PXE."
    exit 1
fi
CreateTempPxeMenu
if [ $? -ne 0 ]; then
    do_log "FATAL $0 2x111 Échec de la création du fichier temporaire d'entrées."
    exit 1
fi
add_image
if [ $? -ne 0 ]; then
    do_log "FATAL $0 3x111 Échec de l'ajout de l'image au menu PXE."
    exit 1
fi