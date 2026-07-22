from __future__ import annotations
from typing import List, Tuple

Relation = Tuple[Tuple[bool, ...], ...]

def dual(rel: Relation, n: int) -> Relation:
    """Order reversal: transpose the relation matrix."""
    return tuple(tuple(rel[b][a] for b in range(n)) for a in range(n))

def discrete_order(n: int) -> Relation:
    """The equality order a <= b iff a == b (the identity matrix)."""
    return tuple(tuple(a == b for b in range(n)) for a in range(n))

def self_dual_count(orders: List[Relation], n: int) -> int:
    """Count fixed points of duality. By the uniqueness theorem this is 1."""
    return sum(1 for r in orders if dual(r, n) == r)

def parity_from_involution(orders: List[Relation], n: int) -> int:
    """Return P(n) mod 2 via the fixed-point parity principle.

    P(n) = (#fixed points) + 2*(#pairs), so P(n) mod 2 = (#fixed) mod 2.
    """
    fixed = self_dual_count(orders, n)
    return fixed % 2
