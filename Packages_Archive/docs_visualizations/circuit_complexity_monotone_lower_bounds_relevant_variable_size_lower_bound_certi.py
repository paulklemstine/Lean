from itertools import product
from typing import Callable, Dict, List

Assignment = Dict[int, bool]


def depends_on(f: Callable[[Assignment], bool], i: int, indices: List[int]) -> bool:
    """DependsOn(f, i): some background flip of coordinate i changes f's value."""
    others = [j for j in indices if j != i]
    for bits in product([False, True], repeat=len(others)):
        base = dict(zip(others, bits))
        xt = dict(base); xt[i] = True
        xf = dict(base); xf[i] = False
        if f(xt) != f(xf):
            return True
    return False


def certified_size_lower_bound(f: Callable[[Assignment], bool],
                               indices: List[int]) -> int:
    """Returns |R| = #relevant variables. By card_le_size_of_relevant this is a
    certified lower bound on the size of ANY monotone circuit computing f."""
    return sum(1 for i in indices if depends_on(f, i, indices))
