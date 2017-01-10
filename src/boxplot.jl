function qstats(data::Vector)
    l = length(data)
    ml, mr, m = if isodd(l)
        mdl = (l >> 1) + 1
        m = data[mdl]*1.
        l == 1 ? mdl : mdl-1, l == 1 ? mdl : mdl+1, m
    else
        mdl = l >> 1
        m = (data[mdl] + data[mdl+1])/2.
        mdl, mdl+1, m
    end

    return median(data[1:ml]), m, median(data[mr:end])
end

function boxparams(data::Vector; minmax = false)
    q1, q2, q3 = qstats(data)

    lfence, hfence = if minmax
        lfence, hfence = extrema(data)
        lfence, hfence
    else
        IQR = q3-q1
        lfence = q1 - 1.5IQR
        hfence = q3 + 1.5IQR
        lfence, hfence
    end

    return lfence, q1, q2, q3, hfence
end

function boxplot{T<:Real}(data::Dict{T, Vector{T}}; minmax=false, boxwidth=0.8)

    x = convert(Vector{PLFLT}, sort!(collect(keys(data))))
    y = [boxparams(sort(data[k]), minmax=minmax) for k in x]

    # Get plot dimension parameters

    xmin, xmax = extrema(x)
    xw = (xmax-xmin)/(length(x)-1)
    xmin -= xw
    xmax += xw

    ymin = minimum(map(e->e[1], y))
    ymax = maximum(map(e->e[5], y))

    exy = [extrema(v) for (k,v) in data]
    ydmin = mapreduce(z->z[1], min, exy)
    ydmax = mapreduce(z->z[2], max, exy)
    ymin = min(ymin, ydmin)
    ymax = max(ymax, ydmax)

    yw = (ymax-ymin)/100.
    ymin -= yw
    ymax += yw

    # Setup environment
    plenv(xmin, xmax, ymin, ymax, Int32(Independent), Int32(Default))

    hbw = xw*boxwidth/2.
    for (b,(wl, bl, med, bh, wh)) in zip(x,y)
        # Box
        x0 = PLFLT[b-hbw, b+hbw, b+hbw, b-hbw, b-hbw]
        y0 = PLFLT[bl, bl, bh, bh, bl]
        plline(5, x0, y0)

        # Whiskers
        pllsty(2)
        pljoin(b, bh, b, wh)
        pllsty(1)
        pljoin(b-hbw*0.75, wh, b+hbw*0.75, wh)

        pllsty(2)
        pljoin(b, bl, b, wl)
        pllsty(1)
        pljoin(b-hbw*0.75, wl, b+hbw*0.75, wl)

        # Median
        plwidth(2.)
        pljoin(b-hbw, med, b+hbw, med)
        plwidth(1.)

        # Outliers
        outl = filter(z->(z<wl || z > wh), data[b])
        length(outl) > 0 && plpoin(length(outl), fill(b, length(outl)), outl, Int32(20))

        b+=1.
    end
end
