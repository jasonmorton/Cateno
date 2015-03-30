using GTNTypes,ExampleTensorSignature
import GTNTypes:MonoidalCategory,dom,cod,id,munit,⊗,∘
using Base.Test
import ExampleInterpretation

F=ExampleInterpretation.value #defines an interpretation, i.e. an X monodial functor from the free X monoidal category over the tensor schme to the quantitative category

@test F(f⊗g)==F(f)⊗F(g)
@test F(f∘h)==F(f)∘F(h)

#Monoidal Categories------------------
#Tests of tensor scheme and morphism word manipulation
@test dom(f)==cod(h)
@test dom(f∘h)==dom(g)


#Tests of interpretation
@test F(f ∘ h) ==
    Float64[50.0   60.0
            114.0  140.0]
@test F(f ∘ h) ⊗ F(g) ==
Float64[
  50.0   100.0    60.0   120.0
 150.0   200.0   180.0   240.0
 250.0   300.0   300.0   360.0
 400.0   450.0   480.0   540.0
 114.0   228.0   140.0   280.0
 342.0   456.0   420.0   560.0
 570.0   684.0   700.0   840.0
 912.0  1026.0  1120.0  1260.0]

#dom, cod, id, and munit etc. need to be called specifically from F at this point
#@test F.dom(F(f ∘ h) ⊗ F(g))==4

#Closed Compact Categories------------------
using Typeclass

import GTNTypes:ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma

#monoidal language tests
@test dom(tr(id(dom(f))))==munit(dom(g))


#replace with "using IntMat"
#The CCC Int Mat
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

#trace(f) = (ev(dual(dom(f)))) ∘ (f ⊗ id(dual(dom(f)))) ∘ coev(dom(f))

#raw Int Mat as a CCC tests (no tensor sig)
@test coev(2)==Float64[1 0 0 1]' #; would give 4 elt not 4x1


#Interpretation in the CCC Int Mat
#we want objects to resolve and F to be a functor so commute with dom
#test Functoriality
@test dom(F(f))==4 
@test dom(F(f ∘ h) ⊗ F(g))==4 #no longer needs to be qualified
@test F(dom(f))==4 
@test F(dom(f⊗f))==dom(F(f⊗f))==16
@test F(cod(f⊗f))==cod(F(f⊗f))==4

@test F(f⊗g)==F(f)⊗F(g)
@test F(f∘h)==F(f)∘F(h)

 
