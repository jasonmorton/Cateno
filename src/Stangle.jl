using MonoidalCategories,Typeclass
import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘ 
export dom,cod,id,munit,⊗,∘


type Domcodpm
    dom::Array{Bool}
    cod::Array{Bool}
end
==(x::Domcodpm,y::Domcodpm)=x.dom==y.dom && x.cod==y.cod
# type PrimitiveObject
#     dom::Array{Domcodpm}
#     cod::Domcodpm
# end
typealias CompoundObject Array{Domcodpm,1} #PO,1
numberofvertices(x::Domcodpm)=length(x.dom)+length(x.cod)
#numberofvertices(x::PrimitiveObject)=mapreduce(numberofvertices,+,0,[x.dom;x.cod])
numberofvertices(x::CompoundObject)=mapreduce(numberofvertices,+,0,x)
#output object type of RawTangles.



type RTIndex
    index::Integer
    side::Bool #true if on dom side, false if on cod side
end
typealias domside true
typealias codside false
==(i::RTIndex,j::RTIndex)=i.index==j.index && i.side == j.side



type RawTangle #one color tangle
    dom::Integer 
    cod::Integer
    clockwiseloops::Integer #how many loops; all isom since only one color 
    counterclockwiseloops::Integer #how many loops; all isom since only one color 
    partnerofdom::Array{RTIndex}
    partnerofcod::Array{RTIndex}
end
==(r::RawTangle,s::RawTangle)=r.dom == s.dom && r.cod == s.cod &&r.clockwiseloops == s.clockwiseloops && r.counterclockwiseloops == s.counterclockwiseloops && r.partnerofdom == s.partnerofdom && r.partnerofcod == s.partnerofcod


function combine(r::RawTangle,s::RawTangle)
    s_dom_visited=zeros(Bool,s.dom)
    middle_visited=zeros(Bool,s.cod) # =dom(r)
    r_cod_visited=zeros(Bool,r.cod)
    #add the loops, may get others
    clockwiseloops=s.clockwiseloops+r.clockwiseloops
    counterclockwiseloops=s.counterclockwiseloops+r.counterclockwiseloops
    
    newpartnerofdom=deepcopy(s.partnerofdom)
    newpartnerofcod=deepcopy(r.partnerofcod)        
    
    function monitor()
        println("s_dom_visited",s_dom_visited)
        println("middle_visited",middle_visited)
        println("r_cod_visited",r_cod_visited)
    end

    # pingpong recursion
    function exit_vertex_from_middle_linked_by_s(index_of_middle_vertex)
        nextvertex=s.partnerofcod[index_of_middle_vertex] #get next vertex
#        monitor()
        if nextvertex.side==domside #exit through dom(s)
            s_dom_visited[nextvertex.index]=true #mark exit node
            (:s_dom,nextvertex.index) #return exit node and which table it is in
        else #nextvertex.side==codside, so loop back to middle
            middle_visited[nextvertex.index]=true
            exit_vertex_from_middle_linked_by_r(nextvertex.index) 
        end
    end
    
    function exit_vertex_from_middle_linked_by_r(index_of_middle_vertex)
        nextvertex=r.partnerofdom[index_of_middle_vertex] #get next vertex
#        monitor()
        if nextvertex.side==codside #exit through cod(r)
            r_cod_visited[nextvertex.index]=true #mark exit node
            (:r_cod,nextvertex.index)
        else #nextvertex.side=domside, loop back to middle
            middle_visited[nextvertex.index]=true
            exit_vertex_from_middle_linked_by_s(nextvertex.index) 
        end
    end

    println("Iterating through domain")
    for i in 1:s.dom
        println("vertex ",i)
        s_dom_visited[i]? continue : #been here already; if not 
        s_dom_visited[i]=true #mark it as visited
        secondvertex = newpartnerofdom[i] #get the next vertex, either loopback to dom(s)
        #                                  or go to middle
        if secondvertex.side==domside #if it loops back, mark and do nothing
            s_dom_visited[secondvertex.index]=true #mark destination vertex
            println(i," ",newpartnerofdom[secondvertex.index])
            @assert newpartnerofdom[secondvertex.index].index==i #already holds
            #the sameside pairing in s.dom is unchanged in the composition,
            # no update needed, so go to next dom(s) vertex
            continue
        else #secondvertex.side==codside, we are in the middle and must link with r to 
            #either exit through cod(r) or loop back to the middle again
            #this call also takes care of marking visited nodes, incl exit node
            middle_visited[secondvertex.index]=true
            (exitlocation,exitindex)=exit_vertex_from_middle_linked_by_r(secondvertex.index)
            # we either ended up back at dom(s)
            if exitlocation==:s_dom
                newpartnerofdom[i]=RTIndex(exitindex,domside) #and conversely
                newpartnerofdom[exitindex]=RTIndex(i,domside)# on the other hand
                #we connected dom and cod vertices
            else#if exitlocation==:r_cod
                newpartnerofdom[i]=RTIndex(exitindex,codside) #and conversely
                newpartnerofcod[exitindex]=RTIndex(i,domside)
            end
        end
    end
    monitor()
    #find loops.  These can be any size, and must cover all the unvisited vertices of dom(r)=cod(s).


