// Helper functions that handle file oprations

package Runners

import (
	"encoding/csv"
	"os"
	"strconv"

	"gonum.org/v1/plot/plotter"
)

func WriteToCSV(dataXY [4]plotter.XYs, filename string) {

	JLen := len(dataXY[0])

	// Open the file
	file, err := os.Create("./data/" + filename)
	if err != nil {
		panic(err)
	}

	// Initialize the writer
	writer := csv.NewWriter(file)

	for i := 0; i < JLen; i++ {

		J := strconv.FormatFloat(dataXY[0][i].X, 'f', -1, 64)
		E := strconv.FormatFloat(dataXY[0][i].Y, 'f', -1, 64)
		M := strconv.FormatFloat(dataXY[1][i].Y, 'f', -1, 64)
		Cv := strconv.FormatFloat(dataXY[2][i].Y, 'f', -1, 64)
		Khi := strconv.FormatFloat(dataXY[3][i].Y, 'f', -1, 64)

		record := [5]string{J, E, M, Cv, Khi}

		err = writer.Write(record[:])
		if err != nil {
			panic(err)
		}

		writer.Flush()       // Writes the buffered data to the writer
		err = writer.Error() // Checks if any error occurred while writing
		if err != nil {
			panic(err)
		}

	}
}

func ReadCSV(filename string) [4]plotter.XYs {

	file, err := os.Open("./data/" + filename)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	RecordsList, err := reader.ReadAll()
	if err != nil {
		panic(err)
	}

	JLen := len(RecordsList)

	EResults := make(plotter.XYs, JLen)
	MResults := make(plotter.XYs, JLen)
	KhiResults := make(plotter.XYs, JLen)
	CvResults := make(plotter.XYs, JLen)

	var recordFloat [5]float64

	for i, record := range RecordsList {

		for j := 0; j < 5; j++ {
			recordFloat[j], err = strconv.ParseFloat(record[j], 64)

			if err != nil {
				panic(err)
			}

			EResults[i].X = recordFloat[0]
			MResults[i].X = recordFloat[0]
			CvResults[i].X = recordFloat[0]
			KhiResults[i].X = recordFloat[0]
			EResults[i].Y = recordFloat[1]
			MResults[i].Y = recordFloat[2]
			CvResults[i].Y = recordFloat[3]
			KhiResults[i].Y = recordFloat[4]
		}

	}

	return [4]plotter.XYs{EResults, MResults, KhiResults, CvResults}
}
