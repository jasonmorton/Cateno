module temp
using OneCobs, Base.Test
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

#this fails
#a W on its side
#i=gcompose(OneCobs.ev(1),OneCobs.ev(1))
#check it has no loops, just two vertices with an edge between them.


end
