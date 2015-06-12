module TestClosedCompactCategories
using Base.Test
using IntMat
# using MonoidalCategories, Typeclass
# import MonoidalCategories.∘, MonoidalCategories.⊗

# typealias Mat Matrix{Float64}

# @instance MonoidalCategory Int Mat begin
#     dom(f::Mat)=size(f)[2]
#     cod(f::Mat)=size(f)[1]
#     id(A::Int)=eye(A)
#     compose(f::Mat,g::Mat)=f*g
#     otimes(f::Mat,g::Mat)=kron(f,g)
#     otimes(A::Int,B::Int)=A*B
#     munit(::Int)=1
# end



# #if A is M dimensional and B is N dimensional, 
# #the matrix for σ_{A,B}: A⊗B→B⊗A
# function swapmat(M,N)
#     Out=zeros(M*N,N*M)
#     for i = 1:N
#         for j = 1:M
#             Out[(i-1)*M + j,(j-1)*N + i]=1
#         end
#     end
#     Out
# end

# @instance ClosedCompactCategory Int Mat begin
#     dual(A::Int)=A
#     transp(f::Mat)=f'
#     ev(A::Int)= reshape(eye(A),(1,A^2))    #A*⊗A→I
#     coev(A::Int) = reshape(eye(A),(A^2,1)) #I→A⊗A*
#     Hom(A::Int,B::Int)=dual(A)⊗B
#     sigma(A::Int,B::Int)=swapmat(A,B)      #A⊗B→B⊗A
# end



ccctrace(f) = (ev(dual(dom(f)))) ∘ (f ⊗ id(dual(dom(f)))) ∘ coev(dom(f))
fmat=randn(10,10)
@test_approx_eq ccctrace(fmat) trace(fmat)
f=fmat
B = dom(f)
@test  (id(B) ⊗ ev(B)) ∘ (coev(B) ⊗ id(B))  == id(B)
A = dom(f^{⊗3})
@test ev(A) ∘ coev(A) == ev(B) ∘ coev(B) ∘ ev(B) ∘ coev(B) ∘ ev(B) ∘ coev(B)
@test ev(A) ∘ coev(A) == (ev(B) ∘ coev(B)) ⊗ ( ev(B) ∘ coev(B) ) ⊗ ( ev(B) ∘ coev(B))


println("Closed Compact Categories tests passed")
end
