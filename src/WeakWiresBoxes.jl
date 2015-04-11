module WeakWiresBoxes
using Typeclass,MonoidalCategories
import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘ 
import Compose
using Compose:Context,context,rectangle,circle,fill #doesn't put in scope
export dom,cod,id,munit,⊗,∘
import MonoidalCategories:ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma
export dual,transp,ev,coev,tr,Hom,sigma
export bra,ket,mbox,swap,cup,cap,lines,Boxx,Wires,perm,lshiftupfortransp,rshiftupfortransp

import MonoidalCategories:associator,associatorinv,leftunitor,rightunitor,leftunitorinv,rightunitorinv
#import MonoidalCategories:lrweaktranspose

import Base:writemime,length

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


@instance MonoidalCategory Wires Boxx begin #UnitorWeakMC
    dom(c::Boxx)=c.inwires
    cod(c::Boxx)=c.outwires
    id(w::Wires)=Boxx(lines(w.signs),w,w,1) #lines skips Is in array
    compose(f::Boxx,g::Boxx)=hstackCons(f,g)
    otimes(f::Boxx,g::Boxx)=vstackCons(f,g)
    otimes(w::Wires,u::Wires)=Wires(vcat(w.signs,u.signs))
    munit(::Wires)=Wires([0])  
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
        if signs[i]==-1
            thisline=[Compose.line([(0,y),(1,y)]),
                      Compose.line([(.5,y),(.45,y-.05)]),
                      Compose.line([(.5,y),(.45,y+.05)])]
        elseif signs[i]==1
            thisline=[Compose.line([(0,y),(1,y)]),
                      Compose.line([(.5,y),(.55,y-.05)]),
                      Compose.line([(.5,y),(.55,y+.05)])]
        elseif signs[i]==0
            thisline=[Compose.line([(.45,y),(.55,y)])]
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
    Boxx(hstackcontexts(lines(new_v),boxwithtext(txt),lines(new_w)),w,v,1)
end
mbox(w::Wires,v::Wires)=mbox(w,v,"")
mbox(n::Int,m::Int,txt)=mbox(Wires(n),Wires(m),txt)
mbox(n::Int,m::Int)=mbox(n,m,"")
Boxx(n::Int,m::Int,txt)=mbox(n,m,txt)
Boxx(n::Int,m::Int)=mbox(n,m)


swap_underline=Compose.compose(Compose.context(),Compose.curve((0,.75),(.7,.75),(.3,.25),(1,.25)),Compose.stroke(Compose.color("black")),Compose.linewidth(1))
swap_overline(col,wid)=Compose.compose(Compose.context(),Compose.curve((0,.25),(.7,.25),(.3,.75),(1,.75)),Compose.stroke(Compose.color(col)),Compose.linewidth(wid))
swapcon=Compose.compose(swap_underline,Compose.compose(swap_overline("white",2),swap_overline("black",1)))

swap=Boxx(swapcon,[1 1],[1 1],1)


#swaps, unitors, lines, etc all special cases of
function perm(w::Wires,π::Array)
    N=length(w.signs)
    linelocation=[(i-(1/2))/N for i=1:N] 
    lineContexts=Any[]
    for i=1:N
        y=(i-.5)/N
        y1=linelocation[π[i]]
        if w.signs[i]==-1
            thisline=[Compose.curve((0,y1),(.7,y1),(.3,y),(1,y)),
                      Compose.line([(.1,y1),(.05,y1-.05)]),
                      Compose.line([(.1,y1),(.05,y1+.05)])]
        elseif w.signs[i]==1
            thisline=[Compose.curve((0,y1),(.7,y1),(.3,y),(1,y)),
                      Compose.line([(.1,y1),(.15,y1-.05)]),
                      Compose.line([(.1,y1),(.15,y1+.05)])]
        elseif w.signs[i]==0
            thisline=[]
#            thisline=[Compose.line([(.45,y1),(.55,y)])]
        else
            error("invalid line")
        end
        append!(lineContexts,thisline)
    end
    piwsigns=zeros(Int,N)
    for i in 1:N
        piwsigns[π[i]]=w.signs[i]
    end
    piw=Wires(piwsigns)
    Boxx(Compose.compose(Compose.context(),Compose.stroke(Compose.color("black")),Compose.linewidth(1),lineContexts...),w,piw,1)
end


function cup(w::Wires) #coev
    n=length(w.signs)
    linelocation=[(i-(1/2))/(2n) for i=1:2n] 
    pic=Compose.compose(Compose.context(),
                    [Compose.curve((0,linelocation[i]),(.75,linelocation[i]),(.75,linelocation[i+n]),(0,linelocation[i+n])) for i=1:n]...,
                    Compose.stroke(Compose.color("black")),Compose.linewidth(1))
    Boxx(pic,zeros(Int,2n),vcat(w.signs,-w.signs),1)
end
function cap(w::Wires) #ev
    n=length(w.signs)
    linelocation=[(i-(1/2))/(2n) for i=1:2n] 
    pic=Compose.compose(Compose.context(),
                    [Compose.curve((1,linelocation[i]),(.25,linelocation[i]),(.25,linelocation[i+n]),(1,linelocation[i+n])) for i=1:n]...,
                    Compose.stroke(Compose.color("black")),Compose.linewidth(1))
    Boxx(pic,vcat(-w.signs,w.signs),zeros(Int,2n),1)
end
cap(n::Int)=cap(Wires(n))
cup(n::Int)=cup(Wires(n))

#left and right unitors
#f.' ∘(Boxx(WiresBoxes.swap_overline("black",1),1,1,1)⊗id(munit(Wires(1))))
#actually in weak cat, dom and cod of a Boxx should always have same number of wires.
function rshiftupfortransp(f::Boxx)
    nfdom=length(dom(f).signs)
    nfcod=length(cod(f).signs)
    π=vcat( (nfcod+1):(nfcod+nfcod), 1:nfcod, (nfdom+nfcod+1):(nfdom+nfcod+nfdom) ) #middle,beginning,ending
    perm(Wires(vcat(zeros(Int,nfcod),dual(cod(f)).signs,zeros(Int,nfdom)) )  ,π)
end
function lshiftupfortransp(f::Boxx)
    nfdom=length(dom(f).signs)
    nfcod=length(cod(f).signs)
    π=vcat( 1:nfcod, (nfdom+nfcod+1):(nfdom+nfcod+nfdom),(nfcod+1):(nfcod+nfcod) ) #beginning, ending, middle
    perm(Wires(vcat(zeros(Int,nfcod),zeros(Int,nfdom),dual(cod(f)).signs) )  ,π)
end

@instance! ClosedCompactCategory Wires Boxx begin
    dual(w::Wires)=Wires(-w.signs)
    ev(w::Wires)  =cap(w) 
    coev(w::Wires)=cup(w)
    transpose(f::Boxx)= lshiftupfortransp(f) ∘ transp(f) ∘ rshiftupfortransp(f)
    function sigma(w::Wires,v::Wires)
        n=length(w.signs)
        m=length(v.signs)
        perm(w⊗v,vcat( (n+1):(n+m),1:n ))
    end
end


bi= quote
    import Blink; BlinkDisplay.init();media(Boxx,Media.Graphical);media(Compose.Context,Media.Graphical);
    f=mbox(2,2,"f")
    pin()
    f.'
end


end


