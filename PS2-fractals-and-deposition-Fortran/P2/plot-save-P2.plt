# plot-save.plt
set terminal pngcairo size 8000, 8000 fontscale 10 pointscale 1
set size square
set output "fractal-P2.png"
set xrange[-0.5:0.5]
set yrange[-0.1:0.3]
m="data-P2.txt"
plot m with points pt 7 pointsize 1 title ""
