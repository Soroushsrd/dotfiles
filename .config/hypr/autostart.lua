-- User-local wallpaper tools must be visible to every session child.
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. os.getenv("PATH"))
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/scripts/session-start.sh")
    hl.exec_cmd("~/.config/hypr/scripts/gtk.sh")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper-restore.sh")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("hypridle")
end)

-- Restore the current wallpaper on outputs connected after login.
hl.on("monitor.added", function()
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper-output.sh")
end)

-- If the laptop panel was turned off and the external display goes away,
-- turn the panel back on so everything lands on it.
hl.on("monitor.removed", function()
    hl.exec_cmd("~/.config/hypr/scripts/monitor-fallback.sh")
end)
