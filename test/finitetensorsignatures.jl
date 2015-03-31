using FiniteTensorSignatures

@test FTS("f:a⊗b→c,g:a→b⊗c")==FTS("f:a⊗b→c, g:a→b⊗c")

T = FTS("f:a⊗b→c,g:a→b⊗c")

O=FiniteTensorSignatures.OWord
@test O(:A)⊗O(:())⊗munit(O((:B))).word==O(:A).word
