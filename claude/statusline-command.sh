#!/bin/bash

# SYMBOL LEGEND:
# 🤖 Model indicator
# 📁 Current directory
# 📦 Project name (from package.json)
# Git status icons:
#   ✓  Clean repository (green)
#   ⚡ Changes present (yellow)
#   ⚠  Merge conflicts (red)
#   ?N Untracked files count (gray)
#   ~N Modified files count (yellow)
#   +N Staged files count (green)
#   ↑N Commits ahead of remote (green)
#   ↓N Commits behind remote (yellow)
#   ↕N/M Diverged from remote (yellow)
#   PR#N Open pull request number (cyan)
# 🌳 Git worktree indicator
# Context window usage:
#   🟢 0-49% usage (green)
#   🟠 50-74% usage (yellow)
#   🟡 75-89% usage (yellow)
#   🔴 90-100% usage (red)
#   Format: 🟢 50K/25% (tokens/percentage)

# Debug mode - set STATUSLINE_DEBUG=1 to see raw values
DEBUG="${STATUSLINE_DEBUG:-0}"

# Configuration options
CHECK_GITHUB_PR="${STATUSLINE_CHECK_PR:-0}"  # Set to 1 to enable PR checks

# Constants
readonly MAX_PATH_LENGTH=50
readonly MAX_PROJECT_LENGTH=20

# Helper function to parse git status efficiently
parse_git_status() {
    local status_output="$1"
    if [[ -z "$status_output" ]]; then
        echo "untracked=0 modified=0 staged=0 conflicts=0"
        return
    fi
    
    echo "$status_output" | awk '
        BEGIN { untracked=0; modified=0; staged=0; conflicts=0 }
        /^\?\?/ { untracked++ }
        /^.M|^ M/ { modified++ }
        /^[ADMR]/ { staged++ }
        /^UU|^AA|^DD/ { conflicts++ }
        END {
            print "untracked=" untracked " modified=" modified " staged=" staged " conflicts=" conflicts
        }
    '
}

# --- Usage bar helpers ---

# Return color escape for a usage percentage
color_for_pct() {
    local pct="$1"
    if [[ "$pct" -ge 90 ]]; then
        echo '\033[38;2;255;85;85m'    # red
    elif [[ "$pct" -ge 70 ]]; then
        echo '\033[38;2;230;200;0m'    # yellow
    elif [[ "$pct" -ge 50 ]]; then
        echo '\033[38;2;255;176;85m'   # orange
    else
        echo '\033[38;2;0;175;80m'     # green
    fi
}

# Build a progress bar: ■■■■■■■■■■ (filled=colored, empty=dark gray)
build_bar() {
    local pct="$1"
    local width="${2:-10}"
    local filled=$(( (pct * width + 50) / 100 ))
    local empty=$(( width - filled ))
    local bar_color
    bar_color=$(color_for_pct "$pct")

    local filled_char empty_char
    local filled_char="■"
    local empty_color='\033[38;5;236m'

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="${filled_char}"; done
    local empty_part=""
    for ((i=0; i<empty; i++)); do empty_part+="${filled_char}"; done
    echo -e "${bar_color}${bar}${RESET}${empty_color}${empty_part}${RESET}"
}

# Convert ISO 8601 timestamp to epoch seconds (macOS / Linux)
iso_to_epoch() {
    local ts="$1"
    local is_utc=0
    if [[ "$ts" == *"Z" ]] || [[ "$ts" == *"+00:00" ]] || [[ "$ts" == *"+0000" ]]; then
        is_utc=1
    fi
    # Try GNU date first
    if epoch=$(date -d "$ts" +%s 2>/dev/null); then
        echo "$epoch"; return
    fi
    # macOS BSD date fallback
    local clean="${ts%%.*}"          # strip fractional seconds
    clean="${clean%%Z}"              # strip Z
    clean="${clean%%+*}"             # strip +offset
    if [[ $is_utc -eq 1 ]]; then
        epoch=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$clean" +%s 2>/dev/null)
    else
        epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$clean" +%s 2>/dev/null)
    fi
    echo "${epoch:-0}"
}

