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

"""Set color map0 colors by 8-bit RGB values
"""
function setcolormap(rgbcm::Array{Int32,2}, bgc=Int32[], fgc=Int32[]; index=0)
    if length(bgc) == 3
        rgbcm[1,:] = bgc
    end
    if length(fgc) == 3
        rgbcm[2,:] = fgc
    end
    setcolormap(rgbcm[:,1], rgbcm[:,2], rgbcm[:,3], index)
end

function setcolormap(R::Vector{Int32}, G::Vector{Int32}, B::Vector{Int32}, index=0)
    @assert length(R) > 0 "Number of colors must be positive"
    @assert length(R) == length(G) == length(B) "Number of colors must be the same for each channel"
    if index == 0
        plscmap0(R, G, B, Int32(length(R)))
    else
        plscmap1(R, G, B, Int32(length(R)))
    end
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
                opt::Cint=Cint(PLplot.LEGEND_BACKGROUND) | Cint(PLplot.LEGEND_BOUNDING_BOX),
                pos::Cint=Cint(PLplot.POSITION_VIEWPORT),
                x_offset::Cdouble=0.0, y_offset::Cdouble=0.0, width::Cdouble=0.1,
                bg_color::Cint=Cint(0), bb_color::Cint=Cint(1), bb_style::Cint=Cint(1),
                nrow::Cint=Cint(0), ncolumn::Cint=Cint(0),
                text_offset::Cdouble=1.0, text_scale::Cdouble=1.0,
                text_spacing::Cdouble=2.0, text_justification::Cdouble=1.0,
                text_colors::Vector{Cint} = Cint[]
                )

    nlegend = Cint(length(desc))
    opt_array   = fill(Cint(PLplot.LEGEND_LINE), nlegend)
    if length(text_colors) == 0
        text_colors = colorindexes(nlegend)
    end
    text = [convert(Cstring, pointer(desc[i])) for i in 1:nlegend]
    box_colors = Ptr{Cint}(C_NULL)
    box_patterns = Ptr{Cint}(C_NULL)
    box_scales = Ptr{Cdouble}(C_NULL)
    box_line_widths = Ptr{Cdouble}(C_NULL)
    line_colors = text_colors
    line_styles = [Cint(1) for i in 0:nlegend]
    line_widths = [Cdouble(1.0) for i in 0:nlegend]
    symbol_colors = text_colors
    symbol_scales = Ptr{Cdouble}(C_NULL)
    symbol_numbers = Ptr{Cint}(C_NULL)
    symbols = Ptr{Cstring}(C_NULL)

    plw=Ref{Cdouble}(0)
    plh=Ref{Cdouble}(0)
    PLplot.pllegend(plw, plh, opt, pos,
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

"""Write text relative to viewport boundaries"""
function label(side::Symbol, text::String,
               disp::PLFLT=3.0, pos::PLFLT=0.5, just::PLFLT=0.5)
    plmtex(ViewPortText[side], disp, pos, just, text)
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
