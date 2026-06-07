#!/usr/bin/env python3
"""Simple HTTP scan server - wraps scanimage for network access"""
import http.server
import subprocess
import urllib.parse
import os
import tempfile
import json

PORT = 8080
DEVICE = "brother4:net1;dev0"

class ScanHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        print(f"[scan-server] {format % args}")

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(parsed.query)

        if parsed.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok"}).encode())

        elif parsed.path == "/scan":
            fmt = params.get("format", ["tiff"])[0]
            res = params.get("resolution", ["300"])[0]
            source = params.get("source", ["Glass"])[0]

            with tempfile.NamedTemporaryFile(suffix=f".{fmt}", delete=False) as f:
                outfile = f.name

            try:
                cmd = [
                    "scanimage",
                    f"--device={DEVICE}",
                    f"--format={fmt}",
                    f"--resolution={res}",

                    f"--output-file={outfile}"
                ]
                result = subprocess.run(cmd, capture_output=True, text=True)

                if result.returncode != 0:
                    self.send_response(500)
                    self.send_header("Content-Type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({
                        "error": result.stderr
                    }).encode())
                    return

                content_types = {
                    "tiff": "image/tiff",
                    "png": "image/png",
                    "jpeg": "image/jpeg",
                    "pdf": "application/pdf",
                    "pnm": "image/x-portable-anymap"
                }

                with open(outfile, "rb") as f:
                    data = f.read()

                self.send_response(200)
                self.send_header("Content-Type", content_types.get(fmt, "application/octet-stream"))
                self.send_header("Content-Disposition", f'attachment; filename="scan.{fmt}"')
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)

            finally:
                if os.path.exists(outfile):
                    os.unlink(outfile)

        elif parsed.path == "/devices":
            result = subprocess.run(["scanimage", "-L"], capture_output=True, text=True)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"devices": result.stdout}).encode())

        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    server = http.server.HTTPServer(("0.0.0.0", PORT), ScanHandler)
    print(f"[scan-server] Listening on port {PORT}")
    print(f"[scan-server] Endpoints:")
    print(f"[scan-server]   GET /health")
    print(f"[scan-server]   GET /scan?format=tiff&resolution=300&source=Glass")
    print(f"[scan-server]   GET /scan?format=pdf&resolution=200")
    print(f"[scan-server]   GET /devices")
    server.serve_forever()
