package main

import (
	"ermia/IsingModel/Fit"
	"ermia/IsingModel/Plots"
	"ermia/IsingModel/Runners"
	"fmt"

	"gonum.org/v1/plot/plotter"
)

func main() {

	Runners.SimpleRun(200, 0.4) // Test run with ploting the grid

	G10 := Runners.RunSimLThreads(10, 100, 100)
	Runners.WriteToCSV(G10, "G10.csv")

	G20 := Runners.RunSimLThreads(20, 100, 100)
	Runners.WriteToCSV(G20, "G20.csv")

	G30 := Runners.RunSimLThreads(30, 100, 100)
	Runners.WriteToCSV(G30, "G30.csv")

	G40 := Runners.RunSimLThreads(40, 100, 100)
	Runners.WriteToCSV(G40, "G40.csv")

	// We saved our results so we can load them later:

	// G10 := Runners.ReadCSV("G10.csv")
	// G20 := Runners.ReadCSV("G20.csv")
	// G30 := Runners.ReadCSV("G30.csv")
	// G40 := Runners.ReadCSV("G40.csv")

	Labels := []string{"L = 10", "L = 20", "L = 30", "L = 40"}

	Plots.PlotData([]plotter.XYs{G10[0], G20[0], G30[0], G40[0]}, "Energy", "J", "E", Labels, nil)
	Plots.PlotData([]plotter.XYs{G10[1], G20[1], G30[1], G40[1]}, "Magnetization", "J", "M", Labels, nil)
	Plots.PlotData([]plotter.XYs{G10[2], G20[2], G30[2], G40[2]}, "Heat Capcity", "J", "Cv", Labels, nil)
	Plots.PlotData([]plotter.XYs{G10[3], G20[3], G30[3], G40[3]}, "Magnetic Susceptibility", "J", "Khi", Labels, nil)

	println("Jc index for L = 10 :" + fmt.Sprint(Fit.FindTc(G10)))
	println("Jc index for L = 20 :" + fmt.Sprint(Fit.FindTc(G20)))
	println("Jc index for L = 30 :" + fmt.Sprint(Fit.FindTc(G30)))
	println("Jc index for L = 40 :" + fmt.Sprint(Fit.FindTc(G40)))

	TestCor := Runners.RunAutoCor(200, 0.445, 10)
	Plots.PlotData([]plotter.XYs{TestCor}, "Auto Correlation", "Lag", "Correlation", []string{""}, nil)

	println("Critical Exponents for L = 10 : " + fmt.Sprint(Fit.CalcCritExp(G10, 15)))
	println("Critical Exponents for L = 20 : " + fmt.Sprint(Fit.CalcCritExp(G20, 15)))
	println("Critical Exponents for L = 30 : " + fmt.Sprint(Fit.CalcCritExp(G30, 15)))
	println("Critical Exponents for L = 40 : " + fmt.Sprint(Fit.CalcCritExp(G40, 15)))

}
