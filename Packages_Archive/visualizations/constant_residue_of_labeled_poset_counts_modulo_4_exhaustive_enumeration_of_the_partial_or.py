from __future__ import annotations
from itertools import product
from typing import List, Tuple

Relation = Tuple[Tuple[bool, ...], ...]

def is_partial_order(rel: Relation, n: int) -> bool:
    """Test reflexivity, antisymmetry, transitivity in O(n^3)."""
    for a in range(n):
        if not rel[a][a]:
            return False
    for a in range(n):
        for b in range(n):
            if rel[a][b] and rel[b][a] and a != b:
                return False
            if rel[a][b]:
                for c in range(n):
                    if rel[b][c] and not rel[a][c]:
                        return False
    return True

def count_partial_orders(n: int) -> int:
    """Return P(n) by exhaustive search over 2^(n^2) relation matrices."""
    total = 0
    for bits in product((False, True), repeat=n * n):
        rel = tuple(tuple(bits[a * n + b] for b in range(n)) for a in range(n))
        if is_partial_order(rel, n):
            total += 1
    return total
