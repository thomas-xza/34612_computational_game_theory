
using Pkg

Pkg.add(["XLSX", "DataFrames", "Plots", "StatsPlots", "StatsBase"])

using XLSX
using Plots, StatsPlots, DataFrames, StatsBase

function main()

    res = DataFrame[]

    xf = XLSX.readxlsx("data.xlsx")

    for sheet in ["Follower_Mk1", "Follower_Mk2", "Follower_Mk3"]

        df = DataFrame(XLSX.readtable("data.xlsx", sheet))

        res = [df, res...]

    end

    plot_distrib_charts(res)

end


function plot_distrib_charts(res)

    edges_set = [
        (1:0.125:2),
        (1:0.05:3.25),
        (-2:0.05:2)
    ]

    for (i, df) in enumerate(res)

        h1 = fit(Histogram, df[!, "Leader's Price"], edges_set[i]).weights
        h2 = fit(Histogram, df[!, "Follower's Price"], edges_set[i]).weights

        labels = ["$i-$(i+20)" for i in edges_set[i][1:end-1]]

        gb = groupedbar(labels,
                        [h1 h2], 
                        label = ["Leader" "Follower"],
                        title = "Price Distribution Comparison",
                        xlabel = "Price Interval",
                        ylabel = "Frequency",
                        bar_width = 0.7)
 
        savefig(gb, "price_distribs_mk$i.pdf")

    end

end


function plot_line_charts(res)

    max_y_lims = [:auto, (-2, 3.5), :auto]

    for (i, df) in enumerate(res)

        transform!(df, ["Leader's Price", "Follower's Price"] => ((lp, fp) -> lp .- fp) => "Diff")
        
        p = plot(df[!, "Date"], df[!, "Leader's Price"], 
             label = "Leader", 
             xlabel = "Date", 
             ylabel = "Price", 
             title = "Price changes over time",
             linewidth = 2)

        # 2. Add the second line to the same plot
        plot!(p,
              df[!, "Date"],
              df[!, "Follower's Price"], 
              label = "Follower", 
              linewidth = 2,
              ylims = max_y_lims[i]
              )
 
        plot!(p,
              df[!, "Date"],
              df[!, "Diff"], 
              label = "Difference", 
              linewidth = 2,
              ylims = max_y_lims[i]
              )
 
        savefig(p, "lines_changes_time_mk$i.pdf")

    end    

end


function plot_diff_data(res)

    ranges = [
        (0.2:0.01:0.7),
        (-1.5:0.03:0.5),
        (-2:0.02:-1)
    ]

    for (i, df) in enumerate(res)
 
        transform!(df, ["Leader's Price", "Follower's Price"] => ((lp, fp) -> lp .- fp) => "Diff")

        h = histogram(df[!, "Diff"],
                      bins=ranges[i],
                      title="Difference between leader and follower price",
                      xlabel="Price interval",
                      ylabel="Frequency")

        savefig(h, "hist_$i.pdf")

    end

end

main()
