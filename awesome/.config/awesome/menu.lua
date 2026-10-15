-- Prewarmed menu terminal.
--
-- One dedicated kitty window (WM_CLASS "menu", started by menu.service) stays
-- alive for the whole session and is kept hidden by awesome. A hotkey shows it
-- and hands a command to scripts/menu over a FIFO; the wrapper runs the command
-- on the pty, picks up a chained follow-up request if one was queued (see the
-- tv menu channel), and reports back when the window may be hidden again.
--
-- The wrapper is not tied to any program: `tv menu`, `nvim` or a bare prompt are
-- all just a command string.

local awful = require("awful")
local gears = require("gears")

local menu = {}

menu.class = "menu"
menu.service = "menu.service"
menu.runtime_dir = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/awesome-menu"
menu.fifo = menu.runtime_dir .. "/request"

local pending -- request waiting for the window to come up
local busy = false
local mode = "auto"

local function find_client()
	for _, c in ipairs(client.get()) do
		if c.class == menu.class then
			return c
		end
	end
end

local function shell_quote(s)
	return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function hide()
	local c = find_client()
	if c and not c.hidden then
		c.hidden = true
	end
	-- Focus is restored by awful.autofocus, which reacts to property::hidden
	-- and prefers the last focused non-sticky client - i.e. the window that was
	-- focused before the menu.
end

local function send(cmd, request_mode)
	-- Two lines: mode + command. Written from a forked shell so that the FIFO
	-- open can wait for the wrapper to come up without stalling awesome.
	awful.spawn({
		"sh",
		"-c",
		string.format(
			"printf '%%s\\n%%s\\n' %s %s > %s",
			shell_quote(request_mode),
			shell_quote(cmd),
			shell_quote(menu.fifo)
		),
	}, false)
end

function menu.open(cmd, request_mode)
	if busy then
		return
	end
	request_mode = request_mode or "auto"

	local c = find_client()
	if not c then
		-- The window is gone: closed, or the unit has not come up yet. Let
		-- systemd start it and send the request once it is mapped.
		pending = { cmd = cmd, mode = request_mode }
		awful.spawn({ "systemctl", "--user", "start", "--no-block", menu.service }, false)
		local request = pending
		gears.timer.start_new(3, function()
			if pending == request then
				pending = nil
			end
		end)
		return
	end

	busy, mode = true, request_mode
	c.sticky = true
	if resize then
		resize(c) -- the screen may have changed while the window was hidden
	end
	c.hidden = false
	c:emit_signal("request::activate", "menu", { raise = true })
	send(cmd, request_mode)
end

-- Called by the wrapper through awesome-client.
function menu.event(what, rc)
	if what == "busy" then
		busy = true
	elseif what == "done" then
		busy = false
		if mode ~= "hold" then
			hide()
		end
	end
end

client.connect_signal("manage", function(c)
	if c.class ~= menu.class then
		return
	end

	-- Re-hide after an awesome restart (the rule does it on first spawn).
	c.sticky = true
	c.hidden = true

	if pending then
		gears.timer.start_new(0.1, function()
			local request = pending
			pending = nil
			if request then
				menu.open(request.cmd, request.mode)
			end
		end)
	end
end)

client.connect_signal("unmanage", function(c)
	if c.class == menu.class then
		busy = false
		pending = nil
	end
end)

return menu