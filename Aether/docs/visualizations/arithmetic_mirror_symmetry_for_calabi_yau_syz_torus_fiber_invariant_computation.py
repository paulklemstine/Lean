from math import comb
from typing import List

def betti_torus(n: int, k: int) -> int:
    """Betti number b_k(T^n) = C(n, k)."""
    return comb(n, k) if 0 <= k <= n else 0

def torus_invariants(n: int) -> dict:
    """Compute and verify the SYZ torus-fiber invariants for T^n."""
    betti: List[int] = [betti_torus(n, k) for k in range(n + 1)]
    even_sum = sum(b for k, b in enumerate(betti) if k % 2 == 0)
    odd_sum = sum(b for k, b in enumerate(betti) if k % 2 == 1)
    chi = sum((-1) ** k * b for k, b in enumerate(betti))
    return {
        "betti": betti,
        "palindromic_ok": betti == betti[::-1],          # bettiTorus_poincare
        "total": sum(betti),
        "total_is_2pow_ok": sum(betti) == 2 ** n,        # bettiTorus_total
        "euler": chi,
        "euler_zero_ok": (n < 1) or chi == 0,            # eulerTorus_eq_zero
        "even_eq_odd_ok": (n < 1) or even_sum == odd_sum # evenBetti_eq_oddBetti
    }
