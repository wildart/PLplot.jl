type SVG
   s::Array{UInt8}
end
Base.show(io::IO, ::MIME"image/svg+xml", x::SVG) = write(io, x.s)

type PNG
   s::Array{UInt8}
end
Base.show(io::IO, ::MIME"image/png", x::PNG) = write(io, x.s)
