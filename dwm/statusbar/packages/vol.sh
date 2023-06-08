#! /bin/bash
# VOL 音量脚本
# 本脚本需要你自行修改音量获取命令
# 例如我使用的是 pipewire
#
# $ pactl list sinks | grep RUNNING -A 8
#         State: RUNNING
#         Name: bluez_output.88_C9_E8_14_2A_72.1
#         Description: WH-1000XM4
#         Driver: PipeWire
#         Sample Specification: float32le 2ch 48000Hz
#         Channel Map: front-left,front-right
#         Owner Module: 4294967295
# 静音 -> Mute: no                                                                                 
# 音量 -> Volume: front-left: 13183 /  20% / -41.79 dB,   front-right: 13183 /  20% / -41.79 dB

# shellcheck disable=SC2046
temp_file=$(cd $(dirname "$0") || exit;cd ..;pwd)/temp

this=_vol
icon_color="^c#442266^^b#7879560x88^"
text_color="^c#442266^^b#7879560x99^"
signal=$(echo "^s$this^" | sed 's/_//')

# 中英文适配
case "$LANG" in
  "zh_CN.UTF-8")
  vol_name="音量"
  ;;
  "en_US.UTF-8")
  vol_name="Volume"
  ;;
esac

# check
[ ! "$(command -v pactl)" ] && echo command not found: pactl && exit

update() {
  sink=$(pactl info | grep 'Default Sink' | awk '{print $3}')
  vol_text=$(pactl list sinks | grep "$sink" -A 7 | sed -n '8p' | awk -F "/" '{printf int($2)}')
  vol_toggle_cn=$(pactl list sinks | grep "$sink" -A 6 | sed -n '7p' | grep '静音:' | awk -F ": " '{print $2}')
  vol_toggle_us=$(pactl list sinks | grep "$sink" -A 6 | sed -n '7p' | grep 'Mute:' | awk -F ": " '{print $2}')
  if [ "$vol_toggle_us" == "yes" ] || [ "$vol_toggle_cn" == "是" ];
  then
    vol_text="--"; vol_icon="󰸈";
  elif [ "$vol_text" -eq 0 ];
  then
    vol_text="00"; vol_icon="󰕿";
  elif [ "$vol_text" -lt 10 ];
  then
    vol_icon=""; vol_text=0$vol_text;
  elif [ "$vol_text" -le 50 ];
  then
    vol_icon="󱄠";
  else
    vol_icon="";
  fi

  icon=" $vol_icon "
  text=" $vol_text% "

  sed -i '/^export '$this'=.*$/d' "$temp_file"
  printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> "$temp_file"
}

notify() {
    update
    dunstify -r 9527 -h int:value:$vol_text -h string:hlcolor:#dddddd "$vol_icon $vol_name"
}

call_vol_control() {
    pid1=$(pgrep -f 'st -t status_util')
    pid2=$(pgrep -f 'st -t status_util_vol')
    if [ "$pid2" ]; then
        kill "$pid2"
    else
        if [ "$pid1" ]; then
            kill "$pid1"
        fi
        pavucontrol --name 'st -t status_util_vol'  --class=FGN
    fi
}

click() {
    case "$1" in
        # 仅通知  左击
        L) notify                                           ;;
        # 切换静音 滚轮按键
        M) pactl set-sink-mute @DEFAULT_SINK@ toggle        ;;
        # 打开 pavucontrol 右击
        R) call_vol_control ;;
        # 音量加  滚轮向上滚
        U) pactl set-sink-volume @DEFAULT_SINK@ +5%; notify ;;
        # 音量减  滚轮向下滚
        D) pactl set-sink-volume @DEFAULT_SINK@ -5%; notify ;;
    esac
}

case "$1" in
    click) click "$2" ;;
    notify) notify ;;
    *) update ;;
esac
