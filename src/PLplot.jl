module PLplot

include("wrapper.jl")

function verison()
    pver = convert(Ptr{Cchar}, Libc.malloc(80))
    plgver(convert(Cstring, pver))
    ver = bytestring(pver)
    Libc.free(pver)
    return VersionNumber(ver)
end

function __init__()
    global const libplplot = "/home/art/.local/lib/libplplot.so"
end

end # module
