using Typeclass,Representations,FiniteTensorSignatures,WiresBoxes,MonoidalCategories

#automatically compute a diagram interpretation from a finite tensor signature
#second argument is the kind of category, eg. MC, CCC, DCCC.
#consider placing into show in FTS for MorphismWords
function diagramsfor(T::FiniteTensorSignature,X::Class)
    # eval( Expr(:using,:WiresBoxes))
    # eval( Expr(:using,:Representations))
    mordict=Dict()
    obdict=Dict()
    for mv in T.morvars
        # mv_domain = Wires(length(T.dom[mv]))
        # mv_codomain = Wires(length(T.cod[mv]))
        mv_domain = length(T.dom[mv])
        mv_codomain = length(T.cod[mv])
        mv_label = mv
#        println(mv,mv_domain, mv_codomain, string(mv_label))
        mordict[mv] = mbox(mv_domain, mv_codomain, string(mv_label))
    end
    for ov in T.obvars
 #       println("assigning Wires(1) to ",ov)
        obdict[ov]=Wires(1)
        #arguably the duals should go in the FTS constructor

        obdict[FiniteTensorSignatures.toggledual(ov)]=Wires(1)
    end
#    println(obdict)
#    println(mordict)
    Representation(T,X,obdict,mordict)
#    if X==CompactClosedCategory
#        mordict[:ev]=cap
#    end
end

# import Blink
# BlinkDisplay.init()
# media(Boxx,Media.Graphical)
# mbox(1,1,"f")
# pin()
