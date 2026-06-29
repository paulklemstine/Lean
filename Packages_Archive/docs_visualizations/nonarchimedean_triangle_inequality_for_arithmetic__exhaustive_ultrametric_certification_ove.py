from itertools import product, combinations
from fractions import Fraction
from typing import List

def certify(p: int, S: List[Fraction]) -> bool:
    for x, y, z in product(S, repeat=3):
        assert hdist(p, x, z) <= max(hdist(p, x, y), hdist(p, y, z))
    ints = [int(x) for x in S if x.denominator == 1]
    for m, n in product(ints, repeat=2):
        assert val_int(p, m * n) == val_int(p, m) * val_int(p, n)
        assert val_int(p, m + n) <= max(val_int(p, m), val_int(p, n))
    for x, y, z in combinations(S, 3):
        s = sorted([hdist(p, x, y), hdist(p, y, z), hdist(p, x, z)])
        assert s[1] == s[2]
    return True
