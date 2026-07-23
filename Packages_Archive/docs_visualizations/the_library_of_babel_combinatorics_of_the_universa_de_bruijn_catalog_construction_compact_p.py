from itertools import product
from typing import List

def de_bruijn_sequence(b: int, k: int) -> List[int]:
    """Construct a cyclic de Bruijn sequence B(b,k): a length b**k string over
    {0,...,b-1} in which every length-k word appears exactly once as a cyclic
    window. Runs in O(b**k) time and space (linear in output)."""
    a: List[int] = [0] * (b * k)
    seq: List[int] = []

    def db(t: int, p: int) -> None:
        if t > k:
            if k % p == 0:
                seq.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, b):
                a[t] = j
                db(t + 1, t)

    db(1, 1)
    return seq

def is_perfect_catalog(seq: List[int], b: int, k: int) -> bool:
    """Verify the sequence is a perfect cyclic catalog of all length-k words."""
    n = len(seq)
    windows = {tuple(seq[(i + j) % n] for j in range(k)) for i in range(n)}
    return n == b ** k and windows == set(product(range(b), repeat=k))
