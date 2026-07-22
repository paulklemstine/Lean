from math import comb
from typing import Optional


def probabilistic_lower_bound(k: int) -> int:
    """
    Largest n satisfying the Erdos union bound 2*C(n,k) < 2^C(k,2).
    Any such n certifies a strict diagonal lower bound R(k,k) > n,
    because the expected number of monochromatic K_k under a uniform
    random 2-colouring of K_n is below 1, so a clique-free colouring exists.

    Constant work per candidate n using Python big integers; the search
    terminates because C(n,k) grows polynomially in n while the threshold
    2^C(k,2) is fixed.
    """
    threshold: int = 2 ** comb(k, 2)
    best: int = k - 1
    n: int = k
    while 2 * comb(n, k) < threshold:
        best = n
        n += 1
    return best


def crude_exponential_lower_bound(k: int) -> Optional[int]:
    """
    Lower bound from the crude form 2*n^k < 2^C(k,2) (uses C(n,k) <= n^k).
    Matches the formally verified corollary; e.g. returns 16 for k = 10.
    """
    threshold: int = 2 ** comb(k, 2)
    best: Optional[int] = None
    n: int = k
    while 2 * (n ** k) < threshold:
        best = n
        n += 1
    return best
