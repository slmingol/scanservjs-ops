#!/bin/bash
# This script is meant to be run inside an Automator "Run Shell Script" action
# Set: Pass input = "as arguments", Shell = /bin/bash

SCANNER_URL="http://192.168.7.38:8080"
SAVE_DIR="$HOME/Downloads"
FILENAME="Scan_$(date +%Y%m%d_%H%M%S).pdf"
OUTFILE="$SAVE_DIR/$FILENAME"

# Show scanning notification
osascript -e 'display notification "Place document and wait..." with title "Scanning..."'

# Trigger scan
curl -s "$SCANNER_URL/scan?format=pdf&resolution=200" -o "$OUTFILE"

if [ -s "$OUTFILE" ]; then
    open "$OUTFILE"
    osascript -e "display notification \"Saved: $FILENAME\" with title \"Scan Complete\""
else
    rm -f "$OUTFILE"
    osascript -e 'display notification "Could not reach scanner" with title "Scan Failed"'
fi
