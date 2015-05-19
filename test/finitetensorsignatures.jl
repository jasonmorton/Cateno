module FiniteTensorSignaturesTests
using FiniteTensorSignatures, Base.Test

@test FTS("f:a⊗b→c,g:a→b⊗c")==FTS("f:a⊗b→c, g:a→b⊗c")

fts"f:a⊗b→c,g:a→b⊗c,h:I->a"

# tests that I and id(I) work correctly
# O=FiniteTensorSignatures.OWord
# @test O(:A)⊗O(:())⊗munit(O((:B))).word==O(:A).word
@test id(dom(h))⊗f == f
@test f⊗id(dom(h)) == f

# joining tesor signatures
fts"S;ϕ:A->B"
merged= f ⊗ ϕ
@test merged.signature == FTS("f:a⊗b→c,g:a→b⊗c,h:I->a,ϕ:A->B")


# tests for MC axioms.  This could be generic for any new module implementing an interface, using randomly generated instantiations like typecheck.

println("Finite Tensor Signatures tests passed")
end
