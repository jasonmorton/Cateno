using MonoidalCategories, Typeclass
#import OneCobs automatic from below
import OneCobs.OneCob

typeallias PM Array{OneCobs.PortPair,1}

@instance MonoidalCategory PM OneCob begin
    dom(f::OneCob) = OneCob.innerports
    cod(f::OneCob) = OneCob.outerports
    id(A::PM)      = OneCob() #????
    compose(f::OneCob,g::OneCob) = gcompose(f,g)
    otimes(f::OneCob,g::OneCob) = gotimes(f,g)
    otimes(A::PM,B::PM)::PM #????
    munit(::PM)::PM #????
end

