module OneCobsTest
using OneCobs, Base.Test, Graphs



@test isloop( gcompose(OneCobs.gev(:A),OneCobs.gcoev(:A)) )
c=gcompose(OneCobs.gcoev(:A),OneCobs.gev(:A))
@test length(c.loops)==0
@test length(c.graph.vertices)==4
@test length(c.graph.adjlist)==4


# Morton-Spivak NF paper with id(1) in place of f for now
# should get single loop
afterphi1=gotimes(gid(1),gid(1))
afterphi2=gcompose(gev(1),afterphi1)
afterphi3=gcompose(afterphi2,gcoev(1))
## result is a OneCob which just has a loop with the symbol from 2 labeling it.
@test length(afterphi3.loops)==1
@test isempty(afterphi3.graph.vertices)
@test isempty(afterphi3.graph.adjlist)
#∘(∘(ev(1),⊗(id(1),id(1))),coev(1))
#∘(∘(ev(1),⊗(id(1),f)),coev(1))
#∘(∘(ev(A),⊗(id(A),f)),coev(A))
#∘(∘(ev(A),⊗(id(A_),f)),coev(A_)) #want to go from this to tr(f)
#just functor send A and A_ to 1 and evaluate in operad context should give op
#then need to reverse it.

# Morton-Spivak NF paper with a morvar for f
f = gmorvar(1,1,:f)
afterphi1 = gotimes(gid(1),f)
afterphi2=gcompose(gev(1),afterphi1)
afterphi3=gcompose(afterphi2,gcoev(1))
@test isempty(afterphi3.loops)
@test length(afterphi3.graph.vertices)==2
@test map(length,afterphi3.graph.adjlist) ==[1,1]
@test isempty(afterphi3.outerports.dom)
@test isempty(afterphi3.outerports.cod)
@test length(afterphi3.innerports)==1
@test afterphi3.innerports[1].label==:f
# so this is trace of f


# Morton-Spivak NF paper with a morvar for f:A⊗A→A⊗A (i.e. with doubled wires)
f = gmorvar(2,2,:f)
afterphi1 = gotimes(gid(2),f)
afterphi2=gcompose(gev(2),afterphi1)
afterphi3=gcompose(afterphi2,gcoev(2))
@test isempty(afterphi3.loops)
@test length(afterphi3.graph.vertices)==4
@test map(length,afterphi3.graph.adjlist) ==[1,1,1,1]
@test isempty(afterphi3.outerports.dom)
@test isempty(afterphi3.outerports.cod)
@test length(afterphi3.innerports)==1
@test afterphi3.innerports[1].label==:f
# so again this is the trace of f





#Symbolic labels
A=:A
afterphi1=gotimes(gid(A),gid(A))
afterphi2=gcompose(gev(A),afterphi1)
afterphi3=gcompose(afterphi2,gcoev(A))
## result is a OneCob which just has a loop with the symbol from 2 labeling it.
@test length(afterphi3.loops)==1
@test isempty(afterphi3.graph.vertices)
@test isempty(afterphi3.graph.adjlist)

# to do check that these are what they should be
pp1=PortPair(1,1) #f:A->A
pp2=PortPair(1,1) #f:A->A
g1=adjlist(KeyVertex{Symbol}, is_directed=false)
u1=add_vertex!(g1,pp1.cod[1])
u2=add_vertex!(g1,pp1.dom[1])
add_edge!(g1,u1,u2)
g2=adjlist(KeyVertex{Symbol}, is_directed=false)
v1=add_vertex!(g2,pp2.cod[1])
v2=add_vertex!(g2,pp2.dom[1])
add_edge!(g2,v1,v2)
phi=OneCob(g1,[],pp1,[])
psi=OneCob(g2,[],pp2,[])
gcompose(phi,psi)


#check it has no loops, just two vertices with an edge between them.

#multiple edge 0aries
@test length(gcompose(gev(2),gcoev(2)).loops)==2
@test length(gcompose(gcompose(gev(3),gotimes(gid(3),gid(3))),gcoev(3)).loops)==3

println("OneCobs tests passed")
end #module OneCobsTest1

module OneCobsTest2
using OneCobs
using OneCobAsMC
using Base.Test
#include("../src/OneCobAsMC.jl")

#Construction in OneCob
g=gmorvar(1,1,:g)
f=gmorvar(2,2,:f)
afterphi1 = gotimes(gid(2),f)
afterphi2=gcompose(gev(2),afterphi1)
afterphi3=gcompose(afterphi2,gcoev(2))

#Now test MC constructions

@test afterphi3==tr(f) #RHS is computed by ev coev etc from CCC default
#OneCob(Undirected Graph (4 vertices, 2 edges),[PortPair([symbol("##22977"),symbol("##22978")],[symbol("##22979"),symbol("##22980")],:f)],PortPair([],[],:unlabled),[],:unlabeled)
@test tr(f) == tr(f) #some work to get equality testing to work here
@test tr(f) == tr(f∘id(dom(f)))
@test tr(transp(f)) == tr(f.')  #ensure f.' is dispatching not doing default transpose(x) = x
@test tr(g) == tr(g.') #these are giving graphs with different ordering of vertices.
@test tr(f) == tr(f.') #these are giving graphs with different ordering of vertices.

@test g ∘ g == g ∘ g #not working, errors out
@test f ∘ f == f ∘ f #not working, errors out


end
