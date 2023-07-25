#! /bin/bash
# CPU 获取CPU使用率和温度的脚本

shell_path=$(dirname "$0")
temp_file=$(cd "$shell_path" || exit;cd ..;pwd)/temp

this=_cpu
icon_color="^c#3E206F^^b#6E51760x88^"
text_color="^c#3E206F^^b#6E51760x99^"
signal=$(echo "^s$this^" | sed 's/_//')

cpu_temp() {
    # check
    [ ! "$(command -v sensors)" ] && echo command not found: sensors && return

    temp_text=$(sensors | grep Package | awk '{printf "%d°C", $4}')
    text=" $cpu_text $temp_text "
} 

update() {
    cpu_icon="󰻠"

    # 获取初始的 cpu 统计数据
    read -r cpu_user cpu_nice cpu_system cpu_idel cpu_iowait cpu_irq cpu_softirq cpu_steal cpu_guest cpu_guest_nice <<<"$(grep '^cpu' /proc/stat | awk '{print $2, $3, $4, $5, $6, $7, $8, $9, $10, $11}')"
    # 等待 0.8 秒
    sleep 2
    # 获取更新后的 cpu 统计数据
    read -r new_cpu_user new_cpu_nice new_cpu_system new_cpu_idel new_cpu_iowait new_cpu_irq new_cpu_softirq new_cpu_steal new_cpu_guest new_cpu_guest_nice <<<"$(grep '^cpu' /proc/stat | awk '{print $2, $3, $4, $5, $6, $7, $8, $9, $10, $11}')"

    # 计算 cpu 使用率
    total_prev=$((cpu_user + cpu_nice + cpu_system + cpu_idel + cpu_iowait + cpu_irq + cpu_softirq + cpu_steal + cpu_guest + cpu_guest_nice))
    total_now=$((new_cpu_user + new_cpu_nice + new_cpu_system + new_cpu_idel + new_cpu_iowait + new_cpu_irq + new_cpu_softirq + new_cpu_steal + new_cpu_guest + new_cpu_guest_nice))
    total_diff=$((total_now - total_prev))

    idle_prev=$cpu_idel
    idle_now=$new_cpu_idel
    idle_diff=$((idle_now - idle_prev))

    cpu_text=$(echo $((100 * (total_diff - idle_diff) / total_diff)) | awk '{printf "%02d%", $1}')

    icon=" $cpu_icon "
    text=" $cpu_text "

    cpu_temp

    sed -i '/^export '$this'=.*$/d' "$temp_file"
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
        R) call_b_top ;;
    esac
}

case "$1" in
    click) click "$2" ;;
    notify) notify ;;
    *) update ;;
esac
