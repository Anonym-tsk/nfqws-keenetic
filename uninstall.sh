#!/bin/sh

ABSOLUTE_FILENAME=`readlink -f "$0"`
HOME_FOLDER=`dirname "$ABSOLUTE_FILENAME"`

source $HOME_FOLDER/common/install_func.sh

# Start uninstallation
begin_uninstall_func

# Stop service if exist
stop_func

# Remove all data
remove_all_files_func

# Remove lists
remove_list_func

echo "Unnstallation successful"

exit 0
