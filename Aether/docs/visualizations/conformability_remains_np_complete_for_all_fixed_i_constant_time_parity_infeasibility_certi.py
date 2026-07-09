from typing import Tuple

def odd_cap(a: int) -> int:
    """Largest odd integer <= a, with odd_cap(0) = 0."""
    if a <= 0:
        return 0
    return a if a % 2 == 1 else a - 1

def parity_feasibility_certificate(n: int, d: int, alpha: int) -> str:
    """Constant-time necessary-condition test for conformability of an odd-order
    d-regular graph with independence number bounded by alpha."""
    if n % 2 == 0:
        return "N/A (odd order required)"
    if d % 2 == 1:                       # degree-parity obstruction
        return "INFEASIBLE (odd degree)"
    if (d + 1) * odd_cap(alpha) < n:     # counting obstruction (contrapositive)
        return "INFEASIBLE (size exceeds bound)"
    return "PARITY-FEASIBLE"
