# This module defines monoidal categories and variants as TypeClasses, 
# together with some utility functions useful for instantiation
module MonoidalCategories
export MonoidalCategory,dom,cod,id,munit,⊗,∘,comperr
export ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma
export DaggerClosedCompactCategory,dagger

using Typeclass
import Base:show,ctranspose,transpose

@class MonoidalCategory Ob Mor begin
    dom(f::Mor)::Ob #fix in Typeclass.jl so f.dom::Ob now if we do that ret type is ignored
    cod(f::Mor)::Ob
    id(A::Ob)::Mor
    compose(f::Mor,g::Mor)::Mor #f*g
    otimes(f::Mor,g::Mor)::Mor
    otimes(A::Ob,B::Ob)::Ob
    munit(::Ob)::Ob
    munit(f::Mor)=munit(dom(f))
    # syntax, using unicode
    ∘(f::Mor,g::Mor)=dom(f)==cod(g)?compose(f,g):comperr(f,g)
#    |(f::Mor,g::Mor)=compose(g,f)
    ⊗(f::Mor,g::Mor)=otimes(f,g)
    ⊗(A::Ob,B::Ob)=otimes(A,B) 
    #⊗(As:Array{Ob})=foldl(⊗,As) # not quite but something like this is needed
    ^(f::Mor,ex::Array{Any,2})= ex[1]==⊗? foldl(⊗,[f for i=1:ex[2]]): ex[1]==∘? foldl(∘,[f for i=1:ex[2]]):error("invalid exponent")
end

#Assuming Ob Mor is a MonoidalCategory already
@class ClosedCompactCategory Ob Mor begin
    dual(A::Ob)::Ob
    transp(f::Mor)= (ev(cod(f))⊗id(dual(dom(f)))) ∘ (id(dual(cod(f)))⊗f⊗id(dual(dom(f)))) ∘(id(dual(cod(f))) ⊗ coev(dom(f))) #this only works in a strict CCC, because the grouping of the three spaces has to change.  We could check if strict and add associators to the expression.
    ev(A::Ob)::Mor
    coev(A::Ob)::Mor
    Hom(A::Ob,B::Ob)=dual(A)⊗B
    sigma(A::Ob,B::Ob)::Mor
    tr(f::Mor) = (ev(dom(f))) ∘ (id(dual(dom(f))) ⊗ f) ∘ coev(dual(dom(f))) #or the other way
    #syntax
    transpose(f::Mor)=transp(f) # f.' notation.  This by default won't override.
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
