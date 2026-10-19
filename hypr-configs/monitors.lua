-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
--
-- Idempotent/safe: only applies explicit layout rules for outputs that are
-- actually connected right now. Missing external monitors (HDMI-A-1, DP-1, ...)
-- are skipped instead of configured, so a single-monitor laptop still boots
-- into a usable session instead of hanging in a login loop.

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

local function drm_connected(output)
  -- Check kernel DRM status files, no need for hyprctl/IPC during config load.
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
  { name = "eDP-1", position = "0x0" },
  { name = "HDMI-A-1", position = "1920x0" },
  { name = "DP-1", position = "3840x0" },
}

local connected = {}
for _, output in ipairs(outputs) do
  if drm_connected(output.name) then
    table.insert(connected, output.name)
    hl.monitor({
      output = output.name,
      mode = "preferred",
      position = output.position,
      scale = omarchy_monitor_scale,
    })
  end
end

-- Safe fallback: if none of the preferred outputs are connected (or this is a
-- brand new machine with different connector names), give Hyprland an
-- auto-positioned rule for any connected output so we always get a picture.
if #connected == 0 then
  hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = omarchy_monitor_scale,
  })
end

-- Only pin workspaces to monitors that actually exist. Rules referencing a
-- disconnected output make Hyprland resurface/misplace workspaces on reload.
local workspace_pins = {
  { workspace = "2", monitor = "eDP-1" },
  { workspace = "1", monitor = "HDMI-A-1" },
  { workspace = "3", monitor = "DP-1" },
}

for _, pin in ipairs(workspace_pins) do
  if drm_connected(pin.monitor) then
    hl.workspace_rule({
      workspace = pin.workspace,
      monitor = pin.monitor,
      persistent = true,
      default = true,
    })
  end
end
