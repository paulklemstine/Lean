from itertools import product
from typing import Dict, List, Optional, Sequence, Set, Tuple

Graph = Dict[int, Set[int]]
Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    return tuple(p[q[x]] for x in range(len(p)))

def is_fixed_point_free(p: Perm) -> bool:
    return all(p[x] != x for x in range(len(p)))

def closure(gens: Sequence[Perm], n: int, cap: int) -> Optional[Set[Perm]]:
    elems: Set[Perm] = {tuple(range(n))}
    elems.update(gens)
    frontier = list(gens)
    while frontier:
        a = frontier.pop()
        for b in list(elems):
            for c in (compose(a, b), compose(b, a)):
                if c not in elems:
                    if len(elems) >= cap:
                        return None
                    elems.add(c); frontier.append(c)
    return elems

def is_regular_subgroup(elems: Set[Perm], n: int) -> bool:
    if len(elems) != n:
        return False
    ident = tuple(range(n))
    if any(p != ident and not is_fixed_point_free(p) for p in elems):
        return False
    return {p[0] for p in elems} == set(range(n))

def has_regular_aut_subgroup(auts: List[Perm], n: int) -> Optional[Set[Perm]]:
    """Sabidussi test: is some subgroup of Aut(G) regular? (=> G is Cayley.)"""
    fpf = [p for p in auts if is_fixed_point_free(p)]
    for a in fpf:
        sub = closure([a], n, cap=n + 1)
        if sub is not None and is_regular_subgroup(sub, n):
            return sub
    for a, b in product(fpf, repeat=2):
        sub = closure([a, b], n, cap=n + 1)
        if sub is not None and is_regular_subgroup(sub, n):
            return sub
    return None
