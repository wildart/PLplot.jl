module PLplot

    # Link dependency
    depsfile = joinpath(dirname(@__FILE__),"..","deps","deps.jl")
    if isfile(depsfile)
        include(depsfile)
    else
        error("PLplot binary not properly installed. Please run Pkg.build(\"PLplot\")")
    end

    include("wrapper.jl")

    function verison()
        pver = convert(Ptr{Cchar}, Libc.malloc(80))
        plgver(convert(Cstring, pver))
        ver = bytestring(pver)
        Libc.free(pver)
        return VersionNumber(ver)
    end

end # module
