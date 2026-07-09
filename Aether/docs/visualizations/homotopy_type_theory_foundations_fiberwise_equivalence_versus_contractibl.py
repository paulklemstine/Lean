from itertools import product
from typing import Dict, Hashable, List, Set, Tuple

Point = Hashable
Family = Dict[Point, Set[int]]


def total_space(B: Family) -> List[Tuple[Point, int]]:
    """Enumerate the dependent total space Sum_x B(x)."""
    return [(x, u) for x, fiber in B.items() for u in sorted(fiber)]


def is_contractible(elements: List[Hashable]) -> bool:
    """A finite type is contractible iff it has exactly one element."""
    return len(set(elements)) == 1


def encode_is_fiberwise_equiv(a: Point, B: Family, b: int) -> bool:
    """encode_x an equivalence for all x iff every fiber is a singleton."""
    for x, fiber in B.items():
        for u in sorted(fiber):
            # in the proof-irrelevant model the fiber over u is inhabited
            # iff a == x and u == b, with a unique (reflexivity) witness
            witnesses = 1 if (a == x and u == b) else 0
            if witnesses != 1:
                return False
    return True


def fundamental_theorem_check(a: Point, B: Family, b: int) -> Tuple[bool, bool, bool]:
    """Return (lhs, rhs, lhs == rhs) verifying the fundamental theorem."""
    lhs = encode_is_fiberwise_equiv(a, B, b)
    rhs = is_contractible(total_space(B))
    return lhs, rhs, lhs == rhs
