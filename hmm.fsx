#r "nuget: Deedle"

open Deedle

[<Literal>]
let path = __SOURCE_DIRECTORY__ + "/data copy.csv"

let schema = "Hidden(string),Visible(int)"
let df_csv = Frame.ReadCsv(path, hasHeaders=true, inferTypes=true, inferRows = 1)

df_csv |> Frame.indexRowsString("K")
       |> Frame.getCol "Y"
       |> Series.get "Grumpy"

df_csv?Hidden
df_csv?Visible

df_csv.Format() |> printfn "%s"
df_csv.ColumnTypes |> Seq.iter(printfn "%A")

df_csv.ColumnKeys

df = df_csv.Columns.[["Hidden"; "Visible"]] 

df.GetColumn<string>("Hidden") |> Series.applyLevel fst (fun s -> series (Seq.co))

printf "%s" DataFilePath

let t = snd (1,2)
