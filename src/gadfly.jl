import PLplot

type PLPPropertyState
    stroke::RGBA{Float64}
    fill::RGBA{Float64}
    lwidth::Float64
end

type PLPPropertyFrame
    # Vector properties in this frame.
    vector_properties::Dict{Type, Property}

    # True if this property frame has scalar properties. Scalar properties are
    # emitted as a group {scope} that must be closed when the frame is popped.
    has_scalar_properties::Bool

    function PLPPropertyFrame()
        return new(Dict{Type, Property}(), false)
    end
end

type PLP <: Backend
    # Image size in millimeters.
    width::Float64
    height::Float64

    stroke::RGBA{Float64}
    fill::RGBA{Float64}
    lwidth::Float64

    driver::String
    stream::Int32

    state_stack::Vector{PLPPropertyState}
    property_stack::Vector{PLPPropertyFrame}
    vector_properties::Dict{Type, Union(Nothing, Property)}

    # True when finish has been called and no more drawing should occur
    finished::Bool

    function PLP(driver, width, height)
        width = size_measure(width)
        height = size_measure(height)
        img = new()
        img.driver = driver
        img.width  = width.abs
        img.height = height.abs
        img.stroke = default_stroke_color == nothing ?
                        RGBA{Float64}(0, 0, 0, 0) : convert(RGBA{Float64}, default_stroke_color)
        img.fill   = default_fill_color == nothing ?
                        RGBA{Float64}(0, 0, 0, 0) : convert(RGBA{Float64}, default_fill_color)
        img.state_stack = Array(PLPPropertyState, 0)
        img.property_stack = Array(PLPPropertyFrame, 0)
        img.vector_properties = Dict{Type, Union(Nothing, Property)}()
        img.finished = false

        PLplot.plsdev(img.driver)
        PLplot.plinit()
        PLplot.pladv(0)
        #PLplot.plenv( 0.0, img.width, 0.0, img.height, 0, -2 )

        return img
    end
end

function root_box(img::PLP)
    AbsoluteBoundingBox(0.0, 0.0, img.width, img.height)
end

function push_property_frame(img::PLP, properties::Vector{Property})
    isempty(properties) && return

    frame = PLPPropertyFrame()
    applied_properties = Set{Type}()
    scalar_properties = Array(Property, 0)
    for property in properties
        if isscalar(property) && !(typeof(property) in applied_properties)
            push!(scalar_properties, property)
            push!(applied_properties, typeof(property))
            frame.has_scalar_properties = true
        elseif !isscalar(property)
            frame.vector_properties[typeof(property)] = property
            img.vector_properties[typeof(property)] = property
        end
    end

    push!(img.property_stack, frame)
    isempty(scalar_properties) && return

    save_property_state(img)
    for property in scalar_properties
        apply_property(img, property.primitives[1])
    end

    fillstroke(img)
end

function pop_property_frame(img::PLP)
    @assert !isempty(img.property_stack)
    frame = pop!(img.property_stack)

    if frame.has_scalar_properties
        restore_property_state(img)
    end

    for (propertytype, property) in frame.vector_properties
        img.vector_properties[propertytype] = nothing
        for i in length(img.property_stack):-1:1
            if haskey(img.property_stack[i].vector_properties, propertytype)
                img.vector_properties[propertytype] =
                    img.property_stack[i].vector_properties[propertytype]
            end
        end
    end
    fillstroke(img)
end

function save_property_state(img::PLP)
    push!(img.state_stack,
        PLPPropertyState(
            img.stroke,
            img.fill,
            img.lwidth)
        )
end

function restore_property_state(img::PLP)
    state = pop!(img.state_stack)
    img.stroke = state.stroke
    img.fill = state.fill
    img.lwidth = state.lwidth
end

function finish(img::PLP)
    if img.finished
        return
    end

    while !isempty(img.property_stack)
        pop_property_frame(img)
    end

    img.finished = true
    PLplot.plend()
end

isfinished(img::PLP) = img.finished

function draw(img::PLP, form::Form)
    for (idx, primitive) in enumerate(form.primitives)
        draw(img, primitive)
    end
end

function draw(img::PLP, prim::PolygonPrimitive)
    isempty(prim.points) && return

    paths = make_paths(prim.points)
    for path in paths
        x = Float64[]
        y = Float64[]
        for p in path
            push!(x, p.x.abs)
            push!(y, p.y.abs)
        end
        push!(x, x[1])
        push!(y, y[1])
        PLplot.plline(length(x), x, y)
    end
end


function draw(img::PLP, prim::CirclePrimitive)
    plarc(x, y, a, b, angle1, angle2, rotate, img.fill)
end

function apply_property(img::PLP, p::LineWidthPrimitive)
    img.lwidth = p.value.abs
end

function apply_property(img::PLP, p::StrokePrimitive)
    img.stroke = p.color
end

function apply_property(img::PLP, p::StrokeOpacityPrimitive)
    img.stroke = RGBA{Float64}(img.stroke.c, p.value)
end

function apply_property(img::PLP, p::FillPrimitive)
    img.fill = p.color
end

function apply_property(img::PLP, p::FillOpacityPrimitive)
    img.fill = RGBA{Float64}(img.fill.c, p.value)
end

function Base.convert(::Type{NTuple{3,Int32}}, c::RGB{Float64})
    return round(Int32, c.r*255), round(Int32, c.b*255), round(Int32, c.b*255)
end

function fillstroke(img::PLP)
    # line width
    PLplot.plwidth(img.lwidth)
    # fill (background)
    PLplot.plscol0a(0, convert(NTuple{3,Int32}, img.fill.c)..., img.fill.alpha)
    # stroke (foreground)
    PLplot.plscol0a(1, convert(NTuple{3,Int32}, img.stroke.c)..., img.stroke.alpha)
end

# No-op SVG+JS only properties
function apply_property(img::Image, property::JSIncludePrimitive)
end

function apply_property(img::Image, property::JSCallPrimitive)
end

function apply_property(img::Image, property::SVGIDPrimitive)
end

function apply_property(img::Image, property::SVGClassPrimitive)
end

function apply_property(img::Image, property::SVGAttributePrimitive)
end