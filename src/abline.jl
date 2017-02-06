# AB line

"Adds a+bx... straight line over the current plot"
function abline!(;a=NaN, b=NaN, v=NaN, h=NaN, kwargs...)
    vp = PLplot.getviewport(:world)
    xpts = Float64[]
    ypts = Float64[]

    if !isnan(a) || !isnan(b)
        push!(xpts, vp[:xmin])
        push!(xpts, vp[:xmax])
        ypts = [(isnan(b) ? 0. : b) + (isnan(a) ? 0. : a)*x for x in xpts]
    elseif !isnan(v)
        push!(xpts, v)
        push!(xpts, v)
        push!(ypts, vp[:ymin])
        push!(ypts, vp[:ymax])
    elseif !isnan(h)
        push!(xpts, vp[:xmin])
        push!(xpts, vp[:xmax])
        push!(ypts, h)
        push!(ypts, h)
    end

    # If added line
    if length(xpts) > 0
        PLplot.plot!(xpts, ypts; typ=:line, kwargs...)
    end
end
