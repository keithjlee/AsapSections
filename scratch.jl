using AsapSections, kjlMakie

# test hollow circle
n = 100
thet_range = range(0, 2pi, n)

r1 = 200.
r2 = 500.

pts1 = hcat([r1 .* [cos(thet), sin(thet)] for thet in thet_range]...)
pts2 = hcat([r2 .* [cos(thet), sin(thet)] for thet in thet_range]...)


solid = SolidSection(pts2)
void = VoidSection(pts1)

allsections = [solid, void]

compound = CompoundSection([solid, void])

I_true = .25pi * (r2^4 - r1^4)
compound.Ix


## I beam test


w1100_499 = w_section_maker(1120, 404, 45, 26.2)

solid = SolidSection(w1100_499)

using AsapToolkit

w_sections = Vector{SolidSection}()
Ix_diff = Vector{Float64}()
Iy_diff = Vector{Float64}()
Sx_diff = Vector{Float64}()
Sy_diff = Vector{Float64}()

for w in allW()
    wgeo = w_section_maker(w.d, w.bf, w.tf, w.tw)

    section = SolidSection(wgeo)
    push!(w_sections, section)


    #testing accuracy
    Ix = (section.Ix - w.Ix) / w.Ix
    Iy = (section.Iy - w.Iy) / w.Iy
    Sx = (section.Sx - w.Sx) / w.Sx
    Sy = (section.Sy - w.Sy) / w.Sy

    push!(Ix_diff, Ix)
    push!(Iy_diff, Iy)
    push!(Sx_diff, Sx)
    push!(Sy_diff, Sy)

end

using kjlMakie

begin
    nb = 40
    fig = Figure()
    ax_ix = Axis(fig[1,1],
        title = "Ix",
        aspect = nothing)

    hist!(Ix_diff, bins = nb)

    ax_iy = Axis(fig[1,2],
        title = "Iy",
        aspect = nothing)

    hist!(Iy_diff, bins = nb)

    ax_sx = Axis(fig[2,1],
        title = "Sx",
        aspect = nothing)

    hist!(Sx_diff, bins = nb)


    ax_sy = Axis(fig[2,2],
        title = "Sy",
        aspect = nothing)

    hist!(Sy_diff, bins = nb)

    fig
end