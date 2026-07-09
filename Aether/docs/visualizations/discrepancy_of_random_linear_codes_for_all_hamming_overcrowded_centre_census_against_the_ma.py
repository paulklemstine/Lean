from itertools import product
from typing import List, Tuple

def bad_centre_census(code: List[Tuple[int, ...]], q: int, n: int, r: int, t: int) -> Tuple[int, int]:
    """Return (number of centres with >= t codewords in B_r(z), Markov ceiling |C||B_r|)."""
    space = [tuple(v) for v in product(range(q), repeat=n)]
    cset = set(code)
    def count(z: Tuple[int, ...]) -> int:
        return sum(1 for c in cset if sum(a != b for a, b in zip(c, z)) <= r)
    bad = sum(1 for z in space if count(z) >= t)
    ball = sum(1 for x in space if sum(a != 0 for a in x) <= r)
    return bad, len(code) * ball
