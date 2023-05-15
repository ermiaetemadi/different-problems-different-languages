# plot-save-P3.plt
set terminal pngcairo size 8000, 8000 fontscale 10 pointscale 1
# set size square
set output "fractal-P3.png"
set xrange[0:3000]
set yrange[0:3000]
set xtics ('-1.5' 0, '-1' 500, '-0.5' 1000, '0' 1500, '0.5' 2000, '1.0' 2500, '1.5' 3000)
set ytics ('-1.5' 0, '-1' 500, '-0.5' 1000, '0' 1500, '0.5' 2000, '1.0' 2500, '1.5' 3000)
set title "Julia Set"
m="data-P3.txt"
plot m matrix with image title ""
