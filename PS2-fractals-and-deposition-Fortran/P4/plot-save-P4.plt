# plot-save.plt
set terminal pngcairo size 8000, 8000 fontscale 10 pointscale 1
# set size square
set output "bd-P4.png"
set xrange[0:200]
set yrange[0:400]

# set style line 1 lc rgb 'red'
# set style line 2 lc rgb 'blue'
# set style line 3 lc rgb 'green'
# set style line 4 lc rgb 'magenta'
# set style line 5 lc rgb 'yellow'


m="data-P4.txt"
plot m using 1:2:3 linecolor variable pt 5 pointsize 8 title ""
