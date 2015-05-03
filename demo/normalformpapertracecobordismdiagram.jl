include("WeakDiagramsFor.jl")
fts"T;f:I->A⊗A_" #just need the A for cob cat.
D=diagramsfor(T,ClosedCompactCategory).value
ϕ₃ = ev(dual(A)⊗A)
ϕ₂ =ev(dual(A)⊗A)⊗id(A⊗dual(A))
ϕ₁ = id(dual(A)) ⊗ sigma(A,A) ⊗ id(dual(A))

cob= ϕ₃ ∘ (ϕ₂ ⊗ coev(dual(A))) ∘ (coev(A) ⊗ ϕ₁) ∘ (coev(dual(A)) ⊗ f )
D(cob) #draws picture from paper with Spivak on normal forms.