#    println("Iterating through codomain")
    for i in 1:r.cod #not much left unvisted often, consider optimization
        r_cod_visited[i]? continue : #been here already; if not 
        r_cod_visited[i]=true #mark it as visited
        secondvertex = newpartnerofcod[i] #get the next vertex, either loopback to cod(r)
        #                                  or go to middle
        if secondvertex.side==codside #if it loops back, mark and do nothing
            r_cod_visited[secondvertex.index]=true 
            @assert newpartnerofcod[secondvertex.index].index==i #already holds
            #the sameside pairing in cod(r) is unchanged in the composition,
            # no update needed, so go to next cod(r) vertex
            continue
        else #secondvertex.side==domside, we are in the middle and must link with s to 
            #either exit through dom(s) or loop back to the middle again
            #this call also takes care of marking visited nodes, incl exit node
            middle_visited[secondvertex.index]=true
            (exitlocation,exitindex)=exit_vertex_from_middle_linked_by_s(secondvertex.index)
            # we either ended up back at cod(r)
            if exitlocation==:r_cod
                newpartnerofcod[i]=RTIndex(exitindex,codside) #and conversely
                newpartnerofcod[exitindex]=RTIndex(i,codside)# on the other hand
                #if we connected dom and cod vertices
            else#if exitlocation==:s_dom
                newpartnerofcod[i]=RTIndex(exitindex,domside) #and conversely
                newpartnerofdom[exitindex]=RTIndex(i,codside)
            end
        end
    end
#    monitor()
    #find loops.  These can be any size, and must cover all the unvisited vertices of dom(r)=cod(s).


    if true #!all(middle_visited)
        print("finding loops...")
        x=[1:s.cod]
        unvisited_middle_vertices = Set(x[!middle_visited])
        newloops = 0
        while length(unvisited_middle_vertices)>0
            v=pop!(unvisited_middle_vertices)
            newloops = newloops+1
            while true
                nextv=s.partnerofcod[v].index
                v=nextv
                if v in unvisited_middle_vertices
                    pop!(unvisited_middle_vertices,v)
                else
                    break
                end
            end
        end
        println(newloops," loops found")
    end
#    monitor()


    RawTangle(s.dom,r.cod, clockwiseloops, newloops+counterclockwiseloops,
              newpartnerofdom,newpartnerofcod)
end






#stack f on top of g and renumber g; 
#new start for g on codside and domside is different
function bump(f::RawTangle,a::Array{RTIndex})
    newa=Array(RTIndex,length(a))
    for i in 1:length(a)
        offset = a[i].side==domside? f.dom : f.cod
        newa[i]=RTIndex(offset+a[i].index , a[i].side)
    end
    newa
end


@instance MonoidalCategory Integer RawTangle begin
    dom(f::RawTangle)=f.dom
    cod(f::RawTangle)=f.cod
    id(n::Integer)=RawTangle(n,n,0,0,[RTIndex(i,codside) for i=1:n],
                             [RTIndex(i,domside) for i=1:n])
    compose(f::RawTangle,g::RawTangle)=combine(f,g)
    otimes(f::RawTangle,g::RawTangle)=RawTangle(dom(f)+dom(g),cod(f)+cod(g),
                                                f.clockwiseloops+g.clockwiseloops,
                                                f.counterclockwiseloops+g.counterclockwiseloops,
                                                #disjoint union by bumping indices
                                                [f.partnerofdom; bump(f,g.partnerofdom)],
                                                [f.partnerofcod; bump(f,g.partnerofcod)])

    otimes(n::Integer,m::Integer)=n+m
    munit(::Integer)=0
