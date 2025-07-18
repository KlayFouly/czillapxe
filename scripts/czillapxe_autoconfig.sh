#!/bin/bash

source /opt/czillapxe/scripts/logger
source /etc/czillapxe/czillapxe.cfg
source /opt/czillapxe/scripts/czillapxe_tools


function StartAutoConfig() {

    if [ ! -f "$czillaPxeMenu" ]; then
        do_log "ERROR 0x001 => Le fichier de configuration $czillaPxeMenu n'existe pas."
        return 1
    fi

    # Check if imagePath is set
    if [ -z "$czillaImageDir" ]; then
        do_log "ERROR 0x002 Le chemin de l'image n'est pas défini dans le fichier de configuration."
        return 1
    fi
    # Check if imagePath exists
    if [ ! -d "$czillaImageDir" ]; then
        do_log "ERROR 0x003 Le chemin de l'image $imagePath n'existe pas."
        return 1
    fi
}

function CreateTempPxeMenu() {
    > "$entriesFile"
    for image in $(ls $czillaImageDir); do
        menuName=$(basename "$image") # Remove extension for menu name
        # Check if the image is already in the entries file
        
        CheckImage "$menuName"
        if [ $? -eq 1 ]; then
            do_log "INFO Image $menuName already exists in the entries file, skipping."
            continue
        fi
        cat >> $entriesFile << EOF

LABEL $menuName
    MENU LABEL $menuName
    TEXT HELP
        Clonage de l'image $menuName sur le disque dur de votre choix.
    ENDTEXT
    KERNEL Clonezilla-live-vmlinuz
    APPEND initrd=Clonezilla-live-initrd.img username=user boot=live union=overlay locales=fr_FR.UTF-8 keyboard-layouts=fr root=/dev/nfs netboot=nfs nfsroot=172.16.128.102:/tftpboot/node_root/clonezilla-live/ ocs_repository=smb://clonezilla:clonezilla@172.16.128.102/partage/ ocs_live_run=ocs-sr -batch -scr -r -g auto -e1 auto -e2 -j2 -k1 -p poweroff restoredisk $menuName ask_user

EOF
    if [ $? -ne 0 ]; then
        do_log "ERROR 2x001 Échec de l'ajout de l'image $menuName au fichier d'entrées."
        return 1
    fi
    do_log "OK 2x000 Image $menuName ajoutée au fichier d'entrées."
    done
}

function CheckImage() {
    local name="$1"
    if grep -q "$name" "$entriesFile"; then
        return 1
    fi
    return 0
}

function UpdatePxeMenu() {
    awk '
        /# DO NOT REMOVE THIS LINE !!/ {
            print
            while ((getline line < "/opt/czillapxe/tmp/clonezilla_entries.tmp") > 0) print line
            inblock=1
            next
        }
        /# Fin du bloc d automatisation/ {inblock=0; print; next}
        !inblock
    ' "$czillaPxeMenu" | tee "$czillaTmpMenu"  > /dev/null
    mv $czillaTmpMenu "$czillaPxeMenu"
    if [ $? -ne 0 ]; then
        do_log "ERROR 3x001 Échec Lors de la modification du fichier $czillaPxeMenu."
        return 1
    fi
    rm $entriesFile
    if [ $? -ne 0 ]; then
        do_log "WARNING 3x002 Échec de la suppression du fichier temporaire $entriesFile."
    fi
    do_log "INFO Le fichier $czillaPxeMenu a été mis à jour avec succès."
}

StartAutoConfig
if [ $? -ne 0 ]; then
    do_log "FATAL 0x111 Échec de l'initialisation de CZillaPXE."
    exit 1
fi
PxeBackup
if [ $? -ne 0 ]; then
    do_log "FATAL 1x111 Échec de la sauvegarde du répertoire de configuration PXE."
    exit 1
fi
CreateTempPxeMenu
if [ $? -ne 0 ]; then
    do_log "FATAL 2x111 Échec de la création du fichier temporaire d'entrées."
    exit 1
fi
UpdatePxeMenu
if [ $? -ne 0 ]; then
    do_log "FATAL 3x111 Échec de la mise à jour du fichier de configuration PXE."
    exit 1
fi