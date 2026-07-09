from fractions import Fraction
from math import comb
from typing import Dict, Tuple

def sprugnoli_array(N: int) -> Dict[Tuple[int, int], int]:
    """T[n,k] = C(n+k, 2k) for 0 <= k <= n < N."""
    return {(n, k): comb(n + k, 2 * k) for n in range(N) for k in range(n + 1)}

def inverse_sprugnoli_array(N: int) -> Dict[Tuple[int, int], Fraction]:
    """Closed-form inverse S[n,k] = (-1)^(n+k) (2k+1)/(2n+1) C(2n+1, n-k)."""
    S: Dict[Tuple[int, int], Fraction] = {}
    for n in range(N):
        for k in range(n + 1):
            sign = -1 if (n + k) % 2 else 1
            S[(n, k)] = sign * Fraction((2 * k + 1) * comb(2 * n + 1, n - k), 2 * n + 1)
    return S

def verify_orthogonal(N: int) -> bool:
    """Check T*S = S*T = identity over the first N indices."""
    T = sprugnoli_array(N)
    S = inverse_sprugnoli_array(N)
    g = lambda A, a, b: A.get((a, b), 0)
    for n in range(N):
        for m in range(N):
            ts = sum(g(T, n, j) * g(S, j, m) for j in range(N))
            st = sum(g(S, n, j) * g(T, j, m) for j in range(N))
            if ts != (n == m) or st != (n == m):
                return False
    return True
