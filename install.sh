#!/bin/sh

ABSOLUTE_FILENAME=`readlink -f "$0"`
HOME_FOLDER=`dirname "$ABSOLUTE_FILENAME"`

source $HOME_FOLDER/common/install_func.sh

# Start installation
begin_install_func

# Installing packages
install_packages_func

# Check old configuration
check_old_config_func

# Stop service if exist
stop_func

# Copy files
config_copy_files_func

# Copy list
config_copy_list_func

# Download nfqws binary
config_select_arch_func

# Setup ISP interface
show_interfaces_func
config_interface_func

# Setup working mode
config_select_mode_func

# Setup http support
config_http_func

# Setup https support
config_https_func

# Setup quic support
config_quic_func

# Setup IPv6 support
config_ipv6_func

# Starting Services
start_func

echo "Installation successful"

exit 0
