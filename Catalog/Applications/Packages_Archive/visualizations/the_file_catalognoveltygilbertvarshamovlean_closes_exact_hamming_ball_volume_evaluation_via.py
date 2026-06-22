from math import comb
from typing import List

def sphere_count(n: int, q: int, k: int) -> int:
    """Number of words at Hamming distance EXACTLY k: C(n,k)*(q-1)^k."""
    if k < 0 or k > n:
        return 0
    return comb(n, k) * (q - 1) ** k

def ball_volume(n: int, q: int, t: int) -> int:
    """V(t) = sum_{i=0}^{t} C(n,i)*(q-1)^i  (incremental, O(t))."""
    t = min(t, n)
    total = 0
    term = 1  # C(n,0)*(q-1)^0
    for i in range(t + 1):
        total += term
        # term_{i+1} = term_i * (n-i)/(i+1) * (q-1)
        term = term * (n - i) // (i + 1) * (q - 1)
    return total
