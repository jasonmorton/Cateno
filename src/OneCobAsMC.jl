using MonoidalCategories, Typeclass
#import OneCobs automatic from below
import OneCobs.OneCob
import FiniteTensorSignatures.ObjectWord

#
# There are two monoidal categories in OneCob: the monoidal category of the
# underlying closed compact category which is being modeled,
# (all ops are primitive) and the enveloping monoidal category (the usual
# OneCob) in which the objects are plus-minus lists (possibly partitioned)
# and the morphism are 1-cobordisms.
# 


# first the internal category; interpreting a word of a closed compact category
# over one object in this category returns the normal form.
typeallias PM Array{OneCobs.PortPair,1}

@instance MonoidalCategory PM OneCob begin
    # dom and cod are functions of the OneCob's outerports' signs
    # for (dual vs primal) and the label, which must be dualizable
    # for example ev(A) has dom I and cod A_⊗A
    function dom(f::OneCob)
        label = f.label
        domsymbols = f.outerports.dom
        codsymbols = f.outerports.cod
        domsigns   = f.domsigns
        codsigns   = f.codsigns
        
        
    end
    cod(f::OneCob) = OneCob.outerports
    id(A::PM)      = OneCob.id(A) 
    compose(f::OneCob,g::OneCob) = OneCobs.gcompose(f,g)
    otimes(f::OneCob,g::OneCob) = OneCobs.gotimes(f,g)
    otimes(A::PM,B::PM) = error("Why should I")
    munit(::PM)::PM #????
end

# @instance ClosedCompactCategory PM OneCob begin
#     end

# 1 write an interpretation OneCobordismOf::FTS->FTS which turns term=(∘(∘,ev(A), (⊗,id(dual(A)),f)),coev(dual(A))) into the above cob word


# really should use wrapper pattern.  Define the minimal onecob as the contents, type with objects and stuff.  So MonCat it with one nothing object, then do a typed version.


type WrappedOneCob #{Ob}
    dom::WrappedObjectWord
    cod::WrappedObjectWord
    contents::OneCob
end

type WrappedObjectWord
    contents::ObjectWord
end

@instance WrappedObjectWord WrappedOneCob begin
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
    id(A::WrappedObjectWord) = WrappedOneCob(A,A,OneCob.id(A)) # maybe number
                                                               # of wires in A
    compose(f::OneCob,g::OneCob) = WrappedOneCob(dom(g),cod(f),OneCobs.gcompose(f,g))
    otimes(f::OneCob,g::OneCob) = WrappedOneCob(dom(g),cod(f),OneCobs.gotimes(f,g)
    otimes(A::PM,B::PM) = error("Why should I")
    munit(::PM)::PM #????
end
