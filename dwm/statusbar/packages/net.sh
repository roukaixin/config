#! /bin/bash

shell_path=$(dirname "$0")
temp_file=$(cd "$shell_path" || exit;cd ..;pwd)/temp

this=_net
icon_color="^c#000080^^b#3870560x88^"
text_color="^c#000080^^b#3870560x99^"
signal=$(echo "^s$this^" | sed 's/_//')

# check
[ ! "$(command -v nmcli)" ] && echo command not found: nmcli && exit

# 中英文适配
case "$LANG" in
  "zh_CN.UTF-8")
  net_grep_keyword="已连接 到"
  net_disconnected="未连接"
  net_disconnected_notify="未连接到网络"
  net_delimiter="： "
  net_name="以太网"
  ;;
  "en_US.UTF-8")
  net_grep_keyword="connected to"
  net_disconnected="disconnected"
  net_disconnected_notify="disconnected"
  net_delimiter=":  "
  net_name="Internet"
  ;;
esac

update() {
  # 获取以太网网卡
  connection_method_en=$(nmcli | grep "$net_grep_keyword" | grep "en" | sed "s/$net_grep_keyword//" | awk -F "$net_delimiter" '{print $1}' | awk -F '' '{print $1$2}')
  net_text_en=$(nmcli | grep "$net_grep_keyword" | grep "en" | sed "s/$net_grep_keyword//" | awk -F "$net_delimiter" '{print $2}' | paste -d " " -s)
  # 获取 wifi 网卡
  connection_method_wl=$(nmcli | grep "$net_grep_keyword" | grep "wl" | sed "s/$net_grep_keyword//" | awk -F "$net_delimiter" '{print $1}' | awk -F '' '{print $1$2}')
  net_text_wl=$(nmcli | grep "$net_grep_keyword" | grep "wl" | sed "s/$net_grep_keyword//" | awk -F "$net_delimiter" '{print $2}' | paste -d " " -s)

  if [ "$connection_method_en" ]; then
    # 连接到以太网
    net_icon="󰈀"
    net_text=$net_text_en
    connection_name=$net_name
  elif [ "$connection_method_wl" ]; then
    # 连接到 wifi
    net_icon="󰤨"
    net_text=$net_text_wl
    connection_name="Wifi"
  else
    # 未连接状态 图标：web
    net_icon="󰕑"
    net_text=$net_disconnected
    connection_name=$net_disconnected_notify
  fi


  icon=" $net_icon "
  text=" $net_text "

  sed -i '/^export '$this'=.*$/d' "$temp_file"
  printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> "$temp_file"
}

notify() {
    update
    dunstify -r 9527 "$net_icon $connection_name" "\n$net_text"
}

call_net() {
    pid1=$(pgrep -f 'st -t status_util')
    pid2=$(pgrep -f 'st -t status_util_net')
    if [ "$pid2" ]; then
        kill "$pid2"
    else
        if [ "$pid1" ]; then
            kill "$pid1"
        fi
    fi
}

click() {
    case "$1" in
        L) notify ;;
        R) call_net ;;
    esac
}

case "$1" in
    click) click "$2" ;;
    notify) notify ;;
    *) update ;;
esac
