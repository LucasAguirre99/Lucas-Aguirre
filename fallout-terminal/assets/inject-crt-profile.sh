#!/bin/bash
DB=$(find "$HOME/.local/share/cool-retro-term" -name "*.sqlite" 2>/dev/null | head -1)

if [[ -z "$DB" ]]; then
  cool-retro-term --default-settings &
  CRT_PID=$!
  sleep 3
  kill "$CRT_PID" 2>/dev/null
  sleep 1
  DB=$(find "$HOME/.local/share/cool-retro-term" -name "*.sqlite" 2>/dev/null | head -1)
fi

[[ -z "$DB" ]] && exit 1

EXISTING=$(sqlite3 "$DB" "SELECT value FROM settings WHERE setting='_CUSTOM_PROFILES';" 2>/dev/null)
echo "$EXISTING" | grep -q '"Fallout"' && exit 0

python3 - "$DB" << 'PYEOF'
import json, sys, subprocess

settings = {
    "ambientLight": 0.2,
    "backgroundColor": "#000800",
    "bloom": 0.7,
    "brightness": 0.5,
    "burnIn": 0.65,
    "chromaColor": 0.0,
    "contrast": 0.85,
    "flickering": 0.15,
    "fontColor": "#00ff41",
    "lineSpacing": 0.1,
    "glowingLine": 0.45,
    "horizontalSync": 0.1,
    "jitter": 0.1,
    "rasterization": 1,
    "rgbShift": 0,
    "saturationColor": 0.0,
    "screenCurvature": 0.15,
    "screenRadius": 0.1,
    "staticNoise": 0.15,
    "windowOpacity": 1,
    "margin": 0.2,
    "blinkingCursor": True,
    "frameSize": 0.05,
    "frameColor": "#003300",
    "frameShininess": 0.1
}

db = sys.argv[1]
raw = subprocess.check_output(['sqlite3', db, "SELECT value FROM settings WHERE setting='_CUSTOM_PROFILES';"], text=True).strip()
try:
    profiles = json.loads(raw) if raw else []
except Exception:
    profiles = []
profiles = [p for p in profiles if p.get('text') != 'Fallout']
profiles.append({"text": "Fallout", "obj_string": json.dumps(settings), "builtin": False})
value = json.dumps(profiles)
subprocess.run(['sqlite3', db, f"INSERT OR REPLACE INTO settings VALUES ('_CUSTOM_PROFILES', '{value}');"])
PYEOF
