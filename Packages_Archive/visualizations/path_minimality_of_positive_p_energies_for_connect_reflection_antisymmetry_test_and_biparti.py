from __future__ import annotations
from typing import List

def is_reflection_antisymmetric(spectrum: List[float], tol: float = 1e-9) -> bool:
    """Check f(n-1-k) = -f(k) on the decreasing-sorted spectrum."""
    s = sorted(spectrum, reverse=True)
    n = len(s)
    return all(abs(s[n - 1 - k] + s[k]) < tol for k in range(n))

def balance_gap(spectrum: List[float], p: float) -> float:
    """|E_p^+ - E_p^-|: zero exactly when the spectrum is reflection-antisymmetric."""
    pos = sum(x ** p for x in spectrum if x > 0.0)
    neg = sum((-x) ** p for x in spectrum if x < 0.0)
    return abs(pos - neg)
