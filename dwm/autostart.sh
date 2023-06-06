#! /bin/bash



daemons() {
  sh $HOME/wm/config/dwm/statusbar/statusbar.sh cron &
  fcitx5 &
  flameshot &
  dunst -conf $HOME/wm/config/dunst/dunst.conf &
  picom --config $HOME/wm/config/picom/picom.conf &
}

cron() {
	while true;
	do
		feh --bg-fill --randomize --no-fehbg $HOME/wm/wallpaper/*.png
		sleep 300
	done &
}

daemons 3 &
cron 5 &
