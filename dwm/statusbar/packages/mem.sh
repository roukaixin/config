#! /bin/bash
# MEM

shell_path=$(dirname "$0")
temp_file=$(cd "$shell_path" || exit;cd ..;pwd)/temp

this=_mem
icon_color="^c#3B001B^^b#6873790x88^"
text_color="^c#3B001B^^b#6873790x99^"
signal=$(echo "^s$this^" | sed 's/_//')

# 中英文适配
case "$LANG" in
  "zh_CN.UTF-8")
  notify_theme="内存"
  ;;
  "en_US.UTF-8")
  notify_theme="Memory"
  ;;
esac

update() {
	mem_icon="󰘚"
    mem_total=$(< /proc/meminfo grep "MemTotal:"| awk '{print $2}')
    mem_free=$(< /proc/meminfo grep "MemFree:"| awk '{print $2}')
    mem_buffers=$(< /proc/meminfo grep "Buffers:"| awk '{print $2}')
    mem_cached=$(< /proc/meminfo grep -w "Cached:"| awk '{print $2}')
    men_usage_rate=$(((mem_total - mem_free - mem_buffers - mem_cached) * 100 / mem_total))
    mem_text=$(echo $men_usage_rate | awk '{printf "%02d%", $1}')

    icon=" $mem_icon "
    text=" $mem_text "

    sed -i '/^export '$this'=.*$/d' "$temp_file"
    printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> "$temp_file"
}

notify() {
    free_result=$(free -h)
    text="
可用:\t $(echo "$free_result" | sed -n 2p | awk '{print $7}')
用量:\t $(echo "$free_result" | sed -n 2p | awk '{print $3}')/$(echo "$free_result" | sed -n 2p | awk '{print $2}')
swap:\t $(echo "$free_result" | sed -n 3p | awk '{print $3}')/$(echo "$free_result" | sed -n 3p | awk '{print $2}')
"
    dunstify "󰘚 $notify_theme" "$text" -r 9527
}

call_b_top() {
    pid1=$(pgrep -f 'st -t status_util')
    pid2=$(pgrep -f 'st -t status_util_mem')
    mx=$(xdotool getmouselocation --shell | grep X= | sed 's/X=//')
    my=$(xdotool getmouselocation --shell | grep Y= | sed 's/Y=//')
    if [ "$pid2" ]; then
        kill "$pid2"
    else
      if [ "$pid1" ]; then
          kill "$pid1"
      fi
      st -t status_util_mem -g 82x25+$((mx - 328))+$((my + 20)) -c FGN -e btop
    fi
}

click() {
    case "$1" in
        L) notify ;;
        R) call_b_top ;;
    esac
}

case "$1" in
    click) click "$2" ;;
    notify) notify ;;
    *) update ;;
esac
