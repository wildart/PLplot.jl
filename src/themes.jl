import FixedPointNumbers
const ColorU8 = FixedPointNumbers.Normed{UInt8, 8}

"""Maximally distinguishable color theme

    `cname` is a color name
"""
function distinguishable_theme(cname="white", len=16)
    cm = Colors.distinguishable_colors(len, parse(Colors.Colorant, cname))
    return hcat([ Cint[c.r.i, c.g.i, c.b.i] for c in cm]...)'
end

"""Gadfly-like colors theme:

    0-white, 1-black, 2...-Gadfly colors
"""
function gadfly_theme(len=14)
    cm = Colors.distinguishable_colors(len, [Colors.LCHab(70, 60, 240)],
                                    transform=c ->Colors.deuteranopic(c, 0.5),
                                    lchoices=Float64[65, 70, 75, 80],
                                    cchoices=Float64[0, 50, 60, 70],
                                    hchoices=linspace(0, 330, 24))
    cmrgb = map(c->convert(Colors.RGB{ColorU8}, c), cm)
    return hcat(fill(Cint(255),3), zeros(Cint,3), [ Cint[c.r.i, c.g.i, c.b.i] for c in cmrgb]...)'
end


""" Returns a predefined sequential or diverging color theme.

    `cname` is a color name, choices are `Blues`, `Greens`, `Grays`, `Oranges`, `Purples`, and `Reds`.
"""
function color_theme(cname="Blues", len=16)
    cm = convert(Array{Colors.RGB{ColorU8},1}, Colors.colormap(cname, len))
    return hcat([ Cint[c.r.i, c.g.i, c.b.i] for c in cm]...)'
end


function theme!(thm = :Default)
    global THEME

    THEME = if thm == :Gadfly
        gadfly_theme()
    elseif thm == :Default
        nothing
    elseif isa(thm, Matrix{Cint})
        thm
    else
        THEME
    end

    return THEME
end

function fillpattern!(pat::Symbol = :Solid; inclination = [450], spacing = [1000])
    if pat == :Solid
        plpsty(0)
    elseif pat == :Straight
        plpsty(1)
    elseif pat == :Angle
        plpsty(3)
    elseif pat == :Custom
        @assert 1 <= length(inclination) <= 2 "Cannot set more less than 1 and more than 2 patterns"
        @assert length(inclination) == length(spacing)
        plpat(length(inclination), convert(Vector{PLINT}, inclination),  convert(Vector{PLINT}, spacing))
    else
        plpsty(0)
    end
end

