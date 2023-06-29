#! /bin/bash
# 屏幕亮度脚本
# sudo pacman -S brightnessctl

# cricle
shell_path=$(dirname "$0")
temp_file=$(cd "$shell_path" || exit;cd ..;pwd)/temp

this=_bright
icon_color="^c#442266^^b#7879560x88^"
text_color="^c#442266^^b#7879560x99^"
signal=$(echo "^s$this^" | sed 's/_//')


# check
[ ! "$(command -v brightnessctl)" ] && echo command not found: brightnessctl && exit


# 中英文适配
case "$LANG" in
  "zh_CN.UTF-8")
  bright_name="屏幕亮度"
  ;;
  "en_US.UTF-8")
  bright_name="screen brightness"
  ;;
esac

update() {
  # bright_text=$(brightnessctl | grep 'Current brightness' | awk -F ":" '{ print $2 }')
  bright_text=$(brightnessctl | grep 'Current brightness' | awk -F " " '{ print $4 }' | awk -F "%" '{print $1}' | awk -F "(" '{print $2}')
  if   [ "$bright_text" -ge 95 ]; then bright_icon="󰛨";
  elif [ "$bright_text" -ge 90 ]; then bright_icon="󱩖";
  elif [ "$bright_text" -ge 80 ]; then bright_icon="󱩕";
  elif [ "$bright_text" -ge 70 ]; then bright_icon="󱩔";
  elif [ "$bright_text" -ge 60 ]; then bright_icon="󱩔";
  elif [ "$bright_text" -ge 50 ]; then bright_icon="󱩒";
  elif [ "$bright_text" -ge 40 ]; then bright_icon="󱩑";
  elif [ "$bright_text" -ge 30 ]; then bright_icon="󱩐";
  elif [ "$bright_text" -ge 20 ]; then bright_icon="󱩏";
  elif [ "$bright_text" -ge 10 ]; then bright_icon="󱩎";
  else bright_icon="󰛩"; fi
  icon=" $bright_icon "
  text=" $bright_text% "

  sed -i '/^export '$this'=.*$/d' "$temp_file"
  printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> "$temp_file"
}

notify() {
    update
    dunstify -r 9527 -h int:value:$bright_text -h string:hlcolor:#dddddd "$bright_icon $bright_name"
}


click() {
    case "$1" in
        # 仅通知  左击
        L) notify ;;
        # 亮度加  滚轮向上滚
        U) brightnessctl set 1%+; notify ;;
        # 亮度减  滚轮向下滚
        D) brightnessctl set 1%-; notify ;;
    esac
}

case "$1" in
    click) click "$2" ;;
    notify) notify ;;
    *) update ;;
esac
