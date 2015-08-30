module PLplot

    export draw, plot, points, lines, labels

    # Link dependency
    depsfile = joinpath(dirname(@__FILE__),"..","deps","deps.jl")
    if isfile(depsfile)
        include(depsfile)
    else
        error("PLplot binary not properly installed. Please run Pkg.build(\"PLplot\")")
    end

    include("wrapper.jl")
    include("plot.jl")

    # try
    #     require(:Gadfly)
    #     include("gadfly.jl")
    # catch
    #     global PLP
    #     PLP(::String, ::MeasureOrNumber, ::MeasureOrNumber) =
    #         error("PLplot must be installed to use the PLplot backend.")
    # end

    @enum(AxisScale, NotSet=-1,
                     Independent=0,
                     Equal=1,
                     Square=2)

    @enum(AxisBox,   NoBox                       = -2,
                     BoxOnly                     = -1,
                     Default                     =  0,
                     DefaultOrigin               =  1,
                     DefaultOriginMajorTick      =  2,
                     DefaultOriginMajorMinorTick =  3,
                     LogX                        = 10,
                     LogXOrigin                  = 11,
                     LogXOriginMajorTick         = 12,
                     LogXOriginMajorMinorTick    = 13,
                     LogY                        = 20,
                     LogYOrigin                  = 21,
                     LogYOriginMajorTick         = 22,
                     LogYOriginMajorMinorTick    = 23,
                     LogXY                       = 30,
                     LogXYOrigin                 = 31,
                     LogXYOriginMajorTick        = 32,
                     LogXYOriginMajorMinorTick   = 33,
                     DateTimeX                   = 40,
                     DateTimeXOrigin             = 41,
                     DateTimeXOriginMajorTick    = 42,
                     DateTimeXOriginMajorMinorTick = 43,
                     DateTimeY                   = 50,
                     DateTimeYOrigin             = 51,
                     DateTimeYOriginMajorTick    = 52,
                     DateTimeYOriginMajorMinorTick = 53,
                     DateTimeXY                  = 60,
                     DateTimeXYOrigin            = 61,
                     DateTimeXYOriginMajorTick   = 62,
                     DateTimeXYOriginMajorMinorTick = 63,
                     Custom                      = 70,
                     CustomOrigin                = 71,
                     CustomOriginMajorTick       = 72,
                     CustomOriginMajorMinorTick  = 73)

    """Open driver for drawing.

    Keyword parameters:

    - 'filename': Set file name for a output driver
    """
    function draw(plotting::Function, driver::Symbol=:xwin; kvopts...)
        @assert driver in keys(devices()) "Driver $driver is not supported"

        opts = Dict(kvopts)

        # set device
        plsdev(string(driver))

        # set file name
        if driver ∉ [:xwin, :xcairo]
            fname = bytestring(get(opts ,:filename, "output"))
            plsfnam(fname)
        end

        # initialize plotting
        plinit()
        try
            plotting(kvopts)
        finally
            plend()
        end
    end

    """Plot points with a specified glyph using its integer code.

    Integer code range: [0,31]
    """
    function scatter(x::Vector{Float64}, y::Vector{Float64}, g::Int32)
        @assert length(x) == length(y) "Number of point should be equal for each axis"
        plpoin(length(x), x, y, g)
    end

    """Plot points with a specified glyph as character.

    Available glyphs: '⚪','◯','⊙','⭒','⊕','+','×','□','*','✠','⋅','∙','✶','⋄','✽','∘','▵','▪','⋆','⚬','▢','▴','◦','⌑','▫'
    """
    function scatter(x::Vector{Float64}, y::Vector{Float64}, g::Char)
        hc =  get(hershey, g, Int32(23))
        points(x, y, hc)
    end

    """Draws line defined by in x and y. """
    function lines(x::Vector{Float64}, y::Vector{Float64})
        @assert length(x) == length(y) "Number of point should be equal for each axis"
        plline(length(x), x, y)
    end

    """Simple routine to write labels for plot title, X and Y axes."""
    function labels(xaxis::AbstractString, yaxis::AbstractString, title::AbstractString)
       pllab( bytestring(xaxis), bytestring(yaxis), bytestring(title))
    end

    function getviewport()
        xmin = Ref{Float64}(0.)
        ymin = Ref{Float64}(0.)
        xmax = Ref{Float64}(0.)
        ymax = Ref{Float64}(0.)
        plgvpw(xmin, ymin, xmax, ymax)
        return (xmin[], xmax[], ymin[], ymax[])
    end

end # module
