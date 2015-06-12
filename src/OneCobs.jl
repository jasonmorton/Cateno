module OneCobs
using Docile
@docstrings
import Base:in,show
import Base:transpose
using Graphs

export PortPair,OneCob,gcompose,gotimes, isloop
export gid,gev,gcoev,gmorvar
# A representation of a FTS in this category will calculate the normal form 
# when evaluated.

################################################################################
# Types
################################################################################
# consider AbstractPortPair, InnerPortPair (has label), OuterPortPair (no label)
@doc "Holds a pair of ports, cod and dom, both of which are arrays of symbols.  Since some innermost PortPairs can correspond to morphism variables, so there is an optional Symbol label for a portpair."->
type PortPair
    cod::Array{Symbol,1}
    dom::Array{Symbol,1}
    label::Symbol
end
PortPair(cod::Array{Symbol,1},dom::Array{Symbol,1})=PortPair(cod,dom,:unlabled)
# warning, flipped order
PortPair(d::Integer,c::Integer) = PortPair([gensym() for i in 1:c],
                                           [gensym() for i in 1:d])
PortPair(d::Integer,c::Integer,f::Symbol) = PortPair([gensym() for i in 1:c],
                                                     [gensym() for i in 1:d],
                                                     f)

==(pp1::PortPair,pp2::PortPair) = pp1.cod == pp2.cod && pp1.dom == pp2.dom && pp1.label == pp2.label


in(item,p::PortPair) = item in p.cod || item in p.dom
in(item,ps::Array{PortPair}) = any([item in p for p in ps])

function replacesymbol(s::Symbol,n::Symbol,p::PortPair)
    q=deepcopy(p)
    if s in q.dom
        ix = findfirst(q.dom,s)
        q.dom[ix] = n
        q
    elseif s in q.cod
        ix = findfirst(q.cod,s)
        q.cod[ix] = n
        q
    else
        p
    end
end



type OneCob
    graph::GenericAdjacencyList{KeyVertex{Symbol},Array{KeyVertex{Symbol},1},Array{Array{KeyVertex{Symbol},1},1}}
    innerports::Array{PortPair,1}
    outerports::PortPair
    loops::Array{Symbol}
    label #usually a symbol
end
OneCob(graph,innerports,outerports,loops)=OneCob(graph,innerports,outerports,loops,:unlabeled) #default label

function ==(oc1::OneCob,oc2::OneCob)
    # At first, (id(A) ⊗ ev(A)) ∘ (coev(A) ⊗ id(A))  != id(A)  because they are merely isomorphic: the new symbols being generated in each call. To fix this, we compare OneCobs with no innerports by composing them with something
    if isempty(oc1.innerports)
        domwires = length(oc1.outerports.dom) #dom(oc1).nwires
        temp = gmorvar(domwires,domwires,gensym())
        return gcompose(oc1,temp) == gcompose(oc2,temp)
    end
        
    oc1.graph==oc2.graph && Set(oc1.innerports) == Set(oc2.innerports) && oc1.outerports == oc2.outerports && length(oc1.loops) == length(oc2.loops) && oc1.label == oc2.label
    
end

function show(io::IO,o::OneCob)
    println(io,o.graph,o.graph.vertices," adjlist: ",o.graph.adjlist)
    println(io,"innerports:",o.innerports)
    println(io,"outerports:",o.outerports)
    println(io,"loops:",o.loops)
end
#also need an isom where gensym symbols are allowed to change



################################################################################
# Utilities
################################################################################
# assumes NO OVERLAP IN KEYS which is reasonable because they are generated by
# gensym().  If this changes, so must this function.
function disjoint_union(g,h)#::GenericAdjacencyList,h::GenericAdjacencyList)
    g = deepcopy(g)
    index=Dict([ (v.key,v.index) for v in g.vertices  ]) #not in Graphs.jl?
    
    for v in h.vertices
        newv=add_vertex!(g,v.key)
        index[newv.key]=newv.index
    end
    
    for v in h.vertices
        for u in out_neighbors(v,h)
            if g.vertices[index[v.key]] in out_neighbors(g.vertices[index[u.key]], g) #otherwise will add multiple edges, two for each edge
                nothing
            else
                add_edge!(g, g.vertices[index[v.key]],g.vertices[index[u.key]])
            end
        end
    end
    return (g,index)
