# plot-save.plt
# set terminal epslatex
# set size square
# set output "P2-anal.tex"
# set xrange[8:14]
# set yrange[2.5:5]
set key right bottom
m = "var-P2.txt"
set xlabel "Log(Steps)"
set ylabel "Log($\\omega$)"
plot -0.19711733010017013 + 0.38661710188684728*x with line title "Line Fit" linecolor "red" linetype "-", 3.97708201 + 0.0*x with line title "$w_s$" linecolor "red" linetype "-" , m using 1:2 with points pt 7 title "Data Points"
