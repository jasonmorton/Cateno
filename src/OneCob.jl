module OneCob
using Docile
@docstrings

@doc """
#Every OneCob has two inner boxes, each with dom and cod ports, and one outer box with dom and cod ports.  (Additionally it has loop ports). In the destinations list, they are listed in order: inner1 (top or left) dom, inner1.cod, inner2.dom, inner2.cod, outer.dom, outer.cod.
""" ->
type OneCob
    destinations::Array{Int,1} # where each port goes
    #  number of each kind of port.
    #               # port ranges:
    inner1dom::Int  # 1 to inner1dom 
    inner1cod::Int  # inner1dom+1 to inner1dom+inner1cod 
    inner2dom::Int  # inner1dom+inner1cod+1 to inner1dom+inner1cod+inner2dom
    inner2cod::Int  # inner1dom+inner1cod+inner2dom+1 to 
                    #     inner1dom+inner1cod+inner2dom+inner2cod
    outer1dom::Int  # inner1dom+inner1cod+inner2dom+inner2cod+1 to 
                    #     inner1dom+inner1cod+inner2dom+inner2cod+outer1dom
    outer1cod::Int  # inner1dom+inner1cod+inner2dom+inner2cod+inner1dom+1 to  
                    #inner1dom+inner1cod+inner2dom+inner2cod+outer1dom+outer1cod 
    numloops::Int
    numports::Int
    OneCob(dest,i1d,i1c,i2d,i2c,o1d,o1c,nl) = new(vec(dest),i1d,i1c,i2d,i2c,
                                                  o1d,o1c,length(destinations))
end

################################################################################
function morcompose(phi,psi)
    # first renumber the ports of psi
    psi.destinations=psi.destinations+phi.numports
    # allocate new op with some correct defaults
    out=OneCob([ psi.destinations ; phi.destinations ],
               psi.numinputs + phi.numinputs,
               psi.numloops + phi.numloops
               
               
    
end

function morotimes(phi,psi)

end
