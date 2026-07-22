from math import comb


def tangent_k_coeff(n: int, k: int) -> int:
    """Alternating Euler-characteristic coefficient
        tau(n,k) = sum_{j=0}^{k} (-1)^j C(n+1,j) (k+1-j)^n.
    Equal to the Eulerian number <n,k> (the P^K = Hilb identity).
    Time O(k) big-integer operations (terms may be exponentially larger
    than the final value, then cancel)."""
    total = 0
    for j in range(k + 1):
        total += (-1) ** j * comb(n + 1, j) * (k + 1 - j) ** n
    return total
