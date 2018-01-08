using BinDeps

@BinDeps.setup

version = "5.13.0"
plplot_arc = "PLplot-plplot-$version"
plplot_url = "https://github.com/PLplot/PLplot/archive/plplot-$version.tar.gz"
shapelib_arc = "shapelib-1.3.0"
shapelib_url = "http://download.osgeo.org/shapelib/$(shapelib_arc).zip"

libplplot = library_dependency("libplplot")

srcdir = joinpath(BinDeps.srcdir(libplplot))
incdir = joinpath(BinDeps.includedir(libplplot))
libdir = joinpath(BinDeps.libdir(libplplot))
instdir = joinpath(BinDeps.usrdir(libplplot))

provides(Sources, URI(plplot_url), libplplot, unpacked_dir=plplot_arc)

shapelib_dir = joinpath(srcdir, shapelib_arc)
libplplot_dir = joinpath(srcdir, plplot_arc)
libplplotbuild = joinpath(libplplot_dir, "build")
libplplotfile = joinpath(libdir, libplplot.name*"."*Libdl.dlext)

provides(BuildProcess,
    (@build_steps begin
        CreateDirectory(libdir)
        CreateDirectory(incdir)
        @build_steps begin
            BinDeps.prepare_src(BinDeps.depsdir(libplplot), shapelib_url, "$(shapelib_arc).zip", shapelib_arc)
            @build_steps begin
                ChangeDirectory(joinpath(BinDeps.depsdir(libplplot), "src", shapelib_arc))
                MakeTargets(shapelib_dir, ["lib"])
                `cp $(joinpath(shapelib_dir, "libshp.a")) $libdir`
                `cp $(joinpath(shapelib_dir, "shapefil.h")) $incdir`
            end
        end
        @build_steps begin
            GetSources(libplplot)
            CreateDirectory(libplplotbuild)
            @build_steps begin
                ChangeDirectory(libplplotbuild)
                FileRule(libplplotfile, @build_steps begin
                    `cmake -DHAVE_SHAPELIB=ON -DENABLE_fortran=OFF -DENABLE_python=OFF -DENABLE_cxx=OFF -DBUILD_TEST=OFF -DCMAKE_INSTALL_PREFIX=$(instdir) ..`
                    `make install`
                end)
            end
        end
    end), [libplplot], os = :Unix)

provides(Binaries,
    URI("https://github.com/wildart/PLplot.jl/releases/download/v0.1.0/libplplot-$(version)-julia-$VERSION-x86_64.tar.gz"),
    libplplot,
    unpacked_dir=".", os = :Windows)

@BinDeps.install Dict( :libplplot => :libplplot )
