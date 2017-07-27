using PLplot

XPTS = 35
YPTS = 46
lvls = collect(linspace(-1.,1.,11))

# generate data
z = zeros(XPTS, YPTS)
w = zeros(XPTS, YPTS)
for i in 1:XPTS
    xx = (i - 1. - XPTS/2.)/(XPTS/2.)
    for j in 1:YPTS
        yy = (j - 1. - YPTS/2.)/(YPTS/2.) - 1.
        z[i,j] = xx*xx - yy*yy
        w[i,j] = 2.*xx*yy
    end
end

# Setup transformation function
const TR=PLplot.transform1to1(z)
function transformfunc(x::PLplot.PLFLT, y::PLplot.PLFLT, tx::Ptr{PLplot.PLFLT}, ty::Ptr{PLplot.PLFLT}, pltr_data::Ptr{Void})
    unsafe_store!(tx, TR[1] * x + TR[2] * y + TR[3])
    unsafe_store!(ty, TR[4] * x + TR[5] * y + TR[6])
    return
end

# draw plot
draw() do opts
    PLplot.pl_setcontlabelformat(4,3)
    PLplot.pl_setcontlabelparam(0.006,0.3,0.1,1)
    PLplot.plenv(-1., 1., -1., 1., 0., 0.)
    color!(1)
    contour(z, transformfunc, levels=lvls)
    color!(2)
    contour(w, transformfunc, levels=lvls)
    PLplot.pl_setcontlabelparam(0.006,0.3,0.1,0)
end


cg1 = PLplot.Grid(XPTS, YPTS)
# cg2 = PLplot.Grid2(XPTS, YPTS)
xx = [0.]
yy = [0.]
distort = 0.4
for i in 1:XPTS
    for j in 1:YPTS
        transformfunc(i-1., j-1., pointer(xx), pointer(yy), C_NULL)
        argx = xx[]*π/2
        argy = yy[]*π/2
        cg1.xg[i] = xx[] + distort*cos(argx)
        cg1.yg[j] = yy[] - distort*cos(argy)

        # cg2.xg[i,j] = xx[] + distort * cos(argx) * cos(argy)
        # cg2.yg[i,j] = yy[] - distort * cos(argx) * cos(argy)
    end
end

# draw plot
draw() do opts
    PLplot.plenv(-1., 1., -1., 1., 0., 0.)
    color!(1)
    contour(z, PLplot.pltr1, levels=lvls, payload=cg1)
    color!(2)
    contour(w, PLplot.pltr1, levels=lvls, payload=cg1)
end
