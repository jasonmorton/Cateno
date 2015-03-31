macro wrapped_integer(name)
    type :($name) <: Integer
        contents::Integer
    end
    +(a::$name,b::$name)=a.contents+b.contents
    getindex(A,ind::$name)=A[ind.contents]
end