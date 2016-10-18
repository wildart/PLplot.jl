using PLplot

n = 1000

x = zeros(n) 
y = zeros(n)
z = zeros(n)

for i in 1:n
    z[i] = -1. + 2. * i / n
    r = z[i] # 1. - i / n
    x[i] = r * cos(12π * i / n)
    y[i] = r * sin(12π * i / n )
end

draw(:xwin) do opts
    # x, y & z have line points
    plot3(x, y, z, typ=:line, col=2,
          xmin=-1., xmax=1., ymin=-.9, ymax=1.1, zmin=-1.0, zmax=1.0,
          alt=45.)
    # filter points and form a matrix as a paramater
    plot3(hcat(x, y, z)[1:10:n,:], pch='*', col=3, overlay=true)
end
