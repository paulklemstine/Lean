from __future__ import annotations
import cmath, math
from itertools import product
from typing import Dict, List, Tuple


def euler_totient(n: int) -> int:
    """Euler's totient phi(n)."""
    return sum(1 for a in range(1, n + 1) if math.gcd(a, n) == 1)


def _element_order(a: int, n: int) -> int:
    order, cur = 1, a % n
    while cur != 1:
        cur = (cur * a) % n
        order += 1
    return order


def cyclic_decomposition(n: int) -> Tuple[List[int], List[int]]:
    """(Z/nZ)^x as an internal direct product <g_1> x ... x <g_r>."""
    units = [a for a in range(1, n) if math.gcd(a, n) == 1]
    target = euler_totient(n)
    if target == 1:
        return [], []
    gens: List[int] = []
    ords: List[int] = []
    subgroup = {1}

    def span(gs: List[int], os: List[int]) -> set:
        elems = {1}
        for exps in product(*[range(o) for o in os]):
            val = 1
            for g, e in zip(gs, exps):
                val = (val * pow(g, e, n)) % n
            elems.add(val)
        return elems

    while len(subgroup) < target:
        best_g, best_o = None, 0
        for g in units:
            o = _element_order(g, n)
            val, indep = 1, True
            for _ in range(1, o):
                val = (val * g) % n
                if val in subgroup:
                    indep = False
                    break
            if indep and o > best_o:
                best_o, best_g = o, g
        assert best_g is not None
        gens.append(best_g)
        ords.append(best_o)
        subgroup = span(gens, ords)
    return gens, ords


def enumerate_characters(n: int) -> List[Tuple[int, ...]]:
    """All phi(n) Dirichlet characters mod n as exponent vectors in the basis."""
    _, ords = cyclic_decomposition(n)
    if not ords:
        return [()]
    return [tuple(e) for e in product(*[range(o) for o in ords])]


def langlands_correspondence(n: int) -> Dict[Tuple[int, ...], Dict[int, complex]]:
    """
    Realize langlandsGL1: each Dirichlet character (exponent vector) is mapped to
    the Galois representation k |-> chi(k), tabulated on the units k of (Z/nZ)^x.
    Returns {exponent_vector: {k: value}}.
    """
    gens, ords = cyclic_decomposition(n)
    units = [a for a in range(1, n) if math.gcd(a, n) == 1]
    # discrete logs: coordinates of each unit in the basis
    dlog: Dict[int, Tuple[int, ...]] = {}
    if gens:
        for exps in product(*[range(o) for o in ords]):
            val = 1
            for g, e in zip(gens, exps):
                val = (val * pow(g, e, n)) % n
            dlog[val] = exps
    else:
        dlog[1] = ()

    def evaluate(char: Tuple[int, ...], k: int) -> complex:
        phase = sum(a * c / d for a, c, d in zip(char, dlog[k % n], ords))
        return cmath.exp(2j * math.pi * phase)

    table: Dict[Tuple[int, ...], Dict[int, complex]] = {}
    for char in enumerate_characters(n):
        table[char] = {k: evaluate(char, k) for k in units}
    return table
