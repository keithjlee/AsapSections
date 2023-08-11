abstract type PolygonalSection end

mutable struct SolidSection <: PolygonalSection
    points::Matrix{Float64}
    points_circular::Matrix{Float64}
    npoints::Int64
    centroid::Vector{Float64}
    area::Float64
    Ix::Float64
    Sx::Float64
    Iy::Float64
    Sy::Float64
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64

    """
        Solid(points::Matrix{Float64})

    Create a solid section from a [2 × n] matrix of ordered 2D points
    """
    function SolidSection(points::Matrix{Float64})

        #check 2D
        @assert size(points, 1) == 2 "matrix of point positions must be [2 × n]"

        #remove duplicated end point
        if isapprox(points[:, 1], points[:, end])
            points = points[:, 1:end-1]
        end

        #ensure order of points is counterclockwise
        if !is_counter_clockwise(points)
            reverse!(points, dims = 2)
        end

        #make solid
        solid = new(points, [points points[:, 1]], size(points, 2))

        #populate section properties
        section_properties!(solid)

        return solid
    end

    """
        Solid(points::Vector{Vector{Float64}})

    Create a solid section from a vector of ordered 2D point vectors
    """
    function SolidSection(points::Vector{Vector{Float64}})

        points = hcat(points...)

        SolidSection(points)

    end
end

mutable struct VoidSection <: PolygonalSection
    points::Matrix{Float64}
    npoints::Int64
    centroid::Vector{Float64}
    area::Float64
    Ix::Float64
    Sx::Float64
    Iy::Float64
    Sy::Float64

    """
        Void(points::Matrix{Float64})

    Create a void section from a [2 × n] matrix of ordered 2D points
    """
    function VoidSection(points::Matrix{Float64})

        #check 2D
        @assert size(points, 1) == 2 "matrix of point positions must be [2 × n]"

        #remove duplicated points
        if isapprox(points[:, 1], points[:, end])
            points = points[:, 1:end-1]
        end

        #ensure order of points is clockwise
        if is_counter_clockwise(points)
            reverse!(points, dims = 2)
        end

        #make solid
        void = new(points, size(points, 2))

        #populate section properties
        section_properties!(void)

        return void

    end

    function VoidSection(points::Vector{Vector{Float64}})

        points = hcat(points...)

        Void(points)

    end
end

struct CompoundSection
    solids::Vector{SolidSection}
    voids::Vector{VoidSection}
    centroid::Vector{Float64}
    area::Float64
    Ix::Float64
    Sx::Float64
    Iy::Float64
    Sy::Float64
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64

    function CompoundSection(sections::Vector{SolidSection})

        #get centroid and area
        A = 0.
        centroid = [0., 0.]

        for section in sections
            A += section.area
            centroid += section.area * section.centroid
        end

        centroid /= A

        Cx, Cy = centroid

        #get section properties
        Ix = 0.
        Iy = 0.

        for section in sections
            Ix += section.Ix + section.area * (centroid[2] - section.centroid[2])^2
            Iy += section.Iy + section.area * (centroid[1] - section.centroid[1])^2
        end

        all_points = hcat(getproperty.(sections, :points)...)

        Sx_offset = maximum(abs.(extrema(all_points[2, :]) .- Cy))
        Sy_offset = maximum(abs.(extrema(all_points[1, :]) .- Cx))

        #critical section modulii
        Sx = Ix / Sx_offset
        Sy = Iy / Sy_offset

        #organize sections
        solids = Vector{SolidSection}()
        voids = Vector{VoidSection}()

        for section in sections
            if typeof(section) == SolidSection
                push!(solids, section)
            else
                push!(voids, section)
            end
        end

        xmin = minimum(getproperty.(section.solids, :xmin))
        xmax = maximum(getproperty.(section.solids, :xmax))
        ymin = minimum(getproperty.(section.solids, :ymin))
        ymax = maximum(getproperty.(section.solids, :ymax))

        return new(solids, voids, centroid, A, Ix, Sx, Iy, Sy, xmin, xmax, ymin, ymax)
    end
end
