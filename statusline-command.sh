#!/bin/sh
# Claude Code status line — 3-line layout
#
# Line 1: model·Style ██░░░░░░░░ ctx%/1M | branch ~N | $cost
# Line 2: 5h X% XhXm→HH:MM | 7d X% XdXh→MM/DD
# Line 3: I:Xk O:Xk ⚡X% | +N/-N | ~/path

input=$(cat)

# DEBUG: uncomment to inspect raw JSON
# echo "$input" > /tmp/statusline-debug.json

# --- Raw data extraction ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model_display=$(echo "$input" | jq -r '.model.display_name // ""')

ctx_total=$(echo "$input"        | jq -r '.context_window.context_window_size // 0')
ctx_used_pct=$(echo "$input"     | jq -r '.context_window.used_percentage // empty')
input_tokens=$(echo "$input"     | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input"    | jq -r '.context_window.total_output_tokens // 0')
cache_read=$(echo "$input"       | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_write=$(echo "$input"      | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

five_pct=$(echo "$input"         | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input"      | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_pct=$(echo "$input"        | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_resets=$(echo "$input"     | jq -r '.rate_limits.seven_day.resets_at // empty')

session_cost=$(echo "$input"     | jq -r '.cost.total_cost_usd // 0')
# cost object: session-level cumulative stats
lines_added=$(echo "$input"      | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input"    | jq -r '.cost.total_lines_removed // 0')
output_style=$(echo "$input"     | jq -r '.output_style.name // empty')

# --- Colors (4-tier hierarchy) ---
# P0 Alert: bright/bold — demands attention
C_WARN="\033[1;33m"            # bold yellow — warning (>50%)
C_CRIT="\033[1;31m"            # bold red — critical (>80%)
# P1 Core: bright — primary glance info
C_MODEL="\033[1;37m"           # bold white — model name
C_CTX="\033[1;37m"             # bold white — ctx% (overridden by level)
C_COST="\033[1;37m"            # bold white — session cost
C_STYLE="\033[38;5;141m"       # purple — output style
C_BAR_FILL="\033[33m"          # yellow — bar fill
C_BAR_EMPTY="\033[38;5;236m"   # very dark gray — bar empty
# P2 Reference: medium — look when needed
C_GIT="\033[38;5;114m"         # soft green — branch
C_5H_LABEL="\033[38;5;244m"    # mid gray — "5h" label
C_5H_VAL="\033[38;5;75m"       # soft blue — 5h percentage value
C_7D_LABEL="\033[38;5;244m"    # mid gray — "7d" label
C_7D_VAL="\033[38;5;180m"      # warm sand — 7d percentage value
C_DIFF_ADD="\033[38;5;114m"    # soft green — additions
C_DIFF_DEL="\033[38;5;174m"    # soft red — deletions
# P3 Background: dim — ambient context
C_TOK="\033[38;5;240m"         # dark gray — token counts
C_DIR="\033[38;5;240m"         # dark gray — directory
C_SEP="\033[38;5;236m"         # very dark gray — separators
C_RST="\033[0m"

SEP=" ${C_SEP}|${C_RST} "

# --- Model name ---
model_name=$(echo "$model_display" | sed 's/^Claude //')

# --- Output style label ---
style_seg=""
if [ -n "$output_style" ] && [ "$output_style" != "null" ] && [ "$output_style" != "default" ]; then
  style_seg="$output_style"
fi

# --- Context window size label ---
ctx_size_label=""
if [ "$ctx_total" -ge 1000000 ] 2>/dev/null; then
  ctx_size_label="$(echo "$ctx_total" | awk '{printf "%dM", $1/1000000}')"
elif [ "$ctx_total" -gt 0 ] 2>/dev/null; then
  ctx_size_label="$(echo "$ctx_total" | awk '{printf "%dk", $1/1000}')"
fi

# --- Context usage ---
ctx_int=0
if [ -n "$ctx_used_pct" ]; then
  ctx_int=$(printf "%.0f" "$ctx_used_pct")
fi

# Bar + ctx color by usage (P0 alert when high, P1 core when normal)
if [ "$ctx_int" -lt 30 ]; then
  C_CTX="\033[1;37m"             # bold white — comfortable
  C_BAR_FILL="\033[38;5;143m"    # olive yellow
elif [ "$ctx_int" -lt 60 ]; then
  C_CTX="\033[1;33m"             # bold yellow — getting used
  C_BAR_FILL="\033[33m"          # yellow
elif [ "$ctx_int" -lt 80 ]; then
  C_CTX="\033[1;38;5;208m"       # bold orange — warning
  C_BAR_FILL="\033[38;5;208m"    # orange
else
  C_CTX="\033[1;31m"             # bold red — critical
  C_BAR_FILL="\033[1;31m"        # bold red
fi

# --- Context bar: 10 chars wide ---
bar_width=10
bar_filled=$(echo "$ctx_int $bar_width" | awk '{f=int($1/100*$2+0.5); if(f>$2)f=$2; print f}')
bar_empty=$((bar_width - bar_filled))

# --- Git branch + change count ---
git_branch=""
git_changes=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
               || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  changed=$(git -C "$cwd" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$changed" -gt 0 ]; then
    git_changes=" ~${changed}"
  fi
fi

# --- Session cost ---
session_cost_fmt=$(printf "%.2f" "$session_cost")

# --- Helper: epoch or ISO8601 -> epoch ---
to_epoch() {
  ts="$1"
  case "$ts" in
    *[!0-9]*)
      date -j -f "%Y-%m-%dT%H:%M:%S" "$(echo "$ts" | sed 's/\.[0-9]*Z$//' | sed 's/Z$//')" +%s 2>/dev/null
      ;;
    *)
      echo "$ts"
      ;;
  esac
}

# --- Helper: seconds -> "XhYm" or "XdYh" ---
fmt_remaining() {
  diff="$1"
  if [ "$diff" -le 0 ]; then echo "0m"; return; fi
  days=$((diff / 86400))
  hours=$(( (diff % 86400) / 3600 ))
  mins=$(( (diff % 3600) / 60 ))
  if [ "$days" -gt 0 ]; then
    echo "${days}d${hours}h"
  elif [ "$hours" -gt 0 ]; then
    echo "${hours}h${mins}m"
  else
    echo "${mins}m"
  fi
}

# --- Helper: epoch -> "HH:MM" or "MM/DD" ---
fmt_reset_time() {
  reset_epoch="$1"
  now_epoch=$(date +%s)
  diff=$((reset_epoch - now_epoch))
  if [ "$diff" -le 86400 ]; then
    date -r "$reset_epoch" +%H:%M 2>/dev/null || date -d "@$reset_epoch" +%H:%M 2>/dev/null
  else
    date -r "$reset_epoch" +%m/%d 2>/dev/null || date -d "@$reset_epoch" +%m/%d 2>/dev/null
  fi
}

# --- 5-hour segment ---
five_val=""
five_detail=""
C_5H_PCT="$C_5H_VAL"
if [ -n "$five_pct" ]; then
  five_int=$(printf "%.0f" "$five_pct")
  if [ "$five_int" -ge 80 ] 2>/dev/null; then
    C_5H_PCT="$C_CRIT"
  elif [ "$five_int" -ge 50 ] 2>/dev/null; then
    C_5H_PCT="$C_WARN"
  fi
  five_val="${five_int}%"
  five_epoch=$(to_epoch "$five_resets")
  if [ -n "$five_epoch" ]; then
    now=$(date +%s)
    diff=$((five_epoch - now))
    five_detail=" $(fmt_remaining "$diff")→$(fmt_reset_time "$five_epoch")"
  fi
fi

# --- 7-day segment ---
seven_val=""
seven_detail=""
C_7D_PCT="$C_7D_VAL"
if [ -n "$seven_pct" ]; then
  seven_int=$(printf "%.0f" "$seven_pct")
  if [ "$seven_int" -ge 80 ] 2>/dev/null; then
    C_7D_PCT="$C_CRIT"
  elif [ "$seven_int" -ge 50 ] 2>/dev/null; then
    C_7D_PCT="$C_WARN"
  fi
  seven_val="${seven_int}%"
  seven_epoch=$(to_epoch "$seven_resets")
  if [ -n "$seven_epoch" ]; then
    now=$(date +%s)
    diff=$((seven_epoch - now))
    seven_detail=" $(fmt_remaining "$diff")→$(fmt_reset_time "$seven_epoch")"
  fi
fi

# --- I/O token segment: session cumulative input/output tokens ---
# Shows total token consumption split by direction (I=input, O=output)
tok_seg=""
if [ "$input_tokens" -gt 0 ] || [ "$output_tokens" -gt 0 ]; then
  tok_seg=$(echo "$input_tokens $output_tokens" | awk '{
    printf "I:%dk O:%dk", $1/1000+0.5, $2/1000+0.5
  }')
fi

# --- Cache hit rate: cache_read / (cache_read + cache_create + raw_input) ---
# High % = good prompt caching, directly reduces cost and latency
# Below 80% suggests prompt structure issues worth investigating
cache_seg=""
raw_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_total=$((cache_read + cache_write + raw_input))
if [ "$cache_total" -gt 0 ]; then
  cache_pct=$(echo "$cache_read $cache_total" | awk '{printf "%d", $1/$2*100+0.5}')
  cache_seg="⚡${cache_pct}%"
fi


# --- Session cumulative lines changed (from cost object) ---
# Covers all changes in session including already-committed ones,
# more complete than git diff which only shows uncommitted
diff_seg=""
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
  diff_seg="+${lines_added}/-${lines_removed}"
fi

# --- Short working directory ---
short_dir=$(echo "$cwd" | sed "s|^${HOME}|~|")

# =========================================================
# Output
# =========================================================

# LINE 1: ✦ model·Style ██░░░░ ctx%/1M | ⎇ branch ~N | $cost
printf "${C_MODEL}✦ %s${C_RST}" "$model_name"
if [ -n "$style_seg" ]; then
  printf "${C_SEP}·${C_RST}${C_STYLE}%s${C_RST}" "$style_seg"
fi
printf " "
i=0; while [ $i -lt $bar_filled ]; do printf "${C_BAR_FILL}█"; i=$((i+1)); done
i=0; while [ $i -lt $bar_empty ];  do printf "${C_BAR_EMPTY}░"; i=$((i+1)); done
printf "${C_RST}"
if [ -n "$ctx_used_pct" ]; then
  printf " ${C_CTX}%d%%${C_RST}" "$ctx_int"
  if [ -n "$ctx_size_label" ]; then
    printf "\033[38;5;245m/%s${C_RST}" "$ctx_size_label"
  fi
fi
if [ -n "$git_branch" ]; then
  printf "${SEP}${C_GIT}⎇ %s%s${C_RST}" "$git_branch" "$git_changes"
fi
printf "${SEP}${C_COST}⟡ \$%s${C_RST}" "$session_cost_fmt"
printf "\n"

# LINE 2: ↻ 5h X% XhXm→HH:MM | ↻ 7d X% XdXh→MM/DD
if [ -n "$five_val" ] || [ -n "$seven_val" ]; then
  first2=1
  if [ -n "$five_val" ]; then
    printf "${C_5H_LABEL}↻ 5h ${C_5H_PCT}%s${C_5H_LABEL}%s${C_RST}" "$five_val" "$five_detail"
    first2=0
  fi
  if [ -n "$seven_val" ]; then
    [ "$first2" -eq 0 ] && printf "${SEP}"
    printf "${C_7D_LABEL}↻ 7d ${C_7D_PCT}%s${C_7D_LABEL}%s${C_RST}" "$seven_val" "$seven_detail"
  fi
  printf "\n"
fi

# LINE 3: ▪ I:Xk O:Xk ⚡X% | +N/-N | ⁂ path
first3=1
if [ -n "$tok_seg" ]; then
  printf "${C_TOK}▪ %s${C_RST}" "$tok_seg"
  first3=0
fi
if [ -n "$cache_seg" ]; then
  [ "$first3" -eq 0 ] && printf " "
  printf "${C_TOK}%s${C_RST}" "$cache_seg"
  first3=0
fi
if [ -n "$diff_seg" ]; then
  [ "$first3" -eq 0 ] && printf "${SEP}"
  printf "${C_DIFF_ADD}+%s${C_RST}${C_SEP}/${C_RST}${C_DIFF_DEL}-%s${C_RST}" "$lines_added" "$lines_removed"
  first3=0
fi
[ "$first3" -eq 0 ] && printf "${SEP}"
printf "${C_DIR}⁂ %s${C_RST}" "$short_dir"
printf "\n"
