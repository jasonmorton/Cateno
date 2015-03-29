module BinBraKet
using MonoidalCategories
using IntMat
export @ket_str,@bra_str

#string literal definitions 
#bra"0010" for <0010|,  ket"1101" for |1101>
macro ket_str(bitstring)
    v=zeros(2^length(bitstring),1)
    v[parseint(bitstring,2)+1]=1.0
    v
end

macro bra_str(bitstring)
    v=zeros(1,2^length(bitstring))
    v[parseint(bitstring,2)+1]=1.0
    v
end


end
