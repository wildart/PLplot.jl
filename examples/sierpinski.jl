using Compose

function sierpinski(n::Int)
    if n == 0
        compose(context(), polygon([(1,1), (0,1), (1/2, 0)]))
    else
        t = sierpinski(n - 1)
        compose(context(),
                (context(1/4,   0, 1/2, 1/2), t),
                (context(  0, 1/2, 1/2, 1/2), t),
                (context(1/2, 1/2, 1/2, 1/2), t))
    end
end

img = PLP("xwin", 4inch, 4(√3/2)inch)
p = compose(sierpinski(6), linewidth(0.1mm), fill(nothing), stroke("tomato"));
draw(img, p)
