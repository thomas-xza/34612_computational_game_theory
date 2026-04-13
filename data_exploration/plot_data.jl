
using Pkg

# Pkg.add(["XLSX", "DataFrames", "Plots", "StatsPlots", "StatsBase", "Colors"])
# Pkg.add(["ShiftedArrays"])

using XLSX
using Plots, StatsPlots, DataFrames, StatsBase, Colors, ShiftedArrays


##  Demand function (in Jupyter): (u_L - c_L) * (2 - u_L + 0.3 u_F)

##  Demand function (in spec): (u_L - c_L) * (100 - 5 * u_L + 3 * u_F)


function main()

    res = DataFrame[]

    xf = XLSX.readxlsx("data.xlsx")

    for sheet in ["Follower_Mk1", "Follower_Mk2", "Follower_Mk3"]

        df = DataFrame(XLSX.readtable("data.xlsx", sheet))

        res = [df, res...]

    end

    plot_profitability_leader_price_deriv(
        res,
        parse(Int, ARGS[1])
    )
    
end


function plot_profitability_leader_price_2nd_deriv(res)

    ranges = [(:auto, :auto), (:auto, :auto), (:auto, :auto)]

    for (i, df) in enumerate(res)

        transform!(df, ["Leader's Price", "Follower's Price", "Cost"] =>
            ((lp, fp, c) -> (lp .- c) .* (100 .- 5 .* lp .+ 3 .* fp)) => "Profit")

        df[!, "Leader's Price diff"] = [0; diff(df[!, "Leader's Price"])]
 
        df[!, "Leader's Price 2nd deriv"] = [0; diff(df[!, "Leader's Price diff"])]
 
        df[!, "Profit diff"] = [0; diff(df[!, "Profit"])]

        df[!, "Profit 2nd deriv"] = [0; diff(df[!, "Profit diff"])]
 
        println(df)

        p = plot(df[!, "Leader's Price 2nd deriv."],
                 df[!, "Profit 2nd deriv."],
                 title = "2nd derivatives: profitability, leader's price",
                 xlabel = "Leader's price 2nd deriv.",
                 ylabel = "Profit 2nd deriv.",
                 ylims = ranges[i],
                 label="MK$(i)",
                 seriestype = :scatter)

        savefig(p, "profitability_leader_price_$(i)_pdf_demand_model_2nd_deriv.pdf")

    end

end


function plot_profitability_leader_price_deriv(res, n :: Int)

    ranges = [(:auto, :auto), (:auto, 90), (:auto, :auto)]

    for (i, df) in enumerate(res)

        ##  Demand function (in Jupyter): (u_L - c_L) * (2 - u_L + 0.3 u_F)

        ##  Demand function (in spec): (u_L - c_L) * (100 - 5 * u_L + 3 * u_F)

        transform!(df, ["Leader's Price", "Follower's Price", "Cost"] =>
            ((lp, fp, c) -> (lp .- c) .* (100 .- 5 .* lp .+ 3 .* fp)) => "Profit")

        df[!, "Leader's Price diff"] = [0; diff(df[!, "Leader's Price"])]

        df[!, "Leader's Price last $(n) avg."] = Float64.(rolling_sum_n(df[!, "Leader's Price diff"], n))
 
        df[!, "Profit diff"] = [0; diff(df[!, "Profit"])]

        df[!, "Profit last $(n) avg."] = Float64.(rolling_sum_n(df[!, "Profit diff"], n))
 
        # println(df)

        p = plot(df[!, "Leader's Price last $(n) avg."],
                 df[!, "Profit last $(n) avg."],
                 title = "Avg. of last $(n) differences: profitability, leader's price",
                 xlabel = "Leader's price, avg. of last $(n) diff",
                 ylabel = "Profit diff, avg. of last $(n) diff.",
                 ylims = ranges[i],
                 label="MK$(i)",
                 seriestype = :scatter)

        savefig(p, "profitability_leader_price_$(i)_pdf_demand_deriv_avg_of_last_$(n)_diff.pdf")

    end

