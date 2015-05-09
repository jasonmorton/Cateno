println("Resolving package dependencies:")
#Pkg.resolve() #which REQUIRE does it look at?
Pkg.add("Typeclass")
Pkg.add("Graphs")
Pkg.add("Docile")

println("Adding src to path")
#srcpath=joinpath(cd(pwd,".."),"src")
srcpath=joinpath(pwd(),"src")
push!(LOAD_PATH, srcpath)

println("Running tests:")
using Base.Test, Typeclass
#using GeneralizedTensorNetworks #.MonoidalCategories
using MonoidalCategories
import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘
include("monoidalcategories.jl")
println("Monoidalcategories tests passed")
include("finitetensorsignatures.jl")
println("FTS tests passed")

#include("intepretations.jl")
#include("closedcompactcategories.jl")
#include("binbraket.jl")
include("onecobs.jl")
println("OneCobs tests passed")
