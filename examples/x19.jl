import PLplot: plsdev, plinit, plcol0, plenv, plmap, plmapfill, plfill, plspause, plend

miny = -70
maxy = 80
minx = -170
maxx = minx + 360

plsdev("xwin")
plinit()
plcol0(1)
plenv( minx, maxx, miny, maxy, 0, 70 )
plmap( C_NULL, "usaglobe", minx, maxx, miny, maxy )
#plmap( C_NULL, joinpath(pwd(), "examples/ne_50m_land/ne_50m_land"), minx, maxx, miny, maxy )

plcol0( 2 )
beachareas = collect(map(Int32, 1:200))
plmapfill( C_NULL, "usaglobe", minx, maxx, miny, maxy, beachareas, length(beachareas) );

plcol0( 3 )
x = -76.0
y =  39.0
xs = [x, x,     x+0.5, x+0.5]
ys = [y, y+0.5, y+0.5, y]
plfill(length(xs), xs, ys)

#plspause(0)
plend()