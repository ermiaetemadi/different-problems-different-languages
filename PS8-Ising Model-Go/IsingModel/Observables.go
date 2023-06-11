package IsingModel

import "math"

func CalcM(Grid *IsingGrid) float64 {

	Mag := 0

	for x := 1; x < Grid.L; x++ {
		for y := 1; y < Grid.L; y++ {

			Mag += Grid.Space[x][y]
		}
	}

	return math.Abs(float64(Mag)) / float64(Grid.N)
}

func CalcE(Grid *IsingGrid) float64 {

	L := Grid.L
	Eng := 0

	var left, right, up, down int

	for x := 1; x < L; x++ {
		for y := 1; y < L; y++ {

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

			Eng += -Grid.Space[x][y] * (Grid.Space[x][up] + Grid.Space[x][down] + Grid.Space[right][y] + Grid.Space[left][y])
		}
	}

	return float64(Eng) * Grid.J / float64(Grid.N)
}

func CalcAutoCor(grid *IsingGrid, lag int) float64 {

	L := grid.L
	N := grid.N
	MeanSum := 0
	CorSum := 0.0
	VarSum := 0.0

	for i := 0; i < L; i++ {
		for j := 0; j < L; j++ {

			MeanSum += grid.Space[i][j]
		}
	}

	Mean := float64(MeanSum) / float64(N)

	for i := 0; i < L; i++ {
		for j := 0; j < L; j++ {

			VarSum += math.Pow(float64(grid.Space[i][j])-Mean, 2)
			CorSum += (float64(grid.Space[i][j]) - Mean) * (float64(grid.Space[(i+lag)%L][j]) - Mean)
		}
	}

	return CorSum / VarSum

}
