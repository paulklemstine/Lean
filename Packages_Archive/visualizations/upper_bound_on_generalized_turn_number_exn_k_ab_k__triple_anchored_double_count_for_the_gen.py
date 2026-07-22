from math import comb
from typing import Tuple

def turan_upper_bound(a: int, b: int, n: int) -> Tuple[int, int]:
    """Return (tight, loose) upper bounds on the number of labelled copies of
    K_{a,b} in an n-vertex K_{3,b+1}-free graph.

    tight = C(n,3) * C(b, a-3),   loose = C(b, a-3) * n^3.
    Requires 3 <= a <= b.
    """
    if not (3 <= a <= b):
        raise ValueError("need 3 <= a <= b")
    cap = b  # (b+1) - 1: max common neighbors of any triple
    per_triple = comb(cap, b) * comb(cap, a - 3)  # C(b,b)=1
    tight = comb(n, 3) * per_triple
    loose = comb(b, a - 3) * n ** 3
    return tight, loose

if __name__ == "__main__":
    print(turan_upper_bound(3, 3, 10))   # (120, 1000)
    print(turan_upper_bound(4, 4, 12))   # (880, 6912)
