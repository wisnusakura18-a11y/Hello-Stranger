#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import re
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse, unquote

HOST = "0.0.0.0"
PORT = int(os.environ.get("HELLO_STRANGER_PORT", "8765"))
DATA_DIR = Path(__file__).resolve().parent / "data"
PROFILE_DIR = DATA_DIR / "profiles"
PROFILE_DIR.mkdir(parents=True, exist_ok=True)


def safe_name(name: str) -> str:
    name = name.strip().lower()
    name = re.sub(r"[^a-z0-9_-]+", "_", name)
    return (name or "stranger")[:32]


def read_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None


def write_json(path: Path, data) -> None:
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    tmp.replace(path)


def entry_from_profile(data: dict) -> dict:
    completed = data.get("completed_quests", [])
    if not isinstance(completed, list):
        completed = []
    return {
        "name": str(data.get("player_name", "STRANGER")),
        "gender": str(data.get("player_gender", "girl")),
        "score": int(data.get("total_score", 0)),
        "time": float(data.get("total_time_seconds", 0.0)),
        "quests": completed,
        "quest_count": len(completed),
        "day": int(data.get("current_day", 1)),
    }


class Handler(BaseHTTPRequestHandler):
    server_version = "HelloStrangerLAN/1.0"

    def _send_json(self, code: int, payload: dict) -> None:
        raw = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(raw)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/api/ping":
            self._send_json(200, {"ok": True, "service": "hello-stranger", "port": PORT})
            return
        if parsed.path == "/api/profile":
            values = parse_qs(parsed.query)
            name = unquote(values.get("name", [""])[0]).strip()
            if not name:
                self._send_json(400, {"ok": False, "error": "missing_name"})
                return
            path = PROFILE_DIR / f"{safe_name(name)}.json"
            profile = read_json(path)
            if not isinstance(profile, dict):
                self._send_json(200, {"ok": False, "error": "not_found"})
                return
            self._send_json(200, {"ok": True, "profile": profile})
            return
        if parsed.path == "/api/players":
            entries = []
            for path in PROFILE_DIR.glob("*.json"):
                data = read_json(path)
                if not isinstance(data, dict):
                    continue
                entries.append(entry_from_profile(data))
            entries.sort(key=lambda e: e["name"].lower())
            self._send_json(200, {"ok": True, "players": entries, "count": len(entries)})
            return
        if parsed.path == "/api/leaderboard":
            entries = []
            for path in PROFILE_DIR.glob("*.json"):
                data = read_json(path)
                if not isinstance(data, dict):
                    continue
                entry = entry_from_profile(data)
                entries.append(entry)
            entries.sort(key=lambda e: (-e["score"], e["time"], e["name"].lower()))
            self._send_json(200, {"ok": True, "entries": entries, "count": len(entries)})
            return
        self._send_json(404, {"ok": False, "error": "not_found"})

    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path != "/api/profile":
            self._send_json(404, {"ok": False, "error": "not_found"})
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
            raw = self.rfile.read(length)
            data = json.loads(raw.decode("utf-8"))
        except Exception:
            self._send_json(400, {"ok": False, "error": "invalid_json"})
            return
        if not isinstance(data, dict) or not str(data.get("player_name", "")).strip():
            self._send_json(400, {"ok": False, "error": "missing_player_name"})
            return
        name = str(data["player_name"]).strip()
        data["server_saved_at"] = __import__("time").time()
        path = PROFILE_DIR / f"{safe_name(name)}.json"
        write_json(path, data)
        self._send_json(200, {"ok": True, "saved": entry_from_profile(data)})

    def log_message(self, fmt: str, *args):
        print(f"[server] {self.address_string()} - {fmt % args}")


if __name__ == "__main__":
    print("=" * 58)
    print(" HELLO, STRANGER • LAN SYNC SERVER")
    print(f" Listening on http://0.0.0.0:{PORT}")
    print(" Put this PC's LAN IP into the game Settings on PCs A/B.")
    print("=" * 58)
    ThreadingHTTPServer.allow_reuse_address = True
    httpd = ThreadingHTTPServer((HOST, PORT), Handler)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
    finally:
        httpd.server_close()
