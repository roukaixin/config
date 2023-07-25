#! /bin/bash

shell_path=$(dirname "$0")
this_dir=$(cd "$shell_path" || exit;pwd)
temp_file=$this_dir/temp
touch "$temp_file"

# 设置某个模块的状态 update cpu mem ...
update() {
    [ ! "$1" ] && refresh && return                                      # 当指定模块为空时 结束
    sh "$this_dir"/packages/"$1".sh                                         # 执行指定模块脚本
    shift 1; update "$@"                                                   # 递归调用
}

# 处理状态栏点击
click() {
    [ ! "$1" ] && return                                                 # 未传递参数时 结束
    sh "$this_dir"/packages/"$1".sh click "$2"                                # 执行指定模块脚本
    update "$1"                                                            # 更新指定模块
    refresh                                                              # 刷新状态栏
}

# 更新状态栏
refresh() {
    _icons='';_bright='';_net='';_cpu='';_mem='';_vol='';_date='';_bat='';            # 重置所有模块的状态为空
    # shellcheck source=$HOME/wm/config/dwm/statusbar/temp
    source "$temp_file"                                                             # 从 temp 文件中读取模块的状态
    xsetroot -name "$_icons$_bright$_net$_cpu$_mem$_vol$_date$_bat"                 # 更新状态栏
}

icons_fun(){
  while true; do
    update icons
    sleep 10800
  done
}

net_fun(){
  while true; do
    update net
    sleep 1
  done
}

cpu_fun(){
  while true; do
    update cpu
  done
}

mem_fun(){
  while true; do
    update mem
    sleep 1
  done
}

vol_fun(){
  while true; do
    update vol
    sleep 1
  done
}

date_fun(){
  while true; do
    update date
    sleep 1
  done
}

bat_fun(){
  while true; do
    update bat
    sleep 3
  done
}

# 启动定时更新状态栏 不同的模块有不同的刷新周期 注意不要重复启动该func
cron() {
    echo > "$temp_file"   # 清空 temp 文件
    icons_fun &
    net_fun &
    cpu_fun &
    mem_fun &
    vol_fun &
    date_fun &
    bat_fun &
}

# cron 启动定时更新状态栏
# update 更新指定模块 `update cpu` `update mem` `update date` `update vol` `update bat` 等
# update all 更新所有模块 | check 检查模块是否正常(行为等于update all)
# * 处理状态栏点击 `cpu 按键` `mem 按键` `date 按键` `vol 按键` `bat 按键` 等
case $1 in
    cron) cron ;;
    update) shift 1; update "$@" ;;
    updateall|check) update icons bright net cpu men vol date bat;;
    *) click "$1" "$2" ;;       # 接收 click statusbar 传递过来的信号 $1: 模块名  $2: 按键(L|M|R|U|D)
esac
