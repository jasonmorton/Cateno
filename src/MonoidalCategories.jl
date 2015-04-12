# This module defines monoidal categories and variants as TypeClasses, 
# together with some utility functions useful for instantiation
module MonoidalCategories
export MonoidalCategory,dom,cod,id,munit,⊗,∘,comperr
export ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma,σ
export DaggerClosedCompactCategory,dagger
#export associator,associatorinv,leftunitor,rightunitor,leftunitorinv,rightunitorinv
#export lrweaktranspose


using Typeclass
import Base:show,ctranspose,transpose

@class MonoidalCategory Ob Mor begin
    dom(f::Mor)::Ob #fix in Typeclass.jl so f.dom::Ob now if we do that ret type is ignored
    cod(f::Mor)::Ob
    id(A::Ob)::Mor
    compose(f::Mor,g::Mor)::Mor 
    otimes(f::Mor,g::Mor)::Mor
    otimes(A::Ob,B::Ob)::Ob
    munit(::Ob)::Ob
    munit(f::Mor)=munit(dom(f))
    # syntax, using unicode
    ∘(f::Mor,g::Mor)=dom(f)==cod(g)?compose(f,g):comperr(f,g)
#    |(f::Mor,g::Mor)=compose(g,f)
    ⊗(f::Mor,g::Mor)=otimes(f,g)
    ⊗(A::Ob,B::Ob)=otimes(A,B) 
    ⊗(As::Array{Ob})=foldl(⊗,As) 
    ⊗(As::Array{Mor})=foldl(⊗,As) 
    ^(f::Mor,ex::Array{Any,2})= ex[1]==⊗? foldl(⊗,[f for i=1:ex[2]]): ex[1]==∘? foldl(∘,[f for i=1:ex[2]]):error("invalid exponent")
    # default strict, but stubs in case needed.  WeakMC also should be defined
    # associator(A::Ob,B::Ob,C::Ob)=id(A⊗B⊗C) #foldl->foldr
    # associatorinv(A::Ob,B::Ob,C::Ob)=id(A⊗B⊗C) 
    # leftunitor(I::Ob,A::Ob)=id(A) #I⊗A→A
    # rightunitor(A::Ob,I::Ob)=id(A)#A⊗I→A
    # leftunitorinv(A::Ob)=id(A)    #A→I⊗A
    # rightunitorinv(A::Ob)=id(A)   #A→A⊗I
end


#Assuming Ob Mor is a MonoidalCategory already
@class ClosedCompactCategory Ob Mor begin
    dual(A::Ob)::Ob
    # the following transpose requires both strict associativivity, because 
    # the grouping of the three spaces in the middle changes, and strict right
    # and left unitors, because the domain is I \ot A and codomain is A \ot I
    # for example in the graphical representation, shifts/ half swaps are 
    # required for f.' ∘ g.' to line up.
    transp(f::Mor)= (ev(cod(f))⊗id(dual(dom(f)))) ∘ (id(dual(cod(f)))⊗f⊗id(dual(dom(f)))) ∘(id(dual(cod(f))) ⊗ coev(dom(f))) 
    # Thus we provide weak versions as utilities, to make nearly-strict CCCs 
    # easier to define.
    # -Left and right unitor weak version
    # shiftdown(A::Ob)=leftunitorinv(A) ∘ rightunitor(A,munit(A)) #A⊗I→A→I⊗A 
    # shiftup(A::Ob)  =rightunitorinv(A) ∘ leftunitor(munit(A),A) #I⊗A→A→A⊗I 
    # lrweaktranspose(f::Mor)= shiftup(dual(dom(f))) ∘ transp(f) ∘ shiftup(dual(cod(f)))
    # -Associator weak version
    # assocweaktranspose(f::Mor)= (ev(cod(f))⊗id(dual(dom(f)))) ∘ (id(dual(cod(f)))⊗f⊗id(dual(dom(f)))) ∘(id(dual(cod(f))) ⊗ coev(dom(f))) 
    ev(A::Ob)::Mor #A_ \ot A ->I
    coev(A::Ob)::Mor
    Hom(A::Ob,B::Ob)=dual(A)⊗B
    sigma(A::Ob,B::Ob)::Mor
    tr(f::Mor) = (ev(dom(f))) ∘ (id(dual(dom(f))) ⊗ f) ∘ coev(dual(dom(f))) #or the other way
    #syntax
    transpose(f::Mor)=transp(f) # f.' notation.  This by default won't override.
    σ(A::Ob,B::Ob)=sigma(A,B) #not specializing for some reason
end



#Assuming Ob Mor is a CCC
# @class NonstrictClosedCompactCategory Ob Mor begin
#     leftunitor(f::Mor,id::Mor)
# end


#Assuming Ob Mor is a ClosedCompactCategory already
@class DaggerClosedCompactCategory Ob Mor begin
    dagger(A::Ob)=A
    dagger(f::Mor)::Mor
    #syntax
    ctranspose(f::MorphismWord)=dagger(f) #f' notation
end

# Utility functions
comperr(f,g)=error("Domain $(dom(f)) unequal to codomain $(cod(g))")





#next: tests for this functionality, including Interpretations
#Then: dungeon and SRel (or just implement BP for SRel)
#Then: numerical word problems (HDRA/QPL)
#Then: MC enriched over vector spaces so we can 3f+g

@class AbEnrichedCategory Ob Mor begin
    +(f::Mor,g::Mor)::Mor
    -(f::Mor,g::Mor)::Mor
    -(f::Mor)::Mor
    zero(domain::Ob,codomain::Ob)::Mor
end


end
