// Here we have functions that run different simulations

package Runners

import (
	"ermia/IsingModel"
	"ermia/IsingModel/Plots"
	"fmt"
	"math/rand"
	"sync"
	"time"

	"github.com/schollz/progressbar/v3"
	"gonum.org/v1/plot/plotter"
)

func SimpleRun(GridL int, J float64) {

	randGen := rand.New(rand.NewSource(time.Now().UnixNano()))

	TestGrid := IsingModel.InitGrid(GridL, J)
	IsingModel.RandomizeGrid(&TestGrid, randGen)

	Plots.HeatmapGrid(TestGrid, "0-Starting Grid")

	IsingModel.MetropolisWalk(&TestGrid, *randGen, 500000)
	Plots.HeatmapGrid(TestGrid, "1-Grid after"+"500000"+"Steps(J="+fmt.Sprint(J)+")")

}

func RunSimL(GridL int, JLen int, MetropolisRuns int) [4]plotter.XYs {

	randGen := rand.New(rand.NewSource(time.Now().UnixNano())) // Random generator
	bar := progressbar.Default(int64(JLen))                    // Simple progress bar

	// Results := make([]float64, JLen)
	EResults := make(plotter.XYs, JLen)
	MResults := make(plotter.XYs, JLen)
	KhiResults := make(plotter.XYs, JLen)
	CvResults := make(plotter.XYs, JLen)

	for Jit := 0; Jit < JLen; Jit++ {
		J := 0.01 * float64(Jit)
		Results := IsingModel.MetropolisSimulation(GridL, J, *randGen, MetropolisRuns)
		EResults[Jit].X = J
		MResults[Jit].X = J
		CvResults[Jit].X = J
		KhiResults[Jit].X = J
		EResults[Jit].Y = Results[0]
		MResults[Jit].Y = Results[1]
		CvResults[Jit].Y = Results[2]
		KhiResults[Jit].Y = Results[3]

		bar.Add(1)
	}

	return [4]plotter.XYs{EResults, MResults, KhiResults, CvResults}

}

func RunSimLThreads(GridL int, JLen int, MetropolisRuns int) [4]plotter.XYs {

	randGenList := make([]*rand.Rand, JLen)
	TimeSeed := time.Now().UnixNano()

	for Jit := 0; Jit < JLen; Jit++ {
		randGenList[Jit] = rand.New(rand.NewSource(TimeSeed + int64(10*Jit))) // Random generator
	}

	var wg sync.WaitGroup
	wg.Add(JLen)

	bar := progressbar.Default(int64(JLen)) // Simple progress bar

	Results := make([]float64, JLen)
	EResults := make(plotter.XYs, JLen)
	MResults := make(plotter.XYs, JLen)
	KhiResults := make(plotter.XYs, JLen)
	CvResults := make(plotter.XYs, JLen)

	for Jit := 0; Jit < JLen; Jit++ {

		go func(i int) {
			defer wg.Done()
			J := 0.01 * float64(i)
			Results = IsingModel.MetropolisSimulation(GridL, J, *randGenList[i], MetropolisRuns)
			EResults[i].X = J
			MResults[i].X = J
			CvResults[i].X = J
			KhiResults[i].X = J
			EResults[i].Y = Results[0]
			MResults[i].Y = Results[1]
			CvResults[i].Y = Results[2]
			KhiResults[i].Y = Results[3]

			bar.Add(1)
		}(Jit)
	}

	wg.Wait()
	return [4]plotter.XYs{EResults, MResults, KhiResults, CvResults}

}

func RunAutoCor(GridL int, J float64, MetropolisRuns int) plotter.XYs {

	LagLen := GridL / 2
	bar := progressbar.Default(int64(MetropolisRuns)) // Simple progress bar

	randGen := rand.New(rand.NewSource(time.Now().UnixNano())) // Random generator

	dataXY := make(plotter.XYs, LagLen)
	Grid := IsingModel.InitGrid(GridL, J)

	for run := 0; run < MetropolisRuns; run++ {

		IsingModel.RandomizeGrid(&Grid, randGen)
		IsingModel.MetropolisWalk(&Grid, *randGen, Grid.N*Grid.N)
		for i := 0; i < LagLen; i++ {

			dataXY[i].Y += IsingModel.CalcAutoCor(&Grid, i)
		}

		bar.Add(1)

	}

	for i := 0; i < LagLen; i++ {

		dataXY[i].X = float64(i)
		dataXY[i].Y = dataXY[i].Y / float64(MetropolisRuns)
	}

	return dataXY

}
