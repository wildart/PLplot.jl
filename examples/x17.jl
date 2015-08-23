import PLplot: plsdev, plinit, pladv, plvsta, plstripc, plstripa, plstripd, plspause, plend

# X17
nsteps = 1000

ymin = -0.1
ymax = 0.1
tmin  = 0.
tmax  = 10.
tjump = 0.3

colbox     = Int32(1)
collab     = Int32(3)
styline = colline = Int32[2, 3, 4, 5]
legline = ["sum", "sin", "sin*noi", "sin+noi"]

xlab = 0.0
ylab = 1.0
autoy = Int32(1)
acc   = Int32(1)

plsdev("xcairo")
plinit()
pladv(0)
plvsta()

id1 = Int32[0]
plstripc(id1, "bcnst", "bcnstv",
        tmin, tmax, tjump, ymin, ymax,
        xlab, ylab,
        autoy, acc,
        colbox, collab,
        colline, styline, map(x -> Base.unsafe_convert(Cstring,x), legline),
        "t", "", "Strip chart demo")

y1 = y2 = y3 = y4 = 0.0
dt = 0.1
for n in 1:nsteps
    sleep(0.001)

    t     = n * dt
    noise = rand() - 0.5
    y1    = y1 + noise
    y2    = sin( t * π / 18. )
    y3    = y2 * noise
    y4    = y2 + noise / 3.

    n % 2 == 0 && plstripa( id1[1], 0, t, y1 )
    n % 3 == 0 && plstripa( id1[1], 1, t, y2 )
    n % 4 == 0 && plstripa( id1[1], 2, t, y3 )
    n % 5 == 0 && plstripa( id1[1], 3, t, y4 )

    # PLplot.pleop() # needed if using double buffering
end
plstripd( id1[1] )
#plspause(0)
plend()