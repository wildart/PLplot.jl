"""PLplot Graphics Input structure
"""
immutable GraphicsInput
    etype::Cint   # type of of event (CURRENTLY UNUSED)
    state::Cuint  # key or button mask
    keysym::Cuint # key selected
    button::Cuint # mouse button selected
    subwindow::PLINT # subwindow (alias subpage, alias subplot) number
    translated::NTuple{16,Cchar} # translated string
    pX::Cint # absolute device coordinates of pointer
    pY::Cint
    dX::PLFLT  # relative device coordinates of pointer
    dY::PLFLT
    wX::PLFLT  # world coordinates of pointer
    wY::PLFLT

    GraphicsInput() = new(zero(Cint), zero(Cuint), zero(Cuint), zero(Cuint), zero(PLINT),
                         ntuple(x->zero(Cchar),16), zero(Cint), zero(Cint),
                         zero(PLFLT), zero(PLFLT), zero(PLFLT), zero(PLFLT))
end

"""Wait for graphics input event and translate to world coordinates.

   Returns `GraphicsInput` structure
"""
function getcursor()
    input = Ref{GraphicsInput}()
    res = ccall((:plGetCursor, libplplot), Cint, (Ref{GraphicsInput},), input)
    return input[]
end

""" Get page parameters

DESCRIPTION:

    Gets the current page configuration. The length and offset values are
    expressed in units that are specific to the current driver. For
    instance: screen drivers will usually interpret them as number of
    pixels, whereas printer drivers will usually use mm.
"""
function pageparams()
    p_xp=Ref{Cdouble}(0)
    p_yp=Ref{Cdouble}(0)
    p_xleng=Ref{Cint}(0)
    p_yleng=Ref{Cint}(0)
    p_xoff=Ref{Cint}(0)
    p_yoff=Ref{Cint}(0)

    plgpage(p_xp, p_yp, p_xleng, p_yleng, p_xoff, p_yoff)
    return Dict(:xdpi=>p_xp[], :ydpi=>p_yp[], :xlen=>p_xleng[], :ylen=>p_yleng[], :xoff=>p_xoff[], :yoff=>p_yoff[])
end

"""Set page parameters

DESCRIPTION:

    Sets the page configuration (optional).  If an individual parameter is
    zero then that parameter value is not updated.  Not all parameters are
    recognized by all drivers and the interpretation is device-dependent.
    The X-window driver uses the length and offset parameters to determine
    the window size and location.  The length and offset values are
    expressed in units that are specific to the current driver. For
    instance: screen drivers will usually interpret them as number of
    pixels, whereas printer drivers will usually use mm. This routine, if
    used, must be called before initializing PLplot.
"""
function pageparams!(; xdpi=-1., ydpi=-1., xlen=-1, ylen=-1, xoff=-1, yoff=-1)
    params = pageparams()

    xdpi < 0. && (xdpi = params[:xdpi])
    ydpi < 0. && (ydpi = params[:ydpi])
    xlen < 0. && (xlen = params[:xlen])
    ylen < 0. && (ylen = params[:ylen])
    xoff < 0. && (xoff = params[:xoff])
    yoff < 0. && (yoff = params[:yoff])

    plspage(xdpi, ydpi, xlen, ylen, xoff, yoff)
end

"""Set color map `cmap` colors by 8-bit RGB values
"""
function setcolormap!(rgbcm::Array{PLINT,2}, bgc=PLINT[], fgc=PLINT[]; cmap=0, interpolate=false)
    if length(bgc) == 3
        rgbcm[1,:] = bgc
    end
    if length(fgc) == 3
        rgbcm[2,:] = fgc
    end
    setcolormap!(rgbcm[:,1], rgbcm[:,2], rgbcm[:,3], cmap, (interpolate && cmap == 1))
end

function setcolormap!(R::Vector{PLINT}, G::Vector{PLINT}, B::Vector{PLINT}, cmap=0, interpolate=false)
    l = convert(PLINT, length(R))
    @assert l > 0 "Number of colors must be positive"
    @assert l == length(G) == length(B) "Number of colors must be the same for each channel"
    if cmap == 0
        plscmap0(R, G, B, l)
    else
        if interpolate
            pos = collect(linspace(zero(PLFLT), one(PLFLT), l))
            plscmap1l(one(PLINT), l, pos, R./255f0, G./255f0, B./255f0, Ptr{PLINT}(C_NULL))
        else
            plscmap1(R, G, B, l)
        end
    end
    return
end

"""Set current color using `idx` from color map `cmap`
"""
function color!(idx, cmap=0)
    if cmap == 0
        plcol0(convert(PLINT, idx))
    else
        plcol1(convert(PLFLT, idx))
    end
    return
end

"""Get current subpage parameters

DESCRIPTION:

   Gets the size of the current subpage in millimeters measured from
   the bottom left hand corner of the output device page or screen.
"""
function getsubpage()
    p_xmin=Ref{Cdouble}(0)
    p_xmax=Ref{Cdouble}(0)
    p_ymin=Ref{Cdouble}(0)
    p_ymax=Ref{Cdouble}(0)

    plgspa(p_xmin, p_xmax, p_ymin, p_ymax)
    return Dict(:xmin=>p_xmin[], :xmax=>p_xmax[], :ymin=>p_ymin[], :ymax=>p_ymax[])
