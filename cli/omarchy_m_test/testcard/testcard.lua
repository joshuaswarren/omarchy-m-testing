-- omarchy-m-test: once mpv shows the test card, screenshot the screen with grim, then quit.
-- OMT_SHOT is the PNG to write, OMT_OUTPUT the screen, OMT_WINDOWS the file for the window list
-- (see video-card.sh for the exit codes).
local shot, output = os.getenv("OMT_SHOT"), os.getenv("OMT_OUTPUT")
local shown = false

-- hyprctl's answer as JSON text, or nil.
local function hypr(what)
  local r = mp.command_native({
    name = "subprocess", args = {"timeout", "5", "hyprctl", what, "-j"},
    playback_only = false, capture_stdout = true,
  })
  return r.status == 0 and r.stdout or nil
end

-- OMT_WINDOWS: save the monitors and windows as they are when the screenshot is taken, so the CLI
-- can tell a window above the video (a floating terminal) from a wrong colour. Best effort.
local function save_windows()
  local path, monitors, clients = os.getenv("OMT_WINDOWS"), hypr("monitors"), hypr("clients")
  if not (path and monitors and clients) then return end
  local file = io.open(path, "w")
  if not file then return end
  file:write('{"pid":', tostring(require("mp.utils").getpid()), ',"monitors":', monitors, ',"clients":', clients, '}')
  file:close()
end

mp.register_event("playback-restart", function()
  if shown then return end
  shown = true
  -- Leave time for the fullscreen animation and the first frame to reach the screen.
  mp.add_timeout(1.5, function()
    save_windows()
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
