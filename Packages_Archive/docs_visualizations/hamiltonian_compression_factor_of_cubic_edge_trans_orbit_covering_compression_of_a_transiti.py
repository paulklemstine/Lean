from __future__ import annotations
from itertools import permutations
from typing import Callable, List, Set, Tuple

Perm = Tuple[int, ...]


def orbit_cover(
    n: int,
    is_sym: Callable[[Perm], bool],
    base,
    act,
    targets: Set,
) -> List[Perm]:
    """
    Construct a *minimal-style* symmetry certificate by greedily collecting
    automorphisms whose action on `base` reaches new targets, until the orbit
    of `base` equals `targets`. This is the orbit-covering compression that turns
    a quadratic 'for all pairs find a symmetry' search into a linear cover.

    Complexity: enumerates Sym(n) once (n! permutations); each kept generator
    contributes one new target, so the certificate has at most |targets| entries.
    """
    reached = {}
    for p in permutations(range(n)):
        if not is_sym(p):
            continue
        img = act(p, base)
        if img in targets and img not in reached:
            reached[img] = p
            if set(reached) == targets:
                break
    if set(reached) != targets:
        raise ValueError("action is not transitive on targets")
    return list(reached.values())
