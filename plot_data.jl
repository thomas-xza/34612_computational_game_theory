
using Pkg

 # Pkg.add(["XLSX", "DataFrames", "Plots"])

using XLSX
using Plots, DataFrames


function main()

    res = DataFrame[]

    xf = XLSX.readxlsx("data.xlsx")

    for sheet in ["Follower_Mk1", "Follower_Mk2", "Follower_Mk3"]

        df = DataFrame(XLSX.readtable("data.xlsx", sheet))

        res = [df, res...]

    end

    for (i, df) in enumerate(res)
 
        transform!(df, ["Leader's Price", "Follower's Price"] => ((lp, fp) -> lp .- fp) => "Diff")

        h = histogram(df[!, "Diff"], bins=32, title="Distribution of Scores", xlabel="Interval", ylabel="Frequency")

        savefig(h, "hist_$i.pdf")

    end

end

main()
