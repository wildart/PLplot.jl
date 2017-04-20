"""Plot points with a specified glyph using its integer code.

    Integer code range: [0,31]
"""
function scatter3{T<:AbstractFloat}(x::AbstractVector{T}, y::AbstractVector{T}, z::AbstractVector{T}, g::Int32=Int32(23))
    @assert length(x) == length(y) == length(z) "Number of point should be equal for each axis"
    plpoin3(length(x), collect(x), collect(y), collect(z), g)
end

"""Plot points with a specified glyph as character.
"""
function scatter3{T<:AbstractFloat}(x::AbstractVector{T}, y::AbstractVector{T}, z::AbstractVector{T}, g::Char)
    hc =  get(PLplot.hershey, g, Int32(23))
    scatter3d(x, y, z, hc)
end

"""Draws line in 3 space defined by in x, y and z.
"""
function lines3{T<:AbstractFloat}(x::AbstractVector{T}, y::AbstractVector{T}, z::AbstractVector{T})
    @assert length(x) == length(y) == length(z) "Number of point should be equal for each axis"
    plline3(length(x), collect(x), collect(y), collect(z))
end

"""Plots a three dimensional surface plot
"""
function mesh3d{T<:AbstractFloat}(x::AbstractVector{T}, y::AbstractVector{T}, z::Matrix{T}; kvopts...)
    mesh3d(collect(x), collect(y), [z[:,i] for i in 1:size(z,2)], opt3d=opt3d, kvopts...)
end

"""Plots a surface mesh

  Optinal parameter:
  - **sides**, indicates whether or not sides should be draw on the figure. Values: **true** or **false**.
  - **contour**, array that defines the contour level spacing.
"""
function mesh3d{T<:AbstractFloat}(x::Vector{T}, y::Vector{T}, z::Vector{Vector{T}}; kvopts...)
    @assert length(x) == length(z) "Number of rows in 'z' should be equal to elements in 'x'"
    @assert length(y) == length(z[1]) "Number of columns in 'z' should be equal to elements in 'y'"

    sides = -1
    opt3d = Cint(DRAW_LINEXY)
    contour = nothing
    for (ko, kv) in kvopts
        if ko == :sides
            sides = convert(Cint, kv)
        elseif ko == :contour
            if isa(kv, Vector{PLFLT}) 
                contour = kv
            end
        elseif ko == :opt3d
            opt3d = convert(Cint, kv)
        end
    end

    if contour === nothing
        if sides < 0
            plmesh(collect(x), collect(y), z, length(x), length(y), opt3d)
        else
            plot3d(collect(x), collect(y), z, length(x), length(y), opt3d, Cint(sides))
        end
    else
        plmeshc(collect(x), collect(y), z, length(x), length(y), opt3d, contour, length(contour))
    end
end

"""Generic 3D Plotting. Accepts the coordinates of points in the plot.

Keyword parameters:

- 'typ': Type of plot should be drawn. Possible types are ':point', ':line', ':overlay'. Default type is ':point'

- 'pch': Either an integer specifying a symbol or a single character glyph to be used as the default in plotting points.
    - Integer range is [0,31].
    - Avalible glyphs: '⚪','◯','⊙','⭒','⊕','+','×','□','*','✠','⋅','∙','✶','⋄','✽','∘','▵','▪','⋆','⚬','▢','▴','◦','⌑','▫'.
    - Defaul value is '◯' or 23.

- 'col': Color index from Color Map0 (range [0,15])

Example:
```
    draw(:xwin) do opts
       plot3(rand(3, 10), pch='⋄', col=15)
    end
```
"""
function plot3{T<:AbstractFloat}(x::AbstractVector{T}, y::AbstractVector{T}, z::AbstractVector{T}; kvopts...)
    # get extreme points
    xmin, xmax = extrema(x)
    ymin, ymax = extrema(y)
    zmin, zmax = extrema(y)

    # parse KV parameters
    opts = Dict(kvopts)
    xmin       = get(opts, :xmin, xmin)
    xmax       = get(opts, :xmax, xmax)
    ymin       = get(opts, :ymin, ymin)
    ymax       = get(opts, :ymax, ymax)
    zmin       = get(opts, :zmin, zmin)
    zmax       = get(opts, :zmax, zmax)
    xspec      = get(opts, :xspec, "bnstu")
    xlabel     = get(opts, :xlabel, "x axis")
    xmajorint  = get(opts, :xmajorint, 0.0)
    xminornum  = get(opts, :xminornum, 0)
    yspec      = get(opts, :yspec, "bnstu")
    ylabel     = get(opts, :ylabel, "y axis")
    ymajorint  = get(opts, :ymajorint, 0.0)
    yminornum  = get(opts, :yminornum, 0)
    zspec      = get(opts, :zspec, "bcdmnstuv")
    zlabel     = get(opts, :zlabel, "z axis")
    zmajorint  = get(opts, :zmajorint, 0.0)
    zminornum  = get(opts, :zminornum, 0)
    xminvp     = get(opts, :xminvp, 0.0)
    xmaxvp     = get(opts, :xmaxvp, 1.0)
    yminvp     = get(opts, :yminvp, 0.0)
    ymaxvp     = get(opts, :ymaxvp, 0.9)
    xminwd     = get(opts, :xminwd, -1.0)
    xmaxwd     = get(opts, :xmaxwd, 1.0)
    yminwd     = get(opts, :yminwd, -0.9)
    ymaxwd     = get(opts, :ymaxwd, 1.1)
    ptype      = get(opts, :typ, :point)
    boxcolor   = Int32(get(opts, :boxcol, 1))
    datacolor  = Int32(get(opts, :col, 1))
    overlay    = get(opts, :overlay, false)
    pen        = get(opts, :pen, 1.)
    alt        = get(opts, :alt, 45.)
    az         = get(opts, :az,  30.)
    basex      = get(opts, :basex, 1.)
    basey      = get(opts, :basey, 1.)
    height     = get(opts, :height, 1.)

    hc = Int32(23)
    if :pch in keys(opts)
        val = opts[:pch]
        hc = if isa(val, Char)
            get(Hershey, val, hc)
        elseif isa(val, Integer)
            Int32(val)
        end
    end

    # setup environment
    if !overlay
        plcol0(boxcolor)

        # advance page
        pladv(0)

        # set world coordinates of viewport boundaries
        plvpor( xminvp, xmaxvp, yminvp, ymaxvp )

        # set world coordinates of viewport boundaries
        plwind( xminwd, xmaxwd, yminwd, ymaxwd )

        # set 3-d plotting window 
        plw3d( basex, basey, height,
 	           xmin, xmax, ymin, ymax, zmin, zmax,
               alt, az)

        # set box parameters
        plbox3( xspec, xlabel, xmajorint, xminornum,
                yspec, ylabel, ymajorint, yminornum,
                zspec, zlabel, zmajorint, zminornum )
    end

    plcol0(datacolor)
    pen != 1.0 && plwidth(pen) # set pen widths if available

    # plot points
    ptype == :point && scatter3(x, y, z, hc)
    ptype == :line  && lines3(x, y, z)

    pen != 1.0 && plwidth(1.) # reset pen widths
    return
end

function plot3{T<:AbstractFloat}(coords::AbstractMatrix{T}; kvopts...)
    @assert size(coords,2) == 3 "Input matrix should have 3 columns"
    plot3(coords[:,1], coords[:,2], coords[:,3]; kvopts...)
end
