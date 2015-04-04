module Representations
# import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘,comperr
# import MonoidalCategories:ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma
# import MonoidalCategories:DaggerClosedCompactCategory,dagger

using FiniteTensorSignatures
# export dom,cod,id,munit,⊗,∘
# export dual,transp,ev,coev,tr,Hom,sigma
# export dagger

export Representation


using Typeclass


# julia> function foo()
#        eval(:(let f=5;f+3;end))
#        end
#returns 8, doesn't affect global scope's defn of f

#also works:
# function bar()
#     ex=quote
#         let f=5
#             f+10
#         end
#     end
#     eval(ex)
# end
value(obvardict,morvardict,s::Symbol) = haskey(obvardict,s)?obvardict[s]:morvardict[s]
value(obvardict,morvardict,o::OWord) = value(obvardict,morvardict,o.word) 
value(obvardict,morvardict,o::ObjectWord) = value(obvardict,morvardict,o.contents) 
value(obvardict,morvardict,w::MorphismWord) = value(obvardict,morvardict,w.contents) 
function value(objectVariableDictionary,morphismVariableDictionary,ex::Expr)
    bindings=[[Expr(:(=),k,v) for (k,v) in objectVariableDictionary];
              [Expr(:(=),k,v) for (k,v) in morphismVariableDictionary]]
    newex=Expr(:let,ex,bindings...)
    eval(newex)
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
            value(od,md,ex)
        end
        #todo check that X applies to both cats

        #check that F resp dom,cod
        for f in T.morvars
            #check that F(f) is defined
            @assert haskey(md,f)
            #check that dom(F(f))==F(dom(f))
            @assert F(T.dom[f])==dom(F(f))  ("dom(F(f)):",F(T.dom[f])," unequal to F(dom(f)): ",dom(F(f)))
            #check that cod(F(f))==F(cod(f)) 
            @assert F(T.cod[f])==cod(F(f))
        end
        new(T,X,od,md,F)
    end
end






end #module
