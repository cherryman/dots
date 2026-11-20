-- https://www.superlogical.com/rex/docs/customize/config
-- mirrors tmux/tmux.conf and ghostty/config.ghostty: prefix is alt+a.

local prefix = "alt+a"

local function pbind(key, action, args)
  rex.bind(prefix .. ">" .. key, action, args)
end

pbind(prefix, "pane.send_key", { key = prefix })

-- panes
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("alt+" .. key, "pane.focus", { direction = dir })
  pbind(key, "pane.focus", { direction = dir })
  pbind("ctrl+" .. key, "pane.resize", { direction = dir })
  pbind("shift+" .. key, "pane.move", { direction = dir })
end

pbind("-", "pane.split", { direction = "down" })
pbind("\\", "pane.split", { direction = "right" })
pbind("z", "pane.zoom")
pbind("x", "pane.close")
pbind("=", "pane.balance")

-- tabs
rex.bind("alt+p", "client.tab.previous")
rex.bind("alt+n", "client.tab.next")
rex.bind("alt+shift+p", "client.tab.move.backward")
rex.bind("alt+shift+n", "client.tab.move.forward")
pbind("p", "client.tab.previous")
pbind("n", "client.tab.next")
pbind("shift+p", "client.tab.move.backward")
pbind("shift+n", "client.tab.move.forward")
pbind("c", "client.tab.new")
pbind(",", "client.tab.rename")

for i = 1, 9 do
  rex.bind("alt+" .. i, "client.tab.goto", { index = i })
end

-- sessions
rex.bind("alt+q", "session.switch")
pbind("s", "session.switch")
pbind("shift+4", "session.rename") -- $
pbind("shift+9", "session.previous") -- (
pbind("shift+0", "session.next") -- )

-- misc
pbind("b", "client.sidebar.toggle")
pbind("backspace", "client.font.reset")
