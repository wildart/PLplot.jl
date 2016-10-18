# __precompile__()

module PLplot

    export draw, plot, points, lines, labels, legend

    # Link dependency
    depsfile = normpath(dirname(@__FILE__),"..","deps","deps.jl")
    if isfile(depsfile)
        include(depsfile)
    else
        error("PLplot binary not properly installed. Please run Pkg.build(\"PLplot\")")
    end

    include("wrapper.jl")
    include("plot.jl")
    include("hist.jl")
    include("utils.jl")
    include("ijulia.jl")

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

    const AxisBoxParams = Dict(
        zip(
            map(Int32, instances(PLplot.AxisBox)),
            [
                ("", "")
                ("bc", "bc")

                ("bcnst", "bcnstv")
                ("abcnst", "abcnstv")
                ("abcgnst", "abcgnstv")
                ("abcgnsth", "abcgnstvh")

                ("bclnst", "bcnstv")
                ("abclnst", "abcnstv")
                ("abcglnst", "abcgnstv")
                ("abcglnsth", "abcgnstvh")

                ("bcnst", "bclnstv")
                ("abcnst", "abclnstv")
                ("abcgnst", "abcglnstv")
                ("abcgnsth", "abcglnstvh")

                ("bclnst", "bclnstv")
                ("abclnst", "abclnstv")
                ("abcglnst", "abcglnstv")
                ("abcglnsth", "abcglnstvh")

                ("bcdnst", "bcnstv")
                ("abcdnst", "abcnstv")
                ("abcgdnst", "abcgnstv")
                ("abcgdnsth", "abcgnstvh")

                ("bcnst", "bcdnstv")
                ("abcnst", "abcdnstv")
                ("abcgnst", "abcgdnstv")
                ("abcgnsth", "abcgdnstvh")

                ("bcdnst", "bcdnstv")
                ("abcdnst", "abcdnstv")
                ("abcgdnst", "abcgdnstv")
                ("abcgdnsth", "abcgdnstvh")

                ("bcnost", "bcnostv")
                ("abcnost", "abcnostv")
                ("abcgnost", "abcgnostv")
                ("abcgnosth", "abcgnostvh")
            ]
        )
    )

    const ViewPortText = Dict(
        :bottom   => "b",
        :bottom90 => "bv",
        :left     => "l",
        :left90   => "lv",
        :right    => "r",
        :right90  => "rv",
        :top      => "l",
        :top90    => "lv"
    )


    """Open driver for drawing.

    Keyword parameters:

    - 'filename': Set file name for a output driver
    """
    function draw(plotting::Function, driver::Symbol=:xwin; kvopts...)
        @assert driver in keys(devices()) "Driver $driver is not supported"

        opts = Dict(kvopts)

        # set device
        plsdev(string(driver))

        isinline = get(opts ,:inline, false)

        # set file name
        if driver ∉ [:xwin, :xcairo]
            if driver ∈ [:svg, :svgcairo, :svgqt, :pngcairo, :pngqt] && isinline
                fname = tempname()
            else
                fname = string(get(opts ,:filename, "output"))
            end
            plsfnam(fname)
        end

        # initialize plotting
        plinit()
        try
            plotting(kvopts)
        finally
            plend()
        end

        if !isinline
            return nothing
        else
            io = open(fname)
            res = if driver ∈ [:svg, :svgcairo, :svgqt]
                SVG(read(io))
            elseif driver ∈ [:pngcairo, :pngqt]
                PNG(read(io))
            else
                nothing
            end
            close(io)
            rm(fname)
            return res
        end
    end

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
        hc =  get(hershey, g, Int32(23))
        scatter(x, y, hc)
    end

    """Draws line defined by in x and y. """
    function lines{T<:Real}(x::AbstractVector{T}, y::AbstractVector{T})
        @assert length(x) == length(y) "Number of point should be equal for each axis"
        plline(length(x), collect(x), collect(y))
    end

    """Simple routine to write labels for plot title, X and Y axes."""
    function labels(xaxis::String, yaxis::String, title::String)
       pllab(xaxis, yaxis, title)
    end

    """ Writes text at a specified position relative to the viewport boundaries.

        Text may be written inside or outside the viewport, but is clipped at
        the subpage boundaries. The reference point of a string lies along
        a line passing through the string at half the height of a capital letter.

        The position of the reference point along this line is determined by *just*,
        and the position of the reference point relative to the viewport is set
        by *disp* and *pos* .
    """
    function label(lbl::String, side::Symbol, disp::PLFLT=1., pos::PLFLT=0.5, just::PLFLT=0.5)
       @assert haskey(ViewPortText, side) "Unknow symbol $side to specify lable position"
       plmtex(ViewPortText[side], disp, pos, just, lbl)
    end

end # module
