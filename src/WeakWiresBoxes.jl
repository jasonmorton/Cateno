module WeakWiresBoxes
using Typeclass,MonoidalCategories
import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘,comperr
import Compose
using Compose:Context,context,rectangle,circle,fill #doesn't put in scope
export dom,cod,id,munit,⊗,∘
import MonoidalCategories:CompactClosedCategory,dual,transp,ev,coev,tr,Hom,sigma
export dual,transp,ev,coev,tr,Hom,sigma
export bra,ket,mbox,swap,cup,cap,lines,Boxx,Wires

#import MonoidalCategories:associator,associatorinv,leftunitor,rightunitor,leftunitorinv,rightunitorinv
#import MonoidalCategories:lrweaktranspose

import Base:writemime,length
include("MatchWires.jl")
################################################################################
############# Basic defintions and instance declaration ################
type Wires  
    signs::Array{Int,1} # 1=primal 0=I -1=dual
end
==(w::Wires,z::Wires)=w.signs==z.signs
Wires(signs::Array{Int,2})=Wires(vec(signs))
Wires(n::Int)=Wires(sign(n)*ones(Int,abs(n)))
length(w::Wires)=length(w.signs)

#weak Boxx should always have same *number* of in and out wires, although not direction/object necessarily.
type Boxx    
    con::Context   #The Compose.jl Context that holds the drawing
    inwires::Wires
    outwires::Wires
    length::Int    #number of primitive horizontal boxes in the Boxx
end
Boxx(c,n::Array{Int},m::Array{Int},ell)=Boxx(c,Wires(n),Wires(m),ell) 
Boxx(c,n::Int,m::Int,ell)=Boxx(c,Wires(n),Wires(m),ell) 
writemime(io::IO, m::MIME"image/svg+xml", b::Boxx)=writemime(io::IO, m, b.con)


@instance MonoidalCategory Wires Boxx begin #UnitorWeakMonoidalCategory
    dom(c::Boxx)=c.inwires
    cod(c::Boxx)=c.outwires
    id(w::Wires)=primitive(w,:line) #Boxx(lines(w.signs),w,w,1) #lines skips Is in array
    function compose(f::Boxx,g::Boxx)
        if dom(f)==cod(g)
            hstackCons(f,g)     
#            hstackCons( hstackCons(f,labeledbarelines()),g) but Boxx doesn't know its labels.


        #  try to unify the objects, and then apply a permutation
        #  first of all, see if they have the same objects up to insertion and 
        #  deletion of Is, e.g. A⊗I⊗B and A⊗B⊗I⊗I
        elseif  filter(x->x!=0,dom(f).signs)==filter(x->x!=0,cod(g).signs)
            # now figure out which is longer (therefore has more Is), f or g, 
            # and pad the other one to the same length.
#            println("Adjusting domains")
            length_domf_minus_length_codg=length(dom(f))-length(cod(g))
            if  length_domf_minus_length_codg==0 #they are already the same length,
                                                 # and just need a permutation
                nothing
            elseif length_domf_minus_length_codg>0 # we pad g
                #this shouldn't modify given g, passed by value
                #todo: match padding if possible, e.g. match any Is in the beginning
                lz=leadin_zeros(dom(f).signs)

                #pad both top and bottom
                if lz!=0 && (length_domf_minus_length_codg-lz)!=0 
                    g=(id(munit(g))^{⊗lz}) ⊗ g ⊗ (id(munit(g))^{⊗ (length_domf_minus_length_codg-lz)}) 
                    
                # pad top only, nothing left after top Is
                elseif lz!=0 && (length_domf_minus_length_codg-lz)==0 
                    g=(id(munit(g))^{⊗lz}) ⊗ g 
                
                # pad bottom only, no top Is
                elseif lz==0
                    g= g ⊗ (id(munit(g))^{⊗ (length_domf_minus_length_codg)}) 
                else
                    error()
                end
                
            elseif length_domf_minus_length_codg<0 # we pad f
                lz=leadin_zeros(cod(g).signs)
                if lz!=0 && (-length_domf_minus_length_codg-lz)!=0  #pad both top and bottom
                    f=(id(munit(g))^{⊗lz}) ⊗f⊗ (id(munit(g))^{⊗ (-length_domf_minus_length_codg-lz)}) 
                elseif  lz!=0 && (-length_domf_minus_length_codg-lz)==0 # pad top only
                    f=(id(munit(g))^{⊗lz}) ⊗f
                    
                elseif lz==0 #pad bottom only
                    f=f⊗ (id(munit(g))^{⊗ (-length_domf_minus_length_codg)}) 
                else
                    error()
                end
            end
            # join, permute, and be merry
            # consider using a three-argument special hstackCons that makes result length 2
            hstackCons(
                       hstackCons(
                                  f,
                                  primitive(cod(g),
                                            :perm,
                                            greedymatchwires(dom(f).signs,cod(g).signs))),
                       g)
        else
            error("Domain $(dom(f)) and codomain $(cod(g)) cannot be converted to a common object by inserting monoidal units and shifts.")
        end
    end

    ∘(f::Boxx,g::Boxx)=compose(f,g)
    otimes(f::Boxx,g::Boxx)=vstackCons(f,g)
    otimes(w::Wires,u::Wires)=Wires(vcat(w.signs,u.signs))
    munit(::Wires)=Wires([0])  
