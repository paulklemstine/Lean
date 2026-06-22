from typing import Callable, List, TypeVar
T = TypeVar("T")

def closure_operator(act: Callable[[T], T], res: Callable[[T], T]) -> Callable[[T], T]:
    """Build the closure operator cl = res o act from a Galois connection act -| res."""
    def cl(x: T) -> T:
        return res(act(x))
    return cl

def closed_elements(carrier: List[T], cl: Callable[[T], T]) -> List[T]:
    """Fixed points of the closure operator = the spectrum."""
    return [x for x in carrier if cl(x) == x]

def spectral_size(carrier: List[T], cl: Callable[[T], T]) -> int:
    """Cardinality of the spectrum (number of closed elements)."""
    return len(closed_elements(carrier, cl))

def tropical_character(top: T, cl: Callable[[T], T]) -> T:
    """chi = cl(top): the largest closed element."""
    return cl(top)
