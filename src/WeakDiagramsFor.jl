push!(LOAD_PATH,  joinpath(homedir(),".julia","v0.3","Cateno","src") )
print("Loading Cateno...")
using Typeclass,Representations,FiniteTensorSignatures,WeakWiresBoxes,MonoidalCategories
import Base.show
import FiniteTensorSignatures.show
#automatically compute a diagram interpretation from a finite tensor signature
#second argument is the kind of category, eg. MC, CCC, DCCC.
#consider placing into show in FTS for MorphismWords

symtosign(s::Symbol)=endswith(string(s),"_")? -1 : s==:I ? 0 : 1 

function OWord_to_pmz(A::FiniteTensorSignatures.OWord)
    map(symtosign,FiniteTensorSignatures.flattenotree(A.word))
end

function diagramsfor(T::FiniteTensorSignature,X::Class)
    mordict=Dict()
    obdict=Dict()
    for mv in T.morvars
        if X==MonoidalCategory
            mv_domain = Wires(length(T.dom[mv]))
            mv_codomain = Wires(length(T.cod[mv]))
        elseif X==CompactClosedCategory #shld use a type poset
            mv_domain = Wires(OWord_to_pmz(T.dom[mv]))
            mv_codomain = Wires(OWord_to_pmz(T.cod[mv]))
        end
        mv_label = mv
#        println(mv,mv_domain, mv_codomain, string(mv_label))
        mordict[mv] = mbox(mv_domain, mv_codomain, string(mv_label))
    end
    for ov in T.obvars
 #       println("assigning Wires(1) to ",ov)
        obdict[ov]=Wires(symtosign(ov))
        #arguably the duals should go in the FTS constructor

        obdict[FiniteTensorSignatures.toggledual(ov)]=Wires(symtosign(FiniteTensorSignatures.toggledual(ov)))
    end
#    println(obdict)
#    println(mordict)
    Representation(T,X,obdict,mordict)
#    if X==CompactClosedCategory
#        mordict[:ev]=cap
#    end
end



if isinteractive()
    # print("Interactive Session.  Loading Compose...")
    # import Compose
    print("Loading Blink...")
    import Blink
    print("Initializing Blink...")
    atomsh = Blink.init() #starts shell
    windw = Blink.Window(atomsh) #wraps in Window
    Blink.title(windw,"Cateno")
# Blink.loadhtml(w,BlinkDisplay.tohtml(d.value(f)))
    let T = FTS("f:A->A"), f = MW(:f,T), d = diagramsfor(f.signature, CompactClosedCategory)
        Blink.loadhtml(windw,BlinkDisplay.tohtml(d.value(f.')))
        #when object labels work, this will spell Cateno
        # let T = FTS("t:A->E,n:E->O"), t = MW(:t,T),  n = MW(:n,T),
        # word = (ev(A)∘(id(dual(A))⊗ (t ∘ n)))
        # Blink.loadhtml(windw,BlinkDisplay.tohtml(d.value(word)))

    end
#    BlinkDisplay.Graphics.render(BlinkDisplay._display, ctx)

    # media(Compose.Context,Media.Graphical)
    # ctx = Compose.compose(Compose.context(),Compose.text(0.5,0.5,"Ready"))
    # display(ctx) # just the statment ctx wont call display if there is anything after it, so nothing to pin to.
    # media(Boxx,Media.Graphical)
 #   pin();
    # display(WeakWiresBoxes.mbox(1,1,"Ready  ").')


    # oldshow=@which show(STDOUT,f) # this gives a method, not callable
                       
    function show(io::IO,w::MorphismWord)
        d = diagramsfor(w.signature, CompactClosedCategory)
#        display(d.value(w))
        #      BlinkDisplay.Graphics.render(BlinkDisplay._display, d.value(w))
        Blink.loadhtml(windw,BlinkDisplay.tohtml(d.value(w)))
        print(io,"$(w.contents):$(FiniteTensorSignatures.otreestring(w.dom.contents.word))→$(FiniteTensorSignatures.otreestring(w.cod.contents.word)) over $(w.signature)")
 #       display(io,d.value(w));
    end

    function viewcontext(c::Compose.Context)
        Blink.loadhtml(windw,BlinkDisplay.tohtml(c))
    end

end


# import Blink
# ash = Blink.init() #starts shell
# w = Blink.Window(ash) #wraps in Window
# Blink.loadhtml(w,BlinkDisplay.tohtml(d.value(f)))




# import Blink
# BlinkDisplay.init()
# media(Boxx,Media.Graphical)
# mbox(1,1,"f")
# pin()

# D(h∘sigma(B,A)∘(f⊗id(A)))
# a> include("DiagramsFor.jl")
# diagramsfor (generic function with 1 method)

# julia> fts"f:A→B,g:B->C,h:A⊗B→C"
# {f:A→B,g:B→C,h:A⊗B→C}

# julia> D=diagramsfor(T,ClosedCompactCategory).value

