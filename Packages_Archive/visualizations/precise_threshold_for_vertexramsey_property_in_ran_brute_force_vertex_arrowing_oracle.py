from __future__ import annotations
from itertools import product


def has_monochromatic_clique(coloring: tuple[int, ...], targets: list[int]) -> bool:
    n = len(coloring)
    return any(sum(1 for v in range(n) if coloring[v] == c) >= s
               for c, s in enumerate(targets))


def arrows_bruteforce(n: int, targets: list[int]) -> bool:
    """Exhaustive reference decision for K_n arrowing (K_{s_i})."""
    r = len(targets)
    for coloring in product(range(r), repeat=n):
        if not has_monochromatic_clique(coloring, targets):
            return False
    return True
