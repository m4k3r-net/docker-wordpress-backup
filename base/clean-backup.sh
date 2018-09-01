# This function is part of a bigger script
#
# Be carefull when editing it

clean_backup_on_space_limit() {
    echo "Check available disk space."

    AVAILABLE_DISK_SPACE=$(df "$BACKUP_PATH_NAME" | awk 'NR==2 { print $4 }')

    show_backup_device_info

    if [ $AVAILABLE_DISK_SPACE -gt $DISK_SPACE_LIMIT_CLEAN ]; then
        NEED_BACKUP=false
        echo
        echo "Space left on disk is greater than limit configured. No clean up needed."
        echo "DISK_SPACE_LIMITE_CLEAN: "$DISK_SPACE_LIMIT_CLEAN" KB"
        return 0
    else
        NEED_BACKUP=true
    fi

    if $NEED_BACKUP; then
        echo "Clean up needed..."
        echo
        run_function clean_up_old_backup_files
#        run_function clean_backup
    fi
}

show_backup_device_info() {

    DEVICE=$(df -h "$BACKUP_PATH_NAME" | awk 'NR==2 { print $1 } ')
    TOTAL_SPACE=$(df -h "$BACKUP_PATH_NAME" | awk 'NR==2 { print $2 } ')
    USED_SPACE=$(df -h "$BACKUP_PATH_NAME" | awk 'NR==2 { print $3 } ')
    LEFT_SPACE=$(df -h "$BACKUP_PATH_NAME" | awk 'NR==2 { print $4 } ')

    echo
    echo "Device: "$DEVICE
    echo "Total:  "$TOTAL_SPACE
    echo "Used:   "$USED_SPACE
    echo "Left:   "$LEFT_SPACE
    echo
}

clean_up_old_backup_files () {

    # Check if folder was set for db and site
    # and go the backup folder

    # Database
    if [ ! -z ${DB_BACKUP_PATH_NAME+X} ]; then
        cd $BACKUP_PATH_NAME"/"$DB_BACKUP_PATH_NAME
        find_oldest_file
        delete_old_backup_file $OLDEST_FILE
    else
        cd $BACKUP_PATH_NAME
        find_oldest_file
        delete_old_backup_file $OLDEST_FILE
    fi

    # Site
    if [ ! -z ${WP_BACKUP_PATH_NAME+X} ]; then
        cd $BACKUP_PATH_NAME"/"$WP_BACKUP_PATH_NAME
        find_oldest_file
        delete_old_backup_file $OLDEST_FILE
    else
        # If user does not use special folder
        # must delete two files which will be
        # the database and the site data
        cd $BACKUP_PATH_NAME
        find_oldest_file
        delete_old_backup_file $OLDEST_FILE
    fi

    cd - 

    LEFT_SPACE=$(df -h "$BACKUP_PATH_NAME" | awk 'NR==2 { print $4 } ')

    echo
    echo "Current Left Space: "$LEFT_SPACE
}


find_oldest_file () {
    OLDEST_FILE=$(ls -tl1 | grep -v '^d' | tail -1 | awk '{ print $NF }')
}

delete_old_backup_file () {

    if [ ! -z $1 ]; then
        rm $1
        echo "File deleted: "$1
    fi
}

#clean_backup () {
#    echo "Clean up old backups files."
#}

