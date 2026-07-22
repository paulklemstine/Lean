from collections import Counter
from typing import Callable, Hashable, Iterable, TypeVar
G=TypeVar("G",bound=Hashable); H=TypeVar("H",bound=Hashable)
def same_view(group: Iterable[G],w1:G,w2:G,c:int,hom:Callable[[G],H],add:Callable[[G,G],G],zero:G) -> bool:
    term1=zero if c==0 else w1; term2=zero if c==0 else w2
    return Counter((hom(r),c,add(r,term1)) for r in group)==Counter((hom(r),c,add(r,term2)) for r in group)
