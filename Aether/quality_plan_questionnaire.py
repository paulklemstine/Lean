#!/usr/bin/env python3
"""Serve the Aether quality improvement questionnaire locally."""

import argparse
import os
import sys
import webbrowser
from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
from threading import Thread


def main():
    parser = argparse.ArgumentParser(
        description="Open the Aether quality planning questionnaire in a browser."
    )
    parser.add_argument(
        "--port", type=int, default=8765, help="Port for the local server (default: 8765)"
    )
    parser.add_argument(
        "--no-open",
        action="store_true",
        help="Serve only; do not open a browser automatically.",
    )
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    html_file = script_dir / "quality_plan_questionnaire.html"
    if not html_file.exists():
        print(f"Questionnaire not found: {html_file}", file=sys.stderr)
        sys.exit(1)

    os.chdir(script_dir)

    class QuietHandler(SimpleHTTPRequestHandler):
        def log_message(self, format, *args):
            pass

    server = HTTPServer(("127.0.0.1", args.port), QuietHandler)
    thread = Thread(target=server.serve_forever, daemon=True)
    thread.start()

    url = f"http://127.0.0.1:{args.port}/quality_plan_questionnaire.html"
    print(f"Serving questionnaire at {url}")

    if not args.no_open:
        webbrowser.open(url)

    try:
        thread.join()
    except KeyboardInterrupt:
        print("\nShutting down server.")
        server.shutdown()


if __name__ == "__main__":
    main()
