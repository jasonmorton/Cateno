module OneCobs
using Docile
@docstrings
import Base.in
using Graphs

export PortPair,OneCob,gcompose
# A representation of a FTS in this category will calculate the normal form 
# when evaluated.


type PortPair
    cod::Array{Symbol,1}
    dom::Array{Symbol,1}
end
in(item,p::PortPair) = item in p.cod || item in p.dom
in(item,ps::Array{PortPair}) = any([item in p for p in ps])
# warning, flipped order
PortPair(d,c) = PortPair([gensym() for i in 1:c],[gensym() for i in 1:d]) 

type OneCob
    graph::GenericAdjacencyList{KeyVertex{Symbol},Array{KeyVertex{Symbol},1},Array{Array{KeyVertex{Symbol},1},1}}
    innerports::Array{PortPair,1}
    outerports::PortPair
    loops::Array{Symbol}
end


#assuming NO OVERLAP IN KEYS
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


#use connected components to compose
function gcompose(phi::OneCob,psi::OneCob)
    innerports = [phi.innerports;psi.innerports] 
    outerports = PortPair(phi.outerports.cod,psi.outerports.dom)
    loops = [phi.loops;psi.loops] # this may grow when simplifying
    # initialize a big graph whose vertices are the symbols of all nonloop ports
    g, index = disjoint_union(phi.graph,psi.graph)
    
    # draw all new edges (identity edges are not needed since we use the ports
    # that would get them as our new external ports
    # this will be different for ⊗
    n=length(phi.outerports.dom) #(==length(psi.outerports.cod))
    for i=1:n
        phiport = phi.outerports.dom[i]
        psiport = psi.outerports.cod[i]
        add_edge!(g, g.vertices[index[phiport]], g.vertices[index[psiport]])
    end


    # Make a new graph to hold the answer.
    h = adjlist(KeyVertex{Symbol}, is_directed=false)

    # Simplify.  Each connected component is an edge of the new graph, iff 
    # it contains two external vertices; otherwise it contains no external 
    # vertices and is a loop.
    cc=connected_components(g)
    for vs in cc
        # find the two exits if they exist
        externals = filter(x->(x.key in outerports) || (x.key in innerports),
                           vs)
        if !isempty(externals)
            @assert length(externals)==2
            # Add the new edge. I can assume neither side is already added to h, 
            # since these are connected components
            a=add_vertex!(h,externals[1].key)
            b=add_vertex!(h,externals[2].key)
            add_edge!(h,a,b)
        else # this has resulted in a loop.  Take the first symbol as a tag
            push!(loops,vs[1].key)
        end
    end
#    return (h,innerports,outerports,loops)
    OneCob(h,innerports,outerports,loops)
    
end


end #module



# function morcompose(phi::OneCob,psi::OneCob)
#     innerports = [phi.innerports;psi.innerports] #but need to relabel somehow, or have a global labeling for all innermost ports in exprsession
#     outerports = [phi.outerports.cod;psi.outerports.dom]
#     destination=Dict{Symbol,Symbol}()
#     for portpair in phi.innerports
#         n = length(portpair.cod)
#         for i=1:n 
#             port = portpair.cod[i]
#             if phi.destination[port] in phi.innerports
#                 destination[port]=phi.destination[port] #todo, start with the old dicts
#             elseif destination(port) in phi.outerports.cod
#                 destination[port]=phi.destination[port]
#             elseif destination(port) in phi.outerports.dom
#                 # send it to cod g port. dom and cod must match, so same number.
#                 #i.e. we identify phi.outerports.dom and psi.outerports.cod, throw away one set of symbols (higher in tree),
#                 # then compute the loops and cob of the result.  external vertices go in one hop to known exits.
#                 # loops of arbitrary complexity must be found and resolved.
#                 psipartner = psi.outerports.cod[i]
#                 # does this port loop back to the dom(f), so a cycle can be created?
#                 phipartner = phi.destination[port] # (loops if in phi.outerports.dom)
#                 # here are the cases.  Loop creation can be arbitrarily complicated.  In each loop we keep one symbol, assuming direction doesn't matter
#                 if phipartner in phi.outerports.dom 
                    
#                 end
#             end
#         end
#     end
#     for portpair in psi.innerports
#         n = length(portpair.cod)
#         for i=1:n 
#             port = portpair.cod[i]
#             if psi.destination[port] in psi.innerports
#                 destination[port]=psi.destination[port] #todo, start with the old dicts
#             elseif destination(port) in psi.outerports.cod
#                 # send it to dom f port. dom and cod must match, so same number.
#                 destination[port] = phi.outerports.dom[i]
#                 #the below assignement should be dealt with in the loop for phi.outerports.dom
#             elseif destination(port) in phi.outerports.dom
#                 nothing #should be already handled
#                 #                destination[port]=psi.destination[port]
#             end
#         end
#     end
#     OneCob(destination,
#            innerports,
#            outerports,
#            numloops)
# end
    
               
    
# end

# function morotimes(phi,psi)

# end



# using Graphs

# # Create new graph
# g = adjlist(KeyVertex{ASCIIString}, is_directed=false)

# # Add 2 vertices
# v = add_vertex!(g, "v")
# u = add_vertex!(g, "u")

# # Add an edge between them
# add_edge!(g, v, u)

# # This will print:

# #   KeyVertex{ASCIIString}(1,"v")

# # which is the neighbour of u
# println(out_neighbors(u, g))

#tests

# using Graphs, OneCobs
# pp1=PortPair(1,1) #f:A->A
# pp2=PortPair(1,1) #f:A->A
# g1=adjlist(KeyVertex{Symbol}, is_directed=false)
# u1=add_vertex!(g1,pp1.cod[1])
# u2=add_vertex!(g1,pp1.dom[1])
# add_edge!(g1,u1,u2)
# g2=adjlist(KeyVertex{Symbol}, is_directed=false)
# v1=add_vertex!(g2,pp2.cod[1])
# v2=add_vertex!(g2,pp2.dom[1])
# add_edge!(g2,v1,v2)

# phi=OneCob(g1,[],pp1,[])
# psi=OneCob(g2,[],pp2,[])
# gcompose(phi,psi)
