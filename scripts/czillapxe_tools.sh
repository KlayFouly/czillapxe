#!/bin/bash

source /etc/czillapxe/czillapxe

PxeBackup() {
    if [[ ! -d "$pxeConfigDir" ]]; then
        do_log "ERROR 1x001 => Le répertoire de configuration PXE $pxeConfigDir n'existe pas."
        return 1
    fi
    
    date=$(date +%d%m%Y_%H%M%S)
    tar -czvf "$czillaBackupDir/clonezillacfg_backup_$date.tar.gz" "$pxeConfigDir"
    if [ $? -ne 0 ]; then
        do_log "ERROR 1x002 Erreur lors de la création de l'archive $czillaBackupDir/clonezillacfg_backup_$date.tar.gz"
        return 1
    fi
    do_log "OK 1x000 Sauvegarde du répertoire de configuration PXE effectuée avec succès."
    return 0
}