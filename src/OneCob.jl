module OneCob
using Docile
@docstrings
import Base.in


@doc """
#Every OneCob has some number (possibly zero) of inner boxes, each with dom and cod ports, and one outer box with dom and cod ports.  (Additionally it has loop ports). In the destinations list, they are listed in the order: outercod, outerdom, inner1cod, inner1dom, etc.
""" ->

type PortPair
    cod::Array{Symbol,1} #pointers maybe? unique gensyms? assume all symbols unique
    dom::Array{Symbol,1}
end
in(item,p::PortPair)= item in p.cod || item in p.dom
in(item,ps::Array{PortPair})= any([item in p for p in ps])
PortPair(d,c)=PortPair([gensym() for i in 1:c],[gensym() for i in 1:d]) #flipped order

type OneCob
    destination::Dict{Symbol,Symbol}
    innerports::Array{PortPair,1}
    outerports::PortPair
    loops::Array{Symbol}
end

destination(phi,port)

################################################################################
# final ports in the new op are numbered as follows.
# first come the innerports of phi, then the innerports of psi, then the outerports
# of the new op.
function morcompose(phi::OneCob,psi::OneCob)
    innerports = [phi.innerports;psi.innerports] #but need to relabel somehow, or have a global labeling for all innermost ports in exprsession
    outerports = [phi.outerports.cod;psi.outerports.dom]
    destination=Dict{Symbol,Symbol}()
    for portpair in phi.innerports
        n = length(portpair.cod)
        for i=1:n 
            port = portpair.cod[i]
            if phi.destination[port] in phi.innerports
                destination[port]=phi.destination[port] #todo, start with the old dicts
            elseif destination(port) in phi.outerports.cod
                destination[port]=phi.destination[port]
            elseif destination(port) in phi.outerports.dom
                # send it to cod g port. dom and cod must match, so same number.
                #i.e. we identify phi.outerports.dom and psi.outerports.cod, throw away one set of symbols (higher in tree),
                # then compute the loops and cob of the result.  external vertices go in one hop to known exits.
                # loops of arbitrary complexity must be found and resolved.
                psipartner = psi.outerports.cod[i]
                # does this port loop back to the dom(f), so a cycle can be created?
                phipartner = phi.destination[port] # (loops if in phi.outerports.dom)
                # here are the cases.  Loop creation can be arbitrarily complicated.  In each loop we keep one symbol, assuming direction doesn't matter
                if phipartner in phi.outerports.dom 
                    
                end
            end
        end
    end
    for portpair in psi.innerports
        n = length(portpair.cod)
        for i=1:n 
            port = portpair.cod[i]
            if psi.destination[port] in psi.innerports
                destination[port]=psi.destination[port] #todo, start with the old dicts
            elseif destination(port) in psi.outerports.cod
                # send it to dom f port. dom and cod must match, so same number.
                destination[port] = phi.outerports.dom[i]
                #the below assignement should be dealt with in the loop for phi.outerports.dom
            elseif destination(port) in phi.outerports.dom
                nothing #should be already handled
                #                destination[port]=psi.destination[port]
            end
        end
    end
    OneCob(destination,
           innerports,
           outerports,
           numloops)
end
    
               
    
end

function morotimes(phi,psi)

end
