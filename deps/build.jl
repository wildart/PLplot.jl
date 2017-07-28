using BinDeps

@BinDeps.setup

version = "5.12.0"
versha = "eaacae285937a991e23fb34aeebc12a789be12a8"
plplot_arc = "plplot-plplot-$versha"
plplot_url = "https://sourceforge.net/code-snapshots/git/p/pl/plplot/plplot.git/plplot-plplot-$versha.zip"
shapelib_arc = "shapelib-1.3.0"
shapelib_url = "http://download.osgeo.org/shapelib/$(shapelib_arc).zip"

libshp = library_dependency("libshp")
libplplot = library_dependency("libplplot")

srcdir = joinpath(BinDeps.srcdir(libplplot))
incdir = joinpath(BinDeps.includedir(libplplot))
libdir = joinpath(BinDeps.libdir(libplplot))
instdir = joinpath(BinDeps.usrdir(libplplot))

provides(Sources, URI(shapelib_url), libshp)
provides(Sources, URI(plplot_url), libplplot)
provides(Binaries,URI("https://github.com/wildart/PLplot.jl/releases/download/v0.1.0/libplplot-$(version)-julia-$VERSION-x86_64.tar.gz"),
         libplplot,
         unpacked_dir=BinDeps.libdir(libplplot),
         os = :Windows)

shapelib_dir = joinpath(srcdir, shapelib_arc)
libshp_file = libshp.name*".a"

libplplot_dir = joinpath(srcdir, plplot_arc)
libplplotbuild = joinpath(libplplot_dir, "build")
libplplotfile = joinpath(libdir, libplplot.name*"."*Libdl.dlext)

provides(BuildProcess,
    (@build_steps begin
        CreateDirectory(libdir)
        CreateDirectory(incdir)
        @build_steps begin
            GetSources(libshp)
            FileRule(joinpath(shapelib_dir, libshp_file), @build_steps begin
                MakeTargets(shapelib_dir, ["lib"])
                `cp $(joinpath(shapelib_dir, libshp_file)) $libdir`
                `cp $(joinpath(shapelib_dir, "shapefil.h")) $incdir`
            end)
        end
        @build_steps begin
            GetSources(libplplot)
            CreateDirectory(libplplotbuild)
            @build_steps begin
                ChangeDirectory(libplplotbuild)
                FileRule(libplplotfile, @build_steps begin
                    `cmake -DHAVE_SHAPELIB=ON -DENABLE_f95=OFF -DENABLE_python=OFF -DENABLE_cxx=OFF -DBUILD_TEST=OFF -DCMAKE_INSTALL_PREFIX=$(instdir) ..`
                    `make install`
                end)
            end
        end
    end), [libplplot, libshp])

@BinDeps.install Dict( :libplplot => :libplplot )