# Format reset time for display
# style "time"     -> 7:00pm  (for current / 5-hour window)
# style "datetime" -> mar 10, 10:00am  (for weekly / 7-day window)
format_reset_time() {
    local iso_ts="$1"
    local style="${2:-time}"
    local epoch
    epoch=$(iso_to_epoch "$iso_ts")
    [[ "$epoch" == "0" ]] && { echo "?"; return; }
    if [[ "$style" == "time" ]]; then
        date -j -f "%s" "$epoch" "+%-I:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]'
    elif [[ "$style" == "datetime" ]]; then
        local mon day time_part
        mon=$(date -j -f "%s" "$epoch" "+%b" 2>/dev/null | tr '[:upper:]' '[:lower:]')
        day=$(date -j -f "%s" "$epoch" "+%-d" 2>/dev/null)
        time_part=$(date -j -f "%s" "$epoch" "+%-I:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]')
        echo "${mon} ${day}, ${time_part}"
    fi
}

# Format reset time as countdown (e.g., "2h 15m", "5d 21h", "45m")
format_countdown() {
    local iso_ts="$1"
    local epoch now diff
    epoch=$(iso_to_epoch "$iso_ts")
    [[ "$epoch" == "0" ]] && { echo "?"; return; }
    now=$(date +%s)
    diff=$(( epoch - now ))
    if [[ "$diff" -le 0 ]]; then
        echo "soon"
        return
    fi
    local days hours minutes
    days=$(( diff / 86400 ))
    hours=$(( (diff % 86400) / 3600 ))
    minutes=$(( (diff % 3600) / 60 ))
    if [[ "$days" -gt 0 ]]; then
        echo "${days}d ${hours}h"
    elif [[ "$hours" -gt 0 ]]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

# Get OAuth token from macOS Keychain or credentials file
get_oauth_token() {
    # 1. Environment variable
    if [[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
        echo "$CLAUDE_CODE_OAUTH_TOKEN"; return
    fi
    # 2. macOS Keychain
    local kc_json
    kc_json=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
    if [[ -n "$kc_json" ]]; then
        local token
        token=$(echo "$kc_json" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
        if [[ -n "$token" ]]; then echo "$token"; return; fi
    fi
    # 3. Credentials file
    if [[ -f "$HOME/.claude/.credentials.json" ]]; then
        local token
        token=$(jq -r '.claudeAiOauth.accessToken // empty' "$HOME/.claude/.credentials.json" 2>/dev/null)
        if [[ -n "$token" ]]; then echo "$token"; return; fi
    fi
    echo ""
}

# Fetch usage data with caching (60s TTL)
fetch_usage() {
    local cache_dir="/tmp/claude"
    local cache_file="${cache_dir}/statusline-usage-cache.json"
    local cache_max_age=60

    mkdir -p "$cache_dir"

    # Check cache freshness
    if [[ -f "$cache_file" ]]; then
        local now file_mod age
        now=$(date +%s)
        file_mod=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        age=$(( now - file_mod ))
        if [[ "$age" -lt "$cache_max_age" ]]; then
            cat "$cache_file"; return
        fi
    fi

    local token
    token=$(get_oauth_token)
    if [[ -z "$token" ]]; then
        [[ -f "$cache_file" ]] && cat "$cache_file"
        return
    fi

    local response
    response=$(curl -s --max-time 5 \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        -H "User-Agent: claude-code/2.1.34" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

    if [[ -n "$response" ]] && echo "$response" | jq -e '.five_hour' >/dev/null 2>&1; then
        echo "$response" > "$cache_file"
        echo "$response"
    else
        [[ -f "$cache_file" ]] && cat "$cache_file"
    fi
}

# Color codes for better visual separation
readonly BLUE='\033[94m'      # Bright blue for model/main info
readonly GREEN='\033[92m'     # Bright green for clean git status
readonly YELLOW='\033[93m'    # Bright yellow for modified git status
readonly RED='\033[91m'       # Bright red for conflicts/errors
readonly PURPLE='\033[95m'    # Bright purple for directory
readonly CYAN='\033[96m'      # Bright cyan for project name
readonly WHITE='\033[97m'     # Bright white for time
readonly GRAY='\033[37m' # Gray for separators
readonly RESET='\033[0m'      # Reset colors
readonly DIM='\033[2m'        # Dim text
readonly BOLD='\033[1m'       # Bold text

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON input using jq
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // "."')

# Extract context window information
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
usage_percent=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Get current directory relative to home directory with smart truncation
if [[ "$current_dir" == "$HOME"* ]]; then
    # Replace home path with ~ for display
    # Use sed for more reliable substitution
    dir_display=$(echo "$current_dir" | sed "s|^$HOME|~|")
else
    # Keep full path if not under home directory
    dir_display="$current_dir"
fi

# Truncate long paths intelligently
if [[ ${#dir_display} -gt $MAX_PATH_LENGTH ]]; then
    # For home paths, show ~/.../<parent>/<current>
    if [[ "$dir_display" == "~/"* ]]; then
        parent=$(basename "$(dirname "$current_dir")")
        current=$(basename "$current_dir")
        dir_display="~/.../${parent}/${current}"

        # If still too long, just show current directory
        [[ ${#dir_display} -gt $MAX_PATH_LENGTH ]] && dir_display="~/.../${current}"
    else
        # For absolute paths, show .../<parent>/<current>
        parent=$(basename "$(dirname "$current_dir")")
        current=$(basename "$current_dir")
        dir_display=".../${parent}/${current}"

        # If still too long, just show current directory
        [[ ${#dir_display} -gt $MAX_PATH_LENGTH ]] && dir_display=".../${current}"
    fi
fi
# Get project name from nearest package.json
project_name=""
search_dir="$current_dir"
while [[ "$search_dir" != "/" ]]; do
    if [[ -f "$search_dir/package.json" ]]; then
        project_name=$(jq -r '.name // empty' "$search_dir/package.json" 2>/dev/null)
        break
    fi
    search_dir=$(dirname "$search_dir")
done

# Truncate long project names
if [[ -n "$project_name" ]] && [[ ${#project_name} -gt $MAX_PROJECT_LENGTH ]]; then
    project_name="${project_name:0:$MAX_PROJECT_LENGTH}…"
fi

# Get git status and worktree information with enhanced detection
git_info=""
if git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)

    # If no branch (detached HEAD), show short commit hash
    if [[ -z "$branch" ]]; then
        branch=$(git -C "$current_dir" rev-parse --short HEAD 2>/dev/null)
        branch="detached:${branch}"
    fi

    # Enhanced worktree detection
    worktree_info=""
    git_dir=$(git -C "$current_dir" rev-parse --git-dir 2>/dev/null)

    # Check if we're in a worktree
    if [[ "$git_dir" == *".git/worktrees/"* ]] || [[ -f "$git_dir/gitdir" ]]; then
        is_worktree=1
    else
        is_worktree=0
    fi

    if [[ -n "$branch" ]]; then
        # Comprehensive git status check
        # Git status format: XY filename
        # X = status of staging area, Y = status of working tree
        git_status=$(git -C "$current_dir" status --porcelain 2>/dev/null)

        # Parse git status using helper function
        read -r untracked modified staged conflicts < <(parse_git_status "$git_status" | awk '{
            for (i=1; i<=NF; i++) {
                split($i, kv, "=")
                if (kv[1] == "untracked") untracked=kv[2]
                else if (kv[1] == "modified") modified=kv[2]
                else if (kv[1] == "staged") staged=kv[2]
                else if (kv[1] == "conflicts") conflicts=kv[2]
            }
            print untracked, modified, staged, conflicts
        }')

        # Debug output
        if [[ "$DEBUG" == "1" ]]; then
            echo "DEBUG: Git Status Raw:" >&2
            echo "$git_status" >&2
            echo "DEBUG: Counts - Staged:$staged Modified:$modified Untracked:$untracked Conflicts:$conflicts" >&2
        fi

        # Check for ahead/behind status
        ahead_behind=""
        upstream=$(git -C "$current_dir" rev-parse --abbrev-ref '@{u}' 2>/dev/null)
        if [[ -n "$upstream" ]]; then
            ahead=$(git -C "$current_dir" rev-list --count '@{u}..HEAD' 2>/dev/null)
            behind=$(git -C "$current_dir" rev-list --count 'HEAD..@{u}' 2>/dev/null)

            if [[ "$ahead" -gt 0 ]] && [[ "$behind" -gt 0 ]]; then
                ahead_behind=" ${YELLOW}↕${ahead}/${behind}${RESET}"
            elif [[ "$ahead" -gt 0 ]]; then
                ahead_behind=" ${GREEN}↑${ahead}${RESET}"
            elif [[ "$behind" -gt 0 ]]; then
                ahead_behind=" ${YELLOW}↓${behind}${RESET}"
            fi
        fi
        
        # Check for rebase/merge status
        rebase_merge_info=""
        if [[ -d "$current_dir/.git/rebase-merge" ]] || [[ -d "$current_dir/.git/rebase-apply" ]]; then
            rebase_merge_info=" ${RED}🔀REBASE${RESET}"
        elif [[ -f "$current_dir/.git/MERGE_HEAD" ]]; then
            rebase_merge_info=" ${RED}🔀MERGE${RESET}"
        elif [[ -f "$current_dir/.git/CHERRY_PICK_HEAD" ]]; then
            rebase_merge_info=" ${RED}🍒CHERRY${RESET}"
        elif [[ -f "$current_dir/.git/BISECT_LOG" ]]; then
            rebase_merge_info=" ${YELLOW}🔍BISECT${RESET}"
        fi

        # Check for open PRs using GitHub CLI if available and enabled
        pr_info=""
        if [[ "$CHECK_GITHUB_PR" == "1" ]] && command -v gh >/dev/null 2>&1; then
            # Only check for PRs if we're in a GitHub repo
            remote_url=$(git -C "$current_dir" config --get remote.origin.url 2>/dev/null)
            if [[ "$remote_url" == *"github.com"* ]]; then
                # Quick PR check with timeout (gh caches this, so it's usually fast after first run)
                pr_number=$(timeout 0.5 gh pr view --json number -q .number 2>/dev/null)
                if [[ -n "$pr_number" ]]; then
                    pr_info=" ${CYAN}PR#${pr_number}${RESET}"
                fi
            fi
        fi

        # Build status indicators in compact format
        status_indicators=""
        if [[ "$conflicts" -gt 0 ]]; then
            git_color="${RED}"
            git_icon="⚠"
            status_indicators="${RED}⚠${conflicts}${RESET}"
        elif [[ -n "$git_status" ]]; then
            git_color="${YELLOW}"
            git_icon="⚡"

            # Build compact status string: ?N ~N +N
            status_parts=()
            [[ "$untracked" -gt 0 ]] && status_parts+=("${GRAY}?${untracked}${RESET}")
            [[ "$modified" -gt 0 ]] && status_parts+=("${YELLOW}~${modified}${RESET}")
            [[ "$staged" -gt 0 ]] && status_parts+=("${GREEN}+${staged}${RESET}")

            # Join status parts with spaces
            if [[ ${#status_parts[@]} -gt 0 ]]; then
                status_indicators=$(IFS=" "; echo "${status_parts[*]}")
            fi
        else
            git_color="${GREEN}"
            git_icon="✓"
        fi

        # Build git info components
        git_branch_section="${git_color}${git_icon} ${branch}${RESET}${rebase_merge_info}${pr_info}"
        
        # Collect additional git info sections that have content
        git_extra_sections=()
        
        # Only add status section if there are changes
        if [[ -n "$status_indicators" ]]; then
            git_extra_sections+=("${status_indicators}")
        fi

        # Only add sync section if there's sync info
        if [[ -n "$ahead_behind" ]]; then
            git_extra_sections+=("${ahead_behind# }")  # Remove leading space
        fi

        # Build git info starting with branch
        git_info=" ${GRAY}│${RESET} ${git_branch_section}"
        
        # Add additional sections with separators only if they exist
        for section in "${git_extra_sections[@]}"; do
            git_info="${git_info} ${GRAY}│${RESET} ${section}"
        done
    fi
fi

# Context info is now shown as a bar in the usage lines section (line 2)
# Prepare token display for later use
context_tokens_display=""
if [[ "$context_window_size" -gt 0 ]]; then
    total_tokens=$((context_window_size * usage_percent / 100))
    if [[ "$total_tokens" -ge 1000000 ]]; then
        context_tokens_display=$(awk "BEGIN {printf \"%.1fM\", $total_tokens/1000000}")
    elif [[ "$total_tokens" -ge 1000 ]]; then
        context_tokens_display=$(awk "BEGIN {printf \"%.0fK\", $total_tokens/1000}")
    else
        context_tokens_display="${total_tokens}"
    fi
fi

# Build output string with smart separators
output_string=" ${BOLD}${BLUE}${model_name}${RESET}"

# Add project/directory info combined (with worktree indicator if applicable)
worktree_marker=""
if [[ "${is_worktree:-0}" == "1" ]]; then
    worktree_marker=" ${CYAN}🌳${RESET}"
fi
if [[ -n "$project_name" ]]; then
    output_string="${output_string} ${GRAY}│${RESET} ${CYAN}${project_name}${RESET} ${PURPLE}(${dir_display})${RESET}${worktree_marker}"
else
    output_string="${output_string} ${GRAY}│${RESET} ${PURPLE}${dir_display}${RESET}${worktree_marker}"
fi

# Add git info if present
[[ -n "$git_info" ]] && output_string="${output_string}${git_info}"

# Output ends with trailing space for visual comfort
output_string="${output_string} "

# --- Fetch usage and build extra lines ---
usage_json=$(fetch_usage)

usage_lines=""

# Line 2: Context bar (always shown if context data available)
if [[ "$context_window_size" -gt 0 ]] && [[ -n "$usage_percent" ]]; then
    ctx_bar=$(build_bar "$usage_percent" 10)
    ctx_color=$(color_for_pct "$usage_percent")
    ctx_pct=$(printf "%3d" "$usage_percent")
    ctx_suffix="${context_tokens_display} used"
    usage_lines+="\n ${BLUE}context${RESET} ${ctx_bar} ${ctx_color}${ctx_pct}%${RESET}  ${DIM}${ctx_suffix}${RESET}"
fi

# Lines 3-4: Current (5h) and Weekly (7d) usage
if [[ -n "$usage_json" ]]; then
    five_pct=$(echo "$usage_json" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
    five_reset=$(echo "$usage_json" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
    seven_pct=$(echo "$usage_json" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
    seven_reset=$(echo "$usage_json" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)

    # Round percentages to integers
    five_pct_int=$(awk "BEGIN {printf \"%.0f\", ${five_pct:-0}}")
    seven_pct_int=$(awk "BEGIN {printf \"%.0f\", ${seven_pct:-0}}")

    if [[ -n "$five_pct" ]]; then
        five_bar=$(build_bar "$five_pct_int" 10)
        five_countdown=$(format_countdown "$five_reset")
        five_color=$(color_for_pct "$five_pct_int")
        five_pct_fmt=$(printf "%3d" "$five_pct_int")
        usage_lines+="\n ${GREEN}current${RESET} ${five_bar} ${five_color}${five_pct_fmt}%${RESET}  ${DIM}resets in ${five_countdown}${RESET}"
    fi
    if [[ -n "$seven_pct" ]]; then
        seven_bar=$(build_bar "$seven_pct_int" 10)
        seven_countdown=$(format_countdown "$seven_reset")
        seven_color=$(color_for_pct "$seven_pct_int")
        seven_pct_fmt=$(printf "%3d" "$seven_pct_int")
        usage_lines+="\n ${YELLOW}weekly ${RESET} ${seven_bar} ${seven_color}${seven_pct_fmt}%${RESET}  ${DIM}resets in ${seven_countdown}${RESET}"
    fi
fi

# Output the complete string
echo -e "${output_string}${usage_lines}"
