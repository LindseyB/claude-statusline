#!/bin/bash

input=$(cat)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
ARROW_RIGHT=$(printf '\xee\x82\xb0')
ARROW_LEFT=$(printf '\xee\x82\xb2')
ARROW_ROUND=$(printf '\xee\x82\xb6')
ICON_PLUS=$(printf '\xef\x81\x95')
ICON_MINUS=$(printf '\xef\x81\x96')
ICON_SONNET=$(printf '\xee\xb8\xb4')
ICON_OPUS=$(printf '\xee\xb5\xa2')
ICON_HAIKU=$(printf '\xee\x9f\x95')
ICON_GIT=$(printf '\xee\x82\xa0')
ICON_DIFF=$(printf '\xf3\xb0\xa6\x93')
FG="40;42;54"
BG="40;42;54"
COLOR_DIR="189;147;249"
COLOR_GIT="255;121;198"
COLOR_MODEL="139;233;253"
COLOR_CTX="80;250;123"
COLOR_LINES="255;184;108"

if [ "$current_dir" = "$HOME" ]; then
  dir_display="~"
else
  if [[ "$current_dir" == "$HOME"/* ]]; then
    rel_path="${current_dir#$HOME/}"
    depth=$(echo "$rel_path" | tr -cd '/' | wc -c | tr -d ' ')
    if [ "$depth" -gt 0 ]; then
      dir_display="…/$(basename "$current_dir")"
    else
      dir_display="$(basename "$current_dir")"
    fi
  else
    dir_display="$(basename "$current_dir")"
  fi
fi

git_branch=""
git_changes="0"
git_root=""
if git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
  git_root=$(git -C "$current_dir" rev-parse --show-toplevel 2>/dev/null)
  git_branch=$(git -C "$git_root" symbolic-ref --short HEAD 2>/dev/null || git -C "$git_root" rev-parse --short HEAD 2>/dev/null)
  modified_count=$(git -C "$git_root" status --short --untracked-files=all 2>/dev/null | wc -l | tr -d ' ')
  git_changes="$modified_count"
fi

model_display=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
model_id=$(echo "$input" | jq -r '.model.id // ""')

if echo "$model_display" | grep -qi "sonnet" || echo "$model_id" | grep -qi "sonnet"; then
  model_icon="$ICON_SONNET"
elif echo "$model_display" | grep -qi "haiku" || echo "$model_id" | grep -qi "haiku"; then
  model_icon="$ICON_HAIKU"
elif echo "$model_display" | grep -qi "opus" || echo "$model_id" | grep -qi "opus"; then
  model_icon="$ICON_OPUS"
else
  model_icon="$ICON_SONNET"
fi

context_data=$(echo "$input" | jq '.context_window.current_usage')
context_percentage=""

if [ "$context_data" != "null" ]; then
  input_tokens=$(echo "$context_data" | jq '.input_tokens // 0')
  cache_creation=$(echo "$context_data" | jq '.cache_creation_input_tokens // 0')
  cache_read=$(echo "$context_data" | jq '.cache_read_input_tokens // 0')
  context_size=$(echo "$input" | jq '.context_window.context_window_size // 200000')

  current_usage=$((input_tokens + cache_creation + cache_read))
  percentage=$((current_usage * 100 / context_size))
  context_percentage="$percentage"

  filled_segments=$((percentage / 10))
  if [ $filled_segments -gt 10 ]; then
    filled_segments=10
  fi
  empty_segments=$((10 - filled_segments))

  progress_bar=""
  for i in $(seq 1 $filled_segments); do
    progress_bar="${progress_bar}━"
  done

  fade_idx=0
  for i in $(seq 1 $empty_segments); do
    case $fade_idx in
      0) progress_bar="${progress_bar}\033[38;2;68;71;100m━" ;;
      1) progress_bar="${progress_bar}\033[38;2;68;71;90m━" ;;
      2) progress_bar="${progress_bar}\033[38;2;60;63;80m━" ;;
      3) progress_bar="${progress_bar}\033[38;2;52;55;70m━" ;;
      *) progress_bar="${progress_bar}\033[38;2;44;47;60m━" ;;
    esac
    fade_idx=$((fade_idx + 1))
  done
  progress_bar="${progress_bar}\033[38;2;${FG}m"
fi

lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

printf "\033[38;2;${COLOR_DIR}m${ARROW_ROUND}\033[0m"
printf "\033[38;2;${FG}m\033[48;2;${COLOR_DIR}m $dir_display \033[0m"

if [ -n "$git_branch" ]; then
  printf "\033[38;2;${COLOR_DIR}m\033[48;2;${COLOR_GIT}m${ARROW_RIGHT}\033[0m"
  printf "\033[38;2;${FG}m\033[48;2;${COLOR_GIT}m $ICON_GIT $git_branch \033[0m"
  printf "\033[38;2;${COLOR_GIT}m\033[48;2;${COLOR_MODEL}m${ARROW_RIGHT}\033[0m"
else
  printf "\033[38;2;${COLOR_DIR}m\033[48;2;${COLOR_MODEL}m${ARROW_RIGHT}\033[0m"
fi

printf "\033[38;2;${FG}m\033[48;2;${COLOR_MODEL}m $model_icon $model_display \033[0m"

if [ -n "$context_percentage" ]; then
  printf "\033[38;2;${COLOR_MODEL}m\033[48;2;${COLOR_CTX}m${ARROW_RIGHT}\033[0m"
  printf "\033[38;2;${FG}m\033[48;2;${COLOR_CTX}m "
  printf "%b" "$progress_bar"
  printf " ${context_percentage}%% \033[0m"

  if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ] || [ -n "$git_changes" ]; then
    printf "\033[38;2;${COLOR_CTX}m\033[48;2;${COLOR_LINES}m${ARROW_RIGHT}\033[0m"
    files_part=""
    [ "$git_changes" != "0" ] && files_part="$ICON_DIFF $git_changes "
    printf "\033[38;2;${FG}m\033[48;2;${COLOR_LINES}m ${files_part}$ICON_PLUS $lines_added $ICON_MINUS $lines_removed \033[0m"
    printf "\033[38;2;${COLOR_LINES}m\033[48;2;180;130;80m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;180;130;80m\033[48;2;120;85;55m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;120;85;55m\033[48;2;70;50;35m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;70;50;35m${ARROW_RIGHT}\033[0m\n"
  else
    printf "\033[38;2;${COLOR_CTX}m\033[48;2;55;180;90m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;55;180;90m\033[48;2;40;130;65m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;40;130;65m\033[48;2;30;90;48m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;30;90;48m${ARROW_RIGHT}\033[0m\n"
  fi
else
  if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ] || [ -n "$git_changes" ]; then
    printf "\033[38;2;${COLOR_MODEL}m\033[48;2;${COLOR_LINES}m${ARROW_RIGHT}\033[0m"
    files_part=""
    [ "$git_changes" != "0" ] && files_part="$ICON_DIFF $git_changes "
    printf "\033[38;2;${FG}m\033[48;2;${COLOR_LINES}m ${files_part}$ICON_PLUS $lines_added $ICON_MINUS $lines_removed \033[0m"
    printf "\033[38;2;${COLOR_LINES}m\033[48;2;180;130;80m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;180;130;80m\033[48;2;120;85;55m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;120;85;55m\033[48;2;70;50;35m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;70;50;35m${ARROW_RIGHT}\033[0m\n"
  else
    printf "\033[38;2;${COLOR_MODEL}m\033[48;2;100;180;210m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;100;180;210m\033[48;2;70;130;160m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;70;130;160m\033[48;2;50;90;110m${ARROW_RIGHT}\033[0m"
    printf "\033[38;2;50;90;110m${ARROW_RIGHT}\033[0m\n"
  fi
fi