end

"""Get viewport limits

Parameter values:
- :norm, in normalized device coordinates
- :world, in world coordinates
"""
function getviewport(ptype::Symbol=:norm)
    p_xmin=Ref{Cdouble}(0)
    p_xmax=Ref{Cdouble}(0)
    p_ymin=Ref{Cdouble}(0)
    p_ymax=Ref{Cdouble}(0)

    if ptype == :norm
        plgvpd(p_xmin, p_xmax, p_ymin, p_ymax)
    else
        plgvpw(p_xmin, p_xmax, p_ymin, p_ymax)
    end
    return Dict(:xmin=>p_xmin[], :xmax=>p_xmax[], :ymin=>p_ymin[], :ymax=>p_ymax[])
end


"""Legend
"""
function legend(desc::Vector{String};
                opt::Cint=Cint(LEGEND_BACKGROUND) | Cint(LEGEND_BOUNDING_BOX),
                pos::Cint=Cint(POSITION_VIEWPORT),
                entry_opt = Cint(LEGEND_LINE), entry_opts = Cint[],
                x_offset::Cdouble=0.0, y_offset::Cdouble=0.0, width::Cdouble=0.1,
                bg_color::Cint=Cint(0), bb_color::Cint=Cint(1), bb_style::Cint=Cint(1),
                nrow::Cint=Cint(0), ncolumn::Cint=Cint(0),
                text_offset::Cdouble=1.0, text_scale::Cdouble=1.0,
                text_spacing::Cdouble=2.0, text_justification::Cdouble=1.0,
                text_colors::Vector{Cint} = Cint[],
                symbols = String[], symbol_colors = Cint[], symbol_scales = Cdouble[], symbol_numbers = Cint[],
                line_styles = Cint[], line_widths = Cdouble[], line_colors = Cint[]
                )

    nlegend = Cint(length(desc))
    opt_array   = length(entry_opts) == 0 ? fill(entry_opt, nlegend) : entry_opts
    # Text
    text = [convert(Cstring, pointer(desc[i])) for i in 1:nlegend]
    if length(text_colors) == 0
        text_colors = colorindexes(nlegend)
    end
    # Box
    box_colors = Ptr{Cint}(C_NULL)
    box_patterns = Ptr{Cint}(C_NULL)
    box_scales = Ptr{Cdouble}(C_NULL)
    box_line_widths = Ptr{Cdouble}(C_NULL)
    # Lines
    if length(line_colors) == 0
        line_colors = text_colors
    end
    if length(line_styles) == 0
        line_styles = [Cint(1) for i in 0:nlegend]
    end
    if length(line_widths) == 0
        line_widths = [Cdouble(1.0) for i in 0:nlegend]
    end
    # Symbols
    if length(symbols) == 0
        symbols = Ptr{Cstring}(C_NULL)
    end
    if length(symbol_colors) == 0
        symbol_colors = text_colors
    end
    if length(symbol_scales) == 0
        symbol_scales = [Cdouble(1.0) for i in 0:nlegend]
    end
    if length(symbol_numbers) == 0
        symbol_numbers = [Cint(1) for i in 0:nlegend]
    end

    plw=Ref{Cdouble}(0)
    plh=Ref{Cdouble}(0)
    pllegend(plw, plh, opt, pos,
            x_offset, y_offset, width,
            bg_color, bb_color, bb_style,
            nrow, ncolumn,
            nlegend, opt_array,
            text_offset, text_scale, text_spacing, text_justification,
            text_colors, text,
            box_colors, box_patterns, box_scales, box_line_widths,
            line_colors, line_styles, line_widths,
            symbol_colors, symbol_scales, symbol_numbers,
            symbols)
    return (plw[], plh[])
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
function label(lbl::String, side::Symbol,
               disp::PLFLT=1., pos::PLFLT=0.5, just::PLFLT=0.5)
    @assert haskey(ViewPortText, side) "Unknow symbol $side to specify lable position"
    plmtex(ViewPortText[side], disp, pos, just, lbl)
end

"""Create circular color index (with possibility to skip one color)"""
function colorindexes(n, skip=0)
    i = 0
    idxs = Cint[]
    while length(idxs) < n
        ci = i%16
        if !(ci == skip || ci == 0)
            push!(idxs, ci)
        end
        i+=1
    end
    return idxs
end

"""Generate levels vector"""
function levels(levelMin, levelMax, levelNum)
    levelInc = (ceil(levelMax)-floor(levelMin))/levelNum
    return collect(floor(levelMin):levelInc:ceil(levelMax))
end

# Conversion rules for options
Base.:|(a::PL_POSITION, b::PL_POSITION) = |(Cint(a), Cint(b))
Base.:|(a::Cint, b::PL_POSITION) = |(a, Cint(b))
Base.:|(a::PL_LEGEND, b::PL_LEGEND) = |(Cint(a), Cint(b))
Base.:|(a::Cint, b::PL_LEGEND) = |(a, Cint(b))
