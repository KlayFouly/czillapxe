#!/bin/bash

source /etc/czillapxe/czillapxe.cfg


function StartAutoConfig() {

    if [ ! -f "$czillaPxeMenu" ]; then
        echo "Le fichier de configuration $czillaPxeMenu n'existe pas."
        exit 1
    fi

    # Check if imagePath is set
    if [ -z "$czillaImageDir" ]; then
        echo "Le chemin de l'image n'est pas défini dans le fichier de configuration."
        exit 1
    fi
    # Check if imagePath exists
    if [ ! -d "$czillaImageDir" ]; then
        echo "Le chemin de l'image $imagePath n'existe pas."
        exit 1
    fi
}

function PxeBackup() {
    if [[ ! -d "$pxeConfigDir" ]]; then
        echo "Le répertoire de configuration PXE $pxeConfigDir n'existe pas."
        exit 1
    fi
    
    date=$(date +%d%m%Y_%H%M%S)
    tar -czvf "$czillaBackupDir/clonezillacfg_backup_$date.tar.gz" "$pxeConfigDir"
    
    if [ $? -ne 0 ]; then
        echo "Échec de la sauvegarde du répertoire de configuration PXE."
        exit 1
    fi
    echo "Sauvegarde du répertoire de configuration PXE effectuée avec succès."
}


function CreateTempPxeMenu() {
    > "$entriesFile"
    for image in $(ls $czillaImageDir); do
        menuName=$(basename "$image") # Remove extension for menu name
        # Check if the image is already in the entries file
        
        CheckImage "$menuName"
        if [ $? -eq 1 ]; then
            echo "Image $menuName already exists in the entries file, skipping."
            continue
        fi
        cat >> $entriesFile << EOF

LABEL $menuName
    MENU LABEL $menuName
    KERNEL Clonezilla-live-vmlinuz
    APPEND initrd=Clonezilla-live-initrd.img username=user boot=live union=overlay locales=fr_FR.UTF-8 keyboard-layouts=fr root=/dev/nfs netboot=nfs nfsroot=172.16.128.102:/tftpboot/node_root/clonezilla-live/ ocs_repository=smb://clonezilla:clonezilla@172.16.128.102/partage/ ocs_live_run=ocs-sr -batch -scr -r -g auto -e1 auto -e2 -j2 -k1 -p poweroff restoredisk $menuName ask_user

EOF
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
        echo "Échec de la mise à jour du menu PXE."
        exit 1
    fi
    rm $entriesFile
    echo "Le menu PXE a été mis à jour avec succès."
}

StartAutoConfig
PxeBackup
CreateTempPxeMenu
UpdatePxeMenu