import PLplot: plsdev, plinit, plenv, pllab, plline, plspause, plend

xmin = 0.
xmax = 1.
ymin = 0.
ymax = 100.

x = collect(linspace(xmin, xmax, ymax))
y = ymax*x.^2

plsdev("xwin")
plinit()
plenv( xmin, xmax, ymin, ymax, 0, 0 )
pllab( "x", "y=100 x#u2#d", "Simple PLplot demo of a 2D line plot" )
plline( length(x), x, y )
#plspause(0)
plend()





