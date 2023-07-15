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

# 获取以太网
get_en(){
  connection_method_en=$(nmcli | grep "$net_grep_keyword" | grep "en" | sed "s/$net_grep_keyword//" | awk -F "$net_delimiter" '{print $1}' | awk -F '' '{print $1$2}')
  net_text_en=$(nmcli | grep "$net_grep_keyword" | grep "en" | sed "s/$net_grep_keyword//" | awk -F "$net_delimiter" '{print $2}' | paste -d " " -s)
  if [ "$connection_method_en" ]; then
    en_context="$icon_color 󰈀 $text_color $net_text_en"
    notify_icon_en="󰈀 $net_name"
    net_all_context=("${net_all_context[@]}" "$en_context")
  fi
}

# 获取wifi
get_wl() {
  connection_method_wl=$(nmcli | grep "$net_grep_keyword" | grep "wl" | sed "s/$net_grep_keyword//" | awk -F "$net_delimiter" '{print $1}' | awk -F '' '{print $1$2}')
  net_text_wl=$(nmcli | grep "$net_grep_keyword" | grep "wl" | sed "s/$net_grep_keyword//" | awk -F "$net_delimiter" '{print $2}' | paste -d " " -s)
  if [ "$connection_method_wl" ]; then
    wl_context="$icon_color 󰤨 $text_color $net_text_wl"
    notify_icon_wl="󰤨  wifi"
    net_all_context=("${net_all_context[@]}" "$wl_context")
  fi
}

update() {
  net_all_context=()
  get_en
  get_wl
  text="${net_all_context[*]} "

  net_text=$(nmcli | grep "$net_grep_keyword" | sed "s/$net_grep_keyword//" | awk -F "$net_delimiter" '{print $2}' | paste -d " " -s)
  # 未连接状态 图标：web
  [ "$net_text" = "" ] && text="$icon_color '󰕑' $text_color $net_disconnected "

  sed -i '/^export '$this'=.*$/d' "$temp_file"
  printf "export %s='%s%s'\n" $this "$signal" "$text" >> "$temp_file"
}

notify() {
    update
    if [ "$notify_icon_en" ]; then
      dunstify -r 9526 "$notify_icon_en" "\n$net_text_en"
    fi
    if [ "$notify_icon_wl" ]; then
      dunstify -r 9527 "$notify_icon_wl" "\n$net_text_wl"
    fi
    if [ ! "$notify_icon_en" ] && [ ! "$notify_icon_wl" ]; then
      dunstify -r 9527 "󰕑" "$net_disconnected_notify"
    fi
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
