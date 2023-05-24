#! /bin/bash

thisdir=$(cd $(dirname $0);pwd)
tempfile=$thisdir/temp
touch $tempfile

# 设置某个模块的状态 update cpu mem ...
update() {
    [ ! "$1" ] && refresh && return                                      # 当指定模块为空时 结束
    sh $thisdir/packages/$1.sh                                         # 执行指定模块脚本
    shift 1; update $*                                                   # 递归调用
}

# 处理状态栏点击
click() {
    [ ! "$1" ] && return                                                 # 未传递参数时 结束
    sh $thisdir/packages/$1.sh click $2                                # 执行指定模块脚本
    update $1                                                            # 更新指定模块
    refresh                                                              # 刷新状态栏
}

# 更新状态栏
refresh() {
    # _icons='';_music='';_wifi='';_cpu='';_mem='';_date='';_vol='';_bat=''# 重置所有模块的状态为空
    # source $tempfile                                                     # 从 temp 文件中读取模块的状态
    # xsetroot -name "$_icons$_music$_wifi$_cpu$_mem$_date$_vol$_bat"      # 更新状态栏
    _icons='';_cpu='';_mem='';_vol='';_date='';_bat=''
    source $tempfile                                                     # 从 temp 文件中读取模块的状态
    xsetroot -name "$_icons$_cpu$_mem$_vol$_date$_bat"      # 更新状态栏
}

# 启动定时更新状态栏 不同的模块有不同的刷新周期 注意不要重复启动该func
cron() {
    echo > $tempfile                                                     # 清空 temp 文件

    # 一秒更新
    while true; do
      update date bat cpu mem
      sleep 1;
    done &
    # 五秒更新
    while true; do
      update vol icons
      sleep 5;
    done &
    # 二十秒更新
}

# cron 启动定时更新状态栏
# update 更新指定模块 `update cpu` `update mem` `update date` `update vol` `update bat` 等
# updateall 更新所有模块 | check 检查模块是否正常(行为等于updateall)
# * 处理状态栏点击 `cpu 按键` `mem 按键` `date 按键` `vol 按键` `bat 按键` 等
case $1 in
    cron) cron ;;
    update) shift 1; update $* ;;
    updateall|check) update icons cpu men vol date bat;;
    *) click $1 $2 ;; # 接收clickstatusbar传递过来的信号 $1: 模块名  $2: 按键(L|M|R|U|D)
esac
