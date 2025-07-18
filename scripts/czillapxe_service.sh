#!/bin/bash
source /opt/czillapxe/scripts/logger



if [ ! -f "/opt/czillapxe/main/clonezilla_images.data" ]; then
    do_log "ERROR 0x001 => Le fichier clonezilla_images.data n'existe pas, création en cours..."
    touch /opt/czillapxe/main/clonezilla_images.data
fi


while true; do
    # Check the images in /srv/partage/clonezilla/
    ls -1 /srv/partage/clonezilla/ | sort > /opt/czillapxe/main/clonezilla_images.data.tmp
    if ! diff -q <(sort /opt/czillapxe/main/clonezilla_images.data) /opt/czillapxe/main/clonezilla_images.data.tmp; then
        do_log "INFO 9x002 => Mise à jour de la liste des images Clonezilla."
        cp /opt/czillapxe/main/clonezilla_images.data.tmp /opt/czillapxe/main/clonezilla_images.data
    else
        do_log "INFO 9x003 => La liste des images Clonezilla est à jour."
    fi

    czillapxe autoconfig
    if [ $? -ne 0 ]; then
        do_log "WARNING czillapxe autoconfig failed, retrying in 10 minutes..."
    else
        echo "OK czillapxe autoconfig completed successfully."
    fi
    sleep 600
done