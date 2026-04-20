#!/bin/bash
# ════════════════════════════════════════════════════════════════
#  VAULT-TEC INDUSTRIES — PIP-BOY 3000 TERMINAL SETUP
#  Uso: ./setup.sh [linux|mac] [iterm2|Terminal.app]
#       (si omitís el OS, se auto-detecta)
#  "War. War never changes."
# ════════════════════════════════════════════════════════════════

set -e

GREEN=$'\033[0;32m'
BGREEN=$'\033[1;32m'
DIM=$'\033[2;32m'
RED=$'\033[0;31m'
NC=$'\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf "${GREEN}[VAULT-TEC]${NC} %s\n" "$1"; }
ok()   { printf "${BGREEN}[  OK  ]${NC} %s\n" "$1"; }
warn() { printf "${DIM}[ SKIP ]${NC} %s\n" "$1"; }
err()  { printf "${RED}[ FAIL ]${NC} %s\n" "$1"; exit 1; }

echo ""
printf "${BGREEN}════════════════════════════════════════════════════════${NC}\n"
printf "${BGREEN}   VAULT-TEC INDUSTRIES — PIP-BOY 3000 TERMINAL SETUP  ${NC}\n"
printf "${BGREEN}════════════════════════════════════════════════════════${NC}\n"
echo ""

# ── Argumentos ────────────────────────────────────────────────────
OS="${1:-}"
TERM_APP="${2:-}"

if [[ -z "$OS" ]]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
  else
    OS="linux"
  fi
  log "OS detectado: $OS"
fi

OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
TERM_APP_LC=$(echo "$TERM_APP" | tr '[:upper:]' '[:lower:]')

if [[ "$OS" == "mac" && -z "$TERM_APP" ]]; then
  echo ""
  printf "${RED}ERROR:${NC} Para Mac especificá la terminal:\n"
  printf "  ./setup.sh mac iterm2\n"
  printf "  ./setup.sh mac Terminal.app\n\n"
  exit 1
fi

if [[ "$OS" != "linux" && "$OS" != "mac" ]]; then
  err "OS no soportado: '$OS'. Usá 'linux' o 'mac'."
fi

