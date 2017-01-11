"""Quartile calcululations from 'Simple Implementatons of the Boxplot' by Frigge, Hoaglin & Iglewicz

   quartiles(X::Vector; def::Symbol=:waverage)

Calcualte quartiles for array `X` using  definition specified by parameter `def`.

|   `def`  |Definition|
|----------|----------|
|:average  |Weigted Average Amed at x_((n+1)/4), #4|
|:empirical|EDF with Averaging, #5|
|:tukey    |Standard Forths or Hinges (Tukey), #6|
|:ideal    |Ideal or Machine Forths, #7|
|:clevelend|Weigted Average Amed at x_(n/4+0.5), #8|
"""
function quartiles{T<:Real}(data::Vector{T}; quartile=:waverage)
    n = length(data)

    # calculate lower and upper fourths
    q1, q3 = if n == 1
        [data[1], data[1]]
    elseif quartile == :tukey || quartile == :hinges
        qi = ((n+3)>>1)*0.5
        j = floor(qi)
        g = qi - j
        d = convert(Int, j)
        [(1.0-g)*data[d]+g*data[d+1], (1.0-g)*data[n+1-d]+g*data[n+2-d]]
    elseif quartile == :ideal
        qi = n/4. + 5./12.
        j = floor(qi)
        g = qi - j
        d = convert(Int, j)
        [(1.0-g)*data[d]+g*data[d+1], (1.0-g)*data[n+1-d]+g*data[n+2-d]]
    else
        Q = Float64[]
        for p in [0.25, 0.75]
            q = if quartile == :average # (n+1)*p = j + g
                qi = (n+1)*p
                j = floor(qi)
                g = qi - j
                d = convert(Int, j)
                (1.0-g)*data[d]+g*data[d+1]
            elseif quartile == :empirical
                qi = n*p
                j = floor(qi)
                d = convert(Int, j)
                if qi - j > 0.
                    data[d+1]
                else
                    (data[d] + data[d+1])/2.
                end
            elseif quartile == :clevelend # n*p + 1/2 = j + g
                qi = n*p + 0.5
                j = floor(qi)
                g = qi - j
                d = convert(Int, j)
                (1.0-g)*data[d]+g*data[d+1]
            end
            push!(Q, q)
        end
        Q
    end

    # calculate median
    q2 = if isodd(n)
        mdl = (n >> 1) + 1
        data[mdl]*1.
    else
        mdl = n >> 1
        (data[mdl] + data[mdl+1])/2.
    end

    return q1, q2, q3
end


function fences(data::Vector; quartile=:average, k=1.5)
    q1, q2, q3 = quartiles(data, quartile = quartile)

    lfence, hfence = if isinf(k)
        lfence, hfence = extrema(data)
        lfence, hfence
    else
        IQR = q3-q1
        lfence = q1 - k*IQR
        hfence = q3 + k*IQR
        lfence, hfence
    end

    return lfence, q1, q2, q3, hfence
end

function boxplot{T<:Real}(data::Dict{T, Vector{T}}; quartile=:average, k=1.5, boxwidth=0.8)

    x = convert(Vector{PLFLT}, sort!(collect(keys(data))))
    y = [fences(sort(data[i]), quartile=quartile, k=k) for i in x]

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
