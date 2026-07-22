from itertools import product
from typing import Callable, Dict, List

Func = Dict[object, object]

def all_functions(domain: List[object], codomain: List[object]) -> List[Func]:
    """Enumerate every total function domain -> codomain as a dict."""
    return [{d: v for d, v in zip(domain, vals)}
            for vals in product(codomain, repeat=len(domain))]

def lawvere_fixed_point(e: Dict[object, Func], domain: List[object],
                        f: Callable[[object], object]) -> object:
    """
    Given a surjective evaluation map e : A -> (A -> B) and an endomap f,
    return the Lawvere fixed point y = e[a][a] with f(y) = y, where a is the
    name of the diagonal function d(x) = f(e[x][x]).
    """
    diagonal: Func = {x: f(e[x][x]) for x in domain}
    for a in domain:
        if e[a] == diagonal:
            return e[a][a]
    raise ValueError("evaluation map is not surjective")
