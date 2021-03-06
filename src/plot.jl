"""Plot points with a specified glyph using its integer code.

Integer code range: [0,31]
"""
function scatter{T<:Real}(x::AbstractVector{T}, y::AbstractVector{T}, g::Int32=Int32(23))
    @assert length(x) == length(y) "Number of point should be equal for each axis"
    plpoin(length(x), collect(x), collect(y), g)
end

"""Plot points with a specified glyph as character.

Available glyphs: '⚪','◯','⊙','⭒','⊕','+','×','□','*','✠','⋅','∙','✶','⋄','✽','∘','▵','▪','⋆','⚬','▢','▴','◦','⌑','▫'
"""
function scatter{T<:Real}(x::AbstractVector{T}, y::AbstractVector{T}, g::Char)
    hc =  get(Hershey, g, Int32(23))
    scatter(x, y, hc)
end

"""Draws line defined by in x and y. """
function lines{T<:Real}(x::AbstractVector{T}, y::AbstractVector{T})
    @assert length(x) == length(y) "Number of point should be equal for each axis"
    plline(length(x), collect(x), collect(y))
end

"""Generic X-Y Plotting. Accepts the coordinates of points in the plot.

Keyword parameters:

- 'typ': Type of plot should be drawn. Possible types are ':point', ':line', ':overlay'. Default type is ':point'

- 'pch': Either an integer specifying a symbol or a single character glyph to be used as the default in plotting points.
    - Integer range is [0,31].
    - Avalible glyphs: '⚪','◯','⊙','⭒','⊕','+','×','□','*','✠','⋅','∙','✶','⋄','✽','∘','▵','▪','⋆','⚬','▢','▴','◦','⌑','▫'.
    - Defaul value is '◯' or 23.

- 'col': Color index from Color Map0 (range [0,15])

- 'env': Perform standard window and draw box setup. Defaul value is 'true'.

Example:
```
    draw(:xwin) do opts
       plot(rand(10), pch='⋄', typ=:overlay, col=15)
    end
```
"""
function plot{T<:Real}(x::AbstractVector{T}, y::AbstractVector{T}; kvopts...)
    @assert length(x) == length(y) "Number of point should be equal for each axis"

    xmin, xmax = extrema(x)
    ymin, ymax = extrema(y)

    # parse KV parameters
    opts = Dict(kvopts)
    axis_scale = get(opts, :axis_scale, Independent)
    axis_box   = get(opts, :axis_box, Default)
    txspec, tyspec = AxisBoxParams[Int32(axis_box)]
    xmin       = get(opts, :xmin, xmin)
    xmax       = get(opts, :xmax, xmax)
    ymin       = get(opts, :ymin, ymin)
    ymax       = get(opts, :ymax, ymax)
    xspec      = get(opts, :xspec, txspec)
    xmajorint  = get(opts, :xmajorint, 0.0)
    xminornum  = get(opts, :xminornum, 0)
    yspec      = get(opts, :yspec, tyspec)
    ymajorint  = get(opts, :ymajorint, 0.0)
    yminornum  = get(opts, :yminornum, 0)
    xyratio    = get(opts, :xyratio, 0.0)
    xminvp     = get(opts, :xminvp, 0.18)
    xmaxvp     = get(opts, :xmaxvp, 0.88)
    yminvp     = get(opts, :yminvp, 0.15)
    ymaxvp     = get(opts, :ymaxvp, 0.85)
    ptype      = get(opts, :typ, :point)
    boxcolor   = Int32(get(opts, :boxcol, 1))
    overlay    = get(opts, :overlay, false)
    pen        = get(opts, :pen, 1.)
    xtitle     = get(opts, :xlab, "")
    ytitle     = get(opts, :ylab, "")
    title      = get(opts, :title, "")
    datacolor  = get(opts, :col, 1)
    datacolor  = isa(datacolor, Integer) || datacolor > 1 ? round(PLINT, datacolor) : convert(PLFLT, datacolor)

    hc = Int32(23)
    drawpoints = false
    if :pch in keys(opts)
        val = opts[:pch]
        hc = if isa(val, Char)
            get(Hershey, val, hc)
        elseif isa(val, Integer)
            Int32(val)
        end
        drawpoints = true
    end

    # setup environment
    if !overlay
        plcol0(boxcolor)

        if get(opts, :env, true)
            plenv(xmin, xmax, ymin, ymax, Int32(axis_scale), Int32(axis_box))
        else
            # advance page
            pladv(0)

            # set world coordinates of viewport boundaries
            plvpas( xminvp, xmaxvp, yminvp, ymaxvp, xyratio )

            # set world coordinates of viewport boundaries
            plwind( xmin, xmax, ymin, ymax )

            # set box parameters
            length(xspec)>0 && length(yspec)>0 && plbox(xspec, xmajorint, xminornum, yspec, ymajorint, yminornum)
        end
    end

    if isa(datacolor, PLINT)
        plcol0(datacolor)
    else
        plcol1(datacolor)
    end
    pen != 1.0 && plwidth(pen) # set pen widths if available

    # plot points
    (ptype == :point || drawpoints) && scatter(x, y, hc)
    ptype == :line  && lines(x, y)

    !all(isempty, [title, xtitle, ytitle]) && labels(xtitle, ytitle, title)

    pen != 1.0 && plwidth(1.) # reset pen widths
    return
