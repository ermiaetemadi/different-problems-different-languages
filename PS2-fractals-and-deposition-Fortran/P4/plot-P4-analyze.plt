# plot-save.plt
set terminal epslatex
# set size square
set output "P4-anal.tex"
set xrange[6:9]
set yrange[3:7]
set key left top
m = "var-P4.txt"
set xlabel "Log(Steps)"
set ylabel "Log($\\omega$)"
plot -5.4461584828029741 + 1.3869643698103935*x with line title "Line Fit", m using 1:2 with points pt 5 title "Data Points"
