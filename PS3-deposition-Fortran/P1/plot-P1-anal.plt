# plot-save.plt
# set terminal epslatex
# set size square
# set output "P1-anal.tex"
set xrange[10:15]
set yrange[1.5:2.5]
set key right bottom
m = "var-P1.txt"
set xlabel "Log(Steps)"
set ylabel "Log($\\omega$)"
plot -2.0704407688110646 + 0.34999502452418735*x with line title "Line Fit" linecolor "red" linetype "-", 2.33388352  + 0.0*x with line title "$w_s$" linecolor "red" linetype "-" , m using 1:2 with points pt 7 title "Data Points"
