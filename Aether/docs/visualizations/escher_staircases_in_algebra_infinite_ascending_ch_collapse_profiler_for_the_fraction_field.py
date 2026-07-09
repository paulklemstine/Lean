from __future__ import annotations
from typing import Set, Tuple

def rung_in_ring_is_proper(gens: Set[int]) -> bool:
    """In k[x_0,x_1,...], the ideal <x_i : i in gens> is proper (never contains 1)."""
    return True  # a variable ideal omits the constant 1 for any generator set

def rung_in_field_is_unit(gens: Set[int]) -> bool:
    """In the fraction field, a nonzero ideal is the whole field, so a nonempty rung = (1)."""
    return len(gens) > 0

def collapse_profile(depth: int) -> Tuple[bool, bool]:
    """Return (all rungs proper downstairs, all nonempty rungs = unit upstairs)."""
    downstairs = all(rung_in_ring_is_proper(set(range(n))) for n in range(1, depth))
    upstairs = all(rung_in_field_is_unit(set(range(n))) for n in range(1, depth))
    return downstairs, upstairs
