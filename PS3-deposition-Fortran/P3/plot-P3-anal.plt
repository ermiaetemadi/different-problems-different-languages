# plot-save.plt
# set terminal epslatex
# set size square
# set output "P3-anal.tex"
# set xrange[8:14]
# set yrange[3.5:5]
set key right bottom
m = "var-P3.txt"
set xlabel "Log(Steps)"
set ylabel "Log($\\omega$)"
plot -4.6464487715106912 + 1.0019054726138250*x with line title "Line Fit" linecolor "red" linetype "-", 5.29330492  + 0.0*x with line title "$w_s$" linecolor "red" linetype "-" , m using 1:2 with points pt 7 title "Data Points"
