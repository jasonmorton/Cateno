using MonoidalCategories,FiniteTensorSignatures,Representations,IntMat
eval(fts"f:a⊗b→c")
od=Dict([(:a,2),(:b,2),(:c,3)])
md=Dict([(:f,randn((3,4)))])
r=Representation(T,MonoidalCategory,od,md)
r.value(f⊗f)

#show throws if F doesn't respect domains

workspace()
eval(fts"f:a⊗b→c,g:c→a⊗b")
od=Dict([(:a,2),(:b,2),(:c,3)])
md=Dict([(:f,randn((3,4)))])
r=Representation(T,MonoidalCategory,od,md) #fails because g not assigned
md=Dict([(:f,randn((3,4))),(:g,randn(4,3))])
r=Representation(T,MonoidalCategory,od,md) #fails because g not assigned
F=r.value

F(f∘g) 
F((f⊗f)∘g) #throws before applying functor


#now @time F(f)∘F(g) is fast, but F(f∘g) much slower.  Disappears for
#  @time F(f^{⊗5}∘g^{⊗5}); 
#vs 
#  @time F(f^{⊗5})∘(g^{⊗5}); 
