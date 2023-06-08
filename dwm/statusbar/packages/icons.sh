#! /bin/bash
# ICONS 部分特殊的标记图标 这里是我自己用的，你用不上的话去掉就行

shell_path=$(dirname "$0")
temp_file=$(cd "$shell_path" || exit;cd ..;pwd)/temp

this=_icons
color="^c#2D1B46^^b#5555660x66^"
signal=$(echo "^s$this^" | sed 's/_//')

update() {
  icons=("󰣇")

  text=" ${icons[*]} "

  sed -i '/^export '$this'=.*$/d' "$temp_file"
  printf "export %s='%s%s%s'\n" $this "$signal" "$color" "$text" >> "$temp_file"
}

call_menu() {
    case $(echo -e ' 关机\n 重启\n󰂠 休眠\n 锁定' | rofi -dmenu -window-title power) in
        " 关机") poweroff ;;
        " 重启") reboot ;;
        " 休眠") systemctl hibernate ;;
        " 锁定") ~/wm/config/lock/blurlock.sh ;;
    esac
}

click() {
    case "$1" in
        L) feh --bg-fill --randomize --no-fehbg ~/wm/wallpaper/*.png ;;
        R) call_menu ;;
    esac
}

case "$1" in
    click) click "$2" ;;
    *) update ;;
esac
