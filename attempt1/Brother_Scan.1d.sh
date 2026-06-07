#!/usr/bin/env -S bash --noprofile --norc
# <xbar.title>Brother Scanner</xbar.title>
# <xbar.version>1.0</xbar.version>
# <xbar.desc>Scan from Brother MFC-8480DN over WiFi</xbar.desc>

SCANNER_URL="http://192.168.7.38:8080"
SAVE_DIR="$HOME/Downloads"

# Handle actions
if [ "$1" = "scan_pdf" ]; then
    FILENAME="Scan_$(date +%Y%m%d_%H%M%S).pdf"
    OUTFILE="$SAVE_DIR/$FILENAME"
    RESULT=$(curl -s -w "\n%{http_code}" "$SCANNER_URL/scan?format=pdf&resolution=200" -o "$OUTFILE")
    HTTP_CODE=$(echo "$RESULT" | tail -1)
    if [ "$HTTP_CODE" = "200" ] && [ -s "$OUTFILE" ]; then
        open "$OUTFILE"
        osascript -e "display notification \"Saved to Downloads\" with title \"Scan Complete\" subtitle \"$FILENAME\""
    else
        ERROR=$(cat "$OUTFILE" 2>/dev/null)
        rm -f "$OUTFILE"
        osascript -e "display notification \"Scan failed\" with title \"Scanner Error\""
    fi
    exit 0
fi

if [ "$1" = "scan_pdf_hires" ]; then
    FILENAME="Scan_$(date +%Y%m%d_%H%M%S)_300dpi.pdf"
    OUTFILE="$SAVE_DIR/$FILENAME"
    curl -s "$SCANNER_URL/scan?format=pdf&resolution=300" -o "$OUTFILE"
    if [ -s "$OUTFILE" ]; then
        open "$OUTFILE"
        osascript -e "display notification \"Saved to Downloads (300 DPI)\" with title \"Scan Complete\""
    else
        rm -f "$OUTFILE"
        osascript -e "display notification \"Scan failed\" with title \"Scanner Error\""
    fi
    exit 0
fi

if [ "$1" = "scan_tiff" ]; then
    FILENAME="Scan_$(date +%Y%m%d_%H%M%S).tiff"
    OUTFILE="$SAVE_DIR/$FILENAME"
    curl -s "$SCANNER_URL/scan?format=tiff&resolution=300" -o "$OUTFILE"
    if [ -s "$OUTFILE" ]; then
        open "$OUTFILE"
        osascript -e "display notification \"Saved to Downloads\" with title \"Scan Complete\""
    else
        rm -f "$OUTFILE"
        osascript -e "display notification \"Scan failed\" with title \"Scanner Error\""
    fi
    exit 0
fi

if [ "$1" = "check_status" ]; then
    RESULT=$(curl -s --connect-timeout 2 "$SCANNER_URL/health")
    if echo "$RESULT" | grep -q "ok"; then
        osascript -e "display notification \"Scanner is online and ready\" with title \"Brother MFC-8480DN\""
    else
        osascript -e "display notification \"Scanner is offline or unreachable\" with title \"Brother MFC-8480DN\""
    fi
    exit 0
fi

# Check scanner status for menu icon
STATUS=$(curl -s --connect-timeout 2 "$SCANNER_URL/health" 2>/dev/null)
if echo "$STATUS" | grep -q "ok"; then
    ICON="📄"
    STATUS_LINE="🟢 Online"
else
    ICON="📄"
    STATUS_LINE="🔴 Offline"
fi

# Menu bar output
echo "$ICON Scan"
echo "---"
echo "$STATUS_LINE | color=#888888"
echo "---"
echo "Scan to PDF (200 DPI) | bash='$0' param1=scan_pdf terminal=false refresh=false"
echo "Scan to PDF (300 DPI) | bash='$0' param1=scan_pdf_hires terminal=false refresh=false"
echo "Scan to TIFF (300 DPI) | bash='$0' param1=scan_tiff terminal=false refresh=false"
echo "---"
echo "Check Status | bash='$0' param1=check_status terminal=false refresh=false"
echo "Open Downloads | bash=open param1=$SAVE_DIR terminal=false"
