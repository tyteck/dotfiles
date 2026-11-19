#!/usr/bin/env bash
# Status line Claude Code : jauges d'usage (session 5h, semaine 7j, spend limit org)
# + contexte de la fenetre courante. Alimente par le JSON recu sur stdin.
#
# Payload documente par claude 2.1.x : .rate_limits.{five_hour,seven_day,spend_limit}
# avec .used_percentage (0-100) et .resets_at (epoch s). Absent tant qu'aucune reponse
# API n'est revenue, ou si la fenetre n'est pas rapportee par le provider.

export LC_ALL=C   # printf '%.0f' doit lire "43.7", pas "43,7"

input=$(cat)

C_RESET=$'\033[0m'
C_DIM=$'\033[2m'
C_BOLD=$'\033[1m'
SEP=$'\x1f'

color_for() { # $1 = pourcentage entier
  if   [ "$1" -ge 90 ]; then printf '\033[91m'   # rouge
  elif [ "$1" -ge 75 ]; then printf '\033[33m'   # orange
  elif [ "$1" -ge 50 ]; then printf '\033[93m'   # jaune
  else                       printf '\033[32m'   # vert
  fi
}

bar() { # $1 = pourcentage entier, $2 = largeur
  local pct=$1 width=$2 filled i out=''
  [ "$pct" -gt 100 ] && pct=100
  [ "$pct" -lt 0 ] && pct=0
  filled=$(( (pct * width + 50) / 100 ))
  for ((i = 0; i < width; i++)); do
    if [ "$i" -lt "$filled" ]; then out+='█'; else out+='░'; fi
  done
  printf '%s' "$out"
}

gauge() { # $1 label, $2 pourcentage brut, $3 resets_at (epoch), $4 format date
  local label=$1 raw=$2 reset=$3 fmt=$4 pct col rst=''
  [ -z "$raw" ] && return
  pct=$(printf '%.0f' "$raw") || return
  col=$(color_for "$pct")
  if [ -n "$reset" ]; then
    rst=" ${C_DIM}↻$(TZ=Europe/Paris LC_ALL= LC_TIME=fr_FR.UTF-8 date -d "@$reset" +"$fmt")${C_RESET}"
  fi
  printf '%s %s%s%s %s%3d%%%s%s' \
    "$label" "$col" "$(bar "$pct" 10)" "$C_RESET" "$col" "$pct" "$C_RESET" "$rst"
}

IFS=$SEP read -r five five_r seven seven_r spend spend_r ctx model dir <<EOF
$(printf '%s' "$input" | jq -j '
  [ (.rate_limits.five_hour.used_percentage   // ""),
    (.rate_limits.five_hour.resets_at         // ""),
    (.rate_limits.seven_day.used_percentage   // ""),
    (.rate_limits.seven_day.resets_at         // ""),
    (.rate_limits.spend_limit.used_percentage // ""),
    (.rate_limits.spend_limit.resets_at       // ""),
    (.context_window.used_percentage          // ""),
    (.model.display_name                      // "?"),
    (.workspace.current_dir                   // "")
  ] | map(tostring) | join("\u001f")')
EOF

[ -z "$dir" ] && dir=$PWD
dir_name=${dir##*/}
branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)

# --- Ligne 1 : ou je suis -----------------------------------------------------
case "${CLAUDE_CONFIG_DIR%/}" in
  */.claude-perso) account=$'\033[95m🏠 perso\033[0m' ;;
  *)               account=$'\033[96m💼 pro\033[0m' ;;
esac
line1="${account}  ${C_DIM}📁${C_RESET} ${C_BOLD}${dir_name}${C_RESET}"
[ -n "$branch" ] && line1+=" ${C_DIM}⎇ ${branch}${C_RESET}"
line1+="  ${C_DIM}${model}${C_RESET}"
if [ -n "$ctx" ]; then
  ctx_pct=$(printf '%.0f' "$ctx")
  line1+="  ${C_DIM}ctx${C_RESET} $(color_for "$ctx_pct")${ctx_pct}%${C_RESET}"
fi

# --- Ligne 2 : les jauges de quota --------------------------------------------
line2=''
add() {
  [ -n "$1" ] || return
  [ -n "$line2" ] && line2+="  ${C_DIM}│${C_RESET}  "
  line2+="$1"
}
add "$(gauge '5h ' "$five"  "$five_r"  '%H:%M')"
add "$(gauge '7j ' "$seven" "$seven_r" '%a %d/%m')"
add "$(gauge '💳 ' "$spend" "$spend_r" '%d/%m %H:%M')"
[ -z "$line2" ] && line2="${C_DIM}quotas : en attente de la premiere reponse API...${C_RESET}"

printf '%s\n%s' "$line1" "$line2"