# sed -i compatible: Linux no acepta '' como argumento, macOS lo requiere
SED_I() {
  if [[ "$OS" == "mac" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# ── 1. Dependencias ──────────────────────────────────────────────
log "Instalando dependencias..."
if [[ "$OS" == "linux" ]]; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq zsh git curl wget toilet chafa imagemagick \
    || err "No se pudieron instalar dependencias. Instalá manualmente: zsh git curl toilet chafa imagemagick"

elif [[ "$OS" == "mac" ]]; then
  if ! command -v brew &>/dev/null; then
    log "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Añadir brew al PATH de esta sesión (Apple Silicon vs Intel)
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
  brew install toilet chafa imagemagick git curl 2>/dev/null || true
  command -v zsh &>/dev/null || brew install zsh
  if [[ "$TERM_APP_LC" == "iterm2" ]] && ! brew list --cask iterm2 &>/dev/null 2>&1; then
    log "Instalando iTerm2..."
    brew install --cask iterm2
  fi
fi
ok "Dependencias instaladas"

# ── 2. Oh My Zsh ─────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Instalando Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ok "Oh My Zsh instalado"
else
  warn "Oh My Zsh ya instalado"
fi

CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ── 3. Powerlevel10k ─────────────────────────────────────────────
if [[ ! -d "$CUSTOM_DIR/themes/powerlevel10k" ]]; then
  log "Instalando Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$CUSTOM_DIR/themes/powerlevel10k"
  ok "Powerlevel10k instalado"
else
  warn "Powerlevel10k ya instalado"
fi

# ── 4. Plugins zsh ───────────────────────────────────────────────
log "Instalando plugins zsh..."
[[ ! -d "$CUSTOM_DIR/plugins/zsh-autosuggestions" ]] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$CUSTOM_DIR/plugins/zsh-autosuggestions"
[[ ! -d "$CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$CUSTOM_DIR/plugins/zsh-syntax-highlighting"
ok "Plugins instalados"

# ── 5. Logo Vault-Tec ────────────────────────────────────────────
log "Copiando logo Vault-Tec..."
mkdir -p "$HOME/.local/share/pipboy"
cp "$SCRIPT_DIR/assets/vault-tec-logo-only.png" "$HOME/.local/share/pipboy/"
ok "Logo copiado a ~/.local/share/pipboy/"

# ── 6. Configurar .zshrc ─────────────────────────────────────────
log "Configurando .zshrc..."
BACKUP="$HOME/.zshrc.bak-$(date +%Y%m%d%H%M%S)"
[[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$BACKUP" && warn "Backup guardado en $BACKUP"
touch "$HOME/.zshrc"

if grep -q "pipboy_welcome" "$HOME/.zshrc" 2>/dev/null; then
  warn "pipboy_welcome ya existe en .zshrc"
else
  cat > /tmp/_pipboy_block.zsh << 'PIPBOY_EOF'
# ─────────────────────────────────────────────────────────────────────────────
# PIP-BOY 3000  ·  VAULT-TEC INDUSTRIES (antes del instant prompt de p10k)
# ─────────────────────────────────────────────────────────────────────────────
pipboy_welcome() {
  local BGREEN=$'\033[1;32m' GREEN=$'\033[0;32m' DIM=$'\033[2;32m' NC=$'\033[0m'
  local IMG="$HOME/.local/share/pipboy/vault-tec-logo-only.png"
  local -i LEFT_W=66

  _vw() {
    setopt local_options extendedglob
    local s="$1"
    s="${s//$'\e'\[[0-9;]#[a-zA-Z]/}"
    echo ${#s}
  }

  local -a L=('')
  while IFS= read -r ln; do L+=("${BGREEN}${ln}${NC}"); done \
    < <(toilet -f smblock "PIP-BOY  3000" 2>/dev/null)
  L+=("${DIM}  ══════════════════════════════════════════════════════════${NC}")
  L+=("${GREEN}  VAULT-TEC INDUSTRIES  ·  RobCo Personal Computer  ·  Mk III${NC}")
  L+=("${DIM}  ══════════════════════════════════════════════════════════${NC}")
  L+=("${GREEN}  USER   » ${BGREEN}$(whoami)${NC}")
  L+=("${GREEN}  HOST   » ${BGREEN}$(hostname)${NC}")
  L+=("${GREEN}  DATE   » ${BGREEN}$(date '+%A, %d %b %Y  %H:%M')${NC}")
  L+=("${GREEN}  UPTIME » ${BGREEN}$(uptime -p 2>/dev/null || uptime | sed 's/.*up /up /')${NC}")
  L+=("${DIM}  ══════════════════════════════════════════════════════════${NC}")
  L+=("${DIM}  \"War. War never changes.\"${NC}")

  local -a R=()
  local _stty; _stty=$(stty size 2>/dev/null)
  local -i tw=$(( ${_stty##* } > 0 ? ${_stty##* } : ${COLUMNS:-120} ))
  if [[ -f "$IMG" && tw -ge 114 ]]; then
    while IFS= read -r ln; do R+=("$ln"); done \
      < <(chafa --size 46x14 --stretch --symbols block+half --colors 16 --bg black "$IMG" 2>/dev/null)
  fi

  local -i nL=${#L[@]} nR=${#R[@]}
  local -i total=$(( nL > nR ? nL : nR ))

  for (( i=1; i<=total; i++ )); do
    local left="${L[$i]:-}" right="${R[$i]:-}"
    if (( nR > 0 )); then
      local -i vw; vw=$(_vw "$left")
      local -i pad=$(( LEFT_W - vw ))
      (( pad < 0 )) && pad=0
      printf '%s%*s%s\n' "$left" "$pad" "" "$right"
    else
      printf '%s\n' "$left"
    fi
  done
  printf '\n'
}
[[ -o interactive ]] && pipboy_welcome
# ─────────────────────────────────────────────────────────────────────────────

PIPBOY_EOF

  cat /tmp/_pipboy_block.zsh "$HOME/.zshrc" > /tmp/_new_zshrc
  mv /tmp/_new_zshrc "$HOME/.zshrc"

  grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc" || \
    SED_I 's/ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"

  grep -q "zsh-autosuggestions" "$HOME/.zshrc" || \
    SED_I 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"

  cat >> "$HOME/.zshrc" << 'ZSH_EXTRAS'

# Pip-Boy: autosuggestions dimmed green
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=28'

# Pip-Boy: syntax highlighting green palette
ZSH_HIGHLIGHT_STYLES[default]='fg=82'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=28,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=40,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=46'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=46'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=40'
ZSH_HIGHLIGHT_STYLES[function]='fg=46,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=46,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=34,italic'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=82'
ZSH_HIGHLIGHT_STYLES[path]='fg=34,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=82'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=34'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=34'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=82'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=46'
ZSH_HIGHLIGHT_STYLES[assign]='fg=82'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=40'
ZSH_HIGHLIGHT_STYLES[comment]='fg=22,italic'
ZSH_EXTRAS

  ok ".zshrc configurado"
fi

# Cambiar shell por defecto a zsh
if [[ "$(basename "$SHELL")" != "zsh" ]]; then
  log "Cambiando shell por defecto a zsh..."
  if [[ "$OS" == "mac" ]]; then
    chsh -s /bin/zsh
  else
    chsh -s "$(which zsh)"
  fi
  ok "Shell cambiado a zsh (efectivo en la próxima sesión)"
fi

# ── 7. Colores Powerlevel10k ─────────────────────────────────────
log "Aplicando paleta verde Pip-Boy a Powerlevel10k..."
if [[ -f "$HOME/.p10k.zsh" ]]; then
  cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.bak-$(date +%Y%m%d%H%M%S)"
  SED_I 's/POWERLEVEL9K_BACKGROUND=236/POWERLEVEL9K_BACKGROUND=232/g'                               "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=240/POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=28/g' "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_OS_ICON_FOREGROUND=255/POWERLEVEL9K_OS_ICON_FOREGROUND=82/g'                "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_DIR_FOREGROUND=31/POWERLEVEL9K_DIR_FOREGROUND=46/g'                         "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=103/POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=34/g'    "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39/POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=82/g'           "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=76/POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=46/g' "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=244/POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=28/g' "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76/POWERLEVEL9K_VCS_CLEAN_FOREGROUND=46/g'             "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=76/POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=34/g'     "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178/POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=82/g'      "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_STATUS_OK_FOREGROUND=70/POWERLEVEL9K_STATUS_OK_FOREGROUND=46/g'             "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=70/POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=46/g'   "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=248/POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=34/g' "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=37/POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=46/g' "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_DIRENV_FOREGROUND=178/POWERLEVEL9K_DIRENV_FOREGROUND=82/g'                  "$HOME/.p10k.zsh"
  SED_I 's/POWERLEVEL9K_ASDF_FOREGROUND=66/POWERLEVEL9K_ASDF_FOREGROUND=34/g'                       "$HOME/.p10k.zsh"
  ok "Colores Powerlevel10k aplicados"
else
  warn "~/.p10k.zsh no encontrado — ejecutá 'p10k configure' y corré el script de nuevo"
fi

# ── 8. Colores de terminal ────────────────────────────────────────
if [[ "$OS" == "linux" ]]; then
  # ── GNOME Terminal via dconf ──
  if command -v dconf &>/dev/null && command -v gsettings &>/dev/null; then
    log "Aplicando colores verde fósforo a GNOME Terminal..."
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
    if [[ -n "$PROFILE" ]]; then
      BASE="/org/gnome/terminal/legacy/profiles:/:${PROFILE}"
      PALETTE="['rgb(0,0,0)', 'rgb(0,60,15)', 'rgb(0,140,35)', 'rgb(0,200,50)', 'rgb(0,100,25)', 'rgb(0,160,40)', 'rgb(0,220,55)', 'rgb(0,255,65)', 'rgb(0,25,6)', 'rgb(0,100,25)', 'rgb(0,180,45)', 'rgb(0,240,60)', 'rgb(0,140,35)', 'rgb(0,200,50)', 'rgb(0,255,100)', 'rgb(180,255,185)']"
      dconf write "$BASE/background-color"               "'rgb(0,8,0)'"
      dconf write "$BASE/foreground-color"               "'rgb(0,255,65)'"
      dconf write "$BASE/bold-color"                     "'rgb(0,255,65)'"
      dconf write "$BASE/bold-color-same-as-fg"          "true"
      dconf write "$BASE/palette"                        "$PALETTE"
      dconf write "$BASE/use-theme-colors"               "false"
      dconf write "$BASE/use-transparent-background"     "true"
      dconf write "$BASE/background-transparency-percent" "5"
      dconf write "$BASE/cursor-shape"                   "'block'"
      dconf write "$BASE/cursor-blink-mode"              "'on'"
      dconf write "$BASE/font"                           "'MesloLGS NF 12'"
      dconf write "$BASE/use-system-font"                "false"
      ok "Colores GNOME Terminal aplicados"
    else
      warn "No se detectó perfil de GNOME Terminal"
    fi
  else
    warn "dconf/gsettings no disponible — saltando colores de terminal"
  fi

elif [[ "$OS" == "mac" && "$TERM_APP_LC" == "iterm2" ]]; then
  # ── iTerm2 — Dynamic Profile (se carga automáticamente sin reiniciar) ──
  log "Creando perfil 'Pip-Boy 3000' en iTerm2..."
  ITERM_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$ITERM_DIR"

  cat > "$ITERM_DIR/pipboy.json" << 'ITERM_EOF'
{
  "Profiles": [
    {
      "Name": "Pip-Boy 3000",
      "Guid": "com.vault-tec.pipboy3000",
      "Background Color": {"Red Component": 0.0,     "Green Component": 0.03137, "Blue Component": 0.0,     "Color Space": "sRGB", "Alpha Component": 1.0},
      "Foreground Color": {"Red Component": 0.0,     "Green Component": 1.0,     "Blue Component": 0.25490, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Bold Color":       {"Red Component": 0.0,     "Green Component": 1.0,     "Blue Component": 0.25490, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Cursor Color":     {"Red Component": 0.0,     "Green Component": 1.0,     "Blue Component": 0.25490, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Cursor Text Color":    {"Red Component": 0.0, "Green Component": 0.03137, "Blue Component": 0.0,     "Color Space": "sRGB", "Alpha Component": 1.0},
      "Selected Text Color":  {"Red Component": 0.0, "Green Component": 0.03137, "Blue Component": 0.0,     "Color Space": "sRGB", "Alpha Component": 1.0},
      "Selection Color":      {"Red Component": 0.0, "Green Component": 0.70588, "Blue Component": 0.17647, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 0 Color":  {"Red Component": 0.0,     "Green Component": 0.0,     "Blue Component": 0.0,     "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 1 Color":  {"Red Component": 0.0,     "Green Component": 0.23529, "Blue Component": 0.05882, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 2 Color":  {"Red Component": 0.0,     "Green Component": 0.54902, "Blue Component": 0.13725, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 3 Color":  {"Red Component": 0.0,     "Green Component": 0.78431, "Blue Component": 0.19608, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 4 Color":  {"Red Component": 0.0,     "Green Component": 0.39216, "Blue Component": 0.09804, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 5 Color":  {"Red Component": 0.0,     "Green Component": 0.62745, "Blue Component": 0.15686, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 6 Color":  {"Red Component": 0.0,     "Green Component": 0.86275, "Blue Component": 0.21569, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 7 Color":  {"Red Component": 0.0,     "Green Component": 1.0,     "Blue Component": 0.25490, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 8 Color":  {"Red Component": 0.0,     "Green Component": 0.09804, "Blue Component": 0.02353, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 9 Color":  {"Red Component": 0.0,     "Green Component": 0.39216, "Blue Component": 0.09804, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 10 Color": {"Red Component": 0.0,     "Green Component": 0.70588, "Blue Component": 0.17647, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 11 Color": {"Red Component": 0.0,     "Green Component": 0.94118, "Blue Component": 0.23529, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 12 Color": {"Red Component": 0.0,     "Green Component": 0.54902, "Blue Component": 0.13725, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 13 Color": {"Red Component": 0.0,     "Green Component": 0.78431, "Blue Component": 0.19608, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 14 Color": {"Red Component": 0.0,     "Green Component": 1.0,     "Blue Component": 0.39216, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Ansi 15 Color": {"Red Component": 0.70588, "Green Component": 1.0,     "Blue Component": 0.72549, "Color Space": "sRGB", "Alpha Component": 1.0},
      "Use Bold Font": true,
      "Use Bright Bold": true,
      "Cursor Type": 1,
      "Blinking Cursor": true,
      "Normal Font": "MesloLGSNF-Regular 13",
      "Non Ascii Font": "MesloLGSNF-Regular 13",
      "Columns": 220,
      "Rows": 55,
      "Transparency": 0.05,
      "Blur": false,
      "Use Non-ASCII Font": false,
      "ASCII Anti Aliased": true
    }
  ]
}
ITERM_EOF

  # Intentar setear como perfil por defecto (puede fallar si iTerm2 está cerrado)
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" "com.vault-tec.pipboy3000" 2>/dev/null || true
  ok "Perfil 'Pip-Boy 3000' creado — se cargará automáticamente en iTerm2"

elif [[ "$OS" == "mac" && ( "$TERM_APP_LC" == "terminal.app" || "$TERM_APP_LC" == "terminal" ) ]]; then
  # ── Terminal.app via Python + PyObjC (incluido en macOS) ──
  log "Aplicando colores verde fósforo a Terminal.app..."

  python3 << 'PYEOF'
import sys, os, subprocess, plistlib

try:
    import AppKit
    import Foundation
except ImportError:
    print("[ SKIP ] PyObjC no disponible en este Python — colores no aplicados")
    sys.exit(0)

PROFILE = "Basic"
COLORS = {
    "BackgroundColor":        (0,   8,   0),
    "TextColor":              (0,   255, 65),
    "BoldTextColor":          (0,   255, 65),
    "CursorColor":            (0,   255, 65),
    "SelectionColor":         (0,   180, 45),
    "SelectedTextColor":      (0,   8,   0),
    "ANSIBlackColor":         (0,   0,   0),
    "ANSIRedColor":           (0,   60,  15),
    "ANSIGreenColor":         (0,   140, 35),
    "ANSIYellowColor":        (0,   200, 50),
    "ANSIBlueColor":          (0,   100, 25),
    "ANSIMagentaColor":       (0,   160, 40),
    "ANSICyanColor":          (0,   220, 55),
    "ANSIWhiteColor":         (0,   255, 65),
    "ANSIBrightBlackColor":   (0,   25,  6),
    "ANSIBrightRedColor":     (0,   100, 25),
    "ANSIBrightGreenColor":   (0,   180, 45),
    "ANSIBrightYellowColor":  (0,   240, 60),
    "ANSIBrightBlueColor":    (0,   140, 35),
    "ANSIBrightMagentaColor": (0,   200, 50),
    "ANSIBrightCyanColor":    (0,   255, 100),
    "ANSIBrightWhiteColor":   (180, 255, 185),
}

def encode_color(r, g, b):
    color = AppKit.NSColor.colorWithSRGBRed_green_blue_alpha_(r/255.0, g/255.0, b/255.0, 1.0)
    try:
        # macOS 12+
        data, _ = Foundation.NSKeyedArchiver.archivedDataWithRootObject_requiringSecureCoding_error_(color, False, None)
    except AttributeError:
        data = Foundation.NSKeyedArchiver.archivedDataWithRootObject_(color)
    return bytes(data)

plist_path = os.path.expanduser("~/Library/Preferences/com.apple.Terminal.plist")

try:
    with open(plist_path, "rb") as f:
        prefs = plistlib.load(f)
except FileNotFoundError:
    prefs = {}

window_settings = prefs.get("Window Settings", {})
profile = window_settings.get(PROFILE, {})

for key, (r, g, b) in COLORS.items():
    profile[key] = encode_color(r, g, b)

# Ventana grande (aproxima maximize)
profile["columnCount"] = 220
profile["rowCount"]    = 55
profile["name"]        = PROFILE

window_settings[PROFILE]       = profile
prefs["Window Settings"]       = window_settings
prefs["Default Window Settings"] = PROFILE
prefs["Startup Window Settings"] = PROFILE

with open(plist_path, "wb") as f:
    plistlib.dump(prefs, f, fmt=plistlib.FMT_BINARY)

subprocess.run(["killall", "cfprefsd"], capture_output=True)
print("Colores Terminal.app aplicados correctamente")
PYEOF
  ok "Terminal.app configurado"
fi

# ── 9. Atajo de teclado / Maximize ────────────────────────────────
if [[ "$OS" == "linux" ]]; then
  if command -v gsettings &>/dev/null; then
    log "Configurando Ctrl+Alt+T → gnome-terminal --maximize..."
    gsettings set org.gnome.settings-daemon.plugins.media-keys terminal '[]'
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
      "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
    KB_BASE="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
    KB_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    gsettings set "${KB_BASE}:${KB_PATH}" name    'Terminal'
    gsettings set "${KB_BASE}:${KB_PATH}" command 'gnome-terminal --maximize'
    gsettings set "${KB_BASE}:${KB_PATH}" binding '<Primary><Alt>t'

    mkdir -p "$HOME/.local/share/applications"
    SRC="/usr/share/applications/org.gnome.Terminal.desktop"
    DST="$HOME/.local/share/applications/org.gnome.Terminal.desktop"
    if [[ -f "$SRC" ]]; then
      cp "$SRC" "$DST"
      SED_I '0,/^Exec=gnome-terminal$/s//Exec=gnome-terminal --maximize/' "$DST"
      update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    fi
    ok "Atajo Ctrl+Alt+T configurado"
  fi

elif [[ "$OS" == "mac" ]]; then
  echo ""
  printf "${DIM}────────────────────────────────────────────────────────${NC}\n"
  if [[ "$TERM_APP_LC" == "iterm2" ]]; then
    printf "${GREEN}  Perfil 'Pip-Boy 3000' listo en iTerm2.${NC}\n"
    printf "${GREEN}  Para que abra maximizado:${NC}\n"
    printf "    Preferences → Profiles → Pip-Boy 3000 → Window → Style: Maximized\n"
    printf "${GREEN}  Para activar el perfil como default:${NC}\n"
    printf "    Preferences → Profiles → Pip-Boy 3000 → Other Actions → Set as Default\n"
  else
    printf "${GREEN}  Terminal.app configurada con ventana 220×55.${NC}\n"
    printf "${GREEN}  Para pantalla completa al abrir:${NC}\n"
    printf "    Terminal → Preferencias → Perfiles → Basic → Ventana → tamaño\n"
  fi
  printf "${DIM}────────────────────────────────────────────────────────${NC}\n"
fi

# ── Done ─────────────────────────────────────────────────────────
echo ""
printf "${BGREEN}════════════════════════════════════════════════════════${NC}\n"
printf "${BGREEN}  Instalación completa. Abrí una terminal nueva.        ${NC}\n"
printf "${BGREEN}  Si p10k no estaba configurado: p10k configure         ${NC}\n"
printf "${BGREEN}  \"War. War never changes.\"                             ${NC}\n"
printf "${BGREEN}════════════════════════════════════════════════════════${NC}\n"
echo ""
