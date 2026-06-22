from typing import Callable, Dict, Hashable, List, Sequence, TypeVar
A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)

def fibres(f: Callable[[A], B], domain: Sequence[A],
           codomain: Sequence[B]) -> Dict[B, List[A]]:
    """Compute the homotopy fibre f^{-1}(b) for every b in the codomain."""
    table: Dict[B, List[A]] = {b: [] for b in codomain}
    for a in domain:
        table[f(a)].append(a)
    return table

def is_equivalence(f: Callable[[A], B], domain: Sequence[A],
                   codomain: Sequence[B]) -> bool:
    """f is an equivalence iff every homotopy fibre is contractible
    (a singleton).  This is the executable form of the dictionary
    IsEquiv f  <=>  Function.Bijective f."""
    return all(len(fib) == 1 for fib in fibres(f, domain, codomain).values())
