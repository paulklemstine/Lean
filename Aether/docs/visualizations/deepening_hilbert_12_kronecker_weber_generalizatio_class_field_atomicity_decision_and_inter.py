from __future__ import annotations
from itertools import product
from typing import List, Tuple

Group = Tuple[int, ...]
Element = Tuple[int, ...]


def is_prime(n: int) -> bool:
    """Trial-division primality test."""
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def group_elements(factors: Group) -> List[Element]:
    """All elements of Z/f_0 x ... x Z/f_{k-1}."""
    return [tuple(e) for e in product(*[range(f) for f in factors])]


def add(a: Element, b: Element, factors: Group) -> Element:
    """Componentwise addition modulo the invariant factors."""
    return tuple((x + y) % f for x, y, f in zip(a, b, factors))


def subgroup_generated(gens: List[Element], factors: Group) -> frozenset:
    """Closure of a generating set under the group operation."""
    identity = tuple(0 for _ in factors)
    elems = {identity}
    frontier = [identity]
    while frontier:
        nxt = []
        for x in frontier:
            for g in gens:
                y = add(x, g, factors)
                if y not in elems:
                    elems.add(y)
                    nxt.append(y)
        frontier = nxt
    return frozenset(elems)


def all_subgroups(factors: Group) -> List[frozenset]:
    """Enumerate all subgroups of a small finite abelian group."""
    elems = group_elements(factors)
    subgroups = [subgroup_generated([], factors)]
    seen = set(subgroups)
    changed = True
    while changed:
        changed = False
        for H in list(subgroups):
            for g in elems:
                new = subgroup_generated(list(H) + [g], factors)
                if new not in seen:
                    seen.add(new)
                    subgroups.append(new)
                    changed = True
    return subgroups


def atomicity_and_lattice(factors: Group) -> Tuple[int, int, bool]:
    """
    Given the class group Cl(O_K) by invariant factors, return
      (class_number, number_of_intermediate_fields, is_atomic).
    The number of intermediate fields of H/K equals the number of subgroups of
    the class group; the extension is atomic iff the class number is prime.
    """
    h = 1
    for f in factors:
        h *= f
    n_intermediate = len(all_subgroups(factors))
    return h, n_intermediate, is_prime(h)
