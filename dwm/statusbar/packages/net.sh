#! /bin/bash

tempfile=$(cd $(dirname $0);cd ../;pwd)/temp

this=_net
icon_color="^c#000080^^b#3870560x88^"
text_color="^c#000080^^b#3870560x99^"
signal=$(echo "^s$this^" | sed 's/_//')

# check
[ ! "$(command -v nmcli)" ] && echo command not found: nmcli && exit

# 中英文适配
if [ "$LANG" != "zh_CN.UTF-8" ];
then
  wifi_grep_keyword="connected to"
  wifi_disconnected="disconnected"
  wifi_disconnected_notify="disconnected"
  wifi_delimiter=":  "
  internet_name="Internet"
else
  wifi_grep_keyword="已连接 到"
  wifi_disconnected="未连接"
  wifi_disconnected_notify="未连接到网络"
  wifi_delimiter="： "
  internet_name="以太网"
fi

update() {
  # 取两位
  connection_method=$(nmcli | grep "$wifi_grep_keyword" | sed "s/$wifi_grep_keyword//" | awk -F "$wifi_delimiter" '{print $1}' | awk -F '' '{print $1$2}')
  if [ "$connection_method" == "en" ]; then
    net_icon="󰈀"
    connection_name=$internet_name
  elif [ "$connection_method" == "wl" ]; then
    net_icon="󰤨"
    connection_name="Wifi"
  else
    connection_name=$wifi_disconnected_notify
  fi

  net_text=$(nmcli | grep "$wifi_grep_keyword" | sed "s/$wifi_grep_keyword//" | awk -F "$wifi_delimiter" '{print $2}' | paste -d " " -s)
  # 未连接状态 图标：web
  [ "$net_text" = "" ] && net_text=$wifi_disconnected && net_icon="󰕑"

  icon=" $net_icon "
  text=" $net_text "

  sed -i '/^export '$this'=.*$/d' $tempfile
  printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> $tempfile
}

notify() {
    update
    dunstify -r 9527 "$net_icon $connection_name" "\n$net_text"
}

call_nm() {
    pid1=`ps aux | grep 'st -t statusutil' | grep -v grep | awk '{print $2}'`
    pid2=`ps aux | grep 'st -t statusutil_nm' | grep -v grep | awk '{print $2}'`
    mx=`xdotool getmouselocation --shell | grep X= | sed 's/X=//'`
    my=`xdotool getmouselocation --shell | grep Y= | sed 's/Y=//'`
    kill $pid1 && kill $pid2 || st -t statusutil_nm -g 60x25+$((mx - 240))+$((my + 20)) -c FGN -C "#222D31@4" -e 'nmtui-connect'
}

click() {
    case "$1" in
        L) notify ;;
        R) call_nm ;;
    esac
}

case "$1" in
    click) click $2 ;;
    notify) notify ;;
    *) update ;;
esac
