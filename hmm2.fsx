#r "nuget: FSharp.Data"
#r "nuget: XPlot.Plotly"

open FSharp.Data
open System.IO
open XPlot.Plotly

// https://devblogs.microsoft.com/dotnet/an-introduction-to-dataframe/
// https://dev.to/samueleresca/data-analysis-using-f-and-jupyter-notebook-k97

[<CLIMutable>]
type DataRow = {
        Hidden : string
        Visible: int
    }

let path = Path.Combine(__SOURCE_DIRECTORY__,"data.csv")
let stream = File.Open(path, FileMode.Open)
let csv_data = CsvFile.Load(stream, separators = ",", quote = '"', hasHeaders= true)

let data =
       csv_data.Rows
       |> Seq.map (fun row -> { Hidden = (row.GetColumn "Hidden")
                                Visible = (row.GetColumn "Visible") |> int
                            })

data
       |> Seq.map(fun row -> row.Hidden)
       |> Seq.countBy id |> Seq.toList 
        |> Chart.Pie
        |> Chart.WithTitle "Dataset by Genre"
        |> Chart.WithLegend true
stream.Close()