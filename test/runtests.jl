println("Resolving package dependencies:")
Pkg.resolve()

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
#include("intepretations.jl")
#include("closedcompactcategories.jl")
#include("binbraket.jl")
