# PLplot package for Julia

[PLplot](http://plplot.sourceforge.net/) is a cross-platform software package for creating scientific plots.

## Installation

1. Requirements: julia (v0.4-), cmake (v3.0.2), gcc, libqhull, libfreetype

2. Clone package
```julia
julia> Pkg.clone("https://github.com/wildart/PLplot.jl")
julia> Pkg.build("PLplot")
```

3. Plot some data
```julia
using PLplot
plot(:xwin, rand(10), pch='⋄', typ=:overlay)
```

4. See `examples` directory for some examples or [PLplot documentation](http://plplot.sourceforge.net/documentation.php)


## TODO
- [x] Wrap PLplot functions
- [x] High-level `plot` function
- [x] More high-level plotting functions
- [x] Binary installation
- [ ] Documentation
