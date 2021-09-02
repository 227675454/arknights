#!/usr/bin/env bash
{
  init() {
    declare -A serial
    serial=([k40]=df7592c8 [l]=localhost:5555 [z9]=172.30.25.19:5555 )
    export ANDROID_SERIAL=${serial[${1:-l}]}
    adb forward --remove tcp:9095
    adb forward --remove tcp:9090
    adb forward tcp:9095 tcp:9095
    adb forward tcp:9090 tcp:9090
  }
  restartcolor() { # 重启节点精灵，以适应分辨率变更
    adb shell am force-stop com.aojoy.aplug
    # adb shell monkey -p com.aojoy.aplug -c android.intent.category.LAUNCHER 1
    sleep 1
    adb shell settings put secure enabled_accessibility_services com.aojoy.aplug/com.aojoy.server.CmdAccessibilityService
    sleep 2
    #adb shell am start com.hypergryph.arknights
    adb shell input keyevent KEYCODE_APP_SWITCH
    adb shell input keyevent KEYCODE_APP_SWITCH
    #adb shell monkey -p com.hypergryph.arknights -c android.intent.category.LAUNCHER 1
    sleep 2
  }
  release() {
    sed -i -r 's/(明日方舟速通)（.+）/\1（'"$(date +'%Y.%m.%d %k:%M')"'）/' main.lua
    save "$@"
    curl http://localhost:9090/script/export?name=test >arknights.nsp
    xdg-open http://card.nspirit.cn/admin/apply/list/5963/edit
  }
  stop() {
    echo ==\> stop
    curl http://localhost:9090/script/stop \
      --data-raw 'name=stop'
  }
  save() {
    for x in *.lua; do
      echo ==\> upload "$x"
      curl -sS http://localhost:9090/api/file/save \
        --data-urlencode code="$(cat "$x")" \
        --data-urlencode path=/storage/emulated/0/freespace/scripts/test/"$x" >/dev/null
    done
  }
  find() {
    # 测试不同分辨率下脚本结果
    local option=(
      1080x2400
      720x1280
      1080x1920
    )
    if [[ -n $1 ]]; then
      option=(${option[$1]})
      shift
    fi
    for ((i = 0; i < ${#option[@]}; ++i)); do
      adb shell wm size ${option[$i]}
      restartcolor "$@"
      if [[ $i -eq 0 ]]; then
        save "$@"
      fi
      run "$@"
    done
  }

  run() {
    stop "$@"
    listen "$@" &
    echo ==\> run
    curl -sS http://localhost:9090/script/run \
      --data-urlencode name=test \
      --data-urlencode code= \
      --data-urlencode path=/storage/emulated/0/freespace/scripts/test/placeholder.lua >/dev/null
  }

  saverun() {
    stop "$@"
    save "$@"
    sleep .2
    run "$@"
  }

  listen() {
    websocat -n ws://localhost:9095
  }

  timer() {
    local start=$(date -u +"%s.%N")
    local cur
    while :; do
      cur=$(date -u +"%s.%N")
      printf "\r$(date -u -d "0 $cur seconds - $start seconds" +"%H:%M:%S:%3N")"
    done
  }
  scrcpy() {
    sudo scrcpy "$@"
  }

  "$@"
  wait
}
