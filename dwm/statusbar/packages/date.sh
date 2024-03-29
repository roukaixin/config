#! /bin/bash
# DATE 获取日期和时间的脚本

shell_path=$(dirname "$0")
temp_file=$(cd "$shell_path" || exit;cd ..;pwd)/temp

this=_date
icon_color="^c#4B005B^^b#7E51680x88^"
text_color="^c#4B005B^^b#7E51680x99^"
signal=$(echo "^s$this^" | sed 's/_//')

# 中英文适配
case "$LANG" in
  "zh_CN.UTF-8")
  notify_theme="日历"
  ;;
  "en_US.UTF-8")
  notify_theme="Calendar"
  ;;
esac


update() {
    time_text="$(date '+%m/%d %H:%M:%S')"
    case "$(date '+%I')" in
        "01") time_icon="" ;;
        "02") time_icon="" ;;
        "03") time_icon="" ;;
        "04") time_icon="" ;;
        "05") time_icon="" ;;
        "06") time_icon="" ;;
        "07") time_icon="" ;;
        "08") time_icon="" ;;
        "09") time_icon="" ;;
        "10") time_icon="" ;;
        "11") time_icon="" ;;
        "12") time_icon="" ;;
    esac

    icon=" $time_icon "
    text=" $time_text "

    sed -i '/^export '$this'=.*$/d' "$temp_file"
    printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> "$temp_file"
}

notify() {
    _cal=$(cal --color=always | sed 1,2d | sed 's/..7m/<b><span color="#ff79c6">/;s/..0m/<\/span><\/b>/' )
    dunstify "  $notify_theme" "\n$_cal" -r 9527
}

call_todo() {
    pid1=$(pgrep -f 'st -t status_util')
    pid2=$(pgrep -f 'st -t status_util_todo')
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
        R) call_todo ;;
    esac
}

case "$1" in
    click) click "$2" ;;
    notify) notify ;;
    *) update ;;
esac
