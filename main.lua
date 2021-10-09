-- debug option, should be commented in release
-- predebug = true
-- pcall(exec,
--       "settings put secure enabled_accessibility_services com.aojoy.aplug/com.aojoy.server.CmdAccessibilityService")
-- exec("settings put secure enabled_accessibility_services com.bilabila.arknightsspeedrun/com.aojoy.server.CmdAccessibilityService")
-- during_crisis_contract =true
-- disable_communication_check=true
-- speedrun=true
-- debug = true
-- disable_log = true
-- unsafe_tap = true
zero_wait_click = true
check_after_tap = true
-- enable_dorm_check = true
-- fake_transfer= true
-- verbose_fca = true
-- no_dorm = true
-- test_some = true
-- ok_time = 1
-- ignore_jmfight_enough_check=true
-- test_fight = true
-- fake_fight = true
no_config_cache = true
-- prefer_bapp = true
-- prefer_bapp_on_android7 = true
-- debug0721 = true
-- no_background_after_run = true
-- longest_tag = true
-- very_slow_state_check = true

default_findcolor_confidence = 95
default_max_drug_times = 9999
default_max_fight_times = 9999
default_max_stone_times = 0

screen = getScreen()
if screen.width < screen.height then
  screen.width, screen.height = screen.height, screen.width
end

require("util")
require("point")
require("path")
require("tag")
log(time() .. " 分辨率：" .. screen.width .. "x" .. screen.height)

-- auto switch 官服 and B服
appid_need_user_select = false
appid = "com.hypergryph.arknights"
bppid = "com.hypergryph.arknights.bilibili"
if prefer_bapp then appid = bppid end
if prefer_bapp_on_android7 and android_verison_code < 30 then appid = bppid end
local app_info = getAppinfo(appid)
local bpp_info = getAppinfo(bppid)
if not app_info and not bpp_info then stop("未安装明日方舟官服或B服") end
if bpp_info and not app_info then appid = bppid end
if bpp_info and app_info then appid_need_user_select = true end

