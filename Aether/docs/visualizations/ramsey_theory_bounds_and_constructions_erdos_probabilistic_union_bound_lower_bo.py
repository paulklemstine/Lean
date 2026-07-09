from math import comb

def union_bound_lower(k: int) -> int:
    """Largest n with 2*C(n,k) < 2^C(k,2); certifies R(k,k) > n (Erdos 1947).
    O(n) per step using exact integer binomials."""
    threshold = 2 ** comb(k, 2)
    n, best = k, 0
    while 2 * comb(n, k) < threshold:
        best, n = n, n + 1
    return best

def certifies_lower(n: int, k: int) -> bool:
    """True iff the union bound certifies R(k,k) > n."""
    return k <= n and 2 * comb(n, k) < 2 ** comb(k, 2)