end


function rolling_sum_n(v, n :: Int)
    
    res = fill(Float64(0), length(v))

    for i in n:length(v)

        for j in 0:(n - 1)
        
            res[i] += v[i - j]

            # println(res[i])

        end

        res[i] = res[i] / n
        
    end
    
    return res
    
end


function plot_profitability_over_time(res)

    ranges = [(:auto, :auto), (:auto, 90), (:auto, :auto)]

    for (i, df) in enumerate(res)

        ##  Demand function (in Jupyter): (u_L - c_L) * (2 - u_L + 0.3 u_F)

        ##  Demand function (in spec): (u_L - c_L) * (100 - 5 * u_L + 3 * u_F)

        transform!(df, ["Leader's Price", "Follower's Price", "Cost"] =>
            ((lp, fp, c) -> (lp .- c) .* (100 .- 5 .* lp .+ 3 .* fp)) => "Profit")

        println(df)

        p = plot(df[!, "Date"],
                 df[!, "Profit"],
                 title = "Correlation between profitability and date (MK$i)",
                 xlabel = "Date",
                 ylabel = "Profit",
                 ylims = ranges[i],
                 seriestype = :line)

        savefig(p, "profitability_over_time_$(i)_pdf_demand_model.pdf")

    end

end


function plot_profitability_leader_price(res)

    ranges = [(:auto, :auto), (:auto, 90), (:auto, :auto)]

    for (i, df) in enumerate(res)

        ##  Demand function (in Jupyter): (u_L - c_L) * (2 - u_L + 0.3 u_F)

        ##  Demand function (in spec): (u_L - c_L) * (100 - 5 * u_L + 3 * u_F)

        transform!(df, ["Leader's Price", "Follower's Price", "Cost"] =>
            ((lp, fp, c) -> (lp .- c) .* (100 .- 5 .* lp .+ 3 .* fp)) => "Profit")

        println(df)

        p = plot(df[!, "Leader's Price"],
                 df[!, "Profit"],
                 title = "Correlation between profitability and leader's price (MK$i)",
                 xlabel = "Leader's price",
                 ylabel = "Profit",
                 ylims = ranges[i],
                 seriestype = :scatter)

        savefig(p, "profitability_leader_price_$(i)_pdf_demand_model.pdf")

    end

end


function plot_distrib_charts_by_time_outer_loop(res)
        
    step_set = [0.06, 0.25, 0.25]

    for (i, df) in enumerate(res)

        println(i)

        plot_distrib_charts_by_time(df, string(i), step_set[i])

    end

end


function plot_distrib_charts_by_time(df_full :: DataFrame, file_prefix :: String, step :: Float64)
    
    absolute_min = min(minimum(df_full[!, "Leader's Price"]), minimum(df_full[!, "Follower's Price"]))

    floor_min = floor(absolute_min / step) * step

    absolute_max = max(maximum(df_full[!, "Leader's Price"]), maximum(df_full[!, "Follower's Price"]))

    println(absolute_max)

    if absolute_max > 25

        absolute_max = 3.25

    end

    ceil_max = ceil(absolute_max / step) * (step)

    edges = (floor_min:step:ceil_max)

    ##  The above is generic to the dataframe as a whole, before splitting.

    n = 25

    plot_df = DataFrame()

    reds = Dict("Leader" => 1, "Follower" => 0)

    for target in ["Leader", "Follower"]
    
        r, g, b = reds[target], 0, 0

        col_to_plot = "$target's Price"
        
        for (i, start_idx) in enumerate(1:n:nrow(df_full))

            g = 0.2 * i

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

    println(group_labels)
    
    println(group_colors)
    
    println(plot_df)

    # 3. Plot side-by-side using groupedbar
    gb = groupedbar(
        plot_df.bin_center, 
        plot_df.counts, 
        group = plot_df.set_label,
        color = plot_df.set_colour,
        xlabel = "Price intervals",
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
