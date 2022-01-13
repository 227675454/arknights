print('util')

-- transfer 节点精灵 to 懒人精灵
getColor = function(x, y)
  local bgr = getPixelColor(x, y):upper()
  return bgr:sub(7, 8) .. bgr:sub(5, 6) .. bgr:sub(3, 4)
end
time = systemTime
exit = exitScript
JsonDecode = jsonLib.decode
JsonEncode = jsonLib.encode
findNode = function(selector) return nodeLib.findOne(selector, true) end
clickNode = function(x) nodeLib.click(x, true) end
clickPoint = function(x, y)
  local gesture = Gesture:new()
  local path = Path:new()
  path:setStartTime(0)
  path:setDurTime(1)
  path:addPoint(x, y)
  gesture:addPath(path)
  gesture:dispatch()
end
if not zero_wait_click then clickPoint = tap end

getDir = getWorkPath
base64 = getFileBase64
putClipboard = writePasteboard
_toast = toast
toast = function(x)
  _toast(x)
  log(x)
end

deviceClickEventMaxX = nil
deviceClickEventMaxY = nil
catchClick = function()
  if not root_mode then stop(15) end
  local result = exec("su -c 'getevent -l -c 4 -q'")
  local x, y
  x = result:match('POSITION_X%s+([^%s]+)')
  y = result:match('POSITION_Y%s+([^%s]+)')
  -- log(33, x, y)
  if x and y then
    if not deviceClickEventX then
      local event = result:match('(/dev/[^:]+):.+POSITION_X')
      result = exec("su -c 'getevent -il " .. event .. "'")
      deviceClickEventMaxX = result:match("POSITION_X[^\n]+max%s*(%d+)")
      deviceClickEventMaxY = result:match("POSITION_Y[^\n]+max%s*(%d+)")
    end
    local screen = getScreen()
    return {
      x = math.round(tonumber(x, 16) * screen.width / deviceClickEventMaxX),
      y = math.round(tonumber(y, 16) * screen.height / deviceClickEventMaxY),
    }
  end
end
home = function() keyPress(3) end
back = function() keyPress(4) end
power = function() keyPress(26) end
getScreen = function()
  local width, height = getDisplaySize()
  if getDisplayRotate() % 2 == 1 then width, height = height, width end
  return {width = width, height = height}
end
saveConfig = setStringConfig
loadConfig = function(k, v)
  v = v or ''
  local y = getStringConfig(k)
  if not y or #y == 0 then y = v end
  return y
end

peaceExit = function()
  need_show_console = false
  exit()
end

max = math.max
min = math.min
math.round = function(x) return math.floor(x + 0.5) end
round = math.round
clip = function(x, minimum, maximum) return min(max(x, minimum), maximum) end

-- https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
string.trim = function(s) return
  s:match '^()%s*$' and '' or s:match '^%s*(.*%S)' end

string.count = function(str, pattern)
  local ans = 0
  for _ in str.gfind(pattern) do ans = ans + 1 end
  return ans
end

string.map = function(str, map)
  local ans = ''
  for character in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
    -- print(character)
    if map[character] == nil then
      ans = ans .. character
    else
      ans = ans .. map[character]
    end
  end
  return ans
end

string.split = function(str, sep)
  if sep == nil then sep = "%s" end
  local t = {}
  for str in string.gmatch(str, "([^" .. sep .. "]+)") do table.insert(t, str) end
  return t
end

string.filterSplit = function(str, extra_map)
  str = string.map(str, update({
    [";"] = " ",
    ['"'] = " ",
    ["'"] = " ",
    ["；"] = " ",
    [","] = " ",
    ["_"] = "-",
    ["、"] = " ",
    ["，"] = " ",
    ["|"] = " ",
    ["@"] = " ",
    ["#"] = " ",
    ["\n"] = " ",
    ["\t"] = " ",
  }, extra_map or {}))
  return string.split(str)
end