end




#IntegerRawTangle tests
#Tests
cup=RawTangle(0,2,0,0,[],[RTIndex(2,codside),RTIndex(1,codside)])
cap=RawTangle(2,0,0,0,[RTIndex(2,domside),RTIndex(1,domside)],[])
swap=RawTangle(2,2,0,0,[RTIndex(2,codside),RTIndex(1,codside)],[RTIndex(2,domside),RTIndex(1,domside)])
loop=combine(cap,cup)
combine(loop,loop)

#zigzag equation in IntegerRawTangle:
@assert (id(1)⊗cap) ∘ (cup ⊗ id(1)) ==id(1)
@assert (id(1) ⊗ id(1)) ==id(2)
@assert (id(1) ⊗ id(1)) ∘ cup == id(2) ∘ cup ==swap ∘ cup # cup
@assert cap ∘ id(2) == cap
@assert (cap⊗cap⊗cap⊗cap) ∘ (id(1)⊗cup⊗cup⊗cup⊗id(1)) == cap
@assert (cap⊗cap⊗cap⊗cap) ∘ (cup⊗cup⊗cup⊗cup) ==loop ∘loop ∘loop ∘loop 
#with some zigzags
@assert id(3) ∘ (id(3)⊗cap ) ∘ (swap⊗swap⊗id(1)) ∘ (cup⊗cup⊗id(1)) == cup ⊗ id(1)
@assert (id(3) ⊗ cup) ∘ id(3) == (id(3) ⊗ cup) 
function ab(n)
    a= id(3) ∘ (id(3)⊗cap ) ∘ (swap⊗swap⊗id(1)) ∘ (cup⊗cup⊗id(1))
    b=(id(1) ⊗ cap)
    (cap^{⊗2n}) ∘ ( b^{⊗4n} ) ∘ (a^{⊗4n}) ∘ (cup^{⊗2n})
end
@assert ab(50)==loop^{∘100}


type Stangle
    dom::CompoundObject
    cod::CompoundObject
    contents::RawTangle
end
==(s::Stangle,r::Stangle)=s.dom==r.dom && s.cod==r.cod && s.contents ==r.contents

#this wrapped pattern should be default implementation, delegate to dom,cod,contents fields
@instance MonoidalCategory CompoundObject Stangle begin
    dom(f::Stangle)=f.dom
    cod(f::Stangle)=f.cod
    id(A::CompoundObject)=Stangle(A,A, id(numberofvertices(A)))
    compose(f::Stangle,g::Stangle)=Stangle(dom(g), cod(f), f.contents ∘ g.contents)
    otimes(f::Stangle,g::Stangle)=Stangle(dom(f)⊗dom(g),cod(f)⊗cod(g),f.contents⊗g.contents)
    otimes(A::CompoundObject,B::CompoundObject)=[A;B]
    munit(A::CompoundObject)=Domcodpm[]
end
#id(A::PrimitiveObject)=id([A])

#test
shipspassing=Domcodpm([false,true],[false,true])
A=[shipspassing,shipspassing]
I_Stangle=munit(A)
p_m = Domcodpm([true],[false])
m_p = Domcodpm([false],[true])
_mp = Domcodpm([],[false,true])
mp_ = Domcodpm([false,true],[])

idprimal_stangle=Stangle(munit(A),[p_m],cup)
iddual_stangle=Stangle(munit(A),[m_p],cup)
fbox_stangle = Stangle([p_m],[p_m],id(2))
tr_stangle=Stangle([p_m],munit(A),cap)
perm132 = (id(1)⊗swap)∘(swap⊗id(1))
nestedcap = (cap⊗cap)∘(perm132⊗id(1))
sp_otimes=Stangle([m_p,p_m],[shipspassing],id(1)⊗perm132)
appropcirc1 = Stangle([_mp,shipspassing],[_mp], nestedcap ⊗ id(2) )
ev_stangle = Stangle(munit(A),[_mp],cup)
appropcirc2 = Stangle([_mp,mp_],munit(A),nestedcap)
coev_stangle = Stangle(munit(A),[mp_],cup)


@assert tr_stangle == appropcirc2 ∘ (( appropcirc1 ∘ (ev_stangle ⊗ (sp_otimes ∘ (iddual_stangle ⊗ fbox_stangle))))⊗ coev_stangle)
