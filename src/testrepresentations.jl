using MonoidalCategories,FiniteTensorSignatures,Representations,IntMat
eval(fts"f:a⊗b→c")
od=Dict([(:a,2),(:b,2),(:c,3)])
md=Dict([(:f,randn((3,4)))])
r=Representation(T,MonoidalCategory,od,md)
r.value(f⊗f)
