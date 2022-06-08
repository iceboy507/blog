local hyper = {'left_shift', 'left_control', 'left_option', 'left_command'}
local secondory_hyper = {'left_control', 'left_option', 'left_command'}

---------------------------------------------------------------------------------- 
------------------------------ hotkey app management -----------------------------
---------------------------------------------------------------------------------- 
hs.hotkey.bind(hyper, "i", function() hs.application.launchOrFocus('IntelliJ IDEA') end)
hs.hotkey.bind(hyper, "o", function() hs.application.launchOrFocus('DingTalk') end)
hs.hotkey.bind(hyper, "f", function() hs.application.launchOrFocus('Firefox') end)
hs.hotkey.bind(hyper, "j", function() hs.application.launchOrFocus('Obsidian') end)
hs.hotkey.bind(hyper, "k", function() hs.application.launchOrFocus('iTerm') end)
hs.hotkey.bind(hyper, "l", function() hs.application.launchOrFocus('Google Chrome') end)
hs.hotkey.bind(hyper, "g", function() hs.application.launchOrFocus('diagrams.net') end)
hs.hotkey.bind(hyper, "h", function() hs.application.launchOrFocus('阿里语雀') end)
hs.hotkey.bind(hyper, "n", function() hs.application.launchOrFocus('XMind') end)
hs.hotkey.bind(hyper, "b", function() hs.application.launchOrFocus('Visual Studio Code') end)

hs.hotkey.bind(hyper, "z", function() winresize("max")end)

hs.hotkey.bind(secondory_hyper, "R", function()    hs.reload()  hs.notify.new({title="Hammerspoon config reloaded", informativeText="Manually via keyboard shortcut"}):send()end)

------------------------------ hotkey app management -----------------------------


function showCurrentTime()
	local prettyNow = os.date('%A           📅  %B %d %Y         🕙   %H:%M:%S %p ')
	hs.alert.show(prettyNow, hs.alert.defaultStyle, hs.screen.mainScreen(), 1.5)
end

hs.hotkey.bind(hyper, "t", showCurrentTime) 

---------------------------------------------------------------------------------- 
------------------------------ window management -----------------------------
---------------------------------------------------------------------------------- 
-- Defines for window maximize toggler
local frameCache = {}
local logger = hs.logger.new("windows")

-- Resize current window

function winresize(how)
   local win = hs.window.focusedWindow()
   local app = win:application():name()
   local windowLayout
   local newrect

   if how == "left" then
      newrect = hs.layout.left50
   elseif how == "right" then
      newrect = hs.layout.right50
   elseif how == "up" then
      newrect = {0,0,1,0.5}
   elseif how == "down" then
      newrect = {0,0.5,1,0.5}
   elseif how == "max" then
      showFocusAlert("🎭 Fullscreen")
      newrect = hs.layout.maximized
   elseif how == "left_third" or how == "hthird-0" then
      newrect = {0,0,1/3,1}
   elseif how == "middle_third_h" or how == "hthird-1" then
      newrect = {1/3,0,1/3,1}
   elseif how == "right_third" or how == "hthird-2" then
      newrect = {2/3,0,1/3,1}
   elseif how == "top_third" or how == "vthird-0" then
      newrect = {0,0,1,1/3}
   elseif how == "middle_third_v" or how == "vthird-1" then
      newrect = {0,1/3,1,1/3}
   elseif how == "bottom_third" or how == "vthird-2" then
      newrect = {0,2/3,1,1/3}
   end

   win:move(newrect)
end

function winmovescreen(how)
   local win = hs.window.focusedWindow()
   if how == "left" then
      win:moveOneScreenWest()
   elseif how == "right" then
      win:moveOneScreenEast()
   end
end
------------------------------ window management -----------------------------



function showFocusAlert(content) 
    hs.alert.show(content, hs.alert.defaultStyle, hs.screen.mainScreen(), 0.5)
end

local function keyStroke(mods, key)
	if key == nil then
		key = mods
		mods = {}
	end

	return function() hs.eventtap.keyStroke(mods, key, 1000) end
end

local function remap(mods, key, pressFn)
	return hs.hotkey.bind(mods, key, pressFn, nil, pressFn)
end

--   return function ()
--       hs.eventtap.keyStroke({}, ':b', 10)
--     end
-- end

-- hs.hotkey.bind({'cmd', 'ctrl'}, 'l', test, nil, test)

function switchPane(key)
  local paneOption

  if key == 'h' then
    paneOption = '-L'
  elseif key == 'j' then
    paneOption = '-D'
  elseif key == 'k' then
    paneOption = '-U'
  elseif key == 'l' then
    paneOption = '-R'
  end

  return remap(
      {'cmd', 'ctrl'},
      key,
      function ()
        hs.eventtap.keyStroke({'ctrl'}, 'b', 1000)
        hs.eventtap.keyStroke({'shift'}, ';', 1000)
        hs.eventtap.keyStrokes("select-pane ".. paneOption)
        hs.timer.doAfter(0.1, function ()
          hs.eventtap.keyStroke({}, 'return', 1000)
        end)
      end
    )
end


local scenarioShortcuts = {
  firefox = {
    nextTab = remap({'cmd', 'ctrl'}, 'l', keyStroke({'ctrl'}, 'tab')),
    prevTab = remap({'cmd', 'ctrl'}, 'h', keyStroke({'ctrl', 'shift'}, 'tab'))
  },
  tmux = {
    -- paneRight = switchPane('l'),
    --paneLeft = switchPane('h'),
    --paneUp = switchPane('k'),
    --paneDown = switchPane('j'),
  }
}

local function enableScenarioShortcuts(scenario)
  for _, value in pairs(scenarioShortcuts[scenario]) do
    value:enable()
  end
end

local function disableScenarioShortcuts(scenario)
  for _, value in pairs(scenarioShortcuts[scenario]) do
    value:disable()
  end
  print(serializeTable(scenarioShortcuts))
end


function applicationWatcher(appName, eventType, appObject)

    if (eventType == hs.application.watcher.activated) then
        -- 初始化senarioShortcuts
        if (appName == "Finder") then
            -- Bring all Finder windows forward when one gets activated
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end
        if (appName == "iTerm2") then
            showFocusAlert("TERMINAL")
            enableScenarioShortcuts('tmux')
            disableScenarioShortcuts('firefox')
        end
        if (appName == "Google Chrome") then
            showFocusAlert("GOOGLE CHROME")
        end
        if (appName == "IntelliJ IDEA") then
            showFocusAlert("IDEA")
        end
        if (appName == "Firefox") then
            showFocusAlert("FIREFOX")
            enableScenarioShortcuts('firefox')
            disableScenarioShortcuts('tmux')
        end
        if (appName == "Obsidian") then
            showFocusAlert("OBSIDIAN")
            enableScenarioShortcuts('obsidian')
        end
    end
      print('current' .. serializeTable(scenarioShortcuts))

end
--appWatcher = hs.application.watcher.new(applicationWatcher)
--appWatcher:start()


function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end
