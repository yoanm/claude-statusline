#!/usr/bin/env bash

input=$(cat)

# ── Colors ──
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
MAGENTA='\033[35m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Truecolor helper ──
rgb() { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }

# ── Parse JSON fields ──
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
effort=$(echo "$input" | jq -r '.effort.level // "Unknown"')
extended_thinking_icon=$(echo "$input" | jq -r 'if .thinking.enabled then "💡" else "" end')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
lines_add=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_del=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')


# ── Current directory ──
curr_path="${cwd/${HOME}/~}"

# ── Git info ──
repo=$(echo "$input" | jq -r '.workspace.repo.name // ""')
worktree_icon=$(echo "$input" | jq -r 'if .workspace.git_worktree then " 🔗" else "" end')
branch=""
if [ -n "$cwd" ]; then
  repo=${repo:-$(basename "$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)}
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi

# ── Context bar ──
BAR_WIDTH=20

if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")

  # Round to nearest block
  filled=$(( (used_int * BAR_WIDTH + 50) / 100 ))

  bar=""
  for (( i=0; i<BAR_WIDTH; i++ )); do
    pos=$(( i * 100 / (BAR_WIDTH - 1) ))

    if [ "$pos" -le 50 ]; then
      r=$(( 0 + 220 * pos / 50 ))
      g=200
      b=$(( 80 - 80 * pos / 50 ))
    else
      adj=$(( pos - 50 ))
      r=220
      g=$(( 200 - 160 * adj / 50 ))
      b=$(( 0 + 20 * adj / 50 ))
    fi

    if [ "$i" -lt "$filled" ]; then
      bar="${bar}$(rgb $r $g $b)█"
    else
      bar="${bar}\033[38;2;60;60;60m░"
    fi
  done
  bar="${bar}${RESET}"

  if [ "$used_int" -ge 90 ]; then status_icon="🚨"
  elif [ "$used_int" -ge 70 ]; then status_icon="🔥"
  elif [ "$used_int" -ge 20 ]; then status_icon="⚡️"
  else status_icon="🟢"; fi

  if [ "$used_int" -ge 90 ]; then pct_color="$RED"
  elif [ "$used_int" -ge 70 ]; then pct_color="$YELLOW"
  else pct_color="$GREEN"; fi

  ctx_part="${status_icon} ${bar} ${pct_color}${used_int}%${RESET}"
else
  ctx_part="🟢 \033[38;2;60;60;60m░░░░░░░░░░░░░░░░░░░░${RESET} --%"
fi

# ── Claude work ──
added_removed_by_claude="${GREEN}+${lines_add}${RESET} ${RED}-${lines_del}${RESET}"

out1="${curr_path}"
[ -n "$repo" ] && out1="${out1} ${DIM}|${RESET} ${BOLD}${YELLOW}🐙 ${repo}${worktree_icon}${RESET}"
[ -n "$branch" ] && out1="${out1}${DIM} | ${RESET}${BOLD}${CYAN}⌥ ${branch}${RESET}"
out2="${MAGENTA}🤖 ${model} — ${effort}${extended_thinking_icon}${RESET}"
out2="${out2} ${DIM}|${RESET} ${ctx_part}${RESET}"
out2="${out2} ${DIM}|${RESET} ${added_removed_by_claude}${RESET}"


printf '%b\n' "$out1"
printf '%b' "$out2"
