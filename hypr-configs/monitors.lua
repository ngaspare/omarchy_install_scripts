-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Keep the known three-monitor layout when those outputs are connected. On a
-- different machine, configure only matching outputs and let Hyprland place
-- unknown outputs automatically instead of failing the whole session.
local function drm_connected(output)
  local pipe = io.popen("ls /sys/class/drm/card*-" .. output .. "/status 2>/dev/null")
  if not pipe then
    return false
  end

  for status in pipe:lines() do
    local handle = io.open(status, "r")
    if handle then
      local value = handle:read("*l")
      handle:close()
      if value and value:match("^connected%s*$") then
        pipe:close()
        return true
      end
    end
  end

  pipe:close()
  return false
end

local outputs = {
  { name = "eDP-1", position = "0x0", workspace = "2" },
  { name = "HDMI-A-1", position = "1920x0", workspace = "1" },
  { name = "DP-1", position = "3840x0", workspace = "3" },
}

local connected = 0
for _, output in ipairs(outputs) do
  if drm_connected(output.name) then
    connected = connected + 1
    hl.monitor({
      output = output.name,
      mode = "preferred",
      position = output.position,
      scale = omarchy_monitor_scale,
    })
    hl.workspace_rule({
      workspace = output.workspace,
      monitor = output.name,
      persistent = true,
      default = true,
    })
  end
end

-- This covers laptops with a different connector name and machines with no
-- matching outputs. An empty output matches every connected monitor.
if connected == 0 then
  hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = omarchy_monitor_scale,
  })
end
