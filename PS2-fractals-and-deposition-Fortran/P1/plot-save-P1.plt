# plot-save.plt
set terminal pngcairo size 8000, 8000 fontscale 10 pointscale 1
set size square
set output "fractal-P1.png"
set xrange[0:1]
set yrange[0:1]
set title "Sierpiński triangle"
m="data-P1.txt"
plot m with points pt 7 pointsize 1 title ""
