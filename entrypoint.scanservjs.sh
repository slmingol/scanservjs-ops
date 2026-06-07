#!/bin/bash

# Register the Brother scanner
/opt/brother/scanner/brscan4/brsaneconfig4 \
    -a name=MFC-8480DN \
    model=MFC-8480DN \
    ip=${SCANNER_IP} 2>/dev/null || true

echo "=== Detected scanners ==="
scanimage -L

# Run the original scanservjs entrypoint
exec /entrypoint.sh
