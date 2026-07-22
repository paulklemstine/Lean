from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, Iterator, List

Statement = FrozenSet[int]

def nat_box(s: Statement, n: int) -> Statement:
    return frozenset(m for m in range(n) if all(j in s for j in range(m)))

def implies(a: Statement, b: Statement, n: int) -> Statement:
    return frozenset(m for m in range(n) if m not in a or m in b)

def all_subsets(n: int) -> Iterator[Statement]:
    base = list(range(n))
    for k in range(n + 1):
        for combo in combinations(base, k):
            yield frozenset(combo)

def glfix(c: Statement, n: int) -> Statement:
    """Canonical solution of p = □p ⇨ c (Theorem 3.10)."""
    return implies(nat_box(c, n), c, n)

def solve_and_certify(c: Statement, n: int) -> Statement:
    p = glfix(c, n)
    assert p == implies(nat_box(p, n), c, n)        # fixed point
    assert nat_box(p, n) == nat_box(c, n)           # □(glFix c) = □c
    sols = [q for q in all_subsets(n)
            if q == implies(nat_box(q, n), c, n)]
    assert sols == [p]                              # uniqueness
    return p

def two_param_unique(c: Statement, d: Statement, n: int) -> bool:
    sols = [q for q in all_subsets(n)
            if q == (d & implies(nat_box(q, n), c, n))]
    return len(sols) <= 1
