#!/usr/bin/env bash
# Sync the tmux catppuccin theme with the freedesktop color-scheme portal —
# the same signal GNOME's dark/light toggle (and auto-dark-mode.nvim) uses.
#
# Usage:
#   tmux-theme-sync.sh            apply the current mode to running tmux (one-shot)
#   tmux-theme-sync.sh watch      watch the portal for SettingChanged and re-apply
#   tmux-theme-sync.sh dark|light apply a specific flavour directly

set -u

DARK=macchiato
LIGHT=latte
PLUGIN_SCRIPT="$HOME/.tmux/plugins/tmux/catppuccin.tmux"

# Only act if a tmux server is actually running.
tmux_running() {
  command -v tmux >/dev/null 2>&1 || return 1
  tmux ls >/dev/null 2>&1 # fails with "no server running" when idle
}

apply() {
  local flavour="$1"
  tmux_running || return 0
  tmux set -g "@catppuccin_flavor" "$flavour"
  # Catppuccin theme files set @thm_* with `set -ogq` (only-if-unset), so an
  # already-loaded palette would win. Clear it to force the new flavour.
  if tmux ls >/dev/null 2>&1; then
    for opt in $(tmux show -g 2>/dev/null | awk '$1 ~ /^@thm_/ {print $1}'); do
      tmux set -gu "$opt" 2>/dev/null
    done
  fi
  if [ -r "$PLUGIN_SCRIPT" ]; then
    tmux run-shell "$PLUGIN_SCRIPT" >/dev/null 2>&1
  fi
  return 0
}

# Query the portal: 0 = no preference (light), 1 = prefer-dark, 2 = prefer-light.
portal_value() {
  dbus-send --session --print-reply=literal --reply-timeout=2000 \
    --dest=org.freedesktop.portal.Desktop \
    /org/freedesktop/portal/desktop \
    org.freedesktop.portal.Settings.ReadOne \
    string:org.freedesktop.appearance string:color-scheme 2>/dev/null
}

flavour_from_value() {
  case "$1" in
    *"uint32 1"*) echo "$DARK" ;;
    *"uint32 0"* | *"uint32 2"*) echo "$LIGHT" ;;
    *) echo "" ;;
  esac
}

sync_current() {
  local flavour
  flavour="$(flavour_from_value "$(portal_value)")"
  [ -n "$flavour" ] && apply "$flavour"
  return 0
}

case "${1:-}" in
  dark) apply "$DARK" ;;
  light) apply "$LIGHT" ;;
  watch)
    # Heal tmux servers that started while the system was in the other mode.
    sync_current

    # Instant switching: react to the portal's SettingChanged signal.
    dbus-monitor --session \
      "type='signal',interface='org.freedesktop.portal.Settings',member='SettingChanged',path='/org/freedesktop/portal/desktop',arg0='org.freedesktop.appearance',arg1='color-scheme'" |
      while IFS= read -r line; do
        case "$line" in
          *"uint32 1"*) apply "$DARK" ;;
          *"uint32 0"* | *"uint32 2"*) apply "$LIGHT" ;;
        esac
      done
    ;;
  *) sync_current ;;
esac
