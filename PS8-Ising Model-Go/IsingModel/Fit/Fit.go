// We define functions for linear and non-linear fits

package Fit

import (
	"math"

	"gonum.org/v1/gonum/mat"
	"gonum.org/v1/plot/plotter"
)

func FindMax(dataXY plotter.XYs) int { // We can find Tc in Cv or Khi by the FindMax

	Max := -math.MaxFloat64
	ArgMax := 0

	for i, point := range dataXY {

		if point.Y > Max {

			Max = dataXY[i].Y
			ArgMax = i
		}
	}

	return ArgMax
}

func FindMin(dataXY plotter.XYs) int {

	Min := math.MaxFloat64
	ArgMin := 0

	for i, point := range dataXY {

		if point.Y < Min {

			Min = dataXY[i].Y
			ArgMin = i
		}
	}

	return ArgMin
}

func FindMid(dataXY plotter.XYs) int { // Returns the closest place with Ym = (Max - Min) / 2

	Max := dataXY[FindMax(dataXY)].Y
	Min := dataXY[FindMin(dataXY)].Y
	Mid := (Max - Min) / 2

	Distance := math.MaxFloat64
	ArgMid := 0

	for i, point := range dataXY {

		TempDistance := math.Abs(point.Y - Mid)
		if TempDistance < Distance {
			Distance = TempDistance
			ArgMid = i
		}
	}

	return ArgMid
}

func FindTc(dataXYList [4]plotter.XYs) [3]int { // Finds Tc by Magnetization, Heat Capacity and Susceptibility

	MagTc := FindMid(dataXYList[1])
	CvTc := FindMax(dataXYList[2])
	KhiTc := FindMax(dataXYList[3])

	return [3]int{MagTc, CvTc, KhiTc}

}

func LineFit(dataXY plotter.XYs) [2]float64 {

	JLen := len(dataXY)
	A := mat.NewDense(JLen, 2, nil)

	for i := 0; i < JLen; i++ {

		A.Set(i, 0, 1.0)
		A.Set(i, 1, dataXY[i].X)
	}

	b := mat.NewDense(JLen, 1, nil)

	for i := 0; i < JLen; i++ {

		b.Set(i, 0, dataXY[i].Y)
	}

	para := mat.NewDense(2, 1, nil)
	err := para.Solve(A, b)

	if err != nil {
		panic(err)
	}

	return [2]float64{para.At(0, 0), para.At(1, 0)}
}

func LogData(dataXY plotter.XYs) plotter.XYs { // Takes logarithm of dataXY

	JLen := len(dataXY)
	LogDataXY := make(plotter.XYs, JLen)

	for i := 0; i < JLen; i++ {

		LogDataXY[i].X = math.Log(dataXY[i].X)
		LogDataXY[i].Y = math.Log(dataXY[i].Y)
	}

	return LogDataXY

}

func LogFit(dataXY plotter.XYs) [2]float64 {

	LogDataXY := LogData(dataXY)

	return LineFit(LogDataXY)

}

func DrawLine(para [2]float64, x0 float64, xn float64, JLen int) plotter.XYs { // Draws a line from x0 to xn with para

	dataXY := make(plotter.XYs, JLen)

	x := 0.0
	y := 0.0
	steps := (xn - x0) / float64(JLen)

	for i := 0; i < JLen; i++ {
		x = x0 + float64(i)*steps
		y = para[0] + para[1]*x

		dataXY[i].X = x
		dataXY[i].Y = y
	}

	return dataXY
}

func DataAroundTc(dataXY plotter.XYs, Jc float64) plotter.XYs { // Transforms J to |T - Tc|

	JLen := len(dataXY)
	NewdataXY := make(plotter.XYs, JLen)

	for i := 0; i < JLen; i++ {

		NewdataXY[i].X = math.Abs(1/dataXY[i].X - 1/Jc)
		NewdataXY[i].Y = dataXY[i].Y
	}

	return NewdataXY
}

func CalcCritExp(dataXY [4]plotter.XYs, offset int) [6]float64 { // Calculates critical exponents

	JcList := FindTc(dataXY)
	Jc := JcList[1] // We use the Jc found by Cv maximum

	Beta1 := -LogFit(DataAroundTc(dataXY[1][Jc-offset:Jc-1], dataXY[1][Jc].X))[1]
	Beta2 := -LogFit(DataAroundTc(dataXY[1][Jc+1:Jc+offset], dataXY[1][Jc].X))[1]

	Alpha1 := -LogFit(DataAroundTc(dataXY[2][Jc-offset:Jc-1], dataXY[2][Jc].X))[1]
	Alpha2 := -LogFit(DataAroundTc(dataXY[2][Jc+1:Jc+offset], dataXY[2][Jc].X))[1]

	Gamma1 := -LogFit(DataAroundTc(dataXY[3][Jc-offset:Jc-1], dataXY[3][Jc].X))[1]
	Gamma2 := -LogFit(DataAroundTc(dataXY[3][Jc+1:Jc+offset], dataXY[3][Jc].X))[1]

	return [6]float64{Beta1, Beta2, Alpha1, Alpha2, Gamma1, Gamma2}

}
