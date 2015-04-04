# Finite Tensor signatures as Julia expressions over a fixed 'type' alphabet
module FiniteTensorSignatures
import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘,comperr
import MonoidalCategories:ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma
import MonoidalCategories:DaggerClosedCompactCategory,dagger
export FiniteTensorSignature,nullsig,FTS,MW,@fts_str
export dom,cod,id,munit,⊗,∘
export dual,transp,ev,coev,tr,Hom,sigma
export dagger
export OWord,ObjectWord,MorphismWord #temp

export @minex_str

using Typeclass
import Base:show,ctranspose,transpose
import Base.Meta.quot

#Represent words in $\mathcal{T}^{\circ,\ot}$ as raw Julia expressions with no TS or dom/cod checking, for internal use only
typealias MWord Union(Expr,Symbol)

type OWord
    word::Union(Expr,Symbol)
end

#typealias OWord Union(Expr,Symbol)
@instance MonoidalCategory OWord MWord  begin
    dom(f::MWord)=nothing
    cod(f::MWord)=nothing
    id(A::OWord)=Expr(:call,:id,A.word)
    compose(f::MWord,g::MWord)=Expr(:call,:∘,f,g)  
    otimes(f::MWord,g::MWord)=Expr(:call,:⊗,f,g) 
    function otimes(A::OWord,B::OWord)
        if A.word==:()==B.word
            OWord(:())
        elseif A.word==:()
            B
        elseif B.word==:()
            A
        else
            OWord(Expr(:call,:⊗,A.word,B.word)) #not strictly associative, maybe make associative by looking down.
        end
    end
    munit(::OWord)=OWord(:())
end





#A finite tensor signature consists of a finite set of object and morphism variables, together with cod, dom functions.
#may want this to be singleton or immmutable, it's a essentially a type for the morphism words. OTOH might grow as add stuff.
type FiniteTensorSignature 
    obvars::Set{Symbol}
    morvars::Set{Symbol}
    dom::Dict{Symbol,OWord}
    cod::Dict{Symbol,OWord}
end

#A FTS that casts anywhere
FiniteTensorSignature()=FiniteTensorSignature(Set{Symbol}([]),Set{Symbol}([]),Dict(),Dict())

nullsig = FiniteTensorSignature()

otreestring(otree)=join(flattenotree(otree),⊗)
flattenotree(w::Symbol)=[w]
function flattenotree(w::Expr)
    list=Symbol[]
#    @assert w.head==:call && w.args[1]==⊗
    left=w.args[2]
    right=w.args[3]
    append!(list,flattenotree(left))
    append!(list,flattenotree(right))
end


function show(io::IO,T::FiniteTensorSignature)
    ss=["$(f):$(otreestring(T.dom[f].word))→$(otreestring(T.cod[f].word))" for f in T.morvars]
    print(io,"{",join(ss,","),"}")
end



# FTS("f:a⊗b→c,g:a→b⊗c")
#todo how do I specify monoidal unit?  Now just I then assign in interp.
function FTS(s::String)
    T=FiniteTensorSignature()
    for mstring in split(s,r"[,\s]\s*") # regex matches , or space and any number of trailing spaces
        strname,strtype = split(mstring,":") #todo accept trailing space
        name=symbol(strname)
        domstr,codstr=split(strtype,"→") #todo accept ->
        domarray = map(symbol, split(domstr,"⊗"))
        codarray = map(symbol, split(codstr,"⊗")) #todo accept \otimes and \ot and V_1 \otc V_n
        #add the primitive object symbols to obvars
        union!(T.obvars,domarray)
        union!(T.obvars,codarray)
        #add the morphism symbols to morvars
        union!(T.morvars,[name])
        #in this model the dom and cod are ⊗-trees
        T.dom[name]=foldl(⊗,map(OWord,domarray))
        T.cod[name]=foldl(⊗,map(OWord,codarray))
    end   
    T
end

T=FTS("f:a⊗b→c,g:a→b⊗c")


#without quot, works outside module but not in it, with using FiniteTensorSig
macro minex_str(str)
    quot(
    Expr(:global,
    Expr(:(=),:a,str)))
end

#incomplete:
#instantiates tensor sig and places its variables in global scope.
macro fts_str(str)
    T=FTS(str)
    block=Expr(:block)
    # to do: us a let in this line to not name it?
    Tdecl=Expr(:(=), :T, Expr(:call, :FTS, str))
    push!(block.args,Tdecl)
    for morphism_variable_symbol in T.morvars
        quotedsymbol = quot(morphism_variable_symbol)
        morphism_name_decl=Expr(:(=),
                       morphism_variable_symbol, #LHS
                       Expr(:call,:MW,quotedsymbol,:T), #RHS
                       true)#cargo)
        push!(block.args,morphism_name_decl)
    end
