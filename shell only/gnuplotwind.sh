#!/usr/local/bin/gnuplot -persist
# set terminal pngcairo  transparent enhanced font "arial,10" fontscale 1.0 size 600, 400 
# set output 'pm3d.8.png'
set border 4095 front lt black linewidth 1.000 dashtype solid
set view map scale 1
set samples 50, 50
set isosamples 50, 50
unset surface
set style data lines
set xyplane relative 0
set title "Altitude en fonction des coordonnées" 
set xlabel "latitude" 
set xrange [ -15.0000 : 15.0000 ] noreverse nowriteback
set x2range [ * : * ] noreverse writeback
set ylabel "longitude" 
set yrange [ -15.0000 : 15.0000 ] noreverse nowriteback
set y2range [ * : * ] noreverse writeback
set zrange [ -0.250000 : 1.00000 ] noreverse nowriteback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
set pm3d implicit at b
set colorbox vertical origin screen 0.9, 0.2 size screen 0.05, 0.6 front  noinvert bdefault
NO_ANIMATION = 1
plot "filtre.temp" using (($0==X_row)?(X=column(X_col),X):0)

# splot sin(sqrt(x**2+y**2))/sqrt(x**2+y**2)