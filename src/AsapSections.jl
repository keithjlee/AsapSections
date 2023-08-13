module AsapSections

using LinearAlgebra

include("Sections.jl")
export SolidSection, VoidSection, CompoundSection, OffsetSection

include("GeneralFunctions.jl")
export poly_area
export center_at_centroid!

include("DepthAnalysis.jl")
export sutherland_hodgman
export intersection
export depth_map
export area_from_depth
export depth_from_area

end # module AsapSections
