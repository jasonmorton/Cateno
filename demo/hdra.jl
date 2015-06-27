using OneCobs, OneCobAsMC
f = gmorvar(2,2,:f);
g = gmorvar(1,1,:g);
A = dom(f)
afterphi1 = id(A) ⊗ f;
afterphi2 = ev(A) ∘ afterphi1;
afterphi3 = afterphi2 ∘ coev(A);

afterphi3==tr(f)
tr(f) == tr(f∘id(dom(f)))
tr(f) == tr(f.')

f ∘ id(dom(f)) == f
f.'.' == f
############

f1 = gmorvar(3,3,:f1);
f2 = gmorvar(2,2,:f2);
g1 = gmorvar(3,3,:g1);
g2 = gmorvar(2,2,:g2);
#two ways of composing
(f1 ⊗ f2) ∘ (g1 ⊗ g2) == (f1 ∘ g1) ⊗ (f2 ∘ g2) 

#zigzag
(id(A) ⊗ ev(A)) ∘ (coev(A) ⊗ id(A))  == id(A)

A=dom(g1)
B=dom(g)

#multiple loops
ev(A) ∘ coev(A) == ev(B) ∘ coev(B) ∘ ev(B) ∘ coev(B) ∘ ev(B) ∘ coev(B)
ev(A) ∘ coev(A) == (ev(B) ∘ coev(B)) ⊗ ( ev(B) ∘ coev(B) ) ⊗ ( ev(B) ∘ coev(B))


#inner product vs trace of outer product
psi = gmorvar(0,1,:psi);
phi = gmorvar(1,0,:phi);
phipsi = phi ∘ psi #'inner product'/contraction
psiphi = psi ∘ phi #'outer product'

tr(psi ∘ phi) == phi ∘ psi