end

function plot{T<:Real}(y::AbstractVector{T}; kvopts...)
    x = linspace(1, length(y), length(y))
    plot(x, y; kvopts...)
end

function plot{T<:Real}(x::AbstractVector{T}, ys::AbstractMatrix{T}; kvopts...)
    opts = Dict(kvopts)
    nplots = size(ys,2)
    kopts = keys(opts)

    colors = if haskey(opts, :col)
        col = pop!(opts, :col)
        @assert length(col) == nplots "Number of colors should correspond to number of graphs"
        col
    else
        skip = :boxcol in kopts ? opts[:boxcol] : 0
        colorindexes(nplots, skip)
    end

    plotglyphs = false
    glyphs = if haskey(opts, :pch)
        plotglyphs = true
        pch = pop!(opts, :pch)
        @assert length(pch) == nplots "Number of point glyphs should correspond to number of graphs"
        pch
    else
        colorindexes(nplots)
    end

    xmin, xmax = extrema(x)
    ymin, ymax = extrema(ys)

    pkvopts = Tuple{Symbol,Any}[(k,v) for (k,v) in opts]
    plotglyphs = plotglyphs || !(haskey(opts, :typ) && opts[:typ] == :line)
    for i in 1:nplots
        plotglyphs && push!(pkvopts, (:pch, glyphs[i]))
        plot(x, ys[:,i]; col=colors[i],
             xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax,
             overlay=(i!=1), pkvopts...)
        plotglyphs && pop!(pkvopts)
    end
end

function plot{T<:Real}(xs::AbstractMatrix{T}, ys::AbstractMatrix{T}; kvopts...)
    opts = Dict(kvopts)
    nplots = size(ys,2)

    @assert size(xs) == size(ys) "Number of points should be the same for both dimensions"

    colors = if :col in keys(opts)
        col = pop!(opts, :col)
        @assert length(col) == nplots "Number of colors should correspond to number of graphs"
        col
    else
        colorindexes(nplots)
    end

    glyphs = if :pch in keys(opts)
        pch = pop!(opts, :pch)
        @assert length(pch) == nplots "Number of point glyphs should correspond to number of graphs"
        pch
    else
        [Int32(i%32) for i in 0:nplots]
    end

    xmin, xmax = extrema(xs)
    ymin, ymax = extrema(ys)

    pkvopts = [(k,v) for (k,v) in opts]
    for i in 1:nplots
        plot(xs[:,i], ys[:,i]; col=colors[i], pch=glyphs[i],
             xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax,
             overlay=(i!=1), pkvopts...)
    end
end

"""Plot multiple overlaying graphs from matrix columns.
Example:
```
    draw(:xwin) do opts
       plot(rand(10,3), pch=['⋄','⊕','▴'])
    end
```
"""
function plot{T<:Real}(ys::AbstractMatrix{T}; kvopts...)
    npts = size(ys,1)
    x = linspace(1, npts, npts)
    plot(x, ys; kvopts...)
end

"""Wrapper function for combines 'draw' and 'plot' calls.
Example:
```
    plot(:xwin, rand(10))
```
"""
function plot(drv::Symbol, opts...; kvopts...)
    draw(drv; kvopts...) do dopts
        plot(opts...; dopts...)
    end
end


plot!{T<:Real}(x::AbstractVector{T}, y::AbstractVector{T}; kvopts...) = plot(x, y; overlay=true, kvopts...)
plot!{T<:Real}(y::AbstractVector{T}; kvopts...) = plot(y; overlay=true, kvopts...)
plot!{T<:Real}(x::AbstractVector{T}, ys::AbstractMatrix{T}; kvopts...) = plot(x, ys; overlay=true, kvopts...)
plot!{T<:Real}(xs::AbstractMatrix{T}, ys::AbstractMatrix{T}; kvopts...) = plot(xs, ys; overlay=true, kvopts...)
plot!{T<:Real}(ys::AbstractMatrix{T}, kvopts...) = plot(xs; overlay=true, kvopts...)
