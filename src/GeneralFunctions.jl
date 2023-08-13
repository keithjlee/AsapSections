"""
    is_counter_clockwise(points::Matrix{Float64})

Checks if a series of points that define a polygon are ordered in a counter-clockwise orientation
"""
function is_counter_clockwise(points::Matrix{Float64})
    npoints = size(points)[2]

    summation = 0.

    for i = 1:npoints
        x1, y1 = points[:, i]
        x2, y2 = i == npoints ? points[:, 1] : points[:, i+1]

        summation += (x2 - x1) * (y2 + y1)
    end

    summation < 0 ? true : false
end

"""
    poly_area(points::Matrix{Float64})

Get the area of a polygon defined by a series of vertices in a [2 × n] matrix
"""
function poly_area(points::Matrix{Float64})
    ndims, npoints = size(points)

    @assert ndims == 2

    A = 0.

    for i = 1:npoints
        x1, y1 = points[:, i]
        x2, y2 = i == npoints ? points[:, 1] : points[:, i+1]

        A += (x2 + x1) * (y2 - y1)
    end

    A / 2
end

"""
poly_area(points::Vector{Vector{Float64}})

Get the area of a polygon defined by a vector of vertices
"""
function poly_area(points::Vector{Vector{Float64}})
    npoints = length(points)

    A = 0.

    for i = 1:npoints
        x1, y1 = points[i]
        x2, y2 = i == npoints ? points[1] : points[i+1]

        A += (x2 + x1) * (y2 - y1)
    end

    A / 2
end

"""
    section_properties!(solid::Polygon)

Populates the following section properties of a polygon:
- area::Float64 area of polygon
- centroid::Vector{Float64} centroid of polygon [Cx, Cy]
- Ix::Float64 moment of inertia about X axis about centroid
- Sx::Float64 critical section modulus about X axis about centroid
- Iy::Float64 moment of inertia about Y axis about centroid
- Sy::Float64 critical section modulus about Y axis about centroid

"""
function section_properties!(solid::PolygonalSection)

    #initialize
    Ix = 0. #moment of inertia w/r/t global x
    Iy = 0. #moment of inertia w/r/t global y
    A = 0. #area
    Ccx = 0. #centroid x-position
    Ccy = 0. #centroid y-position

    #area properties w/r/t origin [0., 0.]
    for i = 1:solid.npoints

        x1, y1 = solid.points[:, i]
        x2, y2 = i == solid.npoints ? solid.points[:, 1] : solid.points[:, i+1]

        base = (x1 * y2 - x2 * y1)

        Cx_increment = (y1^2 + y1 * y2 + y2^2)
        Cy_increment = (x1^2 + x1 * x2 + x2^2)

        Ix += base * Cx_increment
        Iy += base * Cy_increment

        A += (x2 + x1) * (y2 - y1)

        Ccx += Cx_increment * (x1 - x2)
        Ccy += Cy_increment * (y2 - y1)

    end
    
    #normalize
    Ix /= 12
    Iy /= 12
    A /= 2
    Cx = Ccy / 6 / A
    Cy = Ccx / 6 / A
    
    #shift rotation axis to centroid
    Ix = Ix - A * Cy^2
    Iy = Iy - A * Cx^2

    #critical extreme fiber distances
    Sx_offset = maximum(abs.(extrema(solid.points[2, :]) .- Cy))
    Sy_offset = maximum(abs.(extrema(solid.points[1, :]) .- Cx))

    #critical section modulii
    Sx = Ix / Sx_offset
    Sy = Iy / Sy_offset

    #extrema
    xmin, xmax = extrema(solid.points[1, :])
    ymin, ymax = extrema(solid.points[2, :])

    #populate
    solid.centroid = [Cx, Cy]
    solid.area = A
    solid.Ix = Ix
    solid.Sx = Sx
    solid.Iy = Iy
    solid.Sy = Sy
    solid.xmin = xmin
    solid.xmax = xmax
    solid.ymin = ymin
    solid.ymax = ymax
end

function center_at_centroid!(section::PolygonalSection)
    section.points .-= section.centroid
    section.points_circular .-= section.centroid
    section.xmin -= section.centroid[1]
    section.xmax -= section.centroid[1]
    section.ymin -= section.centroid[2]
    section.ymax -= section.centroid[2]

    section.centroid = [0., 0.]
end