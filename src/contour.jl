"""Transformation data for one-to-one mapping"""
function transform1to1(nx, ny)
    tr = zeros(PLFLT, 6)
    tr[1] = 2. / ( nx - 1. )
    tr[2] = 0.0
    tr[3] = -1.0
    tr[4] = 0.0
    tr[5] = 2. / ( ny - 1. )
    tr[6] = -1.0
    return tr
end

function transform1to1{T<:AbstractFloat}(z::AbstractMatrix{T})
    nx, ny = size(z)
    return transform1to1(nx, ny)
end

function contour{T<:AbstractFloat}(z::AbstractMatrix{T}, transform::Function; kw...)
    nx, ny = size(z)
    contour([z[i,:] for i in 1:nx], nx, ny, transform; kw...)
end

function contour{T<:AbstractFloat}(func::Function, xv::AbstractVector{T}, yv::AbstractVector{T},
                                   transform::Function; kw...)
    z = Vector{Float64}[]
    for x in xv
        tmp = func(hcat(fill(x, length(yv)), yv)')
        tmp[isinf(tmp)] = zero(T)
        push!(z, tmp)
    end

    contour(z, length(x), length(y), transform; kw...)
end

function contour(z::Vector{Vector{Float64}}, nx::Integer, ny::Integer, transform::Function; kw...)

    nlevels = 10
    clevels = nothing
    payload = C_NULL
    for (k,v) in kw
        if k == :nlevels
            nlevels = v
        elseif k == :levels
            clevels = v
            nlevels = length(v)
        elseif k == :payload
            payload=pointer_from_objref(v)
        end
    end

    # bounds
    zmax = foldr((e,v)->max(v,e[2]), -Inf, map(extrema, z))
    zmin = foldr((e,v)->min(v,e[1]), Inf, map(extrema, z))
    # levels
    if clevels === nothing
        levelInc = (ceil(zmax)-floor(zmin))/nlevels
        clevels = collect(floor(zmin):levelInc:ceil(zmax))
    end
    # transform function
    PTRTR = cfunction(transform, Void, (PLFLT, PLFLT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Void}))
    # contour plot
    println(clevels, nlevels, PTRTR, payload)
    plcont(z, nx, ny, 1, nx, 1, ny, clevels, Cint(nlevels), PTRTR, payload)
end

function mesh3d{T<:AbstractFloat}(func::Function, xv::AbstractVector{T}, yv::AbstractVector{T}; kw...)
    z = Vector{Float64}[]
    for x in xv
        tmp = func(hcat(fill(x, length(yv)), yv)')
        tmp[isinf(tmp)] = zero(T)
        push!(z, tmp)
    end
    # mesh 3d plot
    mesh3d(collect(x), collect(y), z; kw...)
end
