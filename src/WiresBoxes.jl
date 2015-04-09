module WiresBoxes
using Typeclass,MonoidalCategories
import MonoidalCategories:MonoidalCategory,dom,cod,id,munit,⊗,∘ #this unifies id etc
import Compose
using Compose:Context,context,rectangle,circle,fill #doesn't put in scope
export dom,cod,id,munit,⊗,∘
import MonoidalCategories:ClosedCompactCategory,dual,transp,ev,coev,tr,Hom,sigma
export dual,transp,ev,coev,tr,Hom,sigma
export tdraw,draw,bra,ket,mbox,swap,cup,cap,lines,Boxx,Wires

import Base.writemime

#Wires is a container simply so that MonoidalCategory functions like id
#can be dispatched properly and different categories with Integer objects can be
#distinguished. another approach would be to make this a parametric type like
#MyInteger{MorphismType} or MyInteger{CategoryType}
#typealias Wires Int# wouldn't work because id would overwrite other Int defs
#from other categories.

############# Basic defintions and instance declaration ################
type Wires  #An object is a collection of n wires
    n::Integer
end
==(w::Wires,z::Wires)=w.n==z.n

type Boxx    #A morphism is a box with input and output wires (with subboxes)
    con::Context   #The Compose.jl Context that holds the drawing
    inwires::Wires
    outwires::Wires
    length::Int    #number of primitive horizontal boxes in the Boxx
end
Boxx(c,n::Int,m::Int,ell)=Boxx(c,Wires(n),Wires(m),ell) 
writemime(io::IO, m::MIME"image/svg+xml", b::Boxx)=writemime(io::IO, m, b.con)

@instance MonoidalCategory Wires Boxx begin
    dom(c::Boxx)=c.inwires
    cod(c::Boxx)=c.outwires
    id(n::Wires)=Boxx(lines(n.n),n,n,1)
    compose(f::Boxx,g::Boxx)=hstackCons(f,g)
    otimes(f::Boxx,g::Boxx)=vstackCons(f,g)
    otimes(n::Wires,m::Wires)=Wires(n.n+m.n)
    munit(::Wires)=Wires(0)  #this should be an object! if used Boxx, why is Typeclass not throwing an error?
end

##### Associative vertical and horizontal stacking #########
#the strategy to get associative ⊗ vertically is to track the total, maximum number of wires.  In the final image, each wire gets the same amount of space above and below.  For horizontal ∘, we use length.  We may also need virtual wires or spacer wires to pad any vertical slices that fall short.

function vstackCons(top,bot)
    topmax=max(dom(top).n,cod(top).n) #
    botmax=max(dom(bot).n,cod(bot).n) #
    inwires=dom(top)⊗dom(bot) #adds them
    outwires=cod(top)⊗cod(bot) #adds them
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
lines(n)=Compose.compose(Compose.context(),Compose.stroke(Compose.color("black")),Compose.linewidth(1),[Compose.line([(0,(i-(1/2))/(n)),(1,(i-(1/2))/(n))]) for i=1:n]...)

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
               n,0,1)
ket(n,txt)=Boxx(hstackcontexts(lines(n),threeptpoly((1,.5),(0,.95),(0,.05),txt)),
               0,n,1)
ket(n)=ket(n,"")
bra(n)=bra(n,"")

boxwithtext(txt)=Compose.compose(Compose.context(),Compose.rectangle(0,.05,1,.9),Compose.fill(Compose.RGBA{Float64}(0,0,0,0)),Compose.stroke(Compose.color("black")),Compose.text(.5,.55,txt)) #.5 -1textwidth, .5+1textheight is what we want
mbox(n,m,txt) = Boxx(hstackcontexts(lines(m),boxwithtext(txt),lines(n)),n,m,1)
Boxx(n,m,txt)=mbox(n,m,txt)
mbox(n,m)=mbox(n,m,"")
Boxx(n,m)=mbox(n,m)

#todo: make an arbitrary permutation picture and local perm picture
swap_underline=Compose.compose(Compose.context(),Compose.curve((0,.75),(.7,.75),(.3,.25),(1,.25)),Compose.stroke(Compose.color("black")),Compose.linewidth(1))
swap_overline(col,wid)=Compose.compose(Compose.context(),Compose.curve((0,.25),(.7,.25),(.3,.75),(1,.75)),Compose.stroke(Compose.color(col)),Compose.linewidth(wid))
swapcon=Compose.compose(swap_underline,Compose.compose(swap_overline("white",2),swap_overline("black",1)))

swap=Boxx(swapcon,2,2,1)

_cup=Compose.compose(Compose.context(),Compose.curve((0,.75),(.75,.75),(.75,.25),(0,.25)),Compose.stroke(Compose.color("black")),Compose.linewidth(1))
_cap=Compose.compose(Compose.context(),Compose.curve((1,.75),(.25,.75),(.25,.25),(1,.25)),Compose.stroke(Compose.color("black")),Compose.linewidth(1))
cup=Boxx(_cup,0,2,1)
cap=Boxx(_cap,2,0,1)


draw(f::Boxx,filename)=tdraw(f.con,filename)
draw(f::Boxx)=draw(f,"test.svg")
function tdraw(cont,filename)
    img = Compose.SVG(filename, 4Compose.inch, 4(sqrt(3)/2)Compose.inch)
    Compose.draw(img,cont)
end

#without arrows first
@instance! ClosedCompactCategory Wires Boxx begin
    dual(n::Wires)=n
    # ev for Wires(2) is cap ⊗ cap ∘ (id(Wires(1)) ⊗ swap ⊗id(Wires(1)))
    # etc, to fix, use nested
    #the below only work for Wires(1) now
    ev(n::Wires)=cap 
    coev(n::Wires)=cup
    sigma(n::Wires,m::Wires)=swap
end
#now f.' just works, draws the swirl

#must be run from toplevel
# import Blink
# BlinkDisplay.init()
# media(Boxx,Media.Graphical)
# mbox(1,1,"f")
# pin()




end




##then drawings appear and it is beautiful.
