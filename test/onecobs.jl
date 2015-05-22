module OneCobsTests
using OneCobs, Base.Test, Graphs



@test isloop( gcompose(OneCobs.ev(:A),OneCobs.coev(:A)) )
c=gcompose(OneCobs.coev(:A),OneCobs.ev(:A))
@test length(c.loops)==0
@test length(c.graph.vertices)==4
@test length(c.graph.adjlist)==4


# Morton-Spivak NF paper with id(1) in place of f for now
# should get single loop
afterphi1=gotimes(id(1),id(1))
afterphi2=gcompose(ev(1),afterphi1)
afterphi3=gcompose(afterphi2,coev(1))
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
f = morvar(1,1,:f)
afterphi1 = gotimes(id(1),f)
afterphi2=gcompose(ev(1),afterphi1)
afterphi3=gcompose(afterphi2,coev(1))
@test isempty(afterphi3.loops)
@test length(afterphi3.graph.vertices)==2
@test map(length,afterphi3.graph.adjlist) ==[1,1]
@test isempty(afterphi3.outerports.dom)
@test isempty(afterphi3.outerports.cod)
@test length(afterphi3.innerports)==1
@test afterphi3.innerports[1].label==:f
# so this is trace of f




#Symbolic labels
A=:A
afterphi1=gotimes(id(A),id(A))
afterphi2=gcompose(ev(A),afterphi1)
afterphi3=gcompose(afterphi2,coev(A))
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
@test length(gcompose(ev(2),coev(2)).loops)==2
@test length(gcompose(gcompose(ev(3),gotimes(id(3),id(3))),coev(3)).loops)==3




println("OneCobs tests passed")
end
