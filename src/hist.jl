sturges(n) = ceil(Cint,log2(n))+one(Cint)

@enum(PL_HIST,  HIST_DEFAULT         = Cint(0),
                HIST_NOSCALING       = Cint(1),
                HIST_IGNORE_OUTLIERS = Cint(2),
                HIST_NOEXPAND        = Cint(8),
                HIST_NOEMPTY         = Cint(16))

function histogram(v; bins = sturges(length(v)), opts = Cint(HIST_DEFAULT))
    n = PLINT(length(v))
    vmin, vmix = extrema(v)
    plhist(n, v, vmin, vmix, bins, opts)
end