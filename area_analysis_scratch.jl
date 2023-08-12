using AsapSections, kjlMakie, AsapToolkit
include("test_utilities.jl")

# test hollow circle
n = 200
thet_range = range(0, 2pi, n)

r1 = 200.
r2 = 500.

pts = hcat([r2 .* [cos(thet), sin(thet)] for thet in thet_range]...)

circle = SolidSection(pts)

offset = [0., 1250.]

circle2 = SolidSection(pts .+ offset)


barbell = CompoundSection([circle, circle2])

begin
    p1 = Point2.(eachcol(circle.points_circular))
    p2 = Point2.(eachcol(circle2.points_circular))

    fig = Figure()
    ax = Axis(fig[1,1],
        aspect = DataAspect())

    hidespines!(ax); gridtoggle!(ax)

    lines!(p1,
        color = :black)

    lines!(p2,
        color = :black)

    fig
end

@time y, A = depth_map(barbell)

begin
    fig = Figure()
    ax = Axis(fig[1,1],
        aspect = DataAspect())

    hidespines!(ax); gridtoggle!(ax)

    lines!(p1,
        color = :black)

    lines!(p2,
        color = :black)

    scatter!(Point2(barbell.centroid),
        color = blue,
        markersize = 30)


    ax2 = Axis(fig[1,2],
        aspect = nothing)

    gridtoggle!(ax2)

    lines!(A, y)

    fig
end

Atarget = 5e5
@time d_required = depth_from_area(solid, Atarget)

@time Asol = area_from_depth(solid, d_required)


begin
    pts = Point2.(eachcol(solid.points))
    pts_lines = [pts; [pts[1]]]

    fig = Figure()
    ax = Axis(fig[1,1],
        aspect = nothing)

    lines!(pts_lines)

    ax2 = Axis(fig[1,2],
        aspect = nothing,
        xlabel = "Cumulative Area",
        ylabel = "Depth")

    depth_map_points = Point2.(A, solid.ymax .- y)
    push!(depth_map_points, Point2(0., solid.ymin))
    # lines!(A, ymax .- y)
    poly!(depth_map_points)

    hlines!([ymax - d_required], color = :black)

    colsize!(fig.layout, 1, Aspect(1, 1.))

    fig
end