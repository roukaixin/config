#! /bin/bash
# 电池电量
# 需要安装acpi或者upower

shell_path=$(dirname "$0")
temp_file=$(cd "$shell_path" || exit;cd ..;pwd)/temp

this=_bat
icon_color="^c#3B001B^^b#4865660x88^"
text_color="^c#3B001B^^b#4865660x99^"
signal=$(echo "^s$this^" | sed 's/_//')

# 中英文适配
case "$LANG" in
  "zh_CN.UTF-8")
  bat_name="电池电量"
  remaining="剩余"
  available_time="可用时间"
  bat_low="电池电量低，请充电"
  ;;
  "en_US.UTF-8")
  bat_name="Battery"
  remaining="remaining"
  available_time="available time"
  bat_low="The battery is low, please charge it"
  ;;
esac

get_by_acpi() {
    [ ! "$(command -v acpi)" ] && echo command not found: acpi && return
    bat_text=$(acpi -b | sed '2,$d' | awk '{print $4}' | grep -Eo "[0-9]+")
    [ ! "$bat_text" ] && bat_text=$(acpi -b | sed '2,$d' | awk -F'[ %]' '{print $5}' | grep -Eo "[0-9]+")
    ! acpi -b | grep 'Battery 0' | grep Discharging &&
    acpi -a | grep -q on-line
    _time="$available_time: $(acpi | sed 's/^Battery 0: //g' | awk -F ',' '{print $3}' | sed 's/^[ ]//g' | awk '{print $1}')"
    [ "$_time" = "$available_time: " ] && _time=""
}

get_by_upower() {
    [ -n "$bat_text" ] && [ "$bat_text" -gt 0 ] && return
    [ ! "$(command -v upower)" ] && echo command not found: upower && return
    bat=$(upower -e | grep BAT)
    bat_text=$(upower -i "$bat" | awk '/percentage/ {print $2}' | grep -Eo '[0-9]+')
}

update() {
    get_by_acpi
    get_by_upower
    [ -z "$bat_text" ] && bat_text=0

    if ! acpi -b | grep 'Battery 0' | grep Discharging ; then
      dunstctl history-rm 952810
      if   [ "$bat_text" -ge 95 ]; then bat_icon="󰂅";
      elif [ "$bat_text" -ge 90 ]; then bat_icon="󰂋";
      elif [ "$bat_text" -ge 80 ]; then bat_icon="󰂊";
      elif [ "$bat_text" -ge 70 ]; then bat_icon="󰢞";
      elif [ "$bat_text" -ge 60 ]; then bat_icon="󰂉";
      elif [ "$bat_text" -ge 50 ]; then bat_icon="󰢝";
      elif [ "$bat_text" -ge 40 ]; then bat_icon="󰂈";
      elif [ "$bat_text" -ge 30 ]; then bat_icon="󰂇";
      elif [ "$bat_text" -ge 20 ]; then bat_icon="󰂆";
      elif [ "$bat_text" -ge 10 ]; then bat_icon="󰢜";
      else bat_icon="󰢟"; fi
    else
      if   [ "$bat_text" -ge 95 ]; then bat_icon="󰁹";
      elif [ "$bat_text" -ge 90 ]; then bat_icon="󰂂";
      elif [ "$bat_text" -ge 80 ]; then bat_icon="󰂁";
      elif [ "$bat_text" -ge 70 ]; then bat_icon="󰂀";
      elif [ "$bat_text" -ge 60 ]; then bat_icon="󰁿";
      elif [ "$bat_text" -ge 50 ]; then bat_icon="󰁾";
      elif [ "$bat_text" -ge 40 ]; then bat_icon="󰁽";
      elif [ "$bat_text" -ge 30 ]; then bat_icon="󰁼";
      elif [ "$bat_text" -ge 20 ]; then bat_icon="󰁻";
      elif [ "$bat_text" -ge 10 ];
      then
        bat_icon="󰁺";
        # 需要点击通知信息才不会在发生信息
        # && [ "$(dunstctl count displayed)" -eq 0 ]
        if [ ! "$(dunstctl history | grep 952810)" ] ; then
            notify_low 952810;
        fi
      else bat_icon="󰂃"; fi
    fi



    icon=" $bat_icon "
    text=" $bat_text% "

    sed -i '/^export '$this'=.*$/d' "$temp_file"
    printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> "$temp_file"
}

notify() {
    update
    dunstify "$bat_icon $bat_name" "\n$remaining: $bat_text%\n$_time" -r 9527
}

notify_low() {
  dunstify "$bat_low" -r "$1"
}

click() {
    case "$1" in
        L) notify ;;
    esac
}

case "$1" in
    click) click "$2" ;;
    notify) notify ;;
    *) update ;;
esac
