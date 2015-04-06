module Representations
# import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘,comperr
# import MonoidalCategories:ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma
# import MonoidalCategories:DaggerClosedCompactCategory,dagger
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
    obdict::Dict#{Symbol,ObjectType}
    mordict::Dict#{Symbol,MorphismType}
    value::Function
    #inner cons enforcing all obj and mor mapped, and that dom cods match
    function Representation(T,X,od,md)
        function F(ex)
            examplemorphismofQ=[i for i in values(md)][1]
            value(merge({:I=>munit(examplemorphismofQ)},od),md,ex)
#            value(od,md,ex)
        end
        #todo check that X applies to both cats
#        println(md)
        # check that all morphism variables have been assigned a value 
        # in the representation, and that F respects dom,cod
        for f in T.morvars
            #check that F(f) is defined
            @assert haskey(md,f) error("missing value of ",f)
            #check that dom(F(f))==F(dom(f))
            @assert F(T.dom[f])==dom(F(f))  ("dom(F($f)):",F(T.dom[f])," unequal to F(dom($f)): ",dom(F(f)))
            #check that cod(F(f))==F(cod(f)) 
            @assert F(T.cod[f])==cod(F(f)) 
        end
        # check that all object variables have been assigned a value 
        # in the representation
        for A in T.obvars
            @assert haskey(od,A) error("missing value of ",A)
        end
        
        # Construct parameterized structure morphisms appropriate for 
        # the kind X of category
        
        # Always we have at least a MonoidalCategory.  We need I, the monoidal 
        # identity, and identity morphisms for each object
        
        # For a representation of ClosedCompactCategory, we will also need a swap 
        # and ev and coev


        new(T,X,od,md,F)
    end
end






end #module
