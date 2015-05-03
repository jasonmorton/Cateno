module GeneralizedTensorNetworks
# Core typeclass definitions
include("MonoidalCategories.jl")

#Symbolic and expression categories
include("FiniteTensorSignatures.jl")

# Graphical Categories
include("WeakWiresBoxes.jl")

# Functors
include("Representations.jl")

# Quantitative Categories
include("BinBraKet.jl")

# Operadic categories

end
