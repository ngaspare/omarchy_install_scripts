-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")


-- Move "Close window" from SUPER+W to SUPER+SHIFT+Q
hl.unbind("SUPER + W")
o.bind("SUPER + SHIFT + Q", "Close window", hl.dsp.window.close())

-- Move "File manager" from SUPER+SHIFT+F to SUPER+E
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })

-- Swap Omarchy menu and Apps menu
hl.unbind("SUPER + SPACE")
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + SPACE", "Apps menu", "omarchy-menu toggle apps")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")

-- Bar panels moved from SUPER+CTRL+number to the function keys
for panel = 1, 9 do
  hl.unbind("SUPER + CTRL + code:" .. tostring(panel + 9))
  o.bind("SUPER + F" .. panel, "Bar panel " .. panel, "omarchy-shell -q shell togglePanelAt right " .. panel)
end

-- Workspaces 11-19 on SUPER+CTRL+number (freed from bar panels)
for workspace = 11, 19 do
  local key = "code:" .. tostring(workspace - 1)
  o.bind("SUPER + CTRL + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + CTRL + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
end