if predebug then
  fake_fight = true
  fight = {"1-7", "4-4"}
  path.轮次作战()
  exit()
  -- swipo()
  -- exit()
  -- findtap_operator_type("赤金站")
  -- exit()
  path.线索传递()
  -- path.制造换班()
  exit()

  local feature

  -- 1080p feature
  经验加速 = {
    '#261500-50',
    '[{"a":0.129,"d":1.622,"id":"1","r":529.0,"s":"34|5<fOm>&5~9zPN&5~amm]&5>Yg}@&5]8m]^&5X[L$H&5X[L$H&5X[L$X&5>xRmv&5<quBx&5>GERF&5>GERE&5X[L$Y&5X[Npu&5X[Npu&5Y6o!c&5>YhCE&5~a15*&5~9z^6&5~9z^6&2~zjVe"}]',
    0.85,
  }
  赤金加速 = {
    '#202020-50',
    '[{"a":-0.044,"d":1.807,"id":"1","r":358.0,"s":"22|py&PS&PS&PS&H6!&18dN&18dN&18dM&18dM&2OY&2OY&2LC&2LC&2gre&4wSA&8{v2&8{v2&4wSs&aL6&ax~&ax~&lgc&k]*&k]*&lGs&H6!&H6!&H6!&18dM&H6Y"}]',
    0.85,
  }

  feature = 经验加速

  -- 720p feature
  -- feature = {'#16161E-50','[{"a":0.128,"d":1.582,"id":"1","r":217.0,"s":"22|8uPW&8RKD&8SH^&7!GH&7!GD&7!GH&8Nd(&8Nd(&7!GI&7!GA&7!JW&8SMU&8{4Q&8RL~"}]',0.85}
  feature = findShape(feature)
  log(feature)
  log(#feature)
  exit()
  -- log(info)
  local region = {
    {590, 487, 1919, 523}, {1033, 487, 1491, 523}, {1464, 487, 1919, 523},
    {590, 907, 1059, 943}, {1033, 907, 1491, 943}, {1464, 907, 1919, 943},
  }
  local r = region[1]
  r = {590, 907, 1059, 943}
  r[3] = screen.width - 1
  text, info = ocr(table.unpack(r))
  log(text)
  -- log(info)
  local res = ocrp({rect = r})
  log(map(function(x) return x.text end, res))
  exit()
  log(findOne("开始行动"))
  log(findOne("返还规则"))
  log(findOne("报酬合成玉已满"))
  exit()
  path.线索布置()
  exit()
  log(is_screen_on())
  exit()
  log(catchClick())
  exit()
  status, result = pcall(home)
  log(status, result)
  log(findColor({0, 0, 1, 1, "0,0,#000000"}))
  exit()
  -- while true do tap("线索布置5") end
  path.线索布置()
  exit()
  unlock({{529, 2100}, {577, 1410}, {839, 1427}}, true)
  -- tap({467,2248},0,1)
  -- tap({467,1890},0,1)

  gesture({{{x = 529, y = 2154}, {x = 577, y = 1410}, {x = 839, y = 1427}}},
          5000)
  -- gesture({{{x = 529, y = 2100}, {x = 577, y = 1410}, {x = 839, y = 1427}}},
  --         1000)
  -- swip()
  exit()
  -- log(findOne('线索布置按下列表1'))
  -- path.线索布置()
  path.线索传递()

  -- while true do if not findOne("未解锁第9章") then log(375) end end
  -- tap("觉醒")
  -- tap("幻灭")
  exit()
  -- tap("觉醒")
  -- log(findOne("宿舍列表" .. i))

  exit()
  log(958)
  ssleep(1)
  local game = R():name(appid):path("/FrameLayout/View")
  log(find(game))
  game = R():name("com.hypergryph.arknights.bilibili"):path("/FrameLayout")
  log(find(game))
  log(find(R():name("com.hypergryph.arknights.bilibili"):path("/FrameLayout")))
  exit()

  -- swipe("left")
  -- x="9-2"
  -- swip(x)
  -- tap("作战列表" .. x)
  exit()

  -- -- {0,0,0,0,"1059,457,#D2D1D1|1033,455,#FFFFFF|1464,443,#D1CACE|1491,446,#D6D5D5",95}

  -- local r = region[1]
  -- text, info = ocr_fast(math.round(minscale * r[1]),
  --                       math.round(minscale * r[2]),
  --                       math.round(minscale * r[3]), math.round(minscale * r[4]))
  -- log(text, info)
  -- p={}
  -- ocr_text, _ = ocr_fast(table.unpack(p))
  --

  zoom()
  log(findOne("缩放结束"))
  exit()
  -- while true do 
  --   if findOne("资源收集", 90) then log(1) end
  --   if findOne("主题曲", 90) then log(2) end
  --   if findOne("每周部署", 90) then log(3) end
  -- end

  log(findOne("主页按过"))
  -- tapAll({
  --   "干员选择列表6", "干员选择列表7", "干员选择列表8",
  --   "干员选择列表9", "干员选择列表10", "干员选择列表11",
  --   "干员选择列表12",
  -- })
  -- tap("访问下位橘")
  -- tap("访问下位橘")
  -- tap("访问下位橘")
  -- tap("访问下位橘")
  exit()
end

local outside = runThread("outside")

local all_job = {
  "邮件收取", "轮次作战", "访问好友", "基建收获",
  "指定换班", "基建换班", "线索搜集", "制造加速",
  "副手换人", "信用购买", "公招刷新", "任务收集",
  "每日任务速通（慎点）",
}
local now_job = {
  "邮件收取", "轮次作战", "访问好友", "基建收获",
  "线索搜集", "基建换班", "制造加速", "副手换人",
  "信用购买", "公招刷新", "任务收集",
}

local parse_id_to_ui = function(prefix, length)
  local ans = ''
  for i = 1, length do ans = ans .. prefix .. i .. '|' end
  return ans:sub(1, #ans - 1)
end

local parse_value_to_ui = function(all, select)
  local ans = ''
  for _, v in pairs(all) do
    if table.includes(select, v) then ans = ans .. '*' end
    ans = ans .. v .. '|'
  end
  return ans:sub(1, #ans - 1)
end

local parse_from_ui = function(prefix, reference)
  local ans = {}
  for i = 1, #reference do
    if _G[prefix .. i] then table.insert(ans, reference[i]) end
  end
  return ans
end
local ui = {
  title = "明日方舟速通 2021.09.29  0:27",
  cache = not no_config_cache,
  width = -1,
  height = -1,
  time = ok_time or 60,
  views = {
    {title = "账号", type = "edit", id = "username"},
    {title = "密码", type = "edit", id = "password", mode = "password"}, {
      title = "作战",
      type = "edit",
      value = [[当期委托,dqwt,龙门市区，LMSQ
9-19, 4-4, 4-9, 1-7,JT8-3,PR-D-2,PR-D-1,CE-5,LS-5,
上一次,syc]],
      id = "fight",
    }, {title = "换班", type = "edit", value = [[]], id = "dorm"}, {
      title = "设置",
      type = "edit",
      value = [[最大作战次数=]] .. default_max_fight_times .. [[

最大吃药次数=]] .. default_max_drug_times .. [[

最大吃石头次数=]] .. default_max_stone_times,

      id = "lua_setting",
    }, {
      type = "check",
      value = "*保底最高4星时自动招募|*换班技能优先|" ..
        (is_device_swipe_too_fast and "*" or '') ..
        "双指滑动（非真机建议选）|" ..
        (is_device_need_slow_swipe and "*" or '') .. "慢速滑动",
      ore = 1,
      id = "star4_auto|prefer_skill|is_device_swipe_too_fast|is_device_need_slow_swipe",
    }, {
      type = "check",
      ore = 1,
      value = parse_value_to_ui(all_job, now_job),
      id = parse_id_to_ui("now_job_ui", #all_job),
    }, {
      type = "text",
      value = [[
注意：
找不对关卡？试试开关 双指滑动 和 慢速滑动。
刷活动关卡：在接管作战界面运行脚本。
游戏全屏无黑边，基建退出提示必须开，miui游戏模式别开，还是有问题建议用vmos。
]],
    }, -- {
    --   type = 'div',
    --   title = '',
    --   views = {
    --     {
    --       type = "check",
    --       value = "亮屏解锁（需root，开发中别用）",
    --       ore = 1,
    --       id = "need_screen_on",
    --     }, {
    --       type = "text",
    --       value = [[需要手机半夜亮屏执行脚本的可以开，模拟器云手机等常亮设备没必要开。录入亮屏解锁手势或密码：点击下方按钮后脚本将进入亮屏解锁界面，依次点击（注意不是滑动）手势关键点或密码（包括最后的确认键），然后静置5秒，脚本将保存信息并尝试解锁。重启脚本无需重新录入。]],
    --     }, {
    --       type = "button",
    --       value = "录入手势",
    --       title = '',
    --       click = {thread = outside, name = "capture_screen_on_gesture"},
    --     }, {
    --       type = "button",
    --       value = "录入密码",
    --       title = '',
    --       click = {thread = outside, name = "capture_screen_on_password"},
    --     },
    --   },
    -- },     
    {
      type = 'div',
      title = '',
      views = {
        {
          type = "button",
          value = "视频演示",
          title = '',
          click = {thread = outside, name = "goto_bilibili"},
        }, {
          type = "button",
          value = "反馈群",
          title = '',
          click = {thread = outside, name = "goto_qq"},
        }, {
          type = "button",
          value = "源码(好用请star)",
          title = '',
          click = {thread = outside, name = "goto_github"},
        },
      },
    },
  },
  submit = {type = "text", value = "启动"},
  cancle = {type = "text", value = "退出"},
}
-- add server selection to ui
if appid_need_user_select then
  table.insert(ui.views, 1, {
    title = "",
    type = "radio",
    value = "*官服|B服",
    ore = 2,
    id = "server",
  })
end

-- trigger screen recording permission request using one second
findColor({0, 0, 1, 1, "0,0,#000000"})
local miui = R():text("立即开始|start now"):type("Button")
click(miui)

ret = show(ui)
if not ret then exit() end
callThreadFun(outside, "preload")

if server == "B服" then appid = bppid end
log(appid)

now_job = parse_from_ui("now_job_ui", all_job)

fight = string.map(fight, {
  [";"] = " ",
  ["；"] = " ",
  [","] = " ",
  ["_"] = "-",
  ["、"] = " ",
  ["，"] = " ",
  ["|"] = " ",
  ["\n"] = " ",
  ["\t"] = " ",
})
fight = string.split(fight, ' ')
fight = map(string.upper, fight)
for k, v in pairs(fight) do
  if table.includes(table.keys(jianpin2name), v) then
    fight[k] = jianpin2name[v]
  end
  if table.includes(table.keys(extrajianpin2name), v) then
    fight[k] = extrajianpin2name[v]
  end
end
fight = table.filter(fight, function(v) return point['作战列表' .. v] end)

all_open_time_start = parse_time("202108261600")
all_open_time_end = parse_time("202109090400")
update_open_time()

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

if test_fight then

  fight = {
    "1-7", "4-1",

    -- "9-2", "9-3", "9-4", "9-5", "9-6", "9-7", "9-9", "9-10", "9-11", "9-12",
    -- "9-13", "S9-1", "9-14", "9-15", "9-16", "9-17", "9-18", "9-19",

    -- "0-8", "1-7", "S2-7", "3-7", "S4-10", "S5-3", "6-9", "7-15", "R8-2",
    --
    -- "JT8-2", "R8-2", "M8-8",
    -- "CA-5", "CE-5", 'AP-5', 'SK-5', 'LS-5', "PR-D-2", "PR-C-2", "PR-B-2",
    -- "PR-A-2", "龙门外环", "龙门市区", 
    -- "1-7", "1-12", "2-3", "2-4",
    -- "2-9", "S2-7", "3-7", "S4-10", "S5-3", "6-9", "7-6", "7-15", "S7-2",
    -- "JT8-2", "R8-2", "M8-8",

    -- "PR-A-2", "PR-B-1", "PR-B-2", "PR-C-1", "PR-C-2", "PR-D-1", "PR-D-2",
    -- "CE-1", "CE-2", "CE-3", "CE-4", "CE-5", "CA-1", "CA-2", "CA-3", "CA-4",
    -- "CA-5", "AP-1", "AP-2", "AP-3", "AP-4", "AP-5", "LS-1", "LS-2", "LS-3",
    -- "LS-4", "LS-5", "SK-1", "SK-2", "SK-3", "SK-4", "SK-5", "0-1", "0-2", "0-3",
    -- "0-8", "1-9", "2-9", "S3-7", "4-10", "5-9", "6-10", "7-14", "R8-2",
    --
    -- "积水潮窟", "切尔诺伯格", "龙门外环", "龙门市区",
    -- "废弃矿区", "大骑士领郊外", "北原冰封废城", "PR-A-1",
    -- "0-4", "0-5", "0-6", "0-7", "0-8", "0-9", "0-10", "0-11", "1-1", "1-3",
    -- "1-4", "1-5", "1-6", "1-7", "1-8", "1-9", "1-10", "1-11", "1-12", "2-1",
    -- "2-2", "2-3", "2-4", "2-5", "2-6", "2-7", "2-8", "2-9", "2-10", "S2-1",
    -- "S2-2", "S2-3", "S2-4", "S2-5", "S2-6", "S2-7", "S2-8", "S2-9", "S2-10",
    -- "S2-12", "3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7", "3-8", "S3-1",
    -- "S3-2", "S3-3", "S3-4", "S3-5", "S3-6", "S3-7", "4-1", "4-2", "4-3", "4-4",
    -- "4-5", "4-6", "4-7", "4-8", "4-9", "4-10", "S4-1", "S4-2", "S4-3", "S4-4",
    -- "S4-5", "S4-6", "S4-7", "S4-8", "S4-9", "S4-10", "5-1", "5-2", "S5-1",
    -- "S5-2", "5-3", "5-4", "5-5", "5-6", "S5-3", "S5-4", "5-7", "5-8", "5-9",
    -- "S5-5", "S5-6", "S5-7", "S5-8", "S5-9", "5-10", "6-1", "6-2", "6-3", "6-4",
    -- "6-5", "6-7", "6-8", "6-9", "6-10", "S6-1", "S6-2", "6-11", "6-12", "6-14",
    -- "6-15", "S6-3", "S6-4", "6-16", "7-2", "7-3", "7-4", "7-5", "7-6", "7-8",
    -- "7-9", "7-10", "7-11", "7-12", "7-13", "7-14", "7-15", "7-16", "S7-1",
    -- "S7-2", "7-17", "7-18", "R8-1", "R8-2", "R8-3", "R8-4", "R8-5", "R8-6",
    -- "R8-7", "R8-8", "R8-9", "R8-10", "R8-11", "JT8-2", "JT8-3", "M8-6", "M8-7",
    -- "M8-8",
  }

  fight = table.filter(fight, function(v) return point['作战列表' .. v] end)
  log(fight)
  repeat_fight_mode = false
  run("轮次作战")
  exit()
end

if test_some then
  ssleep(1)
  -- tap("基建副手列表4")
  -- tap("基建副手列表5")
  path.副手换人()
  exit()
end

loadstring(lua_setting)()
drug_times = 0
max_drug_times = 最大吃药次数 or default_max_drug_times
stone_times = 0
max_stone_times = 最大吃石头次数 or default_max_stone_times
fight_times = 0
max_fight_times = 最大作战次数 or default_max_fight_times

local start_time = time()
log("start")
run(now_job)
log("end", time() - start_time)
playAudio('/system/media/audio/ui/Effect_Tick.ogg')
ssleep(1)
