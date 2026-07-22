from __future__ import annotations
from math import comb
from typing import Dict

def threshold_report(n: int, m: int, c: int) -> Dict[str, float]:
    """Compare the naive C(n,2)/m threshold with the corrected (n-c)/m threshold."""
    naive = comb(n, 2) / m
    corrected = (n - c) / m
    return {"naive_C_n_2_over_m": naive,
            "corrected_n_minus_c_over_m": corrected,
            "gap": naive - corrected}

def k_block_pattern_norm(k: int, rho: float, p: float, n: int, m: int, c: int) -> float:
    """Closed form rho^m * k^{m - (n-c)/p} for the k-block kernel (Proposition 5.2)."""
    return rho ** m * k ** (m - (n - c) / p)
