using PLplot

x = collect(linspace(0., 1., 100))
y = 100*x.^2

draw(:xwin) do opts
    plot(x, y, typ=:line)
    labels("x", "y=100 x#u2#d", "Simple PLplot demo of a 2D line plot" )
    legend(["y(x)=100 x#u2#d"], text_spacing=4.0,
           pos=Cint(PLplot.POSITION_LEFT)|Cint(PLplot.POSITION_TOP))
end
