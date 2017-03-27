@enum PlotType SVG PNG JPEG PDF

"Inline plot wrapper"
immutable Plot{T}
    blob::Array{UInt8}
end

function Base.show(io::IO, ::MIME"text/plain", p::Plot)
    ptype = typeof(p).parameters |> first
    print(io, "PLplot($ptype, $(length(p.blob)) bytes)")
end

function Base.show(io::IO, ::MIME"image/svg+xml", p::Plot{SVG})
    write(io, p.blob)
end

function Base.show(io::IO, ::MIME"image/png", p::Plot{PNG})
    write(io, p.blob)
end

function Base.show(io::IO, ::MIME"image/jpeg", p::Plot{PNG})
    write(io, p.blob)
end

function Base.show(io::IO, ::MIME"application/pdf", p::Plot{PDF})
    write(io, p.blob)
end