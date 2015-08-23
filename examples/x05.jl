import PLplot: plsdev, plinit, plhist, plcol0, plend, pllab

global NPTS = 2047

plsdev("xcairo")
plinit()

delta = 2.0 * π / NPTS
data = map(i->sin( i * delta ), 1:NPTS)

plcol0( 1 )
plhist( NPTS, data, -1.1, 1.1, 44, 0 )
plcol0( 2 )
pllab( "#frValue", "#frFrequency", "#frPLplot Example 5 - Probability function of Oscillator" )

plend()