end

onecobgraph()=adjlist(KeyVertex{Symbol}, is_directed=false)
==(g::GenericAdjacencyList,h::GenericAdjacencyList) = graphsequal(g,h)#g.vertices == h.vertices && g.adjlist == h.adjlist
==(k::KeyVertex{Symbol},l::KeyVertex{Symbol}) = k.index == l.index && k.key == l.key


function makeedgeset(g::GenericAdjacencyList)
#    edgelist1=edge_type(g)[] # Array{Any,g1.graph.nedges}
    # for i = 1:length(g1.graph.vertices)
    #     for j in g1.graph.adjlist[i]
    #         push!(edgelist1, (g1.graph.vertices[i],j))
    #     end
    # end
    edge_set = Set()
    for u in vertices(g)
        for v in Graphs.out_neighbors(u,g)
            push!(edge_set,(u.key,v.key))
        end
    end

    edge_set
end

function graphsequal(g1,g2)
    if Set([a.key for a  in g1.vertices])!=Set([a.key for a in g2.vertices])
        return false
    end
    edgeset1=makeedgeset(g1)
    edgeset2=makeedgeset(g2)
    edgeset1 == edgeset2
end



function show(io::IO,v::KeyVertex{Symbol})
    print(io,"(",join([v.index,string(v.key)[end-2:end]],","),")")
end

function isloop(g::OneCob)
    length(g.loops)==1 &&
    isempty(g.graph.vertices) &&
    isempty(g.graph.adjlist)
end



################################################################################
# 2-ary ops
################################################################################
@doc "Apply a ∘ op to two Hom-typed arguments and simplify." ->
function gcompose(phi::OneCob,psi::OneCob)
    innerports = [phi.innerports;psi.innerports] 
    outerports = PortPair(phi.outerports.cod,psi.outerports.dom)
    println("innerports: ",innerports)
    println("outerports: ",outerports)
    loops = [phi.loops;psi.loops] # this may grow when simplifying
    # initialize a big graph whose vertices are the symbols of all nonloop ports
    g, index = disjoint_union(phi.graph,psi.graph)
    
    # draw all new edges (identity edges are not needed since we use the ports
    # that would get them as our new external ports
    # this will be different for ⊗
    # println("phi.outerports.dom: ",phi.outerports.dom)
    n=length(phi.outerports.dom) #(==length(psi.outerports.cod))
    for i=1:n
        phiport = phi.outerports.dom[i]
        psiport = psi.outerports.cod[i]
        println("add edge ", g.vertices[index[phiport]], g.vertices[index[psiport]])
        add_edge!(g, g.vertices[index[phiport]], g.vertices[index[psiport]])
    end


    # Make a new graph to hold the answer.
    h = onecobgraph() #adjlist(KeyVertex{Symbol}, is_directed=false)

    # Simplify.  Each connected component is an edge of the new graph, iff 
    # it contains two external vertices; otherwise it contains no external 
    # vertices and is a loop.
    cc=connected_components(g)
#    return g
    println("Connected components: ",cc)
    for vs in cc
        # find the two exits if they exist
#        externals = filter(x->(x.key in outerports) || (x.key in innerports),vs)
        outerexternals = filter(x->(x.key in outerports) ,vs)
        innerexternals = filter(x->(x.key in innerports) ,vs)
        externals = [outerexternals,innerexternals]
        println("outerexternal:",outerexternals,", innerexternal:",innerexternals," externals:",externals)
        if !isempty(externals)
            @assert length(externals)==2  println("outerexternal:",outerexternals,", innerexternal:",innerexternals, " have wrong lengths")
            if length(outerexternals)==1 && length(innerexternals)==1
                print("Modifying...")
                # In this case, we want to replace the outerport gensymbol
                # outerexternals[1] with whatever was originally adjacent to the
                # innerport innerexternals[1]).
