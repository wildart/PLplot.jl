# PLplot package for Julia [![Build Status](https://travis-ci.org/wildart/PLplot.jl.svg?branch=master)](https://travis-ci.org/wildart/PLplot.jl)

[PLplot](http://plplot.sourceforge.net/) is a cross-platform software package for creating scientific plots.

## Installation

0. Requirements: CMake 3.0.2, GCC, Julia 0.4-dev

1. Download, build and install `shapelib`
```bash
> curl -O http://download.osgeo.org/shapelib/shapelib-1.3.0.zip && unzip shapelib-1.3.0.zip
> cd shapelib-1.3.0
> make lib_install
```

2. Build PLplot library (install all requirement before) and disable all binding except `QT`
```bash
> git clone git://git.code.sf.net/p/plplot/plplot plplot
> cd plplot
> mkdir build
> cd build
> cmake .. -DHAVE_SHAPELIB=ON -DCMAKE_INSTALL_PREFIX=<intallation_directory>
> make
> make install
```

3. Clone package
```julia
julia> Pkg.clone("https://github.com/wildart/PLplot.jl")
```

5. Currently there is no binary installation script provided, so package has to be manually setup to work with `libplplot`. Edit `__init__` function in `PLplot.jl`, so  global constant `libplplot` would contain path to `libplplot` library.


6. See `examples` directory for usage examples or [PLplot documentation](http://plplot.sourceforge.net/documentation.php)

## TODO
- [ ] Wrap PLplot functions (115/172)
- [ ] High-level plotting interface
- [ ] Binary installation
- [ ] Documentation