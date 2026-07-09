from typing import Sequence

def lift_finite_tuple(f: Sequence[int]) -> int:
    """Stage index M with every coordinate of finite tuple f in S_M={0..M}."""
    return max(f) if len(f) else 0
