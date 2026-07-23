from typing import List, Tuple

def dyadic_crossing_witnesses(k: int) -> List[Tuple[float, float, int, int]]:
    """
    Produce the 2^k forced-crossing witnesses for the level 1/2.

    For each i in 0..2^k-1 return the dyadic subinterval [i/2^k, (i+1)/2^k]
    together with the certified true tent values (i mod 2, (i+1) mod 2) at its
    endpoints.  Any continuous eps-approximant with eps < 1/2 must hit 1/2 in
    every such interval, certifying width >= 2^k.
    """
    n = 2 ** k
    out: List[Tuple[float, float, int, int]] = []
    for i in range(n):
        left = i / n
        right = (i + 1) / n
        out.append((left, right, i % 2, (i + 1) % 2))
    return out
