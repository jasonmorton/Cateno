using Typeclass,MonoidalCategories
#import OneCobs automatic from below
import OneCobs.OneCob
import FiniteTensorSignatures.ObjectWord

import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘,σ
export dom,cod,id,munit,⊗,∘

import MonoidalCategories:ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma
export dual,transp,ev,coev,tr,Hom,sigma


#
# There are two monoidal categories in OneCob: the monoidal category of the
# underlying closed compact category which is being modeled,
# (all ops are primitive) and the enveloping monoidal category (the usual
# OneCob) in which the objects are plus-minus lists (possibly partitioned)
# and the morphism are 1-cobordisms.
# 


# first the internal category; interpreting a word of a closed compact category
# over one object in this category returns the normal form.
#typeallias PM Array{OneCobs.PortPair,1}

immutable OneCobObject
    nwires::Integer
end

@instance MonoidalCategory OneCobObject OneCob begin
    dom(f::OneCob) = OneCobObject(length(f.outerports.dom))
    cod(f::OneCob) = OneCobObject(length(f.outerports.cod))
    id(A::OneCobObject) = OneCob.id(A.nwires) 
    compose(f::OneCob,g::OneCob) = OneCobs.gcompose(f,g)
    otimes(f::OneCob,g::OneCob) = OneCobs.gotimes(f,g)
    otimes(A::OneCobObject,B::OneCobObject) = OneCobObject(A.nwires + B.nwires)
    munit(A::OneCobObject) = OneCobObject(0)
end


@instance ClosedCompactCategory OneCobObject OneCob begin
    dual(A::OneCobObject) = A
    ev(A::OneCobObject) = OneCob.ev(A.nwires)
    coev(A::OneCobObject)  = OneCob.coev(A.nwires)
    sigma(A::OneCobObject,B::OneCobObject) = error("Not Implemented yet")
end


#almost there for a TS over one object.  Just convert ObjectWord to its length.


# @instance ClosedCompactCategory PM OneCob begin
#     end

# 1 write an interpretation OneCobordismOf::FTS->FTS which turns term=(∘(∘,ev(A), (⊗,id(dual(A)),f)),coev(dual(A))) into the above cob word


# really should use wrapper pattern.  Define the minimal onecob as the contents, type with objects and stuff.  So MonCat it with one nothing object, then do a typed version.


# here is the category we will represent in to compute normal form.
type WrappedObjectWord
    contents::ObjectWord
end
==(A::WrappedObjectWord,B::WrappedObjectWord)= A.contents==B.contents


type WrappedOneCob #{Ob}
    dom::WrappedObjectWord
    cod::WrappedObjectWord
    contents::OneCob
end

nwires(A::WrappedObjectWord) = length(FiniteTensorSignatures.flattenotree(A.contents.contents.word))
                                                                   
@instance MonoidalCategory WrappedObjectWord WrappedOneCob begin
    # dom and cod are functions of the OneCob's outerports' signs
    # for (dual vs primal) and the label, which must be dualizable
    # for example ev(A) has dom I and cod A_⊗A
    dom(f::WrappedOneCob) = f.dom
        # label = f.label
        # domsymbols = f.outerports.dom
        # codsymbols = f.outerports.cod
        # domsigns   = f.domsigns
        # codsigns   = f.codsigns
    cod(f::WrappedOneCob) = f.cod
    id(A::WrappedObjectWord) = WrappedOneCob(A,A,OneCobs.id(nwires(A)))
    compose(f::WrappedOneCob,g::WrappedOneCob) = WrappedOneCob(dom(g),cod(f),OneCobs.gcompose(f.contents,g.contents))
    otimes(f::WrappedOneCob,g::WrappedOneCob) = WrappedOneCob(dom(g),cod(f),OneCobs.gotimes(f.contents,g.contents))
    otimes(A::WrappedObjectWord,B::WrappedObjectWord) = WrappedObjectWord(A.contents ⊗ B.contents)
    munit(A::WrappedObjectWord) =  WrappedObjectWord(munit(A.contents))
end


@instance ClosedCompactCategory WrappedObjectWord WrappedOneCob begin
    dual(A::WrappedObjectWord) = WrappedObjectWord(dual(A.contents))
    ev(A::WrappedObjectWord) = WrappedOneCob(dual(A)⊗A,munit(A),OneCobs.ev(nwires(A)))
    coev(A::WrappedObjectWord)  = WrappedOneCob(munit(A),A⊗dual(A),OneCobs.coev(nwires(A)))
    
    sigma(A::WrappedObjectWord,B::WrappedObjectWord) = error("Not Implemented yet")
end



#something like
#  R=Representation(T,MonoidalCategory,Dict([(X,WrappedObjectWord(X))]),Dict([(f,OneCobs.id(1))]))

#  include("OneCobAsMC.jl")
# using FiniteTensorSignatures; fts"f:A->A"
# ev(A)
# ev(WrappedObjectWord(A))
#ev(WrappedObjectWord(A))∘coev(WrappedObjectWord(dual(A)))

