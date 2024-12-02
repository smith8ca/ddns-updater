#!/bin/bash

# Shell script to update a Namecheap.com dynamic DNS domain to your external IP address.
#
# This script retrieves the current external IP address of the machine and updates the Namecheap
# dynamic DNS record for the specified domain and hostname if the IP address has changed.
#
# Usage:
#   ./ddns-update.sh -c <CONFIG_LOCATION>
#
# Options:
#   -c, --config CONFIG_LOCATION    The CONFIG_LOCATION to use
#   -h, --help                      Display help and exit.
#   -v, --version                   Display version information and exit.
#
# Requirements:
#   - curl
#   - dig (optional, for checking current DNS record)
#

## Function to print full usage information
print_help() {
    echo "Usage: $0 -c <CONFIG_LOCATION>"
    echo
    echo "This script retrieves the current external IP address of the machine and updates the Namecheap dynamic DNS record for the specified domain and hostname if the IP address has changed."
    echo
    echo "Options:"
    echo
    echo "  -c, --config CONFIG_LOCATION    The CONFIG_LOCATION to use"
    echo "  -h, --help                      Display this help and exit"
    echo "  -v, --version                   Display version information and exit"
    echo
    exit 1
}

## Function to print an error message and short usage information
print_error() {
    echo "Usage: $0 -c <CONFIG_LOCATION>"
    echo "Try '$0 -h' for help."
    echo
    if [ -n "$1" ]; then
        echo "ERROR: $1"
        echo
    fi

    exit 1
}

## Function to print version information
print_version() {
    echo "DDNS Updater v1.0.0"
    echo "Authored by Charles Smith <chuck@chuckworks.me>"
    echo
    exit 0
}

## Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
    -c | --config)
        CONFIG="$2"
        shift
        break
        ;;
    -h | --help)
        print_help
        shift
        ;;
    -v | --version)
        print_version
        shift
        ;;
    *)
        print_error "Invalid argument: $1"
        ;;
    esac
    shift
done

## Check if CONFIG is set
if [ -z "$CONFIG" ]; then
    print_error "No <CONFIG_LOCATION> provided."
else
    source $CONFIG
fi

## Domain configuration
# DDNS_DOMAIN=""
# DDNS_HOSTNAME=""
# PASSWORD=""

## Obtain current IP address
CURRENT_IP=$(curl -s ipecho.net/plain)

## Obtain IP address configured for Namecheap DDNS record
DDNS_IP=$(dig +short $DDNS_HOSTNAME.$DDNS_DOMAIN @resolver1.opendns.com)

if [[ "$DDNS_HOSTNAME" == "@" ]]; then
    DDNS_IP=$(dig +short $DDNS_DOMAIN @dns1.registrar-servers.com)
else
    DDNS_IP=$(dig +short $DDNS_HOSTNAME.$DDNS_DOMAIN @dns1.registrar-servers.com)
fi

## Display current configuration
echo "Hostname:     $DDNS_HOSTNAME"
echo "Domain:       $DDNS_DOMAIN"
echo "Current IP:   $CURRENT_IP"
echo "DDNS IP:      $DDNS_IP"
echo ""

## Update the DDNS record if the IP address has changed
if [ "$DDNS_IP" != "$CURRENT_IP" ]; then
    response=$(curl -s "https://dynamicdns.park-your-domain.com/update?host=$DDNS_HOSTNAME&domain=$DDNS_DOMAIN&password=$PASSWORD&ip=$CURRENT_IP")
    echo $response
else
    echo "IP address has not changed. No update will be performed."
fi
