module temp
using FiniteTensorSignatures, Base.Test

@test FTS("f:a⊗b→c,g:a→b⊗c")==FTS("f:a⊗b→c, g:a→b⊗c")

fts"f:a⊗b→c,g:a→b⊗c,h:I->a"

# tests that I and id(I) work correctly
# O=FiniteTensorSignatures.OWord
# @test O(:A)⊗O(:())⊗munit(O((:B))).word==O(:A).word
@test id(dom(h))⊗f == f
@test f⊗id(dom(h)) == f

end
