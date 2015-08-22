using PLplot
using Base.Test

# X01
xmin = 0.
xmax = 1.
ymin = 0.
ymax = 100.

x = collect(linspace(xmin, xmax, ymax))
y = ymax*x.^2

PLplot.plsdev("xwin")
PLplot.plinit()
PLplot.plenv( xmin, xmax, ymin, ymax, 0, 0 )
PLplot.pllab( "x", "y=100 x#u2#d", "Simple PLplot demo of a 2D line plot" )
PLplot.plline( length(x), x, y )
PLplot.plspause(0)
PLplot.plend()


# X17
nsteps = 5000

ymin = -0.1
ymax = 0.1
tmin  = 0.
tmax  = 10.
tjump = 0.3

colbox     = Int32(1)
collab     = Int32(3)
styline = colline = Int32[2, 3, 4, 5]
legline = ["sum", "sin", "sin*noi", "sin+noi"]

xlab = 0.
ylab = 0.35
autoy = Int32(1)
acc   = Int32(1)

PLplot.plsdev("xwin")
PLplot.plinit()
PLplot.pladv(0)
PLplot.plvsta()

id1 = Int32[0]
PLplot.plstripc(id1, "bcnst", "bcnstv",
                tmin, tmax, tjump, ymin, ymax,
                xlab, ylab,
                autoy, acc,
                colbox, collab,
                colline, styline, map(x -> Base.unsafe_convert(Cstring,x), legline),
                "t", "", "Strip chart demo")

y1 = y2 = y3 = y4 = 0.0
dt = 0.1
for n in 1:nsteps
    sleep(0.01)

    t     = n * dt
    noise = rand() - 0.5
    y1    = y1 + noise
    y2    = sin( t * π / 18. )
    y3    = y2 * noise
    y4    = y2 + noise / 3.

    n % 2 == 0 && PLplot.plstripa( id1[1], 0, t, y1 )
    n % 3 == 0 && PLplot.plstripa( id1[1], 1, t, y2 )
    n % 4 == 0 && PLplot.plstripa( id1[1], 2, t, y3 )
    n % 5 == 0 && PLplot.plstripa( id1[1], 3, t, y4 )

    # PLplot.pleop() # needed if using double buffering
end
PLplot.plstripd( id1[1] )
PLplot.plspause(0)
PLplot.plend()