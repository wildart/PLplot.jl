using BinDeps

@BinDeps.setup

version = "5.11.1"
plplot_arc = "plplot-$version"
plplot_url = "http://skylineservers.dl.sourceforge.net/project/plplot/plplot/$(version)%20Source/plplot-$(version).tar.gz"
shapelib_arc = "shapelib-1.3.0"
shapelib_url = "http://download.osgeo.org/shapelib/$(shapelib_arc).zip"

libshp = library_dependency("libshp")
libplplot = library_dependency("libplplot")

provides(Sources, URI(shapelib_url), libshp)
provides(Sources, URI(plplot_url), libplplot)

srcdir = joinpath(BinDeps.srcdir(libplplot))
incdir = joinpath(BinDeps.includedir(libplplot))
libdir = joinpath(BinDeps.libdir(libplplot))
instdir = joinpath(BinDeps.usrdir(libplplot))

shapelib_dir = joinpath(srcdir, shapelib_arc)
libshp_file = libshp.name*".a"

libplplot_dir = joinpath(srcdir, plplot_arc)
libplplotbuild = joinpath(libplplot_dir, "build")
libplplotfile = joinpath(libdir, libplplot.name*"."*BinDeps.shlib_ext)

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
                    `cmake -DHAVE_SHAPELIB=ON -DENABLE_f95=OFF -DENABLE_python=OFF -DENABLE_cxx=OFF -DCMAKE_INSTALL_PREFIX=$(instdir) ..`
                    `make install`
                end)
            end
        end
    end), [libplplot, libshp])

@BinDeps.install Dict( :libplplot => :libplplot )