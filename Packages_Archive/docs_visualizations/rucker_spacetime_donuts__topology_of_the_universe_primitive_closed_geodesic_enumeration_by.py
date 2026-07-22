from __future__ import annotations
from math import gcd, isqrt
from typing import List, Tuple

Vec3 = Tuple[int, int, int]


def primitive_geodesics(k: int) -> List[Vec3]:
    """Enumerate all primitive closed geodesics of squared length exactly k.

    A direction n=(a,b,c) is primitive iff gcd(a,b,c)=1; primitive geodesics are
    traversed once and biject with primitive lattice vectors of the given norm.
    Complexity: O(k) via the shell a^2+b^2 <= k with c solved exactly.
    """
    out: List[Vec3] = []
    r = isqrt(k)
    for a in range(-r, r + 1):
        for b in range(-r, r + 1):
            c2 = k - a * a - b * b
            if c2 < 0:
                continue
            c = isqrt(c2)
            if c * c != c2:
                continue
            for cc in ({c, -c} if c else {0}):
                v = (a, b, cc)
                if v != (0, 0, 0) and gcd(gcd(abs(a), abs(b)), abs(cc)) == 1:
                    out.append(v)
    return out