#    println(Expr(:block,block,nothing))
    for object_variable_symbol in T.obvars
        quotedsymbol = quot(object_variable_symbol)
        object_name_decl=Expr(:(=),
                              object_variable_symbol, #LHS
                              Expr(:call,:(FiniteTensorSignatures.ObjectWord),
                                   Expr(:call, :OWord, quotedsymbol),:T), #RHS
                              true)
        push!(block.args,object_name_decl)
    end
    push!(block.args,:T) #return the tensor scheme, change after let
#    block
#    Expr(:block,block,nothing)
#    info(T,"'s variables added to global scope")
    quot(block)
end
#eval(fts"f:a→b") now works

#An object expression which remembers its FiniteTensorSignature
type ObjectWord #{FiniteTensorSignature}
    contents::OWord
    signature::FiniteTensorSignature
end
function show(io::IO,w::ObjectWord)
#%    if w.contents == Array{Symbol,1}[]
#       print(io,"$I over $(w.signature)")
    print(io,"$(otreestring(w.contents.word)) over $(w.signature)")
end
function ==(A::ObjectWord,B::ObjectWord)
    A.contents.word==B.contents.word && A.signature == B.signature
end



#towards a conversion or promotion mechanism
function tsjoin(f,g)
    if f.signature == g.signature
        return f.signature
    elseif f.signature == nullsig
        return g.signature
    elseif g.signature == nullsig
        return f.signature
    else
        error("TS cannot be joined")
    end
end


type MorphismWord
    contents::MWord #the julia expression, an Expr
    signature::FiniteTensorSignature
    dom::ObjectWord
    cod::ObjectWord
end
#need a constructor because the contents and signature determine the dom and cod
#Just recursively evaluate until get to raw symbols.
# for now assume binary tree expr
# in a sense this is an interpretation of a word in the null signature in the given FTS with the possiblity of error

function MW(fsymbol::Symbol,T::FiniteTensorSignature)
    #Look up cod and dom for the symbol given T
#    print(fsymbol,T,T.dom[fsymbol],T.cod[fsymbol],"\n")
    MorphismWord(fsymbol,T,ObjectWord(T.dom[fsymbol],T),ObjectWord(T.cod[fsymbol],T))
end
function MW(word::Expr,T::FiniteTensorSignature)
    #compute cod and dom for the Expr given T, by calling MW on each piece
    #assume f ⊗ g or f ∘ g so the Expr is :call with args op,f,g
    @assert word.head == :call
    op = word.args[1]
    f = MW(word.args[2],T)
    g = MW(word.args[3],T)
    print(f,"\n")
    print(g,"\n")
    if op == :⊗
        MorphismWord(word,T, f.dom ⊗ g.dom, f.cod ⊗ g.cod)
    elseif op == :∘
        f.dom!=g.cod ? comperr(f,g) : 
        MorphismWord(word, T, g.dom, f.cod)
    else
        error("Invalid expression ", word, op)
    end
end

function show(io::IO,w::MorphismWord)
    print(io,"$(w.contents):$(otreestring(w.dom.contents.word))→$(otreestring(w.cod.contents.word)) over $(w.signature)")
end
function ==(f::MorphismWord,g::MorphismWord)
    f.contents==g.contents && 
    f.signature == g.signature &&
    f.dom == g.dom &&
    f.cod == g.cod
end
##################################################################################

@instance MonoidalCategory ObjectWord MorphismWord begin
    dom(f::MorphismWord)=f.dom
    cod(f::MorphismWord)=f.cod
    id(A::ObjectWord)=MorphismWord(id(A.contents),A.signature,A,A)
    #check they come from the same TS, and coddom compatible
    function compose(f::MorphismWord,g::MorphismWord)
        f.dom!=g.cod ? comperr(f,g) : 
        MorphismWord(f.contents ∘ g.contents, tsjoin(f,g), g.dom, f.cod)
    end
    function otimes(f::MorphismWord,g::MorphismWord)
        MorphismWord(f.contents ⊗ g.contents, tsjoin(f,g),
                     f.dom ⊗ g.dom, f.cod ⊗ g.cod)     
    end
    function otimes(A::ObjectWord,B::ObjectWord)
        ObjectWord(A.contents ⊗ B.contents, tsjoin(A,B))
    end
    munit(::ObjectWord)=ObjectWord(Array{Symbol,1}[],nullsig)    
end