#                inner_external_vertex = g.vertices[index[innerexternals[1]]]
                nbhrs = out_neighbors(innerexternals[1],g)
                @assert length(nbhrs)==1
                newoutersymbol = nbhrs[1].key
                outerports = replacesymbol(outerexternals[1].key,
                                           newoutersymbol,outerports)
                outerexternals = nbhrs #length-one list with the new vertex
                externals = [outerexternals,innerexternals]
                println("Modified, outerexternal:",outerexternals,", innerexternal:",innerexternals," externals:",externals)
            end

            
            # Add the new edge. I can assume neither side is already added to h, 
            # since these are connected components
            a=add_vertex!(h,externals[1].key); print("addv:",a)
            b=add_vertex!(h,externals[2].key); print(", addv:",b)
            add_edge!(h,a,b); print(", adde:",a,b,"\n")
        elseif vs==[] #was if externals==[], exactly the loop case.
            nothing
        else # this has resulted in a loop.  Take the first symbol as a tag
            @assert innerexternals==[] && outerexternals==[] 
            # println(vs," is a loop")
            push!(loops,vs[1].key)
        end
    end
    #    return (h,innerports,outerports,loops)
    @assert phi.label==psi.label println("Label mismatch for OneCobs ",
                                         phi," ",psi)
    OneCob(h,innerports,outerports,loops,phi.label)

end


@doc "Apply an ⊗ op to two Hom-typed arguments and simplify." ->
function gotimes(phi,psi)
    innerports = [phi.innerports;psi.innerports] 
    outerports = PortPair([phi.outerports.cod ; psi.outerports.cod],
                          [phi.outerports.dom ; psi.outerports.dom])
    loops = [phi.loops;psi.loops] 
    g, index = disjoint_union(phi.graph,psi.graph)
    @assert phi.label==psi.label println("Label mismatch for OneCobs ",
                                         phi," ",psi)
    OneCob(g,innerports,outerports,loops,phi.label)
end


################################################################################
# 1-ary ops
################################################################################

################################################################################
# 0-ary ops
################################################################################
@doc " ev: I->A⊗A as a 0-ary op; argument becomes the label of the resulting OneCob.  Note this is a function, rather than a constant, because we need to generate fresh symbols with gensym() for each ev(something) that appears in an expression.  Each symbol corresponds to a different port or vertex." ->
function gev(A::Symbol)
    g  =  onecobgraph() # adjlist(KeyVertex{Symbol}, is_directed=false)

    pp = PortPair(2,0) #I->A_⊗A
    u1 = add_vertex!(g,pp.dom[1])
    u2 = add_vertex!(g,pp.dom[2])

    add_edge!(g,u1,u2)
    innerports = []
    outerports = pp
    loops = []

    OneCob(g,innerports,outerports,loops,A)
end

function gcoev(A::Symbol)
    g  =  onecobgraph() # adjlist(KeyVertex{Symbol}, is_directed=false)

    pp = PortPair(0,2) #A⊗A_ ->I
    u1 = add_vertex!(g,pp.cod[1])
    u2 = add_vertex!(g,pp.cod[2])

    add_edge!(g,u1,u2)
    innerports = []
    outerports = pp
    loops = []

    OneCob(g,innerports,outerports,loops,A)
end

function gid(A::Symbol)
    g  =  onecobgraph()

    pp = PortPair(1,1) #A->A
    u1 = add_vertex!(g,pp.cod[1])
    u2 = add_vertex!(g,pp.dom[1])

    add_edge!(g,u1,u2)
    innerports = []
    outerports = pp
    loops = []

    OneCob(g,innerports,outerports,loops,A)
    