end

function leadin_zeros(x::Array{Int})
    count=0
    for i=1:length(x)
        if x[i]==0
            count=count+1
        else
            break
        end
    end
    return count
end

##### Associative vertical and horizontal stacking #########
#the strategy to get associative ⊗ vertically is to track the total, maximum number of wires.  In the final image, each wire gets the same amount of space above and below.  For horizontal ∘, we use length.  We may also need virtual wires or spacer wires to pad any vertical slices that fall short.

function vstackCons(top,bot)
    #these should always be equal now
    topmax=max( length( dom(top).signs)   ,  length( cod(top).signs) ) 
    botmax=max(length(dom(bot).signs),length(cod(bot).signs))     #these should always be equal now
    inwires=dom(top)⊗dom(bot) #concats
    outwires=cod(top)⊗cod(bot) #concats
    M=topmax+botmax
    topshare=topmax/M
    botshare=botmax/M
    con=Compose.compose(Compose.context(), #the new parent context
                        (Compose.context(0,0,1,topshare),top.con), 
                        (Compose.context(0,topshare,1,botshare),bot.con))
    Boxx(con,inwires,outwires,max(top.length,bot.length))
end

function hstackCons(left,right)
    newlength=left.length+right.length
    leftshare=left.length/newlength
    rightshare=right.length/newlength
    Boxx(Compose.compose(Compose.context(), #the new parent context
                        (Compose.context(0,0,leftshare,1),left.con),
                        (Compose.context(leftshare,0,rightshare,1),right.con)),
        dom(right),cod(left),newlength)
end

############## Graphics primitives #########################
# line spacing designed to work with associative stacking
#lines(n::Integer)=Compose.compose(Compose.context(),Compose.stroke(Compose.color("black")),Compose.linewidth(1),[Compose.line([(0,(i-(1/2))/(n)),(1,(i-(1/2))/(n))]) for i=1:n]...)

lines(n::Int)=lines([1 for i=1:n])

function lines(signs::Array{Int})
    N=length(signs)
    lineContexts=Any[]
    for i=1:N
        y=(i-.5)/N
        # ycy = Compose.Measure(0,0,y,0,0)
        # half = Compose.Measure(0,0.5,0,0,0)
        if signs[i]==-1
            thisline=[Compose.line([(0,y),(1,y)]),
                      Compose.line([(.5,y),(.45,y-.05)]),
                      Compose.line([(.5,y),(.45,y+.05)])]
        elseif signs[i]==1
            thisline=[Compose.line([(0,y),(1,y)]),
                      # Compose.line([(.5,y),(half + .1Compose.w,ycy - .1Compose.h)]),
                      # Compose.line([(.5,y),(half + .1Compose.w,ycy + .1Compose.h)])]
                      Compose.line([(.5,y),(.55,y-.05)]),
                      Compose.line([(.5,y),(.55,y+.05)])]
        elseif signs[i]==0
            thisline=[] #Compose.line([(.45,y),(.55,y)])]
        else
            error("invalid line")
        end
        append!(lineContexts,thisline)
    end
    Compose.compose(Compose.context(),Compose.stroke(Compose.color("black")),Compose.linewidth(1),lineContexts...)
end


