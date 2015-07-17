module SimpleOneCob

# Attempt to rewrite in simplified way with labeled lowered onecob

typealias Adjlist Array{Array{Integer,1}} #Adjlist

type OneCob
    numports::Integer
    inports::Array{Integer,1}
    outports::Array{Integer,1}
    neighbors::Adjlist
    fakeinports::Array{Integer,1} # for morvars and loops (object-labelled)
    #morvaranchor::BitArray{1} # true if corresp to a morvar innerport, or a loop.  So, tracks an external reference to it.
#    offset::Integer #vertices labeled offset+1 to offset+numports
#    edges::Array{Integer,1}
end




function dfs(neighbors::Adjlist,v::Integer)
    N = length(neighbors)
    visited = falses(N)::BitArray{1}
    stack = Integer[]
    push!(stack,v)
    while !isempty(stack)
        v = pop!(stack)
        if !visited[v]
            visited[v] = true
            push!(stack,neighbors[v])
        end
    end
    visited
end

dfs(oc::OneCob,v) = dfs(oc.neighbors,v)

function connectedcomponents(neighbors::Adjlist)
    N = length(neighbors)
    marked = falses(N)
    components = Array{Integer,1}[]
    for i in 1:N
        if !marked[i]
            component = dfs(neighbors,i)::BitArray{1}
            marked = marked | component
            #find converts the bitarray to the list of "true" indices
            push!(components, find(component))
        end
    end
    components
end

connectedcomponents(oc::OneCob) = connectedcomponents(oc.neighbors)

function gotimes(oc1,oc2)
    offset = oc1.numports
    OneCob(
           oc1.numports+oc2.numports,
           [oc1.inports, offset+oc2.inports],
           [oc1.outports, offset+oc2.outports],
           [oc1.neighbors, offset+oc2.neighbors],
           [oc1.fakeinports, offset+oc2.fakeinports]
    )
end

function addedge!(oc::OneCob,i,j)
    if !(j in oc.neighbors[i])
        push!(oc.neighbors[i],j)
    end
    if !(i in oc.neighbors[j])
        push!(oc.neighbors[j],i)
    end
end


function gcompose(oc1,oc2)
    @assert length(oc1.inports) == length(oc2.outports) #replace with domcodtypecheck

    offset = oc1.numports
    numglued = length(oc1.inports) # same as oc2.outports

    newinports = offset+oc2.inports
    newoutports = oc1.outports
    newfakeinports = [oc1.fakeinports,offset+oc2.fakeinports] #this will grow for loops

    # write the two onecobs next to each other
    oc3 = gotimes(oc1,oc2)
    # connect inputs and outputs
    for i in numglued # same as oc2.outports
        addedge!(oc3, oc1.inports[i], offset + oc2.outports[i])
    end
    # Simplify. Decide if each component is a loop; if it is, record that,
    # otherwise replace it with an edge
    simplified_components = Array{Integer,1}[]

    for component in connectedcomponents(oc3)
        # Each connected component is one of four possibilities: a half-loop
        # connecting two inports, a half-loop connecting two outports, a
        # loop, or an edge connecting one inport to one outport.
        component_is_loop = true
        inport = 0
        outport = 0
        for v in component
            if v in newinports # look for ports; port type determines cob type
                component_is_loop = false
                if inport != 0  # already saw an inport, so this component
                                # is a half-loop connecting two inports
                    push!(simplified_components,[inport,v])
                elseif outport !=0 # this must be an edge inport to outport
                    push!(simplified_components,[v,outport])
                else # first port discovered, next port found will determine type
                    inport = v
                end
            elseif v in newoutports
                component_is_loop = false
                if outport != 0  # already saw an outport, so this component
                                # is a half-loop connecting two outports
                    push!(simplified_components,[outport,v])
                elseif inport !=0 # this must be an edge inport to outport
                    push!(simplified_components,[inport,v])
                else # first port discovered, next port found will determine type
                    inport = v
                end

            else # v is internal to the connected component
                nothing
            end
        end

        if component_is_loop
            push!(newfakeinports,?????)
        else
            nothing
        end
            


    end #end component in cc lloop
end


#use tr(id(A)) where id(A) is treated like a morvar, to track loops?
