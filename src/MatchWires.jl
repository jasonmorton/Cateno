import DataStructures.OrderedDict


#first assume L and R have same cardinality
function greedymatchwires(Left,R)
    #OrderedDict is used to retain ordering, so +1,-1,0 s are 
    # only swapped with others, not the same sign.
    L=OrderedDict([(j,Left[j]) for j=1:length(Left)])
    n=length(R)
    destinations=zeros(Int,n) #where R goes
    for i=1:n
        for (j,s) in L
            if s==R[i] #match
                destinations[i]=j #record it
                delete!(L,j) #remove it as an option 
                break # go to next element of R
            end
        end
    end
    return destinations
end
                
            
    
#warning, will happily permute to match eg [1 -1] and [-1 1]
# need to add control to only move around zeros (Is)
