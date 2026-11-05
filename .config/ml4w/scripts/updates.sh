#!/usr/bin/env bash
#  _   _           _       _
# | | | |_ __   __| | __ _| |_ ___  ___
# | | | | '_ \ / _` |/ _` | __/ _ \/ __|
# | |_| | |_) | (_| | (_| | ||  __/\__ \
#  \___/| .__/ \__,_|\__,_|\__\___||___/
#       |_|
#
# Waybar custom/updates: count pending official-repo + AUR updates.
# Restored from the ml4w dotfiles version, adapted to not need
# checkupdates-with-aur (AUR package, not installed here).

set -uo pipefail

threshold_yellow=25
threshold_red=100

# Wait (bounded) for pacman / checkupdates to release their db locks.
wait_for_locks() {
    local pacman_lock="/var/lib/pacman/db.lck"
    local checkup_lock="${TMPDIR:-/tmp}/checkup-db-${UID}/db.lck"
    local waited=0
    while [[ -f $pacman_lock || -f $checkup_lock ]] && ((waited < 120)); do
        sleep 1
        ((waited++))
    done
}

# Prints the number of pending official-repo updates; fails if the sync failed.
count_repo_updates() {
    if command -v checkupdates >/dev/null; then
        # checkupdates exits 2 when there are simply no updates
        local out rc
        out=$(checkupdates 2>/dev/null)
        rc=$?
        ((rc == 0 || rc == 2)) || return 1
        [[ -z $out ]] && echo 0 || wc -l <<<"$out"
        return 0
    fi
    # Same technique as checkupdates (pacman-contrib): sync a private copy of
    # the sync dbs with fakeroot so the real pacman db is never touched.
    command -v fakeroot >/dev/null || return 1
    local db="${TMPDIR:-/tmp}/checkup-db-${UID}"
    mkdir -p "$db/sync" || return 1
    [[ -e $db/local ]] || ln -s /var/lib/pacman/local "$db/local" || return 1
    # --disable-sandbox: pacman 7 can't drop to its 'alpm' download user
    # under fakeroot (checkupdates passes the same flag).
    timeout 90 fakeroot -- pacman -Sy --disable-sandbox --dbpath "$db" \
        --logfile /dev/null >/dev/null 2>&1 || return 1
    pacman -Qu --dbpath "$db" 2>/dev/null | wc -l
}

count_aur_updates() {
    local helper
    helper="$(cat ~/.config/ml4w/settings/aur.sh 2>/dev/null)"
    command -v "$helper" >/dev/null || { echo 0; return 0; }
    timeout 60 "$helper" -Qua 2>/dev/null | wc -l
}

wait_for_locks

if ! repo=$(count_repo_updates); then
    printf '{"text": "!", "alt": "error", "tooltip": "Update check failed (offline?)", "class": "red"}\n'
    exit 0
fi
aur=$(count_aur_updates)
updates=$((repo + aur))

css_class="green"
((updates > threshold_yellow)) && css_class="yellow"
((updates > threshold_red)) && css_class="red"

if ((updates > 0)); then
    tooltip="Official: ${repo}\\nAUR: ${aur}\\nClick to update your system"
else
    tooltip="No updates available"
fi

printf '{"text": "%s", "alt": "%s", "tooltip": "%s", "class": "%s"}\n' \
    "$updates" "$updates" "$tooltip" "$css_class"