#T=FiniteTensorSignature([:A,:B],[:f,:g],{:f=>[:A],:g=>[:B]},{:f=>[:B],:g=>[:A]})
#T=FTS("f:a⊗b→c,g:a→b⊗c,h:a→a⊗b")
#MW(:f ⊗ :h,T)
#⊗(f,h):a⊗b⊗a→c⊗a⊗b over h:a→a⊗b,g:a→b⊗c,f:a⊗b→c,

#---------------------------------------------------------------------------------

#Assuming Ob Mor is a MonoidalCategory already
@class ClosedCompactCategory Ob Mor begin
    dual(A::Ob)::Ob
    transp(f::Mor)=id(dual(cod(f))) ⊗ coev(dom(f)) | id(dual(cod(f)))⊗f⊗id(dual(dom(f))) | ev(cod(f))⊗id(dual(dom(f)))
    ev(A::Ob)::Mor
    coev(A::Ob)::Mor
    Hom(A::Ob,B::Ob)=dual(A)⊗B
    sigma(A::Ob,B::Ob)::Mor
    tr(f::Mor) = (ev(dom(f))) ∘ (id(dual(dom(f))) ⊗ f) ∘ coev(dual(dom(f))) #or the other way
end


#----------------
#augmentation of tensor signature to handle duals and the 3 special morphisms ev, coev, sigma
#A_ convention for symbol for now
#morphisms are :ev, :coev, :sigma


function toggledual(s::Symbol)
    st=string(s)
    if s==:I
        s
    elseif st[end]=='_'
        symbol(st[1:end-1])
    else
        symbol(string(st,'_'))
    end
end


# Assume OWord, MWord are a MonoidalCategory
@instance ClosedCompactCategory OWord MWord  begin
    dual(A::OWord)=map(toggledual,A)
#    transp(f::Mor)=id(cod(f)) ⊗ coev(dom(f)) | id(cod(f))⊗f⊗id(dom(f)) | ev(cod(f))⊗id(dom(f))
    ev(A::OWord)=Expr(:call,:ev,A)     #A*⊗A→I
    coev(A::OWord)=Expr(:call,:coev,A) #I→A⊗A*
#    Hom(A::Ob,B::Ob)=dual(A)⊗B
    sigma(A::OWord,B::OWord)=Expr(:call,:σ,A,B)  #A⊗B→B⊗A
#    tr(f::Mor) = (ev(dual(dom(f)))) ∘ (f ⊗ id(dual(dom(f)))) ∘ coev(dom(f))
end


@instance ClosedCompactCategory ObjectWord MorphismWord begin
    dual(A::ObjectWord)=ObjectWord(map(toggledual,A.contents),A.signature)
    ev(A::ObjectWord)=MorphismWord(ev(A.contents),A.signature,dual(A)⊗A,munit(A))
    coev(A::ObjectWord)=MorphismWord(coev(A.contents),A.signature,munit(A),A⊗dual(A))
    sigma(A::ObjectWord,B::ObjectWord)=MorphismWord(sigma(A.contents,B.contents), A.signature, A⊗B, B⊗A)
end

transpose(f::MorphismWord)=transp(f) #f.' notation

#Assuming Ob Mor is a ClosedCompactCategory already
@class DaggerClosedCompactCategory Ob Mor begin
    dagger(A::Ob)=A
    dagger(f::Mor)=daggerword(f)
end


function toggledagger(s::Symbol)
    st=string(s)
    if st[end]=='d'
        symbol(st[1:end-3])
    else
        symbol(string(st,'d'))
    end
end
daggerword(fsymbol::Symbol) = toggledagger(fsymbol)
function daggerword(word::Expr)
    @assert word.head == :call
    op = word.args[1]
    fdagger = daggerword(word.args[2],T)
    gdagger = daggerword(word.args[3],T)
    # print(f,"\n")
    # print(g,"\n")
    #if (f⊗g):A⊗B→C⊗D,
    #then (f⊗g)†:C⊗D→A⊗B with (f⊗g)† = f† ⊗ g†
    if op == :⊗
        fdagger⊗gdagger
    elseif op == :∘
        gdagger∘fdagger
    else
        error("Invalid expression ", word, op)
    end
end

@instance DaggerClosedCompactCategory ObjectWord MorphismWord begin
    dagger(f::MorphismWord)=MorphismWord(daggerword(f.contents),f.signature,f.cod,f.dom)
end

ctranspose(f::MorphismWord)=dagger(f) #f' notation

end

#next: tests for this functionality, including Interpretations
#Then: dungeon and SRel (or just implement BP for SRel)
#Then: Graphical orbit calculations
#Then: numerical word problems (HDRA/QPL)
#Then: MC enriched over vector spaces so we can 3f+g



