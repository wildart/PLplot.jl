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

    PLplot.plgpage(p_xp, p_yp, p_xleng, p_yleng, p_xoff, p_yoff)
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

    PLplot.plspage(xdpi, ydpi, xlen, ylen, xoff, yoff)
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
        PLplot.plscmap0(R, G, B, Int32(length(R)))
    else
        PLplot.plscmap1(R, G, B, Int32(length(R)))
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

    PLplot.plgspa(p_xmin, p_xmax, p_ymin, p_ymax)
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
        PLplot.plgvpd(p_xmin, p_xmax, p_ymin, p_ymax)
    else
        PLplot.plgvpw(p_xmin, p_xmax, p_ymin, p_ymax)
    end
    return Dict(:xmin=>p_xmin[], :xmax=>p_xmax[], :ymin=>p_ymin[], :ymax=>p_ymax[])
end
