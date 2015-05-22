using Typeclass,MonoidalCategories
import OneCobs.OneCob #implies import OneCobs 
import FiniteTensorSignatures:ObjectWord,MorphismWord

import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘,σ
export dom,cod,id,munit,⊗,∘

import MonoidalCategories:ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma
export dual,transp,ev,coev,tr,Hom,sigma

import Representations


# There are two monoidal categories relevant to OneCob: the monoidal category
# of the underlying closed compact category which is being modeled,
# (all ops are primitive) and the enveloping monoidal category (the usual
# OneCob) in which the objects are plus-minus lists (possibly partitioned)
# and the morphism are 1-cobordisms.
# 
# First the internal category; interpreting a word of a closed compact category
# over one object in this category returns the normal form.

################################################################################
# Internal Category: Representation gives normal form
################################################################################

# We used the wrapped category pattern.  The "data" category is OneCob, with objects just a count of wires to do some basic dom/cod checking.  Mismatches between wires of a different color must be caught in the wrapped category below.  We could have used one object, nothing, as the object here.

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


#  For a TS over one object, just convert ObjectWord to its length to interpret in this category.


# 1 write an interpretation OneCobordismOf::FTS->FTS which turns term=(∘(∘,ev(A), (⊗,id(dual(A)),f)),coev(dual(A))) into the above cob word





# Here is the "typed wrapper" category we will represent in to compute normal form.  It uses FiniteTensorSignatures.ObjectWord as the object type wrapper.
type WrappedObjectWord
    contents::ObjectWord
end
==(A::WrappedObjectWord,B::WrappedObjectWord)= A.contents==B.contents
nwires(A::ObjectWord) = length(FiniteTensorSignatures.flattenotree(A.contents.word))
nwires(A::WrappedObjectWord) = nwires(A.contents)


type WrappedOneCob #{Ob}
    dom::WrappedObjectWord
    cod::WrappedObjectWord
    contents::OneCob
end


                                                                   
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


function rep(w::MorphismWord)
    T=w.signature
    obdict = Dict([(X,WrappedObjectWord(X)) for X in T.obvars])
    mordict = Dict([(f::Symbol,
                     OneCobs.morvar(nwires(T.dom(f)),
                                    nwires(T.cod(f)),
                                    f)
                     )
                    for f in w.signature.morvars])
    R=Representation(w.signature,           # the FTS
                     ClosedCompactCategory, # the doctrine
                     obdict,
                     mordict)
    R.value(w)
end


#strategies: should give same answer
#1 call MorphismWord recursively
#2 compute the Expr directly from the OneCob, apply type at end

function OneCobToExpr(oc::OneCob)
    if oc
end

@doc """
A particular choice of how to get a MorphismWord from a WrappedOneCob.  In general choosing an optimal MorphismWord is NP-hard, since for example it subsumes the problem of finding an optimal junction tree.
""" -> 
function MWfromOC(oc::WrappedOneCob)
    MorphismWord(OneCobToExpr(oc.contents,oc.dom.signature, oc.dom.contents, oc.cod.contents)
end

@doc """
The normal form obtained by 
1. Interpreting the given CCC MorphismWord in OneCob and simplifying to obtain a 0-ary op
2. Applying the mwfoc choice of how to get a MorphismWord from a WrappedOneCob.
""" -> 
function OCNF(w::MorphismWord, mwfoc::Function)
    mwfoc(rep(w))
end
    


#something like
#  R=Representation(T,MonoidalCategory,Dict([(X,WrappedObjectWord(X))]),Dict([(f,OneCobs.id(1))]))

#  include("OneCobAsMC.jl")
# using FiniteTensorSignatures; fts"f:A->A"
# ev(A)
# ev(WrappedObjectWord(A))
#ev(WrappedObjectWord(A))∘coev(WrappedObjectWord(dual(A)))

################################################################################
# External Category.
# Given a word w over a FTS T in a CCC, EC(w) is a word over (a copy of T)
# such that the diagrammatic representation of EC(w) is the cobordism.
# actually this has nothing to do with OneCob per se, and is just a
# transformation of the word w.  Implemented in FiniteTensorSignatures.jl
################################################################################




    
