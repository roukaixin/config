#! /bin/bash

daemons() {
  fcitx5 &
  numlockx &
  nm-applet &
  blueman-applet &
  /usr/lib/polkit-kde-authentication-agent-1 &
  slstatus &
  picom &
  dunst &
  xss-lock -- bash ~/wm/config/lock/blurlock.sh &
}

cron() {
	while true;
	do
		feh --bg-fill --randomize --no-fehbg "$HOME"/wm/wallpaper/*.png
		sleep 1800
	done &
}

daemons 3 &
cron 5 &
