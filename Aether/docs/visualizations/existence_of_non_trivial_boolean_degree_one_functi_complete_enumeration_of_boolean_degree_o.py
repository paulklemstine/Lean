from itertools import product
from typing import Callable, Dict, FrozenSet, List, Tuple


def enumerate_boolean_deg_one(
    points: List[int],
    lines: List[FrozenSet[int]],
    weight_grid: Tuple[float, ...] = (-1.0, 0.0, 1.0),
    const_grid: Tuple[float, ...] = (0.0, 1.0),
) -> List[Tuple[float, Dict[int, float]]]:
    """Enumerate all (c, w) over a finite grid whose induced f(l)=c+sum_{p in l} w(p)
    is Boolean (values in {0,1}) on every line.  Returns the list of witnesses.

    By the integral reduction conjecture, weight_grid={-1,0,1} and const_grid={0,1}
    capture every Boolean degree one function, so this enumeration is complete.
    """
    results: List[Tuple[float, Dict[int, float]]] = []
    n = len(points)
    for c in const_grid:
        for combo in product(weight_grid, repeat=n):
            w = {p: combo[i] for i, p in enumerate(points)}
            ok = True
            for line in lines:
                val = c + sum(w[p] for p in line)
                if abs(val) > 1e-9 and abs(val - 1.0) > 1e-9:
                    ok = False
                    break
            if ok:
                results.append((c, w))
    return results
