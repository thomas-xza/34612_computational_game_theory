
using Pkg

# Pkg.add(["XLSX", "DataFrames", "Plots", "StatsPlots", "StatsBase", "Colors"])

using XLSX
using Plots, StatsPlots, DataFrames, StatsBase, Colors


function main()

    res = DataFrame[]

    xf = XLSX.readxlsx("data.xlsx")

    for sheet in ["Follower_Mk1", "Follower_Mk2", "Follower_Mk3"]

        df = DataFrame(XLSX.readtable("data.xlsx", sheet))

        res = [df, res...]

    end

    plot_distrib_charts_by_time_outer_loop(res)

end


function plot_distrib_charts_by_time_outer_loop(res)
        
    step_set = [0.1, 0.2, 0.4]

    for (i, df) in enumerate(res)

        println(i)

        plot_distrib_charts_by_time(df, string(i), step_set[i])

    end

end


function plot_distrib_charts_by_time(df_full :: DataFrame, file_prefix :: String, step:: Float64)

    gb = groupedbar(String[],
               zeros(0, 2), 
               label = ["Leader" "Follower"],
               title = "Price Distributions",
               xlabel = "Intervals",
               ylabel = "Frequency",
               bar_width = 0.7)
    
    absolute_min = min(minimum(df_full[!, "Leader's Price"]), minimum(df_full[!, "Follower's Price"]))

    floor_min = floor(absolute_min / step) * step

    absolute_max = max(maximum(df_full[!, "Leader's Price"]), maximum(df_full[!, "Follower's Price"]))

    if absolute_max > 25

        absolute_max = 3.25

    end

    floor_max = floor(absolute_max / step) * step

    edges = (floor_min:step:floor_max)

    ##  The above is generic to the dataframe as a whole, before splitting.

    n = 25

    plot_df = DataFrame()

    reds = Dict("Leader" => 1, "Follower" => 0)

    for target in ["Leader", "Follower"]
    
        r, g, b = reds[target], 0, 0

        col_to_plot = "$target's Price"
        
        for (i, start_idx) in enumerate(1:n:nrow(df_full))

            g = 0.1 * i

            b = 0.1 * i

            end_idx = min(start_idx + n - 1, nrow(df_full))
            
            row_set = df_full[start_idx:end_idx, col_to_plot]
            
            h = fit(Histogram, row_set, edges)
            
            centers = [ (edges[j] + edges[j+1]) / 2 for j in 1:length(h.weights) ]
            
            temp_df = DataFrame(
                bin_center = centers,
                counts = h.weights,
                set_label = "Date $start_idx-$end_idx, $target",
                set_colour = RGB(r, g, b)
            )
            append!(plot_df, temp_df)
            
        end

    end

    plot_df.set_colour = parse.(Colorant, plot_df.set_colour)

    unique_data = unique(plot_df[!, [:set_label, :set_colour]])
    group_labels = unique_data.set_label
    group_colors = unique_data.set_colour
    
    println(plot_df)

    # 3. Plot side-by-side using groupedbar
    gb = groupedbar(
        plot_df.bin_center, 
        plot_df.counts, 
        group = plot_df.set_label,
        color = reshape(group_colors, 1, :),
        xlabel = "Price",
        ylabel = "Frequency",
        title = "Distribution over time (of size $n)",
        legend = :outertopright
    )        
    savefig(gb, "price_distribs_split_mk$file_prefix.pdf")

end


function split_df_by_time(df, n)

    split_dfs = [DataFrame(row_group) for row_group in Iterators.partition(eachrow(df), n)]

    return split_dfs

end


function plot_distrib_charts(res, file_prefix)

    for (i, df) in enumerate(res)

        step = 0.025

        absolute_min = min(minimum(df[!, "Leader's Price"]), minimum(df[!, "Follower's Price"]))

        floor_min = floor(absolute_min / step) * step

        absolute_max = max(maximum(df[!, "Leader's Price"]), maximum(df[!, "Follower's Price"]))

        if i == 2

            absolute_max = 3.25

        end

        floor_max = floor(absolute_max / step) * step

        edges = (floor_min:step:floor_max)

        h1 = fit(Histogram, df[!, "Leader's Price"], edges).weights
        h2 = fit(Histogram, df[!, "Follower's Price"], edges).weights

        labels = ["$i" for i in edges[1:end-1]]

        gb = groupedbar(labels,
                        [h1 h2], 
                        label = ["Leader" "Follower"],
                        title = "Price distributions, MK$i",
                        xlabel = "Price Interval",
                        ylabel = "Frequency",
                        xtickfont = 4, 
                        xrotation = 90
                        )
                        # bar_width = 0.7)
 
        savefig(gb, "price_distribs_mk$file_prefix$i.pdf")

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
