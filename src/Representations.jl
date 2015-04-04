module Representations
import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘,comperr
import MonoidalCategories:ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma
import MonoidalCategories:DaggerClosedCompactCategory,dagger

using FiniteTensorSignatures
# export dom,cod,id,munit,⊗,∘
# export dual,transp,ev,coev,tr,Hom,sigma
# export dagger


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


type Representation{ObjectType,MorphismType}
    fts::FiniteTensorSignature
    X::Class #XCategory
    obdict::Dict{Symbol,ObjectType}
    mordict::Dict{Symbol,MorphismType}
    #inner cons enforcing all obj and mor mapped, and that dom cods match
    function Representation(T,X,od,md)
        
        #todo check that X applies to both cats
        #check that F resp dom,cod
        for f in md
            #check that F(f) is defined
            @assert haskey(mordict,f) 
            #look up dom and cod of f
            f.dom
            f.cod
            #compute dom and cod of F(f) 
            
            #check that dom(F(f))==F(dom(f))
            #check that cod(F(f))==F(cod(f))
        end
        new(T,X,od,md)
    end

end



end #module
