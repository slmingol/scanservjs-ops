#!/bin/bash

# Register the Brother scanner
/opt/brother/scanner/brscan4/brsaneconfig4 \
    -a name=MFC-8480DN \
    model=MFC-8480DN \
    ip=${SCANNER_IP} 2>/dev/null || true

# Verify scanner is found
echo "=== Detected scanners ==="
scanimage -L

# Run HTTP scan server
echo "=== Starting scan server ==="
exec python3 /scan-server.py
