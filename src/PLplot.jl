# __precompile__()

module PLplot

    export draw, plot, scatter, lines, labels, legend, plot3, scatter3, lines3

    # Link dependency
    depsfile = normpath(dirname(@__FILE__),"..","deps","deps.jl")
    if isfile(depsfile)
        include(depsfile)
    else
        error("PLplot binary not properly installed. Please run Pkg.build(\"PLplot\")")
    end

    include("wrapper.jl")
    include("plot.jl")
    include("plot3d.jl")
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

    const Hershey = Dict(
        '▫' => Int32(0),  # smwhtsquare
        '⋅'  => Int32(1),  # cdot
        '+'  => Int32(2),
        '*'  => Int32(3),
        '✶'  => Int32(3),  # varstar
        '∘'  => Int32(4),  # circ
        '×'  => Int32(5),  # times
        '▢' => Int32(6),  # squoval
        '▵'  => Int32(7),  # vartriangle
        '⊕' => Int32(8),  # oplus
        '⊙' => Int32(9),  # odot
        '⌑' => Int32(10),  # sqlozenge
        '⋄'  => Int32(11), # diamond
        '⋆'  => Int32(12), # star
        '▴'  => Int32(13), # blacktriangle
        '✠' => Int32(14), # maltese
        '✽' => Int32(15), # dingasterisk
        '▪' => Int32(16), # smblksquare
        '∙' => Int32(17), # vysmblkcircle
        '⭒' => Int32(18), # smwhitestar
        '□' => Int32(19), # square
        '◦' => Int32(20), # smwhtcircle
        '⚬' => Int32(21), # mdsmwhtcircle
        '⚪' => Int32(22), # mdwhtcircle
        '◯' => Int32(23), # lgwhtcircle
    )

    @enum(Opt3D,DRAW_LINEX = Cint(0x001), # draw lines parallel to the X axis   
                DRAW_LINEY = Cint(0x002), # draw lines parallel to the Y axis
                DRAW_LINEXY= Cint(0x003), # draw lines parallel to both the X and Y axis
                MAG_COLOR  = Cint(0x004), # draw the mesh with a color dependent of the magnitude
                BASE_CONT  = Cint(0x008), # draw contour plot at bottom xy plane
                TOP_CONT   = Cint(0x010), # draw contour plot at top xy plane
                SURF_CONT  = Cint(0x020), # draw contour plot at surface
                DRAW_SIDES = Cint(0x040), # draw sides
                FACETED    = Cint(0x080), # draw outline for each square that makes up the surface
                MESH       = Cint(0x100) # draw mesh
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

end # module
