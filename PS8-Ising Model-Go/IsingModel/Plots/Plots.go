/* Here we have our plotting tools*/

package Plots

import (
	"ermia/IsingModel"

	"gonum.org/v1/plot"
	"gonum.org/v1/plot/palette/moreland"
	"gonum.org/v1/plot/plotter"
	"gonum.org/v1/plot/plotutil"
	"gonum.org/v1/plot/vg"
	"gonum.org/v1/plot/vg/draw"
)

type plottableGrid struct { // A type for heatmaps
	grid       [][]int
	N          int
	M          int
	resolution float64
	minX       float64
	minY       float64
}

//	GridXYZ interface

func (p plottableGrid) Dims() (c, r int) {
	return p.N, p.M
}

func (p plottableGrid) X(c int) float64 {
	return p.minX + float64(c)*p.resolution
}

func (p plottableGrid) Y(r int) float64 {
	return p.minY + float64(r)*p.resolution
}

func (p plottableGrid) Z(c, r int) float64 {
	return float64(p.grid[c][r])
}

func HeatmapGrid(Grid IsingModel.IsingGrid, Title string) {

	plotData := plottableGrid{
		grid:       Grid.Space,
		N:          Grid.L,
		M:          Grid.L,
		minX:       0,
		minY:       0,
		resolution: 1.0,
	}

	pal := moreland.SmoothBlueRed().Palette(2)
	hm := plotter.NewHeatMap(plotData, pal)

	p := plot.New()

	p.Title.Text = Title
	p.HideAxes()
	p.Add(hm)

	if err := p.Save(40*vg.Inch, 40*vg.Inch, "outputs/"+Title+".png"); err != nil {
		panic(err)
	}

	// if err := p.Save(8*vg.Inch, 8*vg.Inch, "outputs/"+Title+".svg"); err != nil {
	// 	panic(err)
	// }
}

func PlotData(dataXYList []plotter.XYs, Title string, XLabel string, YLabel string, Labels []string, Styles []string) {

	if Styles == nil {
		Styles = make([]string, len(dataXYList))
		for i := range Styles {
			Styles[i] = "lp"
		}
	}

	p1 := plot.New()
	p1.Add(plotter.NewGrid())

	p1.Title.Text = Title
	p1.Title.TextStyle.Font.Size = 0.2 * vg.Inch
	p1.Title.TextStyle.Font.Typeface = "DejaVu Sans"
	p1.X.Label.Text = XLabel
	p1.X.Label.TextStyle.Font.Size = 0.2 * vg.Inch
	p1.Y.Label.Text = YLabel
	p1.Y.Label.TextStyle.Font.Size = 0.2 * vg.Inch

	for i, dataXY := range dataXYList { // line-point style

		if Styles[i] != "lp" {
			continue
		}
		lines, points, err := plotter.NewLinePoints(dataXY)
		if err != nil {
			panic(err)
		}

		lines.Color = plotutil.Color(i)
		points.Color = plotutil.Color(i)
		points.Shape = draw.CircleGlyph{}
		p1.Add(lines, points)
		p1.Legend.Add(Labels[i], lines, points)

	}

	for i, dataXY := range dataXYList { // point style

		if Styles[i] != "p" {
			continue
		}
		points, err := plotter.NewScatter(dataXY)
		if err != nil {
			panic(err)
		}

		points.Color = plotutil.Color(i)
		points.Shape = draw.CircleGlyph{}
		p1.Add(points)
		p1.Legend.Add(Labels[i], points)

	}

	for i, dataXY := range dataXYList { // line style

		if Styles[i] != "l" {
			continue
		}
		lines, err := plotter.NewLine(dataXY)
		if err != nil {
			panic(err)
		}

		lines.Color = plotutil.Color(i)
		p1.Add(lines)
		p1.Legend.Add(Labels[i], lines)

	}

	p1.Legend.Left = true
	if Title != "Energy" {
		p1.Legend.Top = true
	}

	// Save the plot to a PNG file.
	if err := p1.Save(8*vg.Inch, 8*vg.Inch, "outputs/"+Title+".png"); err != nil {
		panic(err)
	}
}
