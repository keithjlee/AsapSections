module AsapSections

using LinearAlgebra

include("Sections.jl")
export SolidSection, VoidSection, CompoundSection

include("Functions.jl")
export poly_area

include("DepthAnalysis.jl")
export sutherland_hodge
export intersection
export depth_map
export area_from_depth
export depth_from_area

end # module AsapSections
