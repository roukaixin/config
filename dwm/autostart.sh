#! /bin/bash



daemons() {
  sh /home/tnt/wm/config/dwm/statusbar/statusbar.sh cron &
	fcitx5 &
	flameshot &
	dunst -conf ~/wm/config/dunst/dunst.conf &
	picom --config ~/wm/config/picom/picom.conf &
}

cron() {
	while true;
	do
		feh --bg-fill --randomize --no-fehbg ~/wm/wallpaper/*.png
		sleep 300
	done &
}

daemons 3 &
cron 5 &
