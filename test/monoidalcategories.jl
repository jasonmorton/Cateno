module TestMonoidalCategories
using Base.Test
using MonoidalCategories
#import MonoidalCategories:compose
using IntMat
import IntMat:compose,otimes
# ,Typeclass

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

# MonoidalCategory typeclass
@test dom(rand(3,2))==2
@test cod(rand(3,2))==3
f=rand(3,2); g=rand(2,3);
@test compose(f,g)==f*g
@test f∘g==f*g
@test compose(g,f)==g*f
@test otimes(f,g)==kron(f,g)
@test f⊗g==kron(f,g)
@test id(3)==eye(3)
@test id(2)^{⊗3}==eye(8)
@test id(2)^{∘3}==eye(2)
@test munit(f)==1
#@test id(1)=[1.0].'

println("Monoidal Categories tests passed")

end #module TestMonoidalCategories
