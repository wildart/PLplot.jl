import PLplot: plsdev, plinit, pladv, plvpor, plwind, plbox, plsvpa, plptex, plend

plsdev("xcairo")
plinit()

pladv( 0 )
plvpor( 0.0, 1.0, 0.0, 1.0 )
plwind( 0.0, 1.0, 0.0, 1.0 )
plbox( "bc", 0.0, 0, "bc", 0.0, 0 )

plsvpa( 50.0, 150.0, 50.0, 100.0 )
plwind( 0.0, 1.0, 0.0, 1.0 )
plbox( "bc", 0.0, 0, "bc", 0.0, 0 )
plptex( 0.5, 0.5, 1.0, 0.0, 0.5, "BOX at (50,150,50,100)" )
plend()