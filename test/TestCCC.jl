using GTNTypes, Typeclass
import GTNTypes.∘, GTNTypes.⊗

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

@instance ClosedCompactCategory Int Mat begin
    dual(A::Int)=A
    transp(f::Mat)=f'
    ev(A::Int)= reshape(eye(A),(1,A^2))    #A*⊗A→I
    coev(A::Int) = reshape(eye(A),(A^2,1)) #I→A⊗A*
    Hom(A::Int,B::Int)=dual(A)⊗B
    sigma(A::Int,B::Int)=swapmat(A,B)      #A⊗B→B⊗A
end


trace(f) = (ev(dual(dom(f)))) ∘ (f ⊗ id(dual(dom(f)))) ∘ coev(dom(f))