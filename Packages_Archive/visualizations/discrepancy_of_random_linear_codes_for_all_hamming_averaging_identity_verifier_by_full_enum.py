from itertools import product
from typing import List, Tuple

def hamming(x: Tuple[int, ...], y: Tuple[int, ...]) -> int:
    return sum(1 for a, b in zip(x, y) if a != b)

def verify_averaging_identity(code: List[Tuple[int, ...]], q: int, n: int, r: int) -> bool:
    """Confirm sum_z |C cap B_r(z)| == |C| * |B_r| exactly by enumeration."""
    space = [tuple(v) for v in product(range(q), repeat=n)]
    cset = set(code)
    total = sum(sum(1 for c in cset if hamming(c, z) <= r) for z in space)
    ball = sum(1 for x in space if hamming(x, tuple([0]*n)) <= r)
    return total == len(code) * ball
