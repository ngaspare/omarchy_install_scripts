-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Lijevi monitor / Laptop (eDP-1) - fiksni workspace 1
hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "0x0",
  scale = omarchy_monitor_scale,
})

-- Centralni monitor (HDMI-A-1) - fiksni workspace 2
hl.monitor({
  output = "HDMI-A-1",
  mode = "preferred",
  position = "1920x0",
  scale = omarchy_monitor_scale,
})

-- Desni monitor (DP-1) - fiksni workspace 3
hl.monitor({
  output = "DP-1",
  mode = "preferred",
  position = "3840x0",
  scale = omarchy_monitor_scale,
})

hl.workspace_rule({ workspace = "2", monitor = "eDP-1", persistent = true, default = true })
hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", persistent = true, default = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-1", persistent = true, default = true })
