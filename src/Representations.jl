module Representations
using MonoidalCategories
#import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘,comperr
#import MonoidalCategories:ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma
#import MonoidalCategories:DaggerClosedCompactCategory,dagger
using Typeclass
using FiniteTensorSignatures
# export dom,cod,id,munit,⊗,∘
# export dual,transp,ev,coev,tr,Hom,sigma
# export dagger

export Representation


#value(obvardict,morvardict,s::Symbol) = s==:I? esc(:I) : haskey(obvardict,s)?obvardict[s]:morvardict[s]
value(obvardict,morvardict,s::Symbol) = haskey(obvardict,s)?obvardict[s]:morvardict[s]
value(obvardict,morvardict,o::OWord) = value(obvardict,morvardict,o.word) 
value(obvardict,morvardict,o::ObjectWord) = value(obvardict,morvardict,o.contents) 
value(obvardict,morvardict,w::MorphismWord) = value(obvardict,morvardict,w.contents) 
function value(objectVariableDictionary,morphismVariableDictionary,ex::Expr)
    bindings=[[Expr(:(=),k,v) for (k,v) in objectVariableDictionary];
              [Expr(:(=),k,v) for (k,v) in morphismVariableDictionary]]
    newex=Expr(:let,ex,bindings...)
    eval(newex) #try esc
end

type Representation#{ObjectType,MorphismType}
    fts::FiniteTensorSignature
    X::Class #XCategory
    obdict::Dict#{Symbol,ObjectType}    #might be better as a function
    mordict::Dict#{Symbol,MorphismType} #might be better as a function
    value::Function
    # inner cons was enforcing all obj and mor mapped, and that dom cods match.
    # now just constructs value function
    function Representation(T,X,od,md)
        function F(ex)
            examplemorphismofQ=[i for i in values(md)][1]
            value(merge({:I=>munit(examplemorphismofQ)},od),md,ex)
        end
        #todo check that X applies to both cats
        
        # Construct parameterized structure morphisms appropriate for 
        # the kind X of category
        
        # Always we have at least a MonoidalCategory.  We need I, the monoidal 
        # identity, and identity morphisms for each object
        
        # For a representation of ClosedCompactCategory, we will also need a swap 
        # and ev and coev
        new(T,X,od,md,F)
    end
end


# A constructor enforcing that all obj and mor mapped, and that dom cods match. This 
# was the inner constructor, but we need the ability for trusted functions to create a
# Representation.  For example when drawing pictures in a unitorweak category, 
# i.e. had to deal with equality up to isomorphism for padding in WeakWiresBoxes. 
# without forcing equality tests there to be up to isomorphism.
function CheckedRepresentation(fts,X,obdict,mordict) #<:Representation ?
    # check that all morphism variables have been assigned a value 
    # in the representation, and that F respects dom,cod
    for f in T.morvars
        #check that F(f) is defined
        @assert haskey(md,f) error("missing value of ",f)
        #check that dom(F(f))==F(dom(f))
        @assert F(T.dom[f])==dom(F(f))  ("dom(F($f)):",dom(F(f))," unequal to F(dom($f)): ",F(T.dom[f]))
        #check that cod(F(f))==F(cod(f)) 
        @assert F(T.cod[f])==cod(F(f))  ("cod(F($f)):",cod(F(f))," unequal to F(cod($f)): ",F(T.cod[f]))
    end
    
    # check that all object variables have been assigned a value in the representation
    for A in T.obvars
        @assert haskey(od,A) error("missing value of ",A)
    end
    Representation(T,X,od,md,F)
end








end #module
