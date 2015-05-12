include("WeakDiagramsFor.jl")
fts"T;f:I->A⊗A_" #just need the A for cob cat.
D=diagramsfor(T,ClosedCompactCategory).value
ϕ₃ = ev(dual(A)⊗A)
ϕ₂ =ev(dual(A)⊗A)⊗id(A⊗dual(A))
ϕ₁ = id(dual(A)) ⊗ sigma(A,A) ⊗ id(dual(A))

cob= ϕ₃ ∘ (ϕ₂ ⊗ coev(dual(A))) ∘ (coev(A) ⊗ ϕ₁) ∘ (coev(dual(A)) ⊗ f )
D(cob) #draws picture from paper with Spivak on normal forms.

#goals
# 1 write an interpretation OneCobordismOf::FTS->FTS which turns term=(∘(∘,ev(A), (⊗,id(dual(A)),f)),coev(dual(A))) into the above cob word
# 2 write OneCobordismOf::FTS->OneCob which turns term into 
# afterphi1=gotimes(id(1),id(1))
# afterphi2=gcompose(ev(1),afterphi1)
# afterphi3=gcompose(afterphi2,coev(1))
# that is, using ∘,⊗
# afterphi3=∘(∘(ev(1),⊗(id(1),id(1))),coev(1)) ≈ term 
#since input to ev and id and coev is currently ignored, term should work given an interp, so just need to make OneCob into a ClosedCompactCategory

#3 get OneCobNF::FTS->FTS to work by taking the word FTS(OneCobordismOf(term))
