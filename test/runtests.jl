println("Resolving package dependencies:")
#Pkg.resolve() #which REQUIRE does it look at?  The one in julia directory.
Pkg.add("Typeclass")
Pkg.add("Graphs")
Pkg.add("Docile")

println("Adding src to path")
#srcpath=joinpath(cd(pwd,".."),"src")
srcpath=joinpath(pwd(),"src")
push!(LOAD_PATH, srcpath)

println("Running tests:")

include("monoidalcategories.jl")
include("closedcompactcategories.jl")
include("finitetensorsignatures.jl")
include("wellsupportedclosedcompactcategories.jl")

#include("intepretations.jl")
#include("binbraket.jl")
include("onecobs.jl")

