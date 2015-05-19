module TestWellSupportedClosedCompactCategories
using Base.Test
using IntMat

#check Special Commutative Frobenius Algebra axioms

#using IntMat representation
#algebra and coalgebra
@test mu(4) ∘ (id(4) ⊗ u(4))==id(4)
@test mu(4) ∘ (u(4) ⊗ id(4))==id(4)
@test (epsilon(5) ⊗ id(5) ) ∘ delta(5)  == id(5)
@test (id(5) ⊗ epsilon(5) ) ∘ delta(5)  == id(5)

#associativity 
@test mu(3) ∘ (mu(3) ⊗ id(3)) == mu(3) ∘ (id(3) ⊗ mu(3))
@test (delta(4) ⊗ id(4))∘ delta(4) ==  (id(4) ⊗ delta(4)) ∘ delta(4)

# special
@test mu(3) ∘ (id(3) ⊗ id(3))∘ delta(3) ==id(3)
# commutative
@test mu(4) ∘ sigma(4,4) == mu(4)
@test  sigma(4,4) ∘delta(4) == delta(4)
# Frobenius axioms
@test all([delta(i) ∘ mu(i) == (id(i) ⊗ mu(i)) ∘ (delta(i) ⊗ id(i)) for i=1:10])
@test all([delta(i)∘mu(i) == (mu(i)⊗id(i)) ∘ (id(i)⊗delta(i)) for i=1:10])

#compatibility with closed compact structure
@test epsilon(5) ∘ mu(5) == ev(5)
@test  delta(5) ∘ u(5) == coev(5)

println("Well Supported Closed Compact Categories tests passed")
end #module TestWellSupportedClosedCompactCategories
