#! /bin/bash
# 依赖包： i3lock-color

# --bar-indicator : 解锁时按键显示为条形。默认是圆形
# --bar-direction ： 条形的方向。0，1，2
# --bar-max-height ： 一个条形的最大高度
# --bar-color ： 设置条形的颜色


# -k, --clock, --force-clock : 显示时间

i3lock \
    --blur 5 \
    --bar-indicator \
    --bar-pos y+h \
    --bar-direction 1 \
    --bar-max-height 50 \
    --bar-base-width 50 \
    --bar-color 00000022 \
    --keyhl-color ffffffcc \
    --bar-periodic-step 50 \
    --bar-step 20 \
    --redraw-thread \
    --clock \
    --force-clock \
    --time-pos x+5:y+h-80 xdotool\
    --time-color ffffffff \
    --time-align 1 \
    --date-pos tx:ty+15 \
    --date-color ffffffff \
    --date-align 1 \
    --ringver-color ffffff00 \
    --ringwrong-color ffffff88 \
    --status-pos x+5:y+h-16 \
    --wrong-align 1 \
    --wrong-color ffffffff \
    --verif-align 1 \
    --verif-color ffffffff \
    --modif-pos -50:-50
xdotool mousemove_relative 1 1 # 该命令用于解决自动锁屏后未展示锁屏界面的问题(移动一下鼠标)
