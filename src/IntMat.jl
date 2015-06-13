module IntMat

using Typeclass,MonoidalCategories

import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘,σ
export dom,cod,id,munit,⊗,∘

import MonoidalCategories:CompactClosedCategory,dual,transp,ev,coev,tr,Hom,sigma
export dual,transp,ev,coev,tr,Hom,sigma

import MonoidalCategories:WellSupportedCompactClosedCategory,delta,mu,epsilon,u
export delta,mu,epsilon,u

typealias Mat Matrix{Float64}

@instance MonoidalCategory Int Mat begin
    dom(f::Mat)=size(f)[2]
    cod(f::Mat)=size(f)[1]
    id(A::Int)=eye(A)
    compose(f::Mat,g::Mat)=f*g
    otimes(f::Mat,g::Mat)=kron(f,g)
    otimes(A::Int,B::Int)=A*B
    munit(::Int)=1
end

#if A is M dimensional and B is N dimensional, 
#the matrix for σ_{A,B}: A⊗B→B⊗A
function swapmat(M,N)
    Out=zeros(M*N,N*M)
    for i = 1:N
        for j = 1:M
            Out[(i-1)*M + j,(j-1)*N + i]=1
        end
    end
    Out
end

@instance CompactClosedCategory Int Mat begin
    dual(A::Int)=A
    transp(f::Mat)=f.' #f' is dagger
    ev(A::Int)= reshape(eye(A),(1,A^2))    #A*⊗A→I
    coev(A::Int) = reshape(eye(A),(A^2,1)) #I→A⊗A*
    Hom(A::Int,B::Int)=dual(A)⊗B
    sigma(A::Int,B::Int)=swapmat(A,B)      #A⊗B→B⊗A
end



@instance WellSupportedCompactClosedCategory Int Mat begin
    function delta(A::Int) #A→A ⊗ A 
        out=zeros(A*A,A)
        for i=1:A
            out[A*(i-1)+i,i]=1
        end
        out
    end
    mu(A::Int)=delta(A).' #A→A ⊗ A
    epsilon(A::Int)=ones(1,A) #A→I
    u(A::Int)=ones(A,1) #I→A
end 



end
