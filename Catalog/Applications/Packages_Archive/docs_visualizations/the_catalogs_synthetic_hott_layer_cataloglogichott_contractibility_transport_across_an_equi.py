from dataclasses import dataclass
from typing import Callable, Generic, TypeVar, Hashable
T = TypeVar('T', bound=Hashable); S = TypeVar('S', bound=Hashable)

@dataclass
class Contractible(Generic[T]):
    elements: list; center: T
    def is_valid(self) -> bool:
        return all(y == self.center for y in self.elements)

@dataclass
class Equiv(Generic[T, S]):
    to_fun: Callable[[T], S]; inv_fun: Callable[[S], T]

def equiv_contractible(e: 'Equiv[T,S]', h: 'Contractible[T]') -> 'Contractible[S]':
    return Contractible([e.to_fun(x) for x in h.elements], e.to_fun(h.center))
