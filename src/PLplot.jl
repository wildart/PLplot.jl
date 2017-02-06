# __precompile__()

module PLplot

    export draw, plot, plot!, scatter, lines, legend, plot3, scatter3, lines3, boxplot, histogram,
           color!

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
    include("boxplot.jl")
    include("abline.jl")
    include("utils.jl")
    include("ijulia.jl")

    global THEME
    THEME = try
        eval(:(import Colors))
        include("themes.jl")
        gadfly_theme() # default theme
    catch er
        show(er)
        nothing
    end

    # try
    #     eval(:(import Gadfly))
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

    - 'filename': Set file name for a output device
    """
    function draw(plotting::Function, device::Symbol=default_graphic_device; kvopts...)
        @assert device in keys(devices()) "Driver `$device` is not supported"

        opts = Dict(kvopts)

        # set device
        plsdev(string(device))
        viewer = device ∈ [:xwin, :xcairo, :wingcc, :wincairo, :tkwin, :tk, :wxwidgets]
        ijulia = device ∈ [:svg, :svgcairo, :svgqt, :pngcairo, :pngqt]

        # read parameters
        isinline = get(opts ,:inline, false)
        width = get(opts ,:width, default_graphic_width)
        height = get(opts ,:height, default_graphic_height)

        # set image size
        pageparams!(xlen=width, ylen=height)

        # set file name
        fname = Nullable{String}(
            if viewer
                nothing
            elseif haskey(opts, :file)
                ijulia = false # disable inline plotting if filename is provided
                string(opts[:file])
            elseif ijulia
                tempname()
            else
                warn("`file` parameter is not specified for `$device` device. Output will be saved to `default.plot`")
                "default.plot"
            end
        )

        # Set file name
        !isnull(fname) && plsfnam(get(fname))

        # parse color theme parameter
        cmap = theme!(get(opts ,:theme, nothing))
        cmap !== nothing && setcolormap!(cmap)

        # initialize plotting
        plinit()
        try
            plotting(kvopts)
        finally
            plend()
        end

        # if file is not specified, thus no inline possible, then exit
        isnull(fname) && return nothing

        # if inline flag set load image as byte array
        if ijulia
            io = open(get(fname), "r")
            res = if device ∈ [:svg, :svgcairo, :svgqt]
                SVG(read(io))
            elseif device ∈ [:pngcairo, :pngqt]
                PNG(read(io))
            else
                nothing
            end
            close(io)
            rm(get(fname)) # remove temporary file

            return res
        end

        return nothing
    end

    default_graphic_height = 378
    default_graphic_width = round(Int, default_graphic_height*(1.+sqrt(5.))/2.)
    default_graphic_device = :xwin

    """Set default plot size in pixels"""
    function set_default_plot_size(width::Int, height::Int)
        global default_graphic_width
        global default_graphic_height
        default_graphic_width = width
        default_graphic_height = height
        nothing
    end

    """Set default graphic device"""
    function set_default_device(device::Symbol)
        global default_graphic_device
        devs = devices()
        if haskey(devs, device)
           default_graphic_device = device
        else
            error("No such device: $device")
        end
        nothing
    end

    function __init__()
        global default_graphic_device
        if is_windows()
           default_graphic_device = :wincairo
           plsetopt("libdir", dirname(libplplot))
        end
    end

end # module