function labeledbarelines{T<:String}(signs::Array{Int},labels::Array{T})
    N=length(signs)
    lineContexts=Any[]
    for i=1:N
        y=(i-.5)/N
        # ycy = Compose.Measure(0,0,y,0,0)
        # half = Compose.Measure(0,0.5,0,0,0)
        if signs[i]==-1
            thisline=[Compose.line([(0,y),(1,y)]),
                      # Compose.line([(.5,y),(.45,y-.05)]),
                      # Compose.line([(.5,y),(.45,y+.05)]),
                      Compose.compose(Compose.context(),Compose.text(.5,y-.07,labels[i]),Compose.linewidth(.3)) 
                      ]
        elseif signs[i]==1
            thisline=[Compose.line([(0,y),(1,y)]),
                      # Compose.line([(.5,y),(half + .1Compose.w,ycy - .1Compose.h)]),
                      # Compose.line([(.5,y),(half + .1Compose.w,ycy + .1Compose.h)])]
                      # Compose.line([(.5,y),(.55,y-.05)]),
                      # Compose.line([(.5,y),(.55,y+.05)]),
                      Compose.compose(Compose.context(),Compose.text(.5,y+.07,labels[i]),Compose.linewidth(.3)) 
            ]
           
        elseif signs[i]==0
            thisline=[] #Compose.line([(.45,y),(.55,y)])]
        else
            error("invalid line")
        end
        append!(lineContexts,thisline)
    end
    Compose.compose(Compose.context(),Compose.stroke(Compose.color("black")),Compose.linewidth(1),lineContexts...)
end



threeptpoly(a,b,c,tx)=Compose.compose(Compose.context(),Compose.polygon([a,b,c]),Compose.fill(Compose.RGBA{Float64}(0,0,0,0)),Compose.stroke(Compose.color("black")),Compose.text(.5,.5,tx))

### Helper functions for building primitive graphical elements
function hstackcontexts(c1,c2)
    Compose.compose(Compose.context(), #the new parent context
            (Compose.context(0,0,.5,1),c1),
            (Compose.context(.5,0,.5,1),c2))
end
function hstackcontexts(c1,c2,c3)
    Compose.compose(Compose.context(), #the new parent context
                    (Compose.context(0,0,.25,1),c1),
                    (Compose.context(.25,0,.5,1),c2),
                    (Compose.context(.75,0,.25,1),c3)
                    )
end

#primitive graphical elements
bra(n,txt)=Boxx(hstackcontexts(threeptpoly((0,.5),(1,.95),(1,.05),txt),lines(n)),
               ones(Int,n),zeros(Int,n),1)
ket(n,txt)=Boxx(hstackcontexts(lines(n),threeptpoly((1,.5),(0,.95),(0,.05),txt)),              zeros(Int,n),ones(Int,n),1)
ket(n)=ket(n,"")
bra(n)=bra(n,"")

boxwithtext(txt)=Compose.compose(Compose.context(),Compose.rectangle(0,.05,1,.9),Compose.fill(Compose.RGBA{Float64}(0,0,0,0)),Compose.stroke(Compose.color("black")),Compose.text(.5,.55,txt)) #.5 -1textwidth, .5+1textheight is what we want


#Weak mboxes are padded so number of wires is the same coming in and going out
function mbox(w::Wires,v::Wires,txt)
    nwires=max(length(w.signs),length(v.signs))
    new_w=zeros(Int,nwires)
    new_v=zeros(Int,nwires)
    new_w[1:length(w.signs)]=w.signs
    new_v[1:length(v.signs)]=v.signs
    Boxx(hstackcontexts(lines(new_v),boxwithtext(txt),lines(new_w)),new_w,new_v,1)
end
mbox(w::Wires,v::Wires)=mbox(w,v,"")
mbox(w::Array,v::Array)=mbox(Wires(w),Wires(v),"")
mbox(n::Int,m::Int,txt)=mbox(Wires(n),Wires(m),txt)
mbox(n::Int,m::Int)=mbox(n,m,"")
Boxx(n::Int,m::Int,txt)=mbox(n,m,txt)
Boxx(n::Int,m::Int)=mbox(n,m)


swap_underline=Compose.compose(Compose.context(),Compose.curve((0,.75),(.7,.75),(.3,.25),(1,.25)),Compose.stroke(Compose.color("black")),Compose.linewidth(1))
swap_overline(col,wid)=Compose.compose(Compose.context(),Compose.curve((0,.25),(.7,.25),(.3,.75),(1,.75)),Compose.stroke(Compose.color(col)),Compose.linewidth(wid))
swapcon=Compose.compose(swap_underline,Compose.compose(swap_overline("white",2),swap_overline("black",1)))

swap=Boxx(swapcon,[1 1],[1 1],1)

