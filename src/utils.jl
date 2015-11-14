
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