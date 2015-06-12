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



# as can be checked by hand, taking trace of g and g.' via the onecob op method yields graphs with different presentations (vertex orders).  In terms of symbols and edges, the graphs will be the same.  Thus to make these equal we implemented equality of graphs to check that the vertex set and edge set is the same.  See the makeedgeset and graphsequal functions in OneCobs.jl

@test tr(g) == tr(g.') #these were giving graphs with different ordering of vertices.  As it should be, if you work it out on paper.
@test tr(f) == tr(f.') 


# ey = id(dom(g))
# this one required rewriting the compose op to contract from the left, i.e. use the rightmost gensym in each connected component.
@test g ∘ id(dom(g)) == g

f1 = gmorvar(1,1,:f1)
f2 = gmorvar(1,1,:f2)
g1 = gmorvar(1,1,:g1)
g2 = gmorvar(1,1,:g2)
@test (f1 ⊗ f2) ∘ (g1 ⊗ g2) == (f1 ∘ g1) ⊗ (f2 ∘ g2) #everything equal except innerport order is different; changed equality to test for the set of inner ports to be equal (graph equality will check for edge matchup)
f1 = gmorvar(3,3,:f1)
f2 = gmorvar(2,2,:f2)
g1 = gmorvar(3,3,:g1)
g2 = gmorvar(2,2,:g2)
@test (f1 ⊗ f2) ∘ (g1 ⊗ g2) == (f1 ∘ g1) ⊗ (f2 ∘ g2) 

#ZigZag, etc
A=dom(g1)
B=dom(g)

#already ok is 
@test (id(A) ⊗ ev(A)) ∘ (coev(A) ⊗ id(A)) ∘ g1 == id(A) ∘ g1
@test  (id(B) ⊗ ev(B)) ∘ (coev(B) ⊗ g) == g

idB= id(B)
@test (id(B) ⊗ ev(B)) ∘ (coev(B) ⊗ idB)  == idB # even this was not Modifying, because there are no innerports unless idB is replaced by something else.

# At first, (id(A) ⊗ ev(A)) ∘ (coev(A) ⊗ id(A))  != id(A)  because they are merely isomorphic: the new symbols being generated in each call. To fix this, we compare OneCobs with no innerports by composing them with something
@test (id(A) ⊗ ev(A)) ∘ (coev(A) ⊗ id(A))  == id(A)

#currently counting the number of loops.  Subtle error might be possible if there are two different objects/wire colors; might want to use the onecob label field then.
@test ev(A) ∘ coev(A) == ev(B) ∘ coev(B) ∘ ev(B) ∘ coev(B) ∘ ev(B) ∘ coev(B)
@test ev(A) ∘ coev(A) == (ev(B) ∘ coev(B)) ⊗ ( ev(B) ∘ coev(B) ) ⊗ ( ev(B) ∘ coev(B))

@test f.'.' == f

psi = gmorvar(0,1,:psi)
phi = gmorvar(1,0,:phi)
phipsi = phi ∘ psi #'inner product'/contraction
psiphi = psi ∘ phi #'outer product'
@test  tr(psi ∘ phi) == phi ∘ psi


# gensym interacts badly with multiple occurances of $g$.  We need new symbols for each copy of g.
# @test g ∘ g == g ∘ g #<-- we are here
# @test f ∘ f == f ∘ f #not working, errors out

end
