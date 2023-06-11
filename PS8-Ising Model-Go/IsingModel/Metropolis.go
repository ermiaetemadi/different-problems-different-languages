// Metropolis alogorithm for Ising Model

package IsingModel

import (
	"math"
	"math/rand"

	"gonum.org/v1/gonum/stat"
)

func MetropolisStep(Grid *IsingGrid, randGen rand.Rand) bool {

	x, y := randGen.Intn(Grid.L), randGen.Intn(Grid.L)
	TransProb := CalcDeltaEProb(Grid, x, y)

	TransAcc := randGen.Float64()

	if TransProb > TransAcc {
		Grid.Space[x][y] *= -1
		return true
	} else {
		return false
	}

}

func MetropolisWalk(Grid *IsingGrid, randGen rand.Rand, Steps int) int {

	AcceptedSteps := 0

	for i := 1; i <= Steps; i++ {

		if MetropolisStep(Grid, randGen) {
			AcceptedSteps += 1
		}
	}

	return AcceptedSteps
}

func MetropolisSimulation(L int, J float64, randGen rand.Rand, Runs int) []float64 {

	N := math.Pow(float64(L), 2)
	Earray := make([]float64, Runs)
	Marray := make([]float64, Runs)
	Onearray := make([]float64, Runs) // Stupid gonum mean func needs a weight array!
	Steps := int(math.Max(math.Floor(math.Exp(8.0*J)*100*N), 100000))

	SimGrid := InitGrid(L, J)

	for i := 0; i < Runs; i++ {

		RandomizeGrid(&SimGrid, &randGen)
		MetropolisWalk(&SimGrid, randGen, Steps)
		Earray[i] = CalcE(&SimGrid)
		Marray[i] = CalcM(&SimGrid)
		Onearray[i] = 1.0

	}

	Results := make([]float64, 4)

	Results[0] = stat.Mean(Earray, Onearray)
	Results[1] = stat.Mean(Marray, Onearray)
	Results[2] = stat.Variance(Earray, Onearray)
	Results[3] = stat.Variance(Marray, Onearray)

	return Results
}
