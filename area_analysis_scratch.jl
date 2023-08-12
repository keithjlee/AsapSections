using AsapSections, kjlMakie, AsapToolkit
include("test_utilities.jl")

# test hollow circle
n = 200
thet_range = range(0, 2pi, n)

r1 = 200.
r2 = 500.

pts2 = hcat([r2 .* [cos(thet), sin(thet)] for thet in thet_range]...)

solid = SolidSection(pts2)

pts = Point2.(eachcol(solid.points))
pts_lines = [pts; [pts[1]]]

newpoints = sutherland_hodge(solid, 350.)

newsolid = SolidSection(hcat(newpoints...))

fig, ax = lines(pts_lines, axis = (aspect = DataAspect(),))
scatter!(ax, pts)

@time y, A = depth_map(solid)

Atarget = 5e5
@time d_required = depth_from_area(solid, Atarget)

@time Asol = area_from_depth(solid, d_required)

begin
    pts = Point2.(eachcol(solid.points))
    pts_lines = [pts; [pts[1]]]

    fig = Figure()
    ax = Axis(fig[1,1],
        aspect = DataAspect())

    lines!(pts_lines)

    ax2 = Axis(fig[1,2],
        aspect = nothing,
        xlabel = "Cumulative Area",
        ylabel = "Depth")

    ymax = maximum(solid.points[2, :])
    lines!(A, ymax .- y)


    hlines!([ymax - d_required], color = :black)

    fig
end