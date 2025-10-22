#!/bin/bash
# =====================================================================
#  cpfixperms.sh — Comprehensive cPanel Permission Repair Utility
#  Updated: 2025-10-22
#  Description:
#      Safely repairs ownership and permissions for one, multiple,
#      or all cPanel users, with logging, dry-run, and summary report.
# =====================================================================

LOGFILE="/var/log/cpfixperms.log"
DRYRUN=false
FIXALL=false
declare -a USERS

# --- Colors for readable output ---
C_RESET="\033[0m"
C_GREEN="\033[1;32m"
C_RED="\033[1;31m"
C_YELLOW="\033[1;33m"
C_BLUE="\033[1;34m"

# ---------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------

banner() {
    echo -e "${C_BLUE}----------------------------------------------------${C_RESET}"
    echo -e "${C_BLUE} cPanel Account Permission Repair Tool ${C_RESET}"
    echo -e "${C_BLUE}----------------------------------------------------${C_RESET}"
}

usage() {
    echo "Usage: $0 [options] [usernames]"
    echo
    echo "Options:"
    echo "  -a, --all         Fix permissions for ALL users in /var/cpanel/users/"
    echo "  -n, --dry-run     Test mode – show actions without changing anything"
    echo "  -h, --help        Show this help message"
    echo
    echo "Examples:"
    echo "  $0 user1 user2"
    echo "  $0 --all"
    echo "  $0 --dry-run --all"
    exit 0
}

log() {
    echo -e "$1" | tee -a "$LOGFILE"
}

run() {
    local cmd="$1"
    if $DRYRUN; then
        log "[DRY-RUN] $cmd"
    else
        eval "$cmd" >>"$LOGFILE" 2>&1
    fi
}

# ---------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--all) FIXALL=true ;;
        -n|--dry-run) DRYRUN=true ;;
        -h|--help) usage ;;
        *) USERS+=("$1") ;;
    esac
    shift
done

if [ "$FIXALL" = false ] && [ "${#USERS[@]}" -eq 0 ]; then
    usage
fi

# ---------------------------------------------------------------------
# Collect users if --all selected
# ---------------------------------------------------------------------
if $FIXALL; then
    if [ ! -d /var/cpanel/users ]; then
        log "${C_RED}Error: /var/cpanel/users not found.${C_RESET}"
        exit 1
    fi
    mapfile -t USERS < <(basename -a /var/cpanel/users/*)
    log "${C_YELLOW}Detected ${#USERS[@]} users from /var/cpanel/users/${C_RESET}"
fi

# ---------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------
banner
log "$(date '+%Y-%m-%d %H:%M:%S') — Starting permission repair"
log "Log file: $LOGFILE"
log "Mode: $([ $DRYRUN = true ] && echo 'DRY-RUN' || echo 'LIVE')"
log "Users to process: ${#USERS[@]}"
log "----------------------------------------------------"

for user in "${USERS[@]}"; do
    log "\n${C_YELLOW}>>> Processing user: $user ${C_RESET}"

    # Extract home directory
    HOMEDIR=$(awk -F: -v u="$user" '$1 == u {print $6}' /etc/passwd)

    if [ ! -f "/var/cpanel/users/$user" ]; then
        log "${C_RED}✖ Skipping invalid user: $user (no /var/cpanel/users entry)${C_RESET}"
        continue
    fi
    if [ -z "$HOMEDIR" ] || [ ! -d "$HOMEDIR" ]; then
        log "${C_RED}✖ Home directory missing or invalid for $user${C_RESET}"
        continue
    fi

    log "${C_GREEN}✓ Valid user detected — home: $HOMEDIR${C_RESET}"

    # --- Ownership corrections ---
    run "chown -R ${user}:${user} \"$HOMEDIR\""
    run "chmod 711 \"$HOMEDIR\""

    # --- Public directories ---
    [ -d "$HOMEDIR/public_html" ] && run "chown ${user}:nobody \"$HOMEDIR/public_html\" && chmod 750 \"$HOMEDIR/public_html\""
    [ -d "$HOMEDIR/.htpasswds" ] && run "chown ${user}:nobody \"$HOMEDIR/.htpasswds\""

    # --- Mail configuration ---
    if [ -d "$HOMEDIR/etc" ]; then
        run "chown ${user}:mail \"$HOMEDIR/etc\""
        run "find \"$HOMEDIR/etc\" -type f -name shadow -exec chown ${user}:mail {} \;"
        run "find \"$HOMEDIR/etc\" -type f -name passwd -exec chown ${user}:mail {} \;"
    fi

    # --- File & directory permissions ---
    run "find \"$HOMEDIR\" -type f -exec chmod 644 {} \;"
    run "find \"$HOMEDIR\" -type d -exec chmod 755 {} \;"
    run "find \"$HOMEDIR\" -type f \( -name '*.pl' -o -name '*.cgi' \) -exec chmod 755 {} \;"

    # --- Optional CageFS fix ---
    if [ -d "$HOMEDIR/.cagefs" ]; then
        log "Fixing CageFS permissions..."
        run "chmod 775 \"$HOMEDIR/.cagefs\""
        run "chmod 700 \"$HOMEDIR/.cagefs/tmp\" \"$HOMEDIR/.cagefs/var\" 2>/dev/null"
        run "chmod 777 \"$HOMEDIR/.cagefs/cache\" \"$HOMEDIR/.cagefs/run\" 2>/dev/null"
    fi

    log "${C_GREEN}✔ Completed: $user${C_RESET}"
done

# ---------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------
log "\n----------------------------------------------------"
log "Summary:"
log " Mode: $([ $DRYRUN = true ] && echo 'DRY-RUN (no changes)' || echo 'LIVE')"
log " Total users processed: ${#USERS[@]}"
log " Completed at: $(date '+%Y-%m-%d %H:%M:%S')"
log "----------------------------------------------------"
log "${C_BLUE}All done! See $LOGFILE for detailed results.${C_RESET}"
