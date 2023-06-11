/* This files contains the IsingModel module core types and functions which is very POG */

package IsingModel

import (
	"math"
	"math/rand"
	"time"
)

type IsingGrid struct {
	L       int       // Grid length
	N       int       // Number of cells N=L^2
	J       float64   // J
	Space   [][]int   // Grid
	ExpVals []float64 // Calculated values of exp(-Jx)
}

func InitGrid(L int, J float64) IsingGrid {

	if L <= 0 {
		panic("Error: Unvalid L")
	}

	Vals := []float64{-8.0 * J, -4.0 * J, 0.0 * J, 4.0 * J, 8.0 * J}
	expVals := make([]float64, 5)

	for i := range expVals {
		expVals[i] = math.Exp(Vals[i])
	}

	emptyArr := make([][]int, L)

	for i := range emptyArr {
		emptyArr[i] = make([]int, L)
	}

	return IsingGrid{L, L * L, J, emptyArr, expVals}
}

func RandomizeGrid(Grid *IsingGrid, randGen *rand.Rand) {

	if randGen == nil {
		randGen = rand.New(rand.NewSource(time.Now().UnixNano()))
	}

	for i := 0; i < Grid.L; i++ {
		for j := 0; j < Grid.L; j++ {
			Grid.Space[i][j] = 2*randGen.Intn(2) - 1
		}
	}

}

func CalcDeltaEProb(Grid *IsingGrid, x int, y int) float64 {

	// First applying the boundray conditions

	L := Grid.L
	var left, right, up, down int

	if x == 0 {
		left = L - 1
	} else {
		left = x - 1
	}

	if x == L-1 {
		right = 0
	} else {
		right = x + 1
	}

	if y == 0 {
		down = L - 1
	} else {
		down = y - 1
	}

	if y == L-1 {
		up = 0
	} else {
		up = y + 1
	}

	DeltaIndex := -Grid.Space[x][y] * (Grid.Space[x][up] + Grid.Space[x][down] + Grid.Space[right][y] + Grid.Space[left][y])
	DeltaIndex = DeltaIndex/2 + 2

	return Grid.ExpVals[DeltaIndex]
}