#todo: always insert a primitive when composing.  When not needed, just add lengthless one with labels only.
#swaps, unitors, perms, lines, etc all special cases of
primitive(w::Wires,kind::Symbol)=primitive(w::Wires,kind::Symbol,[i for i in 1:length(w.signs)])
function primitive(w::Wires,kind::Symbol,π::Array)
    n=length(w.signs)
    # possible y values 
    if kind in (:perm,:line)
        linelocation=[(i-(1/2))/n for i=1:n] 
    elseif kind in (:cup,:cap)
        linelocation=[(i-(1/2))/(2n) for i=1:2n] 
    end
    contents=Any[]
    for i=1:n
        Icolor=nothing#Compose.color("light grey") #for debugging
        color=w.signs[i]==0?Icolor : Compose.color("black")
        y=linelocation[i]
        if kind==:perm
            y1=linelocation[π[i]]
            thisline=Compose.compose(Compose.context(),
                                     Compose.curve((0,y1),(.7,y1),(.3,y),(1,y)),
                                     Compose.stroke(color),
                                     Compose.linewidth(1))
        elseif kind==:cup
            y1=linelocation[i+n]
            thisline=Compose.compose(Compose.context(),
                                     Compose.curve((0,y),(.75,y),(.75,y1),(0,y1)),
                                     Compose.stroke(color),
                                     Compose.linewidth(1))

        elseif kind==:cap
            y1=linelocation[i+n]
            linelocation=[(i-(1/2))/(2n) for i=1:2n] 
            thisline=Compose.compose(Compose.context(),
                                     Compose.curve((1,y),(.25,y),(.25,y1),(1,y1)),
                                     Compose.stroke(color),
                                     Compose.linewidth(1))
        elseif kind==:line
            y1=linelocation[i]
            if w.signs[i]==-1
                thisline=Compose.compose(Compose.context(),
                                         Compose.line([(0,y),(1,y)]),
                                         Compose.line([(.5,y),(.45,y-.05)]),
                                         Compose.line([(.5,y),(.45,y+.05)]),
                                         Compose.stroke(color),
                                         Compose.linewidth(1))
            elseif w.signs[i]==1
                thisline=Compose.compose(Compose.context(),
                                         Compose.line([(0,y),(1,y)]),
                                         Compose.line([(.5,y),(.55,y-.05)]),
                                         Compose.line([(.5,y),(.55,y+.05)]),
                                         Compose.stroke(color),
                                         Compose.linewidth(1))                
            elseif w.signs[i]==0
                thisline=Compose.compose(Compose.context(),
                                         Compose.line([(0,y),(1,y)]),
                                         Compose.stroke(color),
                                         Compose.linewidth(1))

            end
        end
        push!(contents,thisline)

    end
    
    picture = Compose.compose(contents...)
    if kind==:perm
        piwsigns=zeros(Int,n)
        for i in 1:n
            piwsigns[π[i]]=w.signs[i]
        end
        piw=Wires(piwsigns)
        return Boxx(picture,w,piw,1)
    elseif kind==:cap
        return Boxx(picture,vcat(-w.signs,w.signs),zeros(Int,2n),1)
    elseif kind==:cup
        return Boxx(picture,zeros(Int,2n),vcat(w.signs,-w.signs),1)
    elseif kind==:line
        return Boxx(picture,w,w,1)
    end
end


@instance! CompactClosedCategory Wires Boxx begin
    dual(w::Wires)=Wires(-w.signs)
    ev(w::Wires)  = primitive(w,:cap)
    coev(w::Wires)= primitive(w,:cup)
#    transpose(f::Boxx)= lshiftupfortransp(f) ∘ transp(f) ∘ rshiftupfortransp(f)
    function sigma(w::Wires,v::Wires)
        n=length(w.signs)
        m=length(v.signs)
        primitive(w⊗v,:perm, vcat( (n+1):(n+m),1:n ))
    end
end


bi= quote
    import Blink; BlinkDisplay.init();media(Boxx,Media.Graphical);media(Compose.Context,Media.Graphical);
    f=mbox(2,2,"f")
    pin()
    f.'
end



end


# examples
# f=mbox(2,3)
# f.' ∘ id(Wires([0 0 0 -1 -1 -1 0 0 0])) ∘ (id(Wires([0 0 0])) ⊗ mbox(0,-3) ⊗id(Wires([0 0 0])))
# a=transp(mbox([1 0 1],[0 1 1]) ∘ mbox([1 0 1],[0 1 1]))
# a ∘ a
# mbox([1 -1],[1,-1]) ∘ mbox([1 0 0 0  1],[1 0 0 0 -1 0 0 ]) ∘ ket(2)

