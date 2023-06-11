package test

import (
	"ermia/IsingModel"
	"ermia/IsingModel/Runners"
	"math/rand"
	"testing"
	"time"
)

func BenchmarkRandGrid(b *testing.B) {

	randGen := rand.New((rand.NewSource(time.Now().UnixNano())))
	TestGrid := IsingModel.InitGrid(200, 1.0)

	for i := 1; i <= b.N; i++ {

		IsingModel.RandomizeGrid(&TestGrid, randGen)
	}
}

func BenchmarkDeltaE(b *testing.B) {

	randGen := rand.New((rand.NewSource(time.Now().UnixNano())))
	TestGrid := IsingModel.InitGrid(200, 1.0)
	IsingModel.RandomizeGrid(&TestGrid, randGen)

	for i := 1; i <= b.N; i++ {
		x := randGen.Intn(TestGrid.L)
		y := randGen.Intn(TestGrid.L)

		IsingModel.CalcDeltaEProb(&TestGrid, x, y)
	}
}

func BenchmarkMetropolis(b *testing.B) {

	randGen := rand.New((rand.NewSource(time.Now().UnixNano())))
	TestGrid := IsingModel.InitGrid(200, 1.0)

	for i := 1; i <= b.N; i++ {
		IsingModel.RandomizeGrid(&TestGrid, randGen)
		IsingModel.MetropolisWalk(&TestGrid, *randGen, 10000000)
	}
}

func BenchmarkObserve(b *testing.B) {

	randGen := rand.New((rand.NewSource(time.Now().UnixNano())))
	TestGrid := IsingModel.InitGrid(200, 1.0)
	IsingModel.RandomizeGrid(&TestGrid, randGen)

	for i := 1; i <= b.N; i++ {
		IsingModel.CalcM(&TestGrid)
		IsingModel.CalcE(&TestGrid)
	}
}

func BenchmarkMetropolisSimulation(b *testing.B) {

	randGen := rand.New((rand.NewSource(time.Now().UnixNano())))

	for i := 1; i <= b.N; i++ {
		IsingModel.MetropolisSimulation(200, 0.44, *randGen, 1)
	}
}

func BenchmarkRunSimLThreads(b *testing.B) {

	// randGen := rand.New((rand.NewSource(time.Now().UnixNano())))

	for i := 1; i <= b.N; i++ {
		Runners.RunSimLThreads(5, 100, 2)
	}
}