end


# Integer number of wires
function gev(nwires::Integer)
    g  =  onecobgraph() # adjlist(KeyVertex{Symbol}, is_directed=false)

    pp = PortPair(2*nwires,0) #I -> A_^{⊗nwires}⊗A^{⊗nwires}
    for i=1:(2*nwires)
        add_vertex!(g,pp.dom[i])
    end
    
    for i=1:nwires
        u1 = g.vertices[i] 
        u2 = g.vertices[nwires+i]
        add_edge!(g,u1,u2)
    end
    innerports = []
    outerports = pp
    loops = []

    OneCob(g,innerports,outerports,loops)
end

function gcoev(nwires::Integer)
    g  =  onecobgraph() # adjlist(KeyVertex{Symbol}, is_directed=false)

    pp = PortPair(0,2*nwires) #A^{⊗nwires}⊗A_^{⊗nwires} -> I
    for i=1:(2*nwires)
        add_vertex!(g,pp.cod[i])
    end

    for i=1:nwires
        u1 = g.vertices[i] 
        u2 = g.vertices[nwires+i]
        add_edge!(g,u1,u2)
    end
    innerports = []
    outerports = pp
    loops = []

    OneCob(g,innerports,outerports,loops)
end

function gid(nwires::Integer)
    g  =  onecobgraph()

    pp = PortPair(nwires,nwires) #A->A
    for i=1:nwires
        add_vertex!(g,pp.cod[i])
    end
    for i=1:nwires
        add_vertex!(g,pp.dom[i])
    end
    
    for i=1:nwires
        u1 = g.vertices[i] # vertex corresp to pp.cod[i]
        u2 = g.vertices[nwires+i] # vertex corresp to pp.dom[i]
        add_edge!(g,u1,u2)
    end
    innerports = []
    outerports = pp
    loops = []

    OneCob(g,innerports,outerports,loops)
end

#causes an error on line 32 of onecobs
function newgmorvar(ndomwires::Integer,ncodwires::Integer, f::Symbol) 
    g  =  onecobgraph()
    #A^{⊗ndomwires}->A^{⊗ncodwires}
    opp = PortPair(ndomwires,ncodwires,f) 

    for i=1:ncodwires
        add_vertex!(g,opp.cod[i])
    end
    for i=1:ndomwires
        add_vertex!(g,opp.dom[i])
    end
 
    innerports = [] # this is a 0-ary op, but the innerports carry the label
    outerports = opp
    loops = []

    OneCob(g,innerports,outerports,loops)
    
end



@doc """
morvar differs in that it can have differing numbers of domwires and codwires, and can attach a symbol to its portpair (usually for a morphism variable).
""" ->
function gmorvar(ndomwires::Integer,ncodwires::Integer, f::Symbol) 
    g  =  onecobgraph()
    #A^{⊗ndomwires}->A^{⊗ncodwires}
    opp = PortPair(ndomwires,ncodwires) 
    ipp = PortPair(ndomwires,ncodwires,f)

    for i=1:ncodwires
        add_vertex!(g,opp.cod[i])
    end
    for i=1:ndomwires
        add_vertex!(g,opp.dom[i])
    end
    for i=1:ncodwires
        add_vertex!(g,ipp.cod[i])
    end
    for i=1:ndomwires
        add_vertex!(g,ipp.dom[i])
    end

    # so the order of the vertices is
    # o.cod, o.dom, i.cod, i.dom
    
    for i=1:(ncodwires+ndomwires)
        u1 = g.vertices[i] # vertex in to opp
        u2 = g.vertices[(ncodwires+ndomwires)+i] # vertex in ipp
        add_edge!(g,u1,u2)
    end

    #should have innerports and edges, carrying the label.
    
    innerports = [ipp] # this is a 0-ary op, but the innerports carry the label
    outerports = opp
    loops = []

    OneCob(g,innerports,outerports,loops)
    
end






end #module OneCobs




