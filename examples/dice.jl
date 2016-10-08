using StatsBase
using Distributions 
using PLplot
using Colors

function distinguishable(len, c=colorant"white")
    cm = Colors.distinguishable_colors(len, [LCHab(70, 60, 240)],
                                    transform=c -> deuteranopic(c, 0.5),
                                    lchoices=Float64[65, 70, 75, 80],
                                    cchoices=Float64[0, 50, 60, 70],
                                    hchoices=linspace(0, 330, 24))
    cmrgb = map(c->convert(RGB{U8}, c), cm)
    return hcat([ Cint[c.r.i, c.g.i, c.b.i] for c in cmrgb]...)'
end

"""Gadfly-like colors: 0-white, 1-black, 2...-Gadfly colors"""
function setcolormap(len)
    rgbcm = vcat(fill(Cint(255),3)', zeros(Cint,3)', distinguishable(len+1))
    PLplot.setcolormap(rgbcm, index=0)
end

function plfbox(x0::Float64, y0::Float64, s=1.)
    x = [x0 x0 x0+s x0+s]
    y = [0. y0 y0 0.]

    PLplot.plfill(Cint(4), x, y)
    PLplot.plcol0(1)
    PLplot.pllsty(1)
    PLplot.plline(Cint(4), x, y )

    return
end

n = Cint(10000)
cnts = Cint[1,2,3,5,20,30]
bins = Int[6,12,18,26,33,45]

die = DiscreteUniform(1,6)
setcolormap(length(cnts))
# draw(:pngcairo, filename="norm-hist.png") do opts
draw(:xwin) do opts
    PLplot.plssub( 3, 2 )    
    for (c,(i,j)) in enumerate(zip(cnts, bins))
        smpl = reshape(rand(die, Int(n*i)), Int(n), Int(i))
        v = vec(mean(smpl,2))
        H = fit(Histogram, v, linspace(0.,6.,j+1))

        X = collect(H.edges[1])[2:end]-0.5
        Y = convert(Vector{Float64},  H.weights)
    
        PLplot.pladv(0)
        # PLplot.plvsta()
        PLplot.plvpor( 0.15, 0.85, 0.15, 0.85)
        PLplot.plwind(0., 7., 0.0, ceil(maximum(Y),-2))
        PLplot.plbox( "bcnst", 1.0, 0, "bcntv", 1000.0, 0 )
        
        PLplot.plcol0(1)
        PLplot.pllab("Die toss", "# of Tosses", i == 1 ? "1 Die" : "$i Dice")

        for (x,y) in zip(X,Y)
            PLplot.plcol0(c+1)
            plfbox(x,y,6./j)
        end
    end
end