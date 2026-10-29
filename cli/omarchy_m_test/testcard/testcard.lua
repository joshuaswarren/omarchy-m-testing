-- omarchy-m-test: once mpv shows the test card, screenshot the screen with grim, then quit.
-- OMT_SHOT is the PNG to write, OMT_OUTPUT the screen, OMT_WINDOWS the file for the window list
-- (see video-card.sh for the exit codes).
local shot, output = os.getenv("OMT_SHOT"), os.getenv("OMT_OUTPUT")
local shown = false

local utils = require("mp.utils")

-- hyprctl's answer, parsed, or nil.
local function hypr(what)
  local r = mp.command_native({
    name = "subprocess", args = {"timeout", "5", "hyprctl", what, "-j"},
    playback_only = false, capture_stdout = true,
  })
  return r.status == 0 and utils.parse_json(r.stdout) or nil
end

-- The listed fields of each entry, and nothing else: window titles and classes never leave hyprctl.
local function pick(list, keys)
  local out = {}
  for _, entry in ipairs(list) do
    local kept = {}
    for _, key in ipairs(keys) do kept[key] = entry[key] end
    out[#out + 1] = kept
  end
  return out
end

-- OMT_WINDOWS: save where the screen and the windows are when the screenshot is taken, so the CLI
-- can tell a window above the video (a floating terminal) from a wrong colour. Best effort.
local function save_windows()
  local path, monitors, clients = os.getenv("OMT_WINDOWS"), hypr("monitors"), hypr("clients")
  if not (path and monitors and clients) then return end
  local file = io.open(path, "w")
  if not file then return end
  local screens = pick(monitors, {"id", "name", "x", "y", "width", "height", "scale", "transform", "activeWorkspace", "specialWorkspace"})
  for _, screen in ipairs(screens) do
    screen.activeWorkspace = {id = (screen.activeWorkspace or {}).id}
    screen.specialWorkspace = {id = (screen.specialWorkspace or {}).id}
  end
  local windows = pick(clients, {"pid", "mapped", "hidden", "at", "size", "workspace", "monitor", "floating", "pinned"})
  for _, window in ipairs(windows) do window.workspace = {id = (window.workspace or {}).id} end
  file:write(utils.format_json({pid = utils.getpid(), monitors = screens, clients = windows}))
  file:close()
end

mp.register_event("playback-restart", function()
  if shown then return end
  shown = true
  -- Leave time for the fullscreen animation and the first frame to reach the screen.
  mp.add_timeout(1.5, function()
    pcall(save_windows) -- the screenshot never waits on, or fails with, the window list
    local grim = mp.command_native({
      name = "subprocess", args = {"timeout", "10", "grim", "-s", "0.5", "-o", output, shot},
      playback_only = false, capture_stderr = true,
    })
    if grim.status == 0 then
      mp.msg.info("omarchy-m-test: screenshot taken")
      mp.commandv("quit", "0")
    else
      local why = (grim.stderr or ""):gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")
      mp.msg.error("omarchy-m-test: grim failed (exit " .. tostring(grim.status) .. ")" .. (why ~= "" and ": " .. why or ""))
      mp.commandv("quit", "6")
    end
  end)
end)

mp.add_timeout(20, function()
  if not shown then
    mp.msg.error("omarchy-m-test: the test card never started playing")
    mp.commandv("quit", "7")
  end
end)