string.startsWith = function(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

string.endsWith = function(str, suffix)
  return string.sub(str, #str - string.len(suffix) + 1) == suffix
end

startsWithX = function(x) return
  function(prefix) return x:startsWith(prefix) end end

string.padStart = function(str, len, char)
  if char == nil then char = " " end
  return string.rep(char, len - #str) .. str
end
string.padEnd = function(str, len, char)
  if char == nil then char = " " end
  return str .. string.rep(char, len - #str)
end

table.index = function(t, idx)
  local ans = {}
  for _, i in pairs(idx) do table.insert(ans, t[i]) end
  return ans
end
table.reduce = function(t, f, a)
  a = a or 0
  for _, c in pairs(t) do a = f(a, c) end
  return a
end
table.sum = function(t)
  local a = 0
  for _, c in pairs(t) do a = a + c end
  return a
end
-- 从t中选出长度为n的所有组合，结果在ans，
table.combination = function(t, n)
  local ans = {}
  local cur = {}
  local k = 1
  combination(t, n, ans, cur, k)
  return ans
end
combination = function(t, n, ans, cur, k)
  -- cur = cur or {}
  -- k = k or 1
  if n == 0 then
    table.insert(ans, shallowCopy(cur))
  elseif k <= #t then
    table.insert(cur, t[k])
    combination(t, n - 1, ans, cur, k + 1)
    cur[#cur] = nil
    combination(t, n, ans, cur, k + 1)
  end
end

table.flatten = function(t)
  local ans = {}
  for _, v in pairs(t) do
    if type(v) == 'table' then
      table.extend(ans, table.flatten(v))
    else
      table.insert(ans, v)
    end
  end
  return ans
end

table.remove_duplicate = function(t)
  local ans = {}
  local visited = {}
  for _, v in pairs(t) do
    if not visited[v] then
      table.insert(ans, v)
      visited[v] = 1
    end
  end
  return ans
end

table.appear_times = function(t, times)
  local ans = {}
  local visited = {}
  for _, v in pairs(t) do visited[v] = (visited[v] or 0) + 1 end
  -- log(visited)
  -- exit()
  for k, _ in pairs(visited) do
    if visited[k] == times then table.insert(ans, k) end
  end
  return ans
end
table.intersect = function(a, b)
  local ans = {}
  if #b < #a then a, b = b, a end
  b = table.value2key(b)
  a = table.value2key(a)
  for k, _ in pairs(a) do if b[k] then table.insert(ans, k) end end
  return ans
end

table.slice = function(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do sliced[#sliced + 1] = tbl[i] end
  return sliced
end
-- shallow table
table.contains = function(a, b)
  for k, v in pairs(b) do if a[k] ~= v then return false end end
  return true
end

table.value2key = function(x)
  local ans = {}
  for k, v in pairs(x) do ans[v] = k end
  return ans
end
table.select = function(mask, reference)
  local ans = {}
  for i = 1, #reference do if mask[i] then table.insert(ans, reference[i]) end end
  return ans
end

-- return true if there is an x s.t. f(x) is true
table.any = function(t, f)
  for k, v in pairs(t) do if f(v) then return true end end
end

-- return true if f(x) is all true
table.all = function(t, f)
  for _, v in pairs(t) do if not f(v) then return false end end
  return true
end

table.findv = function(t, f)
  for k, v in pairs(t) do if f(v) then return v end end
end

table.filter = function(t, f)
  local a = {}
  for _, v in pairs(t) do if f(v) then table.insert(a, v) end end
  return a
end

table.keys = function(t)
  local a = {}
  t = t or a
  for k, _ in pairs(t) do table.insert(a, k) end
  return a
end

table.values = function(t)
  local a = {}
  t = t or a
  for _, v in pairs(t) do table.insert(a, v) end
  return a
end

-- a,a+1,...b
range = function(a, b, s)
  local t = {}
  s = s or 1
  for i = a, b, s do table.insert(t, i) end
  return t
end

table.includes = function(t, e)
  return table.any(t, function(x) return x == e end)
end

table.extend = function(t, e)
  for k, v in pairs(e) do table.insert(t, v) end
  return t
end

--  in = {
--    "A" = {1,4,5,7},
--    "B" = {1,2,5,6},
--    "C" = {3,4,6,7},
--    "D" = {2,3,6,7},
--  }
-- out = { {"A","B"},...}
-- n:key, m:value O(mmn)
table.reverseIndex = function(t)
  local r = {}
  local s = {}
  for k, v in pairs(t) do for k2, v2 in pairs(v) do s[v2] = true end end
  for k, v in pairs(s) do
    r[k] = {}
    for k2, v2 in pairs(t) do
      if table.includes(v2, k) then table.insert(r[k], k2) end
    end
  end
  for k, v in pairs(r) do table.sort(v) end
  return r
end

table.find =
  function(t, f) for k, v in pairs(t) do if f(v) then return k end end end

table.shuffle = function(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

-- one depth compare, and key-value pairs all same
table.equal = function(a, b)
  if type(a) ~= 'table' or type(b) ~= 'table' then return end

  if #a ~= #b then return end
  if #a == 0 and #table.keys(a) ~= #table.keys(b) then return end

  for k, v in pairs(a) do if v ~= b[k] then return end end
  return true
end

-- one depth compare, and key all same
table.equalKey = function(a, b)
  if type(a) ~= 'table' or type(b) ~= 'table' then return end

  if #a ~= #b then return end
  if #a == 0 and #table.keys(a) ~= #table.keys(b) then return end

  for k, _ in pairs(a) do if b[k] == nil then return end end
  return true
end

equalX = function(x) return function(y) return x == y end end

shallowCopy = function(x)
  local y = {}
  if x == nil then return y end
  for k, v in pairs(x) do y[k] = v end
  return y
end

update = function(b, x, inplace, false_as_nil)
  local y = inplace and b or shallowCopy(b)
  if x == nil then return y end
  for k, v in pairs(x) do
    if false_as_nil and v == false then v = nil end
    y[k] = v
  end
  return y
end

-- n: num, a: alternative element
repeat_last = function(x, n, a)
  if a == nil then a = x[#x] end
  for i = 1, n do table.insert(x, a) end
  return x
end

-- TODO: better algorithms
loop_times = function(x)
  local times, f, n
  local maxlen = 40 -- of one piece
  local maxtimes = 1 -- of same pieces
  if x == nil or #x == 0 then return 0 end
  for i = 1, maxlen do
    f = true
    n = math.floor(#x / i)
    if n <= maxtimes then break end
    for j = 1, n - 1 do
      for k = 1, i do
        if x[#x - j * i - k + 1] ~= x[#x - k + 1] then
          f = false
          break
        end
      end
      if not f then
        maxtimes = math.max(maxtimes, j)
        break
      else
        maxtimes = math.max(maxtimes, j + 1)
      end
    end
  end
  return maxtimes
end

map = function(...)
  local a = {...}
  local n = select("#", ...)
  local r = {}
  local f, x = a[1], a[2]
  local p, ur
  if n < 2 then return r end
  if n == 2 then
    n = #x
  elseif n > 2 then
    ur = true
    x = {table.unpack(a, 2, n)}
    n = n - 1
  end
  for i = 1, n do
    p = x[i]
    if type(f) == "function" then
      p = f(p)
    elseif type(f) == "table" then
      p = f[p]
    end
    r[i] = p
  end
  if ur then return table.unpack(r, 1, n) end
  return r
end

ssleep = function(x)
  if x == nil then x = 1 end
  sleep(x * 1000)
end

table.join = function(t, d)
  d = not d and ',' or d
  local a = ''
  for i = 1, #t do
    a = a .. t[i]
    if i ~= #t then a = a .. d end
  end
  return a
end

table.clear = function(x) for k, v in pairs(x) do x[k] = nil end end

removeFuncHash =
  function(x) return x:startsWith('function') and 'function' or x end

table2string = function(t)
  if type(t) == 'table' then
    t = shallowCopy(t)
    for k, v in pairs(t) do if type(v) == "function" then t[k] = 'func' end end
    t = JsonEncode(t)
  end
  return t
end

-- log_history = {}
log = function(...)
  if disable_log then return end
  local arg = {...}

  local l = table.join({
    map(tostring, running, ' ', table.unpack(map(table2string, arg))),
  }, ' ')
  -- l = map(removeFuncHash, l)
  -- l = map(table2string, l)

  local a = os.date('%Y.%m.%d %H:%M:%S')
  -- local a = time()
  -- for _, v in pairs(l) do a = a .. ' ' .. v end
  print(l)
  console.println(1, a .. ' ' .. l)
  writeLog(l)
end

open = function() runApp(appid) end

stop = function(msg)
  msg = msg or ''
  msg = "stop " .. msg
  toast(msg)
  home() -- 游戏长时间在前台时模拟器很卡
  exit()
end

findColorAbsolute = function(color, confidence)
  -- print(286, confidence)
  confidence = confidence or 100
  -- keepScreen(true)
  for x, y, c in color:gmatch("(%d+),(%d+),(#[^|]+)") do
    -- log(x, y, c)
    if not compareColor(tonumber(x), tonumber(y), c, confidence) then
      -- if getColor(tonumber(x), tonumber(y)).hex ~= c then
      if verbose_fca then log(x, y, c) end
      -- keepScreen(false)
      return
    end
  end
  local x, y = color:match("(%d+),(%d+)")
  return {x = tonumber(x), y = tonumber(y)}
end

findOne_last_time = 0
findOne = function(x, confidence, disable_game_up_check)
  if type(x) == "function" then return x() end

  if not disable_game_up_check and (time() - findOne_last_time > 5000) then
    findOne_last_time = time()
    wait_game_up()
  end

  local x0 = x
  confidence = confidence or default_findcolor_confidence
  -- print(confidence)
  if type(x) == 'string' and not x:find(coord_delimeter) then x = point[x] end
  if type(x) == "function" then return x() end
  if type(x) == "table" and #x == 0 then return findNode(x) end
  if type(x) == "table" and #x > 0 then return x end
  if type(x) == "string" then
    local pos
    -- log(x0, rfl[x0], x, confidence)
    if rfl[x0] then
      if cmpColorEx(x, confidence) == 1 then pos = first_point[x0] end
    else
      local px, py
      -- log(x0, rfg[x0], first_color[x0], x)
      px, py = findMultiColor(rfg[x0][1], rfg[x0][2], rfg[x0][3], rfg[x0][4],
                              first_color[x0], x, 0, confidence)
      if px ~= -1 then pos = {px, py} end
    end
    return pos
  end
end

findAny = function(x) return appear(x, 0, 0) end

findOnes = function(x, confidence)
  confidence = confidence or default_findcolor_confidence
  return findMultiColorAll(rfg[x][1], rfg[x][2], rfg[x][3], rfg[x][4],
                           first_color[x], point[x], 0, confidence) or {}
end

-- x={2,3} "信用" func nil
tap = function(x, noretry, allow_outside_game)
  if not unsafe_tap and not allow_outside_game and not check_after_tap then
    wait_game_up()
  end

  local x0 = x
  if x == nil then return end
  if x == true then return true end
  if type(x) == "function" then return x() end
  if type(x) == "string" and not x:find(coord_delimeter) then
    x = point[x]
    if type(x) == "string" then
      local p = x:find(coord_delimeter)
      local q = x:find(coord_delimeter, p + 1)
      x = map(tonumber, {x:sub(1, p - 1), x:sub(p + 1, q - 1)})
    end
  end
  log("tap", x0, x)
  if type(x) ~= "table" then return end
  if #x > 0 then
    clickPoint(x[1], x[2])
  else
    clickNode(x)
  end
  local start_time = time()

  -- 后置检查
  if not unsafe_tap and not allow_outside_game and check_after_tap then
    wait_game_up()
  end

  -- 这个sleep的作用是两次gesture间隔太短被判定为长按/点击，游戏界面会无反应，
  -- 所以click后需要等一会儿
  -- 懒人无现象闪退，可能和点太快有关
  sleep(max(milesecond_after_click + start_time - time(), 0))

  -- 返回"面板"后易触发数据更新，导致操作失效
  if noretry then return end
  if type(x0) == 'string' and x0:startsWith('面板') then
    wait(function()
      if not findOne("面板") then return true end
      log("retap", x0)
      tap(x0, true, allow_outside_game)
    end, 10)
  end
end

-- simple swip for 资源收集
swipq = function(direction)
  local finger = {
    point = {
      {screen.width // 2, screen.height // 2},
      {direction == 'right' and (screen.width - 1) or 0, screen.height // 2},
    },
    duration = 500,
  }
  gesture(finger)
  sleep(finger.duration + 50)
end

-- quick swip for fight
swipu = function(dis)
  log('swipu', dis)
  -- preprocess distance
  if type(dis) == "string" then dis = distance[dis] end
  if type(dis) ~= "table" then dis = {dis} end
  if not dis then return end

  -- flatten to one depth
  -- local max_once_dis = 1080
  local max_once_dis = screen.width - scale(300)
  for _, d in pairs(dis) do
    local sign = d > 0 and 1 or -1
    if math.abs(d) == swip_right_max then
      swipe(sign > 0 and "right" or "left")
    else
      -- 只实现了右移
      if sign > 0 then stop(141) end

      local finger = {
        {
          point = {{0, scale(150)}, {0, screen.height - 1}},
          start = 0,
          duration = 0,
        },
      }
      local start = 0
      local duration = 150
      local interval = 50
      local end_delay = 50
      d = math.abs(d)
      while d > 0 do
        if d > max_once_dis then
          table.insert(finger, {
            point = {{max_once_dis, scale(150)}},
            start = start,
            duration = duration,
          })
        else
          table.insert(finger, {
            point = {{d, scale(150)}},
            start = start,
            duration = duration,
          })
        end
        d = d - max_once_dis
        start = start + duration + interval
        log(finger[#finger])
      end
      local last_finger = finger[#finger]
      finger[1].duration = last_finger.start + last_finger.duration + end_delay
      gesture(finger)
      sleep(finger[1].duration + 50)
    end
  end
end

-- swip to end for fight
swipe = function(x)
  -- 作战中第一次右滑容易错位，先做一次
  if first_time_swipe then
    first_time_swipe = false
    swip("9-2")
  end

  log("swipe", x)
  if x == 'right' then
    gesture({
      {
        point = {{scale(300), scale(150)}, {1000000, scale(150)}},
        start = 0,
        duration = 150,
      },
    })
    sleep(150 + 50)
  elseif x == 'left' then
    gesture({
      {
        point = {{scale(300), scale(150)}, {scale(300), screen.height - 1}},
        start = 0,
        duration = 100,
      },
      {point = {{screen.width - scale(300), 150}}, start = 60, duration = 50},
    })
    sleep(100 + 50)
  end

end

-- 安卓8以下的滑动用双指
android_verison_code = tonumber(getSdkVersion())
if android_verison_code < 24 then stop("安卓版本7以下不可用") end
-- if android_verison_code < 26 then
--   is_device_swipe_too_fast = true
-- else
--   is_device_swipe_too_fast = false
-- end

-- 华为手机需要慢速滑动
-- is_device_need_slow_swipe = true

-- simple swip for chapter navigation
swipc = function()
  local x1, y1, x2, y2
  x1, y1 = math.round((500 - 1920 / 2) * minscale + screen.width / 2),
           screen.height // 2
  x2, y2 = math.round((1500 - 1920 / 2) * minscale + screen.width / 2),
           scale(100)
  local finger = {point = {{x1, y1}, {x2, y1}, {x2, y2}}, duration = 500}
  gesture(finger)
  sleep(finger.duration + 50)
end

-- swip for operator
swipo = function(left)
  local duration
  local finger
  if left then
    local x1 = scale(600)
    local x2 = 10000000
    local y1 = scale(533)
    duration = 400
    finger = {{point = {{x1, y1}, {x2, y1}}, duration = duration}}
  else
    local x = scale(600)
    local y = scale(533)
    local y2 = scale(900)
    local x2 = scale(1681)
    local y3 = scale(900)
    local slids = 50
    local slidd = 200
    local taps = slids + slidd + 100
    local tapd = 200
    local downd = taps + 50
    duration = downd
    finger = {
      {point = {{x, y}, {x, y2}}, start = 0, duration = downd},
      {point = {{x2, y}, {x2, y3}}, start = slids, duration = slidd},
      {point = {{x2, y}, {x2, y3}}, start = taps, duration = tapd},
    }
  end
  log(JsonEncode(finger))
  gesture(finger)
  sleep(duration)
end

-- swip for fight
swip = function(dis)
  if type(dis) == "string" then dis = distance[dis] end
  if type(dis) ~= "table" then dis = {dis} end
  if not dis then return end
  for i, d in pairs(dis) do
    if i ~= 1 then ssleep(0.1) end
    if math.abs(d) == swip_right_max then
      swipe(d == swip_right_max and "right" or "left")
    else
      swipu(d)
    end
  end
end

-- pass loading, give a standard view of 基建
zoom = function(retry)
  log("zoom", retry)
  retry = retry or 0
  if retry > 10 then
    -- TODO: 提示到底影响了什么，是不能缩放，还是缩放结束找不到
    log("缩放结束未找到")
    return true
  end
  log(696, findOne("进驻总览"))
  if not findOne("进驻总览") then
    -- stop(695)
    return path.跳转("基建")
  end
  if findOne("缩放结束") then
    log("缩放结束")
    return true
  end

  -- 2x2 pixel zoom
  local duration = 50
  local finger = {
    {point = {{0, 0}}, duration = duration},
    {point = {{5, 0 + 5}, {0, 0}}, duration = duration},
    -- {point = {{0, scale(123)}}, duration = duration},
    -- {point = {{5, scale(123) + 5}, {0, scale(123)}}, duration = duration},
    -- {point = {{0, 0}}, duration = duration},
    -- {point = {{math.random(1,5), 0 + math.random(1,5)}, {0, 0}}, duration = duration},
    -- {point = {{0, 0}, {screen.width // 2 - scale(100), 0}}, duration = duration},
    -- {
    --   point = {
    --     {screen.width - scale(300), 0}, {screen.width // 2 - scale(100), 0},
    --   },
    --   duration = duration,
    -- },

  }
  gesture(finger)
  sleep(duration + 150)

  -- local start_time = time()
  -- if appear("缩放结束", (duration + 50) / 1000) then
  --   sleep(max(0, start_time + duration + 50 - time()))
  --   return true
  -- end 
  return zoom(retry + 1)
end

still_wrapper = function(func)
  return function(...)
    -- nodeLib.keepNode()
    keepCapture()
    local ret = func(...)
    releaseCapture()
    -- nodeLib.releaseNode()
    return ret
  end
end

-- 为什么auto要有两组状态： 第二组状态点唯一性不足，比如返回与邮件同时出现时，需要的是邮件。没有优先级。
auto = function(p, fallback, timeout, total_timeout)
  if type(p) == "function" then return p() end
  if type(p) ~= "table" then return true end
  local start_time = time()
  while true do
    if total_timeout and time() - start_time > total_timeout * 1000 then
      return true
    end
    -- local found = false
    local finish = false
    local check = function()
      for k, v in pairs(p) do
        -- log(663, k, v)
        -- print(type(k))
        if findOne(k) then

          -- log(664, k)
          log(k, "=>", v)
          -- effective_state = k
          -- found = true
          if tap(v) then finish = true end
          return true
        end
      end
    end
    timeout = timeout or 0
    local e = wait(check, timeout)
    if finish then return true end

    -- fallback自动机只做一次
    if not e and fallback then auto(path.fallback, nil, nil, 0) end
  end
end

parse_time = function(x)
  if not x then return os.time() end
  return os.time({
    year = tonumber(x:sub(1, 4)),
    month = tonumber(x:sub(5, 6)),
    day = tonumber(x:sub(7, 8)),
    hour = tonumber(x:sub(9, 10)),
    min = tonumber(x:sub(11, 12)),
  })
end

-- run function / job / table of function and job
run = function(...)
  local arg = {...}

  if #arg == 1 then
    if type(arg[1]) == "function" then return arg[1]() end
    if type(arg[1]) == "table" then arg = arg[1] end
  end
  qqmessage = {' '}
  init_state()

  -- 目前每个账号不同任务的状态共享，因此只在外层执行一次
  update_state()

  wait_game_up()
  setControlBar()

  for _, v in ipairs(arg) do
    -- setControlBarPosNew(0.00001, 1)
    running = v
    if type(v) == 'function' then
      log(773)
      v()
      log(774)
    else
      auto(path[v], path.fallback)
    end
  end

  -- 对每个账号的远程提醒，本地无需装QQ。
  if #QQ > 0 then
    path.跳转("首页")
    captureqqimagedeliver(os.date('%Y.%m.%d %H:%M:%S') .. table.join(qqmessage),
                          QQ)
  end
end

half_hour_cron = function(x, h)
  local m = 30
  if type(x) == "table" then
    if #x == 3 then
      x, h, m = x[1], x[2], x[3]
    else
      x, h = x[1], x[2]
    end
  end
  return {callback = function() run(x) end, hour = h, minute = m}
end

findTap = function(target)
  if type(target) == 'string' or #target == 0 then target = {target} end
  for _, v in pairs(target) do
    -- log(574, v, type(v))
    local p = findOne(v)
    if p then
      --      log("findTap:", v, p)
      tap(p)
      return v
    end
  end
end

appearTap = function(target, timeout, interval)
  if type(target) == 'string' or #target == 0 then target = {target} end
  target = appear(target, timeout, interval)
  if target then
    -- log("apperTap: ", target)
    findTap(target)
    return true
  end
end
-- {x:2,y:3} => {2,3}
xy2arr = function(t) return {t.x, t.y} end

clamp = function(x, minimum, maximum)
  minimum = minimum or 0
  maximum = maximum or (screen.width - 1)
  return min(max(x, minimum), maximum)
end
clampw = clamp
clamph = function(x, minimum, maximum)
  return clampw(x, minimum or 0, maximum or (screen.height - 1))
end

-- resoluton invariant deploy
-- idx=1 => the left most operator
-- idx=total => the right most operator
-- x2,y2 => destination
-- d => direction
deploy2 = function(idx, total, x2, y2, d)
  local max_op_width = scale(178) --  in loose mode, each operator's width
  local x1
  if total * max_op_width > screen.width then
    -- tight
    max_op_width = screen.width // total
    x1 = idx * max_op_width - max_op_width // 2
  else
    -- loose
    x1 = screen.width - (total - idx) * max_op_width - max_op_width // 2
  end
  x2 = math.round((x2 - (1920 / 2)) * minscale) + (screen.width // 2)
  y2 = math.round((y2 - (1080 / 2)) * minscale) + (screen.height // 2)
  deploy(x1, x2, y2, d)
end

deploy = function(x1, x2, y2, d)
  local y1 = screen.height - scale(109)
  d = d or 2
  d = ({{0, -1}, {1, 0}, {0, 1}, {-1, 0}})[d]
  d = {d[1] * 500, d[2] * 500}
  local dragd = 500
  local dird = 200
  local delay = 150
  local x3 = x2 - scale(5)
  local x4 = x2 + scale(5)
  local y3 = y2 - scale(5)
  local y4 = y2 + scale(5)
  local finger = {
    {
      point = {
        {x1, y1}, {x2, y2}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x2, y2},
        -- {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2},
        -- {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2},
        -- {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2},
        -- {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2},
        -- {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2},
        -- {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2},
        -- {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2},
        -- {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2},
        -- {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2},
        -- {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2},
        -- {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2},
        -- {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2},
        -- {x4, y2}, {x3, y2}, {x4, y2}, {x3, y2}, {x4, y2}, {x2, y2},
      },
      duration = dragd,
    }, {
      point = {{x2, y2}, {clamp(x2 + d[1]), clamp(y2 + d[2])}},
      duration = dird,
      start = dragd + delay,
    },
  }
  gesture(finger)
  sleep(dragd + delay + dird + delay)
  log("deploy", finger)
end

-- todo: make a map ?
retreat = function(x1, y1, x2, y2)
  local t = .5
  x1 = math.round((x1 - (1920 / 2)) * minscale) + (screen.width // 2)
  y1 = math.round((y1 - (1080 / 2)) * minscale) + (screen.height // 2)
  x2 = math.round((x2 - (1920 / 2)) * minscale) + (screen.width // 2)
  y2 = math.round((y2 - (1080 / 2)) * minscale) + (screen.height // 2)
  tap({x1, y1})
  ssleep(t)
  tap({x2, y2})
  ssleep(t)

  -- touchDown(0, x1, y1)
  -- ssleep(t)
  -- touchUp(0, x1, y1)
  -- ssleep(t)
  -- touchDown(0, x2, y2)
  -- ssleep(t)
  -- touchUp(0, x2, y2)
end

-- wait until func success
wait = function(func, timeout, interval)
  timeout = timeout or 2
  interval = interval or 0
  -- log(timeout,interval)
  local start_time = time()
  while true do
    local ans = func()
    -- log(584,ans)
    if ans then return ans end
    if (time() - start_time) > timeout * 1000 then break end
    ssleep(interval)
  end
end

-- wait until see node / point / list of node and point
appear = function(target, timeout, interval, disappear)
  log((disappear and "dis" or '') .. "appear", target)
  if not (type(target) == 'table' and #target > 0) then target = {target} end
  return wait(function()
    for _, v in pairs(target) do
      -- log(type(v), #v, v, findNode(v))
      if disappear then
        if type(v) == "function" and not v() then
          return v
        elseif type(v) == "table" and #v == 0 and not findNode(v) then
          return v
        elseif type(v) == "string" and #v > 0 and not findOne(v) then
          return v
        end
      else
        if type(v) == "function" and v() then
          return v
        elseif type(v) == "table" and #v == 0 and findNode(v) then
          return v
        elseif type(v) == "string" and #v > 0 and findOne(v) then
          return v
        end
      end
    end
  end, timeout, interval)
end

disappear = function(target, timeout, interval)
  return appear(target, timeout, interval, true)
end

wait_game_up = function(retry)
  if disable_game_up_check then return end
  retry = retry or 0
  if retry > 3 then stop("不能启动游戏") end
  if findOne("game") then return end
  open()
  screenon()
  appear({"game", "keyguard_indication", "keyguard_input"}, 5)
  checkScreenLock()
  log("wait_game_up next", retry)
  return wait_game_up(retry + 1)
end

screenLockSwipUp = function()
  if not wait(function()
    local node = findOne("keyguard_indication")
    if not node then return true end
    local center = (node.bounds.t + node.bounds.b) // 2
    local width = getScreen().width
    gesture({point = {{width // 2, center}, {width // 2, 1}}, duration = 1000})
    sleep(1000 + 50)
  end, 5) then stop("解锁失败1004") end
end
screenLockGesture = function()
  local point = JsonDecode(unlock_gesture or "[]") or {}
  if findOne("keyguard_input") then
    if unlock_mode == 0 then
      gesture({point = point, duration = 3000})
      sleep(3000 + 50)
    else
      for _, p in pairs(point) do
        tap(p)
        ssleep(.5)
      end
    end
    if not disappear("keyguard_input") then stop("解锁失败1005") end
  end
end

disable_game_up_check_wrapper = function(func)
  return function(...)
    local state = disable_game_up_check
    disable_game_up_check = true
    local ret = func(...)
    disable_game_up_check = state
    return ret
  end
end
never_end_wrapper = function(func)
  return function(...) while true do func(...) end end
end

-- 检查解锁界面
checkScreenLock = function()
  screenLockSwipUp()
  screenLockGesture()
end
checkScreenLock = disable_game_up_check_wrapper(checkScreenLock)

coming_hour = function(a, b, starttime)
  if a == nil then return b end
  if b == nil then return a end
  start = os.date("*t", starttime)

  atime = os.time({
    year = start.year,
    month = start.month,
    day = start.day,
    hour = tonumber(a),
  })
  if atime < starttime then atime = atime + 24 * 3600 end

  btime = os.time({
    year = start.year,
    month = start.month,
    day = start.day,
    hour = tonumber(b),
  })
  if btime < starttime then btime = btime + 24 * 3600 end

  if atime - starttime < btime - starttime then return a end
  return b
end

findtap_operator = function(operator)
  operator_notfound = table.value2key(operator)
  found = #operator
  swipo(true)
  tap("清空选择")
  -- swip 3 times only
  for i = 1, 3 do
    if found <= 0 then return end
    if i ~= 1 then swipo() end
    ssleep(1)
    -- 616,107
    local res = ocrp({
      rect = {scale(616), scale(107), screen.width - 1, screen.height - 1},
    })
    res = res or {}

    for _, node in pairs(res) do
      log(node.text)
      for pattern, _ in pairs(operator_notfound) do
        if string.find(node.text, pattern) then
          log('found', pattern)
          tap(node.text_box_position[1])
          operator_notfound[pattern] = nil
          found = found - 1
          if found == 0 then return end
          break
        end
      end
    end
  end
end

ocr_fast = function(x1, y1, x2, y2, timeout)
  timeout = timeout or 10
  local status, text, info
  wait(function()
    if status then return true end
    status, text, info = pcall(ocr, x1, y1, x2, y2)
  end, timeout)
  if not status then
    text = nil
    info = {}
  end
  return text, info
end

findtap_operator_fast = function(operator)
  operator_notfound = table.value2key(operator)
  found = #operator
  -- swip 3 times only
  for i = 1, 3 do
    if found <= 0 then return end
    if i ~= 1 then swipo() end

    -- TODO: wait for 节点精灵 fix bug
    -- we must ocr on small region if we want to use position
    local region = {
      {590, 487, 1059, 523}, {1033, 487, 1491, 523}, {1464, 487, 1919, 523},
      {590, 907, 1059, 943}, {1033, 907, 1491, 943}, {1464, 907, 1919, 943},
    }

    -- {0,0,0,0,"1059,457,#D2D1D1|1033,455,#FFFFFF|1464,443,#D1CACE|1491,446,#D6D5D5",95}

    -- local r = region[1]
    -- ocr_fast(scale(r[1]), scale(r[2]),
    --          scale(r[3]), scale(r[4]))
    for _, r in pairs(region) do
      local text, info
      text, info = ocr_fast(scale(r[1]), scale(r[2]), scale(r[3]), scale(r[4]))
      if text then
        log(text, info, r)
        for _, w in pairs(info.words) do
          if operator_notfound[w.word] then
            log('found', w.word)
            tap({scale(r[1]) + w.rect.left, scale(r[2]) + w.rect.top})
            operator_notfound[w.word] = nil
            found = found - 1
            if found == 0 then return end
          end
        end
        -- 补救节点精灵bug
        for w in string.gmatch(text, "([%z\1-\127\194-\244][\128-\191]*)") do
          if operator_notfound[w] then
            log('found in text but not in words', w)
            tap({
              math.round((r[3] - 100) * minscale),
              math.round((r[4] - 100) * minscale),
            })
            operator_notfound[w] = nil
            found = found - 1
            if found == 0 then return end
          end
        end
      end
    end
  end
end

findtap_operator_type = function(type)
  swipo(true)
  tap("清空选择")
  ssleep(2)
  log('type', type)
  local 经验加速 = {
    '#261500-50',
    '[{"a":0.129,"d":1.622,"id":"1","r":529.0,"s":"34|5<fOm>&5~9zPN&5~amm]&5>Yg}@&5]8m]^&5X[L$H&5X[L$H&5X[L$X&5>xRmv&5<quBx&5>GERF&5>GERE&5X[L$Y&5X[Npu&5X[Npu&5Y6o!c&5>YhCE&5~a15*&5~9z^6&5~9z^6&2~zjVe"}]',
    0.85,
  }
  local 赤金加速 = {
    '#202020-50',
    '[{"a":-0.044,"d":1.807,"id":"1","r":358.0,"s":"22|py&PS&PS&PS&H6!&18dN&18dN&18dM&18dM&2OY&2OY&2LC&2LC&2gre&4wSA&8{v2&8{v2&4wSs&aL6&ax~&ax~&lgc&k]*&k]*&lGs&H6!&H6!&H6!&18dM&H6Y"}]',
    0.85,
  }
  if type == '经验站' then
    type = 经验加速
  elseif type == "赤金站" then
    type = 赤金加速
  end
  -- swip 3 times only
  for i = 1, 3 do
    if i ~= 1 then swipo() end

    local candidate = findShape(type)
    if candidate then
      log(11777, #candidate)
      local p = {}
      for j, c in pairs(candidate) do
        -- 宽度不超过
        if c['x'] < 1920 * minscale then
          table.insert(p, 'candidates' .. j)
          point['candidates' .. j] = {c['x'], c['y']}
        end
      end
      if #p > 0 then
        tapAll(p)
        ssleep(.1)
      end
    end
  end
  swipo(true)
end

timeit = function(f)
  local start = time()
  f()
  log(time() - start)
end

tapAll = function(ks)
  log("tapAll", ks)
  -- 0 还是漏第一个
  -- 试试100 还是会漏第一个，这是界面看上去已经是完全可用状态了
  local duration = 1
  local finger = {}
  ks = shallowCopy(ks)
  for i, k in pairs(ks) do
    table.insert(finger,
                 {point = {{point[k][1], point[k][2]}}, duration = duration})
  end
  gesture(finger)
  sleep(duration + 50)
end

-- event queue
Lock = {}
function Lock:new(o)
  o = o or {queue = {}, length = 0, id = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end
function Lock:remove(id)
  self.queue[id] = nil
  self.length = self.length - 1
end
function Lock:exist(id) return self.queue[id] end
function Lock:add()
  self.id = self.id + 1
  self.queue[self.id] = 1
  self.length = self.length + 1
  return self.id
end
lock = Lock:new()

captureqqimagedeliver = function(info, to)
  io.open(getWorkPath() .. '/.nomedia', 'w')
  local img = getWorkPath() .. "/tmp.jpg"
  snapShot(img)
  notifyqq(base64(img), tostring(info), tostring(to))
end

poweroff = function() if root_mode then exec("su -c 'reboot -p'") end end
closeapp = function(package)
  log("closeapp", package)
  if not isAppInstalled(package) then return end
  if root_mode then
    exec("su -c 'am force-stop " .. package .. "'")
  elseif false then
    local intent = {
      action = "android.settings.APPLICATION_DETAILS_SETTINGS",
      uri = "package:" .. package,
    }
    runIntent(intent)
    log(intent)
    local stop_node
    stop_node = appear({
      {text = "*停止*"}, {text = "*结束*"}, {text = "*STOP*"},
    }, 10)
    if not stop_node then return end
    stop_node = findNode(stop_node)
    if not stop_node or not stop_node.enabled then return back() end
    tap(stop_node)

    ok_node = nil
    ok_node = appear({{text = "*确*"}, {text = "*OK*"}}, 5)
    if not ok_node then return end
    ok_node = findNode(ok_node)
    if not ok_node or not ok_node.enabled then return back() end
    tap(ok_node)
    disappear(ok_node)
    back()
    disappear(stop_node)
  end
end
closeapp = disable_game_up_check_wrapper(closeapp)
screenoff =
  function() if root_mode then exec('su -c "input keyevent 223"') end end
screenon = function()
  if root_mode then
    exec('su -c "input keyevent 224"')
  else
    -- stop("无障碍亮屏未实现")
  end
end

multiply = function(prefix, times)
  times = times or 1
  local ans = {}
  for i = 1, times do table.insert(ans, prefix .. i) end
  return ans
end

parse_id_to_ui = function(prefix, length)
  local ans = ''
  for i = 1, length do ans = ans .. prefix .. i .. '|' end
  return ans:sub(1, #ans - 1)
end

parse_value_to_ui = function(all, select)
  local ans = ''
  for _, v in pairs(all) do
    if table.includes(select, v) then ans = ans .. '*' end
    ans = ans .. v .. '|'
  end
  return ans:sub(1, #ans - 1)
end

parse_from_ui = function(prefix, reference)
  local ans = {}
  for i = 1, #reference do
    -- log("prefix..i", prefix .. i, _G[prefix .. i])
    if _G[prefix .. i] then table.insert(ans, reference[i]) end
  end
  return ans
end

all_job = {
  "邮件收取", "轮次作战", "访问好友", "基建收获",
  "基建换班", "制造加速", "线索搜集", "副手换人",
  "信用购买", "公招刷新", "任务收集", "限时活动",
}

now_job = {
  "邮件收取", "轮次作战", "访问好友", "基建收获",
  "基建换班", "制造加速", "线索搜集", "副手换人",
  "信用购买", "公招刷新", "任务收集", "限时活动",
}

make_account_ui = function(layout, prefix)
  layout = layout or "main"
  prefix = prefix or ''
  newRow(layout)
  addTextView(layout, "作战")
  ui.addEditText(layout, prefix .. "fight_ui",
                 [[当期委托x2 DQWTx2 龙门市区x0 LMSQx0 9-10*2 9-19 4-4 4-9 JT8-3 PR-D-2 CE-5 LS-5 上一次 syc]])

  newRow(layout)
  addTextView(layout, "最多吃")
  ui.addEditText(layout, prefix .. 'max_drug_times', "9999")
  addTextView(layout, "次药和")
  ui.addEditText(layout, prefix .. 'max_stone_times', "0")
  addTextView(layout, "次石头")

  newRow(layout)
  addTextView(layout, "换班模式")
  ui.addRadioGroup(layout, prefix .. "prefer_speed",
                   {"极速", "高产(别用)"}, 0, -2, -2, true)

  -- newRow(layout)
  -- addTextView(layout, "信用不买")
  -- ui.addEditText(layout, prefix .. 'goods_blacklist', "碳 碳素")

  -- newRow(layout)
  -- addTextView(layout, "换班优先")
  -- ui.addRadioGroup(layout, prefix .. "prefer_skill", {"工作状态", "技能"},
  --                  1, -2, -2, true)

  -- newRow(layout)
  -- addTextView(layout, "基建换班")
  -- ui.addCheckBox(layout, prefix .. "shift1", "宿舍", true)
  -- ui.addCheckBox(layout, prefix .. "shift2", "制造", true)
  -- ui.addCheckBox(layout, prefix .. "shift3", "总览", true)

  newRow(layout)
  addTextView(layout, "自动招募")
  ui.addCheckBox(layout, prefix .. "auto_recruit1", "小车", true)
  ui.addCheckBox(layout, prefix .. "auto_recruit4", "4星", true)
  ui.addCheckBox(layout, prefix .. "auto_recruit5", "5星", false)
  ui.addCheckBox(layout, prefix .. "auto_recruit6", "6星", false)

  -- local max_checkbox_one_row = getScreen().width //200
  local max_checkbox_one_row = 3
  for k, v in pairs(all_job) do
    if k % max_checkbox_one_row == 1 then
      newRow(layout, prefix .. "now_job_row" .. k, "center")
    end
    ui.addCheckBox(layout, prefix .. "now_job_ui" .. k, v,
                   table.includes(now_job, v))
  end
end

show_multi_account_ui = function()
  toast("正在加载多账号设置...")
  local num = 20
  local layout = "multi_account"
  ui.newLayout(layout, ui_page_width, -2)
  ui.setTitleText(layout, "多账号")
  newRow(layout)
  addTextView(layout,
              [[填入账密才有效。双服无账密模式至多执行前两个账号且不会重登，可不填账密。]])
  newRow(layout)
  ui.addCheckBox(layout, "multi_account", "多账号总开关", true)
  ui.addCheckBox(layout, "dual_server", "双服无账密")
  newRow(layout)
  ui.addCheckBox(layout, "multi_account_end_closeapp",
                 "切换账号时关闭其他账号游戏", true)
  newRow(layout, layout .. "_save_row", "center")
  ui.addButton(layout, layout .. "_start", "返回", ui_submit_width)
  ui.setBackground(layout .. "_start", ui_submit_color)
  ui.setOnClick(layout .. "_start", make_jump_ui_command(layout, "main"))

  newRow(layout, "center")
  for i = 1, num do
    local padi = tostring(i):padStart(2, '0')
    newRow(layout)
    addTextView(layout, "账号" .. padi)
    ui.addEditText(layout, "username" .. i, "", -1)
    addTextView(layout, "密码")
    ui.addEditText(layout, "password" .. i, "", -1)
    ui.addCheckBox(layout, "multi_account" .. i, "启用", true)
    newRow(layout)
    addTextView(layout, "账号" .. padi .. "服务器")
    ui.addRadioGroup(layout, "server" .. i, {"官服", "B服"}, 0, -2, -2, true)
    newRow(layout)
    addTextView(layout, "账号" .. padi .. "使用")
    ui.addSpinner(layout, "multi_account_inherit_spinner" .. i, {}, 0)
    addTextView(layout, "设置")
    addButton(layout, "multi_account_inherit_toggle" .. i,
              "切换为独立设置",
              "multi_account_inherit_toggle(" .. i .. ")")
    setNewRowGid("multi_account_user_row" .. i)
    make_account_ui(layout, "multi_account_user" .. i)
    setNewRowGid()
  end

  local all_inherit_choice = map(function(j)
    return "账号" .. tostring(j):padStart(2, '0')
  end, table.filter(range(1, num), function(k) return k ~= i end))
  all_inherit_choice = table.extend({"默认"}, all_inherit_choice)
  -- ui函数必须global
  multi_account_inherit_toggle = function(i)
    local btn = "multi_account_inherit_toggle" .. i
    if ui.getText(btn) == "切换为独立设置" then
      ui.setText(btn, "切换为继承设置")
    else
      ui.setText(btn, "切换为独立设置")
    end
    multi_account_inherit_render(i)
  end

  -- ui函数必须global
  multi_account_inherit_render = function(start, stop)
    local layout = "multi_account"
    start = start or 1
    stop = stop or start
    for i = start, stop do
      local btn = "multi_account_inherit_toggle" .. i
      local gid = "multi_account_user_row" .. i
      if ui.getText(btn) == "切换为独立设置" then
        ui.setRowVisibleByGid(layout, gid, 8)
        ui.setSpinner("multi_account_inherit_spinner" .. i, all_inherit_choice,
                      0)
      else
        ui.setRowVisibleByGid(layout, gid, 0)
        -- TODO 这里“独立”的大小和“默认”有区别
        ui.setSpinner("multi_account_inherit_spinner" .. i, {"  独立  "}, 0)
      end
    end
  end

  ui.loadProfile(getUIConfigPath(layout))
  multi_account_inherit_render(1, num)
  ui.show(layout, false)
end

transfer_global_variable = function(prefix, save_prefix)
  local stem
  for k, v in pairs(_G) do
    if k:startsWith(prefix) then
      stem = string.sub(k, #prefix + 1)
      if save_prefix and #save_prefix > 0 then
        _G[save_prefix .. stem] = _G[stem]
      end
      _G[stem] = v
    end
  end
end

notifyqq = function(image, info, to, sync)
  image = image or ''
  info = info or ''
  to = to or ''
  local id = lock:add()
  local param = "image=" .. encodeUrl(image) .. "&info=" .. encodeUrl(info) ..
                  "&to=" .. encodeUrl(to)
  log('notify qq', info, to)
  asynHttpPost(function(res, code)
    -- log("notifyqq response", res, code)
    lock:remove(id)
  end, "http://82.156.198.12:49875", param)
  if sync then wait(function() return not lock:exist(id) end, 30) end
end

-- remove unneed elements while preserving cursor
clean_table = function(t, idx, bad)
  local ans = {}
  for k, v in pairs(t) do
    if not bad(v) then table.insert(ans, v) end
    if idx == k then idx = #ans end
  end
  return ans, idx
end

hotUpdate = function()
  toast("正在检查更新...")
  if disable_hotupdate then return end
  local url = 'https://gitee.com/bilabila/arknights/raw/master/script.lr'
  local newPath = getWorkPath() .. '/newscript.lr'
  if downloadFile(url, newPath) == -1 then
    toast("更新失败")
    return
  end
  if fileMD5(newPath) == loadConfig("lr_md5", "") then
    toast("已经是最新版")
    return
  end
  installLrPkg(newPath)
  saveConfig("lr_md5", fileMD5(newPath))
  -- toast("已更新至最新")
  return restartScript()
end

styleButton = function(layout)
  ui.setBackground(layout, "#fff1f3f4")
  ui.setTextColor(layout, "#ff000000")
end

addButton = function(layout, id, text, func, w, h)
  ui.addButton(layout, id, text, w or -2, h or -2)
  ui.setOnClick(id, func)
  -- styleButton(id)
end

setNewRowGid = function(gid) default_row_gid = gid end
newRow = function(layout, id, align, w, h)
  -- log(173,default_row_gid)
  ui.newRow(layout, id or randomString(32), w or -2, h or -2, default_row_gid)
  align = align or 'left'
  -- if id and align == 'center' then ui.setGravity(id, 17) end
end
addTextView = function(layout, text, id)
  ui.addTextView(layout, id or randomString(32), text)
end

make_jump_ui_command = function(cur, next, extra)
  -- log(getUIConfigPath(cur))
  local cmd = {
    -- 'log(ui.getData())',
    "ui.saveProfile('" .. getUIConfigPath(cur) .. "')",
    "ui.dismiss('" .. cur .. "');", next and "show_" .. next .. "_ui()" or '',
    extra or '',
  }
  return table.join(cmd, ';')
end

show_main_ui = function()
  local layout = "main"
  ui.newLayout(layout, ui_page_width, -2)
  -- ui.setTitleText(layout, "明日方舟速通 " .. loadConfig("releaseDate", ''))
  ui.setTitleText(layout, "明日方舟速通 " .. release_date)

  if appid_need_user_select then
    newRow(layout)
    addTextView(layout, "服务器")
    ui.addRadioGroup(layout, "server", {"官服", "B服"}, 0, -2, -2, true)
  end

  make_account_ui(layout)

  newRow(layout)
  addTextView(layout, "完成后通知QQ")
  ui.addEditText(layout, "QQ", "")
  addButton(layout, layout .. "jump_qq_btn", "需加机器人好友",
            "jump_qq()")

  newRow(layout)
  addTextView(layout, "完成后")
  ui.addCheckBox(layout, "end_home", "回到主页", true)
  ui.addCheckBox(layout, "end_closeapp", "关闭游戏", true)
  ui.addCheckBox(layout, "end_screenoff", "熄屏")
  newRow(layout)
  addTextView(layout, "定时执行")
  ui.addEditText(layout, "crontab_text", "8:00 16:00 24:00")
  ui.addCheckBox(layout, "crontab_enable", "启用", true)

  -- 无法实现
  -- ui.addCheckBox(layout, "end_poweroff", "关机")

  newRow(layout)
  addTextView(layout,
              [[异形屏适配设为0，开基建退出提示。关游戏模式侧边栏，关深色夜间护眼模式，关隐藏刘海，注意全面屏手势区域。关懒人输入法，音量加停止脚本。看下左下角帮助。]])

  -- local max_checkbox_one_row = getScreen().width // 200
  local max_checkbox_one_row = 3
  local buttons = {
    {
      layout .. "multi_account", "多账号",
      make_jump_ui_command(layout, 'multi_account'),
    }, {
      layout .. "screenon", "亮屏解锁",
      make_jump_ui_command(layout, 'gesture_capture'),
    }, -- {
    --   layout .. "crontab", "定时执行",
    --   make_jump_ui_command(layout, 'crontab'),
    -- },
    -- {
    --   layout .. "github", "源码",
    --   make_jump_ui_command(layout, nil, "jump_github()"),
    -- },
    -- {
    --   layout .. "qqgroup", "反馈群",
    --   make_jump_ui_command(layout, nil, "jump_qqgroup()"),
    -- },
    {
      layout .. "extra", "其他功能",
      make_jump_ui_command(layout, nil, make_jump_ui_command(layout, "extra")),
    }, {layout .. "help", "必读", make_jump_ui_command(layout, "help")},
    -- {
    --   layout .. "demo", "视频演示",
    --   make_jump_ui_command(layout, nil, "jump_bilibili()"),
    -- },
  }
  for k, v in pairs(buttons) do
    if k % max_checkbox_one_row == 1 then
      newRow(layout, layout .. "screenon_row" .. k, "center")
    end
    addButton(layout, v[1], v[2], v[3])
  end

  -- newRow(layout, layout .. "bottom_row", "center")
  addButton(layout, layout .. "_stop", "退出",
            make_jump_ui_command(layout, nil, "peaceExit()"))
  ui.setBackground(layout .. "_stop", ui_cancel_color)
  addButton(layout, layout .. "_start", "启动",
            make_jump_ui_command(layout, nil, "lock:remove(main_ui_lock)"),
            ui_small_submit_width)
  ui.setBackground(layout .. "_start", ui_submit_color)

  ui.loadProfile(getUIConfigPath(layout))
  -- log(getUIConfigPath(layout))
  -- 后处理
  if not root_mode then
    ui.setEnable("end_screenoff", false)
    ui.setEnable("end_poweroff", false)
    ui.setEnable("end_closeapp", false)
  end
  ui.show(layout, false)
end

show_help_ui = function()
  local layout = "help"
  ui.newLayout(layout, ui_page_width, -2)
  ui.setTitleText(layout, "帮助")
  newRow(layout)
  addTextView(layout, [[
源码与其他脚本：github.com/tkkcc/arknights
好用给个star，有问题请反馈，反馈群：1009619697]])

  newRow(layout)
  ui.addButton(layout, layout .. "_stop", "返回")
  ui.setBackground(layout .. "_stop", ui_cancel_color)
  ui.setOnClick(layout .. "_stop", make_jump_ui_command(layout, "main"))

  newRow(layout)
  addTextView(layout, [[
Q&A

Q：怎么用？
A：脚本主界面上方为“任务开始前的设置”，中间为“需要执行的任务”，下方为“任务完成后的设置”，底部为“更多功能”。勾选任务，然后点启动。

Q：怎么刷关卡？
A：勾选“轮次作战”任务，修改“作战”设置，启动。作战将依次执行，跳过无效关，到末尾后再从头开始。

Q：作战设置格式？
A：每个关卡名用常见分隔符隔开，关卡名后可用*或x加数字表示重复，中文可替换为首字母简拼，大小写混输。平时建议填剿灭+常规关，例如填“当期委托*5 CA-5*1 9-10 上一次x0”，表示5次新剿灭+1次CA-5+1次9-10。

Q：合成玉满了还会继续刷吗？
A：不会，任何作战开始前（包括上一次）都会判断合成玉是否已满，已满则所有剿灭无效。

Q：资源关未开放会怎么样？
A：资源关未开放时无效，会跳过。资源关全天开放时段会通过热更新提前设置。

Q：怎么只刷1-7？
A：勾选“轮次作战”，作战设置填“1-7”，启动

Q：怎么只刷上一次？
A：勾选“轮次作战”，作战设置填“上一次”，启动

Q：新剿灭没打，只能打龙门市区？
A：勾选“轮次作战”，作战设置里“当期委托”改成“龙门市区”，启动

Q：作战设置不能修改？
A：别开懒人输入法。

Q：DQWT、LMSQ、syc是什么意思？
A：当期委托、龙门市区、上一次的首字母简拼

Q：活动怎么刷？
A：不想吃石头的勾选“轮次作战”任务，作战设置填“上一次”，然后手动刷一次活动关再启动。想一口气刷满然后搬空商店的，不修改作战设置，调大石头上限，在活动关代理指挥中启动脚本，脚本将优先重复刷当前关。本人使用后者，因为之后无需再关心。

Q：基建反复进入退出？
A：基建退出提示要开。

Q：换班产率太低？
A：“极速”换班以最快放满干员为目标，不考虑干员技能。“高产”换班考虑单站最优技能组合，忽略其他站干员技能加成（如迷迭香、焰尾、森蚺），忽略“意识协议”技能效果。“高产”换班还在开发，建议尝试其他脚本，详见github项目主页。

Q：换班漏换干员？
A：请加群反馈。

Q：换班换了低心情干员？
A：一般是低心情干员过多。用脚本每8小时换一次，一段时间后不会出现。

Q：自动招募怎么用？
A：勾选“公招刷新”任务，启动。“公招刷新”对于保底标签会按“自动招募”设置来执行，“自动招募”勾了就招募，没勾则保留。对于非保底标签能刷新就刷新。

Q：非保底标签能不能也自动招募，刷绿票？
A：暂时不行，建议尝试其他脚本。

Q：自动招募会不会错过资深标签？
A：不会，一是标签识别非常保守，有问题就保留，二是有官方保险，在未勾选资深标签时招募或刷新都会弹窗，脚本遇到会卡住，但理论上不会遇到。

Q：线索满了给谁？
A：优先给缺线索且今日登录的好友。

Q：通知QQ有什么用？
A：任务完成后，机器人将把首页截图与可招募标签发给QQ。一般与 定时任务+云手机/模拟器/备用机 配合使用，这样平时只需检查聊天记录，无需接触游戏。
    
Q：通知QQ无效？
A：一是分辨率过高导致截图超过10M被服务端拒绝，二是机器人仍然无法向你发消息，可以加反馈群，机器人能以“群临时会话”方式向你发消息。

Q：定时任务无效？
A：任务完成后，如果设了定时，脚本会等到下个定时点再做。不启动无效。

Q：脚本有没有记忆？
A：没有，每次运行完全独立，不依赖之前运行结果。

Q：在模拟器上没反应？
A：
1. 脚本适用于雷电、夜神、逍遥、genymotion、vmos。不适用于蓝叠5（无障碍录屏功能缺失），mumu6（安卓6版本过低），mumu9（横竖屏切换闪烁，属于脚本框架问题）。
2. 脚本要求安卓>=7，分辨率>=1280x720，长宽比>=16:9。
3. 切换渲染引擎（DirectX与OpenGL）后再尝试一次。本人逍遥只能用OpenGL。
4. 建议更换其他模拟器或尝试其他脚本。

Q：有root还要手动开启无障碍？
A：有root脚本会自动开无障碍。软件启动后的无障碍提示选“以后不再提醒”，进入后直接点“确定”即可。

Q：在手机上没反应？
A：
1. 手机相比模拟器更复杂，首先检查“模拟器没反应”问题答案。
2. 脚本主界面下方有一段注意事项，请检查。
3. 重启一次系统。
4. 建议通过vmos使用或尝试其他脚本。

Q：游戏在小窗/后台/熄屏时支持吗？
A：不支持，除非通过vmos使用。

Q：vmos是什么？
A：vmos（虚拟大师）是手机上的模拟器/虚拟机。在手机上一边后台刷活动一边做其他事的时候用。

Q：在云手机上没反应？
A：请加群反馈。

Q：正常运行一段时间后突然没反应？
A：确认左下角图标有绿边（表示脚本还在运行），按音量加停止脚本，再运行一次脚本，如果能在相似情况下出现问题，请加群反馈，如果每次出现情况不同，可能是无障碍掉了，解决方法一是保证充足内存防止系统杀掉脚本，二是通过vmos使用或更换模拟器。

Q：正常运行一段时间后突然出现“停止运行”？
A：一般是被系统杀了。保证内存充足，调整系统设置，更换系统等。

Q：直接弹出“停止运行”？
A：一般是安卓版本低于7导致的。请看“模拟器没反应”问题答案。

Q：完成后能不能不弹出日志？
A：暂时不行，属于脚本框架问题。

Q：能不能不震动？
A：软件右上角设置里关掉震动。

Q：弹出日志关不掉？
A：先看左下角图标有无绿边，有绿边先按音量加停止脚本，再向左拖拽日志窗口标题栏，窗口右上角有关闭按钮。

Q：手指点屏幕没反应？
A：脚本运行中极难点击，先按音量加停止脚本。

Q：账号被抢登会怎么样？
A：当前任务会跳过，下个任务会重新登陆再执行。

Q：脚本什么原理？
A：脚本通过无障碍录屏方式获取屏幕，判断状态，执行相应的操作，即所谓的图色脚本。

Q：短信联系人拨号权限？
A：框架限制，不放心可以通过vmos使用或用虚拟机。框架为脚本提供发短信、拨号功能，因此会申请所需权限，即使脚本不使用这些功能。

Q：报毒？
A：框架限制，无法安装或不放心可以通过vmos使用或用虚拟机。

Q：脚本需要游戏在什么界面时启动？
A：任意，但不支持线索传递界面。

Q：登陆出现滑动验证码？
A：一个账号在短时间内多次登陆时会出现。正常8小时间隔挂机不会出现。
]])

  newRow(layout)
  addTextView(layout, [[
更新：
2022-01-09 改善换班漏人。
2022-01-05 修复作战导航。
2022-01-05 完善帮助页面。
2022-01-04 修复3200x1400面板不识别。
2022-01-04 修复party结束后任务跳过。
2022-01-04 改善第一次作战滑动错位。
2022-01-04 修复签到活动最后一个漏选。
2022-01-04 改善慢机上宿舍换人漏选。
2021-12-31 改善party结束后处理。
2021-12-28 调高公招ocr超时。
2021-12-28 改善总览换班漏换问题。
2021-12-27 修复剿灭后停止问题。
2021-12-27 修复总览换班时乱序与漏换问题。
2021-12-26 新增限时活动处理，支持干员/皮肤。
2021-12-26 修复代理中启动时一直按设置导致1倍速问题。
2021-12-26 新增公招稀有标签弹窗处理，优选资深避免弹窗。
2021-12-26 修复信用购买点商品太快导致界面弹不出。
2021-12-21 公招出现未知标签则认为无效，保证高星标签不漏判。
2021-12-19 修复1600x900运行问题。
2021-12-15 规避线索搜集结尾等待。规避任务收集结尾等待。规避公告/签到结尾等待。修正作战右滑高度。
2021-12-14 修正root权限检测，支持无障碍关闭游戏。允许DPI<320，雷电模拟器平板模式测试未发现问题。修复多次传递线索。修复密码输入错误与截屏权限未开导致的定时任务失败。
]])

  ui.show(layout, false)
end

show_extra_ui = function()
  local layout = "extra"
  ui.newLayout(layout, ui_page_width, -2)
  ui.setTitleText(layout, "其他功能")

  newRow(layout)
  addTextView(layout, [[将沿用脚本主页服务器设置]])

  newRow(layout)
  ui.addButton(layout, layout .. "_invest" .. release_date, "战略前瞻投资")
  ui.setOnClick(layout .. "_invest" .. release_date,
                make_jump_ui_command(layout, nil,
                                     "extra_mode='前瞻投资';lock:remove(main_ui_lock)"))

  ui.addCheckBox(layout, "skip_hard", "不打驯兽", true)
  addTextView(layout, [[选第]])
  ui.addEditText(layout, "best_operator", [[1]])
  addTextView(layout, [[个近卫]])

  newRow(layout)
  addTextView(layout, [[打不过就重开，卡了请等30秒]])

  -- ui.(layout, layout .. "_invest", "集成战略前瞻性投资")
  -- ui.setOnClick(layout .. "_invest", make_jump_ui_command(layout, nil,
  --                                                         "extra_mode='前瞻投资';lock:remove(main_ui_lock)"))

  newRow(layout)
  ui.addButton(layout, layout .. "_speedrun", "每日任务速通（别用）")
  ui.setOnClick(layout .. "_speedrun", make_jump_ui_command(layout, nil,
                                                            "extra_mode='每日任务速通';lock:remove(main_ui_lock)"))

  newRow(layout)
  ui.addButton(layout, layout .. "_1-12", "克洛丝单人1-12（没写）")
  ui.setOnClick(layout .. "_1-12", make_jump_ui_command(layout, nil,
                                                        "extra_mode='克洛丝单人1-12';lock:remove(main_ui_lock)"))

  newRow(layout)
  ui.addButton(layout, layout .. "_stop", "返回")
  ui.setBackground(layout .. "_stop", ui_cancel_color)
  ui.setOnClick(layout .. "_stop", make_jump_ui_command(layout, "main"))

  ui.loadProfile(getUIConfigPath(layout))
  ui.show(layout, false)
end

jump_qqgroup = function()
  local qq = "1009619697"
  local key = "KlYYiyXj2VRJg1qNqRo3tExo959SrKhT"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3D" ..
      key,
  }
  runIntent(intent)
  putClipboard(qq)
  toast("群号已复制：" .. qq)
  peaceExit()
end
jump_qq = function()
  local qq = "605597237"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "mqqwpa://im/chat?chat_type=wpa&uin=" .. qq,
  }
  runIntent(intent)
  putClipboard(qq)
  toast("QQ号已复制：" .. qq)
  peaceExit()
end
jump_bilibili = function()
  local bv = "BV1DL411t7n2"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "https://bilibili.com/video/" .. bv,
  }
  runIntent(intent)
  peaceExit()
end
jump_github = function()
  local github = "tkkcc/arknights"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "https://github.com/" .. github,
  }
  runIntent(intent)
  peaceExit()
end
openLog = function()
  local log_file = "file://" .. getSdPath() .. '/' .. getPackageName() ..
                     '/log/log.txt'
  log_file = '/sdcard/Download/icon.png'
  log(log_file)
  if fileExist(log_file) then log(1) end
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "content://" .. log_file,
    -- type= 'image/*'
  }
  log(intent)
  runIntent(intent)
  log(1849)
  ssleep(3)
  peaceExit()
end
show_gesture_capture_ui = function()
  local layout = "gesture_capture"
  ui.newLayout(layout, ui_page_width, -2)
  ui.setTitleText(layout, (root_mode and '亮屏解锁' or
                    " 当前无root权限，无法使用"))

  newRow(layout)
  addTextView(layout,
              [[录入解锁手势或密码，以便熄屏下自动解锁]])

  newRow(layout)
  addTextView(layout,
              "1. 点击 开始录制，将观察到 熄屏+亮屏+上滑 现象")
  newRow(layout)
  addTextView(layout, "2. 手势或密码界面 出现后，手动解锁")
  newRow(layout)
  addTextView(layout,
              "3. 亮屏解锁界面 出现后，点击任意文字区域")
  newRow(layout)
  addTextView(layout, "4. 选择解锁方式")
  ui.addRadioGroup(layout, "unlock_mode", {"手势", "密码"}, 0, -2, -2, true)
  newRow(layout)
  addTextView(layout,
              [[5. 快速测试：启动脚本后，手动熄屏，5秒内应观察到亮屏解锁现象。]])
  newRow(layout)
  addTextView(layout, "当前手势：")
  ui.addTextView(layout, "unlock_gesture", JsonEncode({}))

  newRow(layout, layout .. "_save_row", "center")

  ui.addButton(layout, layout .. "_stop", "返回")
  ui.setBackground(layout .. "_stop", ui_cancel_color)
  ui.setOnClick(layout .. "_stop", make_jump_ui_command(layout, "main"))
  ui.addButton(layout, layout .. "_start", "开始录制", ui_small_submit_width)
  ui.setBackground(layout .. "_start", ui_submit_color)
  ui.setOnClick(layout .. "_start", "gesture_capture()")

  ui.loadProfile(getUIConfigPath(layout))
  ui.show(layout, false)
end

gesture_capture = function()
  local finger = {}
  screenoff()
  disappear("gesture_capture_ui", 5)
  screenon()
  local state
  if not wait(function()
    state = appear({
      "gesture_capture_ui", "keyguard_indication", "keyguard_input",
    }, 5)
    if not state then
      stop("未找到解锁界面")
    elseif state == "gesture_capture_ui" then
      ui.setText("unlock_gesture", JsonEncode({}))
      return true
    elseif state == "keyguard_indication" then
      screenLockSwipUp()
    elseif state == "keyguard_input" then
      return true
    end
  end, 30) then stop("手势录制2010") end

  if state == title then return end
  log(200)

  if not wait(function()
    local p = catchClick()
    if findOne("gesture_capture_ui") then return true end
    if p then
      table.insert(finger, {p.x, p.y})
      ui.setText("unlock_gesture", JsonEncode(finger))
    end
  end, 30) then stop("手势录制超时") end
end
gesture_capture = disable_game_up_check_wrapper(gesture_capture)

show_crontab_ui = function()
  local layout = "crontab"
  ui.newLayout(layout, ui_page_width, -2)
  ui.setTitleText(layout, "定时执行")
  newRow(layout)
  ui.addCheckBox(layout, layout .. "_option", "定时执行总开关", true)
  local max_checkbox_one_row = 4
  local default_hour = {8, 16, 24}
  for i = 1, 24 do
    if i % max_checkbox_one_row == 1 then
      newRow(layout, layout .. "_row" .. i, "center")
    end
    ui.addCheckBox(layout, layout .. i, tostring(i):padStart(2, '0') .. "点",
                   table.includes(default_hour, i))
  end
  newRow(layout, layout .. "_stop_row", "center")
  ui.addButton(layout, layout .. "_stop", "返回", ui_submit_width)
  ui.setBackground(layout .. "_stop", ui_submit_color)
  ui.setOnClick(layout .. "_stop", make_jump_ui_command(layout, "main"))

  ui.loadProfile(getUIConfigPath(layout))
  ui.show(layout, false)
end

assignGlobalVariable = function(t)
  for k, v in pairs(t) do
    if string.find(k, "dual") then log(k, v, type(v)) end
    if _G[k] then log("_G[k] exist", k, v) end
    _G[k] = v
  end
end
getUIConfigPath = function(layout)
  return getWorkPath() .. '/config_' .. layout .. '.json'
end
loadUIConfig = function()
  for _, layout in pairs({"main", "multi_account", "gesture_capture", "extra"}) do
    local config = getUIConfigPath(layout)
    if fileExist(config) then
      log("load", config)
      io.input(config)
      assignGlobalVariable(JsonDecode(io.read() or '{}'))
    end
  end
end

all_apps = getInstalledApk()
isAppInstalled = function(package) return table.includes(all_apps, package) end

randomString = function(length)
  length = length or 8
  local res = ""
  for i = 1, length do res = res .. string.char(math.random(97, 122)) end
  return res
end
gesture = function(fingers)
  if #fingers == 0 then fingers = {fingers} end
  local gesture = Gesture:new() -- 创建一个手势滑动对象
  for _, finger in pairs(fingers) do
    local path = Path:new()
    for _, point in pairs(finger.point) do path:addPoint(point[1], point[2]) end
    path:setDurTime(finger.duration or 1000)
    path:setStartTime(finger.start or 0)
    gesture:addPath(path)
  end
  gesture:dispatch()
end
compareColor = function(x, y, color, sim)
  -- color = color:sub(6,7)..color:sub(4,5)..color:sub(2,3)
  -- log(x,y,color,sim)
  -- exit()
  return cmpColor(x, y, color:sub(2), sim) == 1
end

scale = function(x, mode)
  if not mode or mode == 'min' then
    return math.round(x * minscale)
  elseif mode == 'max' then
    return math.round(x * maxscale)
  end
end

input = function(selector, text)
  if type(text) ~= 'string' then return end
  local node = findOne(selector)
  if not node then return end
  nodeLib.setText(node, text)
end

enable_accessibility_service = function()
  if isAccessibilityServiceRun() then return end
  if root_mode then
    local package = getPackageName()
    local service = package .. "/com.nx.assist.AssistService"
    local services = exec(
                       "su -c 'settings get secure enabled_accessibility_services'")
    services = table.filter(services:trim():split(':'),
                            function(x) return x ~= 'null' end)
    local other_services = table.join(table.filter(services, function(x)
      return x ~= service
    end), ':')
    -- log(2042, services)
    -- if table.includes(services, service) then
    -- 即 “无障碍故障情况”, 需要先停
    -- exec("su -c 'settings put secure enabled_accessibility_services " ..
    --        (#other_services > 0 and other_services or '""') .. "'")
    -- log(2037, other_services, service)
    -- wait(function()
    --   local current = exec(
    --                     "su -c 'settings get secure enabled_accessibility_services'")
    --   return not current:find(service)
    -- end)
    -- local current = exec(
    --                   "su -c 'settings get secure enabled_accessibility_services'")
    -- log(current)

    -- log("su -c 'settings put secure enabled_accessibility_services " ..
    --       other_services .. (#other_services > 0 and ':' or '') .. service ..
    --       "'")
    -- log("su -c 'settings put secure enabled_accessibility_services " ..
    --       (#other_services > 0 and other_services or '""') .. "'")

    -- 秘诀：先开再关再开
    exec("su -c 'settings put secure enabled_accessibility_services " ..
           other_services .. (#other_services > 0 and ':' or '') .. service ..
           "'")
    exec("su -c 'settings put secure enabled_accessibility_services " ..
           (#other_services > 0 and other_services or '""') .. "'")
    exec("su -c 'settings put secure enabled_accessibility_services " ..
           other_services .. (#other_services > 0 and ':' or '') .. service ..
           "'")
    if wait(function() return isAccessibilityServiceRun() end) then return end
  end
  openPermissionSetting()
  toast("请开启无障碍权限")
  if not wait(function() return isAccessibilityServiceRun() end, 600) then
    stop("开启无障碍权限超时")
  end
  toast("已开启无障碍权限")
end

enable_snapshot_service = function()
  if skip_snapshot_service_check then return end
  if isSnapshotServiceRun() then return end
  if root_mode then
    local package = getPackageName()
    -- TODO need this?
    -- exec("su -c 'appops set " .. package .. " PROJECT_MEDIA allow'")
    -- exec("su -c 'appops set " .. package .. " SYSTEM_ALERT_WINDOW allow'")
    if isSnapshotServiceRun() then return end
  end

  if loadConfig("hideUIOnce", "false") ~= "false" then
    log(2237)
    log("定时模式启动，不敢弹录屏")
  end

  openPermissionSetting()
  toast("请开启录屏权限")
  if not wait(function() return isSnapshotServiceRun() end, 600) then
    stop("开启录屏权限超时")
  end
end

test_fight_hook = function()
  if not test_fight then return end
  fight = {
    -- "1-7", "1-7", "CE-5", "LS-5",

    -- "9-2", "9-3", "9-4", "9-5", "9-6", "9-7", "9-9", "9-10", "9-11", "9-12",
    -- "9-13", "S9-1", "9-14", "9-15", "9-16", "9-17", "9-18", "9-19",

    -- "0-8", "1-7", "S2-7", "3-7", "S4-10", "S5-3", "6-9", "7-15", "R8-2",
    --
    -- "JT8-2", "R8-2", "M8-8",
    -- "CA-5", "CE-5", 'AP-5', 'SK-5', 'LS-5', "PR-D-2", "PR-C-2", "PR-B-2",
    "PR-A-2", "龙门外环", "龙门市区", -- "1-7", "1-12", "2-3", "2-4",
    -- "2-9", "S2-7", "3-7", "S4-10", "S5-3", "6-9", "7-6", "7-15", "S7-2",
    -- "JT8-2", "R8-2", "M8-8",
    "PR-A-2", "PR-B-1", "PR-B-2", "PR-C-1", "PR-C-2", "PR-D-1", "PR-D-2",
    "CE-1", "CE-2", "CE-3", "CE-4", "CE-5", "CA-1", "CA-2", "CA-3", "CA-4",
    "CA-5", "AP-1", "AP-2", "AP-3", "AP-4", "AP-5", "LS-1", "LS-2", "LS-3",
    "LS-4", "LS-5", "SK-1", "SK-2", "SK-3", "SK-4", "SK-5", "0-1", "0-2", "0-3",
    "0-8", "1-9", "2-9", "S3-7", "4-10", "5-9", "6-10", "7-14", "R8-2",
    "积水潮窟", "切尔诺伯格", "龙门外环", "龙门市区",
    "废弃矿区", "大骑士领郊外", "北原冰封废城", "PR-A-1", "0-4",
    "0-5", "0-6", "0-7", "0-8", "0-9", "0-10", "0-11", "1-1", "1-3", "1-4",
    "1-5", "1-6", "1-7", "1-8", "1-9", "1-10", "1-11", "1-12", "2-1", "2-2",
    "2-3", "2-4", "2-5", "2-6", "2-7", "2-8", "2-9", "2-10", "S2-1", "S2-2",
    "S2-3", "S2-4", "S2-5", "S2-6", "S2-7", "S2-8", "S2-9", "S2-10", "S2-12",
    "3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7", "3-8", "S3-1", "S3-2",
    "S3-3", "S3-4", "S3-5", "S3-6", "S3-7", "4-1", "4-2", "4-3", "4-4", "4-5",
    "4-6", "4-7", "4-8", "4-9", "4-10", "S4-1", "S4-2", "S4-3", "S4-4", "S4-5",
    "S4-6", "S4-7", "S4-8", "S4-9", "S4-10", "5-1", "5-2", "S5-1", "S5-2",
    "5-3", "5-4", "5-5", "5-6", "S5-3", "S5-4", "5-7", "5-8", "5-9", "S5-5",
    "S5-6", "S5-7", "S5-8", "S5-9", "5-10", "6-1", "6-2", "6-3", "6-4", "6-5",
    "6-7", "6-8", "6-9", "6-10", "S6-1", "S6-2", "6-11", "6-12", "6-14", "6-15",
    "S6-3", "S6-4", "6-16", "7-2", "7-3", "7-4", "7-5", "7-6", "7-8", "7-9",
    "7-10", "7-11", "7-12", "7-13", "7-14", "7-15", "7-16", "S7-1", "S7-2",
    "7-17", "7-18", "R8-1", "R8-2", "R8-3", "R8-4", "R8-5", "R8-6", "R8-7",
    "R8-8", "R8-9", "R8-10", "R8-11", "JT8-2", "JT8-3", "M8-6", "M8-7", "M8-8",
  }
  fight = table.filter(fight, function(v) return point['作战列表' .. v] end)
  log(fight)
  repeat_fight_mode = false
  run("轮次作战")
  exit()
end

predebug_hook = function()
  if not predebug then return end
  ssleep(1)
  log(findOne("指挥分队"))
  exit()


  -- swip
  -- swipzl('left')
  -- swipzl('right')
  -- exit()

  fight1 = {text = '与虫为伴'}
  fight1 = {text = '礼炮小队'}
  deploy3(1, fight1.text, table.includes({"礼炮小队", "驯兽小屋"},
                                         fight1.text) and 2 or 4)
  -- log(findOne("确认招募"))
  -- log(findOne("偏执的"))
  -- local fight1ocr = ocr("第一层作战1")
  -- local fight1ocr = ocr("第一层作战2")
  local fight1ocr = ocr("第一层不期而遇2")
  -- local fight1ocr = ocr("第一层不期而遇1")
  log(fight1ocr)
  exit()
  -- log(findOne("诡意行商投资"))
  if not appear("诡意行商投资", 5) then return end
  if not wait(function()
    if findOne("诡意行商投币") then return true end
    tap("诡意行商投资")
  end) then return end
  if not wait(function()
    if findOne("诡意行商投资入口") then return true end
    tap("诡意行商投币")
  end) then return end
  if not wait(function()
    if not findOne("诡意行商投资入口") then return true end
    tap("诡意行商确认投资")
  end, 30) then return end
  -- if not appear("诡意行商投资", 5) then return end
  -- tap("战略确认")
  exit()

  if not wait(function()
    if not findOne("诡意行商投资入口") then return true end
    tap("诡意行商确认投资")
  end, 30) then return end
  exit()

  if not wait(function()
    if not findOne("常规行动") then return true end
    -- tap("继续探索")
  end, 5) then stop(122) end
  exit()
  tap("收取所有邮件")
  -- tap("邮件收取")
  log(point.面板)
  log(findOne("面板"))
  -- log(findOne("返回确认界面"))
  -- log(findOne("活动签到返回"))
  -- log(findOne("线索传递"))
  -- log(findOne("本次线索交流活动"))
  -- log(findOne("返回"))
  -- log(findOne(""))
  ssleep(10)

  -- local swipd = function()
  --   local flipd = 150
  --   local flips = 50
  --   local duration = flipd + flips + 200
  --   local x1 = screen.width - scale(720 - 500)
  --   local x2 = x1 - scale(100)
  --   local y1 = scale(150)
  --   local y2 = screen.height - scale(150)
  --   local paths = {
  --     {point = {{x1, y1}, {0, y1}}, duration = duration},
  --     {point = {{x1, y2}, {x2, y2}}, duration = flipd, start = flips},
  --   }
  --   gesture(paths)
  --   sleep(duration+50)
  -- end
  -- log(point["公开招募箭头"])
  -- log(findOne("公开招募"))
  -- log(findOne("公开招募箭头"))
  -- tap({796,503})

  -- log(point["今日参与交流已达上限"])
  -- log(point["返回确认"])
  -- log(point["是否确认离开基建"])
  -- log(point["是否返回好友列表"])
  -- log(point["是否退出游戏"])

  -- log(point["今日参与交流已达上限"])
  -- log(point["信用交易所横线"])
  -- log(findOne("返回确认界面"))
  -- log(findOne("是否确认离开基建"))
  -- log(findOne("是否返回好友列表"))
  -- log(findOne("是否退出游戏"))

  -- testManufacturingStationOperatorBest()
  exit()

  log(findOne("返回"))
  -- log(findOne("活动公告返回"))
  -- log(findOne("返回3"))
  -- log(findOne("返回4"))
  -- while true do if findOne("活动公告返回") then stop(2229) end end
  -- log(table.combination(range(1, 10), 3))
  -- log(ans)
  exit()
  log(ans)
  ssleep(1)
  while true do if not appear("怒号光明", 0.5) then stop(1) end end
  exit()
  input("bilibili_username_inputbox", '11111111111')
  -- log(findOne('inputbox'))
  -- log(#findOne('inputbox').text)
  exit()

  keepCapture()
  -- skillimg = {}
  -- skillpng = {"Bskill_ws_evolve3.png"}
  local mask = {}
  w, h = 36, 36
  for i = 1, h do
    for j = 1, w do
      if ((i - 18.5) ^ 2 + (j - 18.5) ^ 2) < 18.5 ^ 2 then
        table.insert(mask, {i, j})
      end
    end
  end
  pngdata = {}
  local s = ''
  for _, v in pairs(skillpng) do
    local _, _, color = getImage('/sdcard/png_noalpha_dim/' .. v)
    pngdata[v] = {}
    for _, m in pairs(mask) do
      i, j = m[1], m[2]
      b, g, r = colorToRGB(color[(w - i - 1) * w + j])
      table.extend(pngdata[v], {r, g, b})
      if nil and v == 'Bskill_man_exp2.png' then
        -- if v == 'Bskill_ws_evolve2.png' then
        r = string.format('%X', r):padStart(2, '0')
        g = string.format('%X', g):padStart(2, '0')
        b = string.format('%X', b):padStart(2, '0')
        s = s .. i .. '|' .. j .. '|' .. r .. g .. b .. ','
      end
    end
  end
  -- log("1s:sub(1,#s)", s:sub(1, #s))

  gg = function(x1, y1, x2, y2)
    s = ''
    local w, h, color = getScreenPixel(x1, y1, x2, y2)
    local i, j, b, g, r
    local data = {}
    for _, m in pairs(mask) do
      i, j = m[1], m[2]
      b, g, r = colorToRGB(color[(i - 1) * w + j])
      table.extend(data, {r, g, b})

      if nil then
        r = string.format('%X', r):padStart(2, '0')
        g = string.format('%X', g):padStart(2, '0')
        b = string.format('%X', b):padStart(2, '0')
        s = s .. i .. '|' .. j .. '|' .. r .. g .. b .. ','
      end
    end
    -- log(s)
    -- exit()
    local best_score = 100000
    local best = nil
    local score
    local abs = math.abs
    for k, v in pairs(pngdata) do
      score = 0
      for i = 1, #mask * 3 do
        score = score + abs(data[i] - v[i])
        if score > best_score then break end
      end
      if best_score > score then
        best_score = score
        best = k
      end
    end
    log(2208, best_score, best)
    return best
  end

  discover()
  exit()
  pic = table.join(skillpng, "|")
  ret, x, y = findPicEx(0, 0, 0, 0, pic, 0.95)
  log(ret, x, y)
  log(getWorkPath())
  exit()
  -- pic='2级.png|Bskill_ctrl_cost.png'
  -- log(pic)
  log(23)
  keepCapture()
  -- for i = 1, 24 do ret, x, y = findPicEx(709, 263, 709 + w+1, 263 + h+1, pic, 0.95) end
  -- for i = 1, 24 do ret, x, y = findPic(709, 263, 709 + w+1, 263 + h+1, pic) end
  for i = 1, 24 do ret, x, y = findPic(0, 0, 0, 0, pic) end
  -- for i = 1, 24 do ret, x, y = findPic(709, 263, 709 + w+1, 263 + h+1, pic) end
  -- for i = 1, 24 do ret, x, y = findPicEx(0,0,0,0, pic, 0.95) end
  -- for i = 1, 24 do ret, x, y = findImage(709, 263, 709 + w, 263 + h, pic, 0.95) end
  -- for i = 1, 24 do ret, x, y = findImage(0,0,0,0, pic, 0.95) end
  releaseCapture()
  log(24)

  log(ret, x, y)
  -- ret = findPicAllPoint(0,0,screen.width-1,screen.height-1,'Bskill_ctrl_cost.png',0.1)
  -- log(ret)
  -- ret,x,y = findImage(0,0,0,0,'Bskill_ctrl_cost.png',"000000",0.7)
  -- log(ret,x,y)
  -- ret,x,y = findPicEx(0,0,0,0,'Bskill_ctrl_cost.png',0.7)
  -- log(ret,x,y)
  exit()
  log(point["第一干员未选中"])
  log(findOne("第一干员未选中"))
  ssleep(1)
  exit()
  -- openLog()

  clickPoint(0, 0)
  clickPoint(1, 1)
  clickPoint(20, scale(123))
  exit()

  require("skill")
  log(time())
  log(#skill)
  local border_height = math.round(
                          (379 - 1080 // 2) * minscale + screen.height / 2)
  local skill_height1 = math.round(
                          (397 - 1080 // 2) * minscale + screen.height / 2)
  local skill_height2 = math.round(
                          (817 - 1080 // 2) * minscale + screen.height / 2)
  local color = {
    math.round(600 * minscale), border_height, screen.width, border_height + 5,
    "663,253,#88888A|663,255,#88888A|665,255,#88888A|661,253,#FFFFFF|661,255,#FFFFFF|659,255,#FFFFFF",
    95,
  }
  log(color)
  local borders = findColors(color)
  if not borders then return end
  -- keepScreen(false)
  -- keepScreen(true)
  for _, border in pairs(borders) do
    log('border', border)
    local skill_top_left = {
      {border.x + math.round(5 * minscale), skill_height1},
      {border.y + math.round(47 * minscale), skill_height1},
    }
    local best_score = 0
    local best_skill = 1
    local valid_score_threshold = 0
    for k, v in pairs(skill) do
      log(81, k)
      local rgb = v[4]
      local alpha = v[5]
      local score = 0
      local predict_score = 0
      for i = 1, 36 * 36 do
        -- log(82, i)
        -- log(83, rgb[i])
        -- log(84, alpha[i])
        score = score +
                  (compareColor(skill_top_left[1][1] + i // 36 + 1,
                                skill_top_left[1][2] + i % 36, rgb[i],
                                95 * alpha[i] // 255) and 1 or 0)
        predict_score = score + 36 * 36 - i
        if predict_score < best_score or predict_score < valid_score_threshold then
          break
        end
      end
      if score > best_score and score > valid_score_threshold then
        best_score = score
        brest_skill = k
      end
      log(v[3], score, skill[best_skill][3])
    end
    log(skill[best_skill][3], best_score)
    exit()
  end
  exit()
end

check_root_mode = function()
  if not disable_root_mode and #exec("su -c 'echo aaa'") > 1 then
    root_mode = true
  end
  log("root_mode", root_mode)
end

update_state_from_ui = function()
  prefer_skill = true
  drug_times = 0
  max_drug_times = tonumber(max_drug_times)
  stone_times = 0
  max_stone_times = tonumber(max_stone_times)
  appid = server == 0 and oppid or bppid
  job = parse_from_ui("now_job_ui", all_job)

  fight = string.filterSplit(fight_ui)
  fight = map(string.upper, fight)

  -- expand LS-5x999
  local expanded_fight = {}
  for _, v in pairs(fight) do
    local cur_fight, times = v:match('(.+)[xX*](%d+)')
    if not cur_fight then
      table.insert(expanded_fight, v)
    else
      for _ = 1, times do table.insert(expanded_fight, cur_fight) end
    end
  end
  fight = expanded_fight
  -- log("expanded_fight", expanded_fight)

  -- LMSQ => 龙门市区
  for k, v in pairs(fight) do
    if table.includes(table.keys(jianpin2name), v) then
      fight[k] = jianpin2name[v]
    end
    if table.includes(table.keys(extrajianpin2name), v) then
      fight[k] = extrajianpin2name[v]
    end
  end
  fight = table.filter(fight, function(v) return point['作战列表' .. v] end)

  all_open_time_start = parse_time("202111221600")
  all_open_time_end = parse_time("202112060400")
  update_open_time()

  crisis_contract_start = parse_time("202111301600")
  crisis_contract_end = parse_time("202112060400")
  local current = parse_time()
  if crisis_contract_start < current and current < crisis_contract_end then
    during_crisis_contract = true
  else
    during_crisis_contract = false
  end

  startup_time = parse_time()
  facility2operator = {}
  facility2nexthour = {}

  for _, v in pairs(string.split(dorm, '\n')) do
    v = string.split(v)
    if #v > 3 then
      local facility = v[1]
      if #facility == 3 then facility = facility .. 1 end
      local hour = tonumber(v[2])
      local operator = table.slice(v, 3)
      local cur_hour = facility2nexthour[facility]
      if coming_hour(cur_hour, hour, startup_time) == hour then
        facility2operator[facility] = operator
        facility2nexthour[facility] = hour
      end
    end
  end
  log(facility2nexthour)
  log(facility2operator)
end

apply_multi_account_setting = function(i, visited)
  visited = visited or {}
  table.insert(visited, i)
  if _G["multi_account_inherit_toggle" .. i] == "切换为独立设置" then
    local inherit = _G["multi_account_inherit_spinner" .. i]
    local j = math.floor(inherit)
    if inherit == 0 or table.includes(visited, j) then
      transfer_global_variable("multi_account_user0")
    else
      apply_multi_account_setting(j, visited)
    end
  else
    transfer_global_variable("multi_account_user" .. i)
  end
end

-- 定时执行逻辑：如果到点但脚本还在run则跳过，因为run中重启可能出现异常
check_crontab = function()
  if not crontab_enable then return end
  local config = string.filterSplit(crontab_text, {"：", ":"})
  local candidate = {}
  if #config == 0 then return end
  for _, v in pairs(config) do
    local hour_second = v:split(':')
    local hour = math.round(tonumber(hour_second[1] or 0) or 0)
    local min = math.round(tonumber(hour_second[2] or 0) or 0)
    table.insert(candidate,
                 os.time(update(os.date("*t"), {hour = hour, min = min})))
    table.insert(candidate,
                 os.time(update(os.date("*t"), {hour = hour + 24, min = min})))
  end
  table.sort(candidate)
  local next_time = table.findv(candidate, function(x) return x > os.time() end)
  toast("下次执行时间：" .. os.date("%H:%M", next_time))
  while true do
    if os.time() >= next_time then break end
    ssleep(1)
    -- ssleep(clamp(next_time - os.time(), 0, 1000))
  end
  saveConfig("hideUIOnce", "true")
  restartScript()
end

setEventCallback = function()
  setStopCallBack(function()
    if need_show_console then
      console.show()
    else
      console.dismiss()
    end
  end)
  -- TODO how to use
  setUserEventCallBack(function(type) stop(type) end)
end
consoleInit = function()
  console.clearLog()
  console.setPos(round(screen.height * 0.05), round(screen.height * 0.05),
                 round(screen.height * 0.9), round(screen.height * 0.9))
  console.setTitle("日志")
  console.show()
  console.dismiss()
end

detectServer = function()
  appid = oppid
  if prefer_bapp then appid = bppid end
  if prefer_bapp_on_android7 and android_verison_code < 30 then appid = bppid end
  local app_info = isAppInstalled(appid)
  local bpp_info = isAppInstalled(bppid)
  if not app_info and not bpp_info then
    stop("未安装明日方舟官服或B服")
  end
  if bpp_info and not app_info then appid = bppid end
  if bpp_info and app_info then appid_need_user_select = true end
  server = appid == oppid and 0 or 1
end

showUI = function()
  if loadConfig("hideUIOnce", "false") ~= "false" then
    saveConfig("hideUIOnce", "false")
  else
    main_ui_lock = lock:add()
    show_main_ui()
    if not wait(function() return not lock:exist(main_ui_lock) end, 600) then
      peaceExit()
    end
  end
end

setControlBar = function()
  -- 用0,1时，会缩进去半个图标，圆角手机不好点
  local screen = getScreen()
  setControlBarPosNew(0, 1)
end

extra_mode_hook = function()
  if extra_mode then
    run(extra_mode)
    exit()
  end
end

ocr = function(r)
  r = point[r]
  log("ocrinput", r)
  r = ocrEx(r[1], r[2], r[3], r[4]) or {}
  log("ocrresult", r)
  return r

end

-- 集成战略
swipzl = function(mode)
  local duration = 300
  local delay = 150 -- 后面直接ocr或点击了，给点时间吧
  local x1 = scale(300)
  local x2 = scale(1555)
  local y = scale(1080 // 2)
  local finger
  if mode == 'right' then
    finger = {
      {point = {{x1, y}, {x1 + 100000, y}}, start = 0, duration = duration}, {
        point = {{x1, y}, {x1 + 100000, y}},
        start = duration + delay,
        duration = duration,
      },
    }
    duration = duration + delay + duration
  else
    finger = {
      {point = {{x2, y}, {0, y}}, start = 0, duration = duration},
      {point = {{x2, y}, {0, y}}, start = duration + delay, duration = duration},
    }
    duration = duration + delay + duration
    delay = 500
  end
  log(2849, finger)
  gesture(finger)
  sleep(duration + delay)
end

-- src: 从右数第几个干员
-- dst: 目标位置，格式{A-G}{1-10} 参考https://map.ark-nights.com/map/ro1_n_1_4
-- total: 当前有几个干员，不同干员数影响干员位置
deploy3 = function(src, dst, direction, total)
  total = total or 1
  local max_op_width = scale(178) --  in loose mode, each operator's width
  local x1
  if total * max_op_width > screen.width then
    -- tight
    max_op_width = screen.width // total
    x1 = src * max_op_width - max_op_width // 2
  else
    -- loose
    x1 = screen.width - (total - src) * max_op_width - max_op_width // 2
  end

  dst = point["部署位" .. dst]
  deploy(x1, dst[1], dst[2], direction)
end
