import PLplot: plsdev, plstar, plsyax, plcol0, plenv, pllab, plpoin,
               plsyax, plline, plxormod, plflush, plspause, plend, plwidth,
               plbox, plstyl, pladv, plvsta, plwind

function plot1(do_test::Bool)
    dsize = 60
    x = zeros(dsize)
    y = zeros(dsize)
    for i in 1:dsize
        x[i] = xoff + xscale * i/dsize
        y[i] = yoff + yscale * x[i]^2.
    end

    xmin = x[1]
    xmax = x[end]
    ymin = y[1]
    ymax = y[end]

    xs = zeros(Int(dsize/10))
    ys = zeros(Int(dsize/10))
    for i in 1:Int(dsize/10)
        xs[i] = x[(i-1) * 10 + 3]
        ys[i] = y[(i-1) * 10 + 3]
    end

    plcol0( 1 )
    plenv( xmin, xmax, ymin, ymax, 0, 0 )
    plcol0( 2 )
    pllab( "(x)", "(y)", "#frPLplot Example 1 - y=x#u2" )

    plcol0( 4 )
    plpoin( 6, xs, ys, 9 )

    plcol0( 3 )
    plline( 60, x, y )

    if do_test
        st = Int32[0]
        plxormod( 1, st )
        if ( st[1] == 1 )
            for i in 1:60
                plpoin( 1, x[i:end], y[i:end], 9 )
                sleep(0.05)
                plflush()
                plpoin( 1, x[i:end], y[i:end], 9 )
            end
            plxormod( 0, st )
        else
            info("'xor' mode is not supported. Use 'xwin' device.")
        end
    end
end

function plot2()
    plcol0( 1 )
    plenv( -2.0, 10.0, -0.4, 1.2, 0, 1 )
    plcol0( 2 )
    pllab( "(x)", "sin(x)/x", "#frPLplot Example 1 - Sinc Function" );

    dsize = 100
    x = zeros(dsize)
    y = zeros(dsize)
    for i in 1:dsize
        x[i] = ( i - 19.0 ) / 6.0
        y[i] = 1.0
        if x[i] != 0.0
            y[i] = sin( x[i] ) / x[i]
        end
    end

    plcol0( 3 )
    plwidth( 2 )
    plline( dsize, x, y )
    plwidth( 1 )
end


function plot3()
    space0 = Int32[0]
    mark0 = Int32[0]
    space1 = Int32[1500]
    mark1 = Ref{Int32}(1500)

# For the final graph we wish to override the default tick intervals, and
# so do not use plenv().
    pladv( 0 )

# Use standard viewport, and define X range from 0 to 360 degrees, Y range
# from -1.2 to 1.2.
    plvsta()
    plwind( 0.0, 360.0, -1.2, 1.2 )

# Draw a box with ticks spaced 60 degrees apart in X, and 0.2 in Y.
    plcol0( 1 )
    plbox( "bcnst", 60.0, 2, "bcnstv", 0.2, 2 )

# Superimpose a dashed line grid, with 1.5 mm marks and spaces.
# plstyl expects a pointer!
    plstyl( 1, mark1, space1 )
    plcol0( 2 )
    plbox( "g", 30.0, 0, "g", 0.2, 0 )
    plstyl( 0, mark0, space0 )

    plcol0( 3 )
    pllab( "Angle (degrees)", "sine", "#frPLplot Example 1 - Sine function" )

    dsize = 101
    x = zeros(dsize)
    y = zeros(dsize)
    for i in 1:dsize
        x[i] = 3.6 * i
        y[i] = sin( x[i] * π / 180.0 )
    end

    plcol0( 4 )
    plline( dsize, x, y )
end


plsdev("xwin")
plstar( 2, 2 )

global xscale = 6.
global yscale = 1.
global xoff   = 0.
global yoff   = 0.
global digmax = 5
plot1( false )

xscale = 1.
yscale = 0.0014
yoff   = 0.0185
plsyax( digmax, 0 )
plot1( true )

plot2()

plot3()

plend()