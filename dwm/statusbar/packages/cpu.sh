#! /bin/bash
# CPU 获取CPU使用率和温度的脚本

# shellcheck disable=SC2046
temp_file=$(cd $(dirname "$0") || exit;cd ..;pwd)/temp

this=_cpu
icon_color="^c#3E206F^^b#6E51760x88^"
text_color="^c#3E206F^^b#6E51760x99^"
signal=$(echo "^s$this^" | sed 's/_//')

with_temp() {
    # check
    [ ! "$(command -v sensors)" ] && echo command not found: sensors && return

    temp_text=$(sensors | grep Package | awk '{printf "%d°C", $4}')
    text=" $cpu_text $temp_text "
} 

update() {
    cpu_icon="󰻠"
    cpu_text=$(top -n 1 -b | sed -n '3p' | awk '{printf "%02d%", 100 - $8}')

    icon=" $cpu_icon "
    text=" $cpu_text "

    with_temp    sed -i '/^export '$this'=.*$/d' "$temp_file"
    printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> "$temp_file"
}

notify() {
    dunstify "󰻠 CPU tops" "\n$(ps axch -o cmd:15,%cpu --sort=-%cpu | head)\\n\\n(100% per core)" -r 9527
}

call_b_top() {
    pid1=$(pgrep -f 'st -t status_util')
    pid2=$(pgrep -f 'st -t status_util_cpu')
    mx=$(xdotool getmouselocation --shell | grep X= | sed 's/X=//')
    my=$(xdotool getmouselocation --shell | grep Y= | sed 's/Y=//')
    if [ "$pid2" ]; then
        kill "$pid2"
    else
      if [ "$pid1" ]; then
          kill "$pid1"
      fi
      st -t status_util_cpu -g 82x25+$((mx - 328))+$((my + 20)) -c FGN -e btop
    fi
}

click() {
    case "$1" in
        L) notify ;;
        M) ;;
        R) call_b_top ;;
        U) ;;
        D) ;;
    esac
}

case "$1" in
    click) click "$2" ;;
    notify) notify ;;
    *) update ;;
esac
