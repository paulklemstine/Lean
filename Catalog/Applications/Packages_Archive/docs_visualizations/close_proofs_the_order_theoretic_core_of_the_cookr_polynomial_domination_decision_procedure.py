from __future__ import annotations
from typing import Callable, Optional, Tuple


def is_poly_mono(f: Callable[[int], int], k: int, n_max: int) -> bool:
    """Verify (up to n_max) that f is a monotone polynomial blow-up with
    witnessing exponent k: f monotone and f(n) + 1 <= (n + 2) ** k."""
    prev = f(0)
    for n in range(n_max + 1):
        cur = f(n)
        if cur < prev or cur + 1 > (n + 2) ** k:
            return False
        prev = cur
    return True


def decide_simulation(
    a: Callable[[int], int],
    b: Callable[[int], int],
    max_exp: int = 8,
    n_max: int = 200,
) -> Optional[Tuple[int, str]]:
    """Decide (semi-numerically) whether sysOfSize(a) p-simulates sysOfSize(b)
    by the Domination Characterization: search the canonical blow-up family
    f_c(m) = (m + 2) ** c - 1 for the least exponent c with a(n) <= f_c(b(n))
    on [0, n_max].  Returns (c, witness) on success, else None (strong evidence
    of a genuine separation)."""
    for c in range(max_exp + 1):
        f = lambda m, c=c: (m + 2) ** c - 1
        if is_poly_mono(f, c, n_max) and all(a(n) <= f(b(n)) for n in range(n_max + 1)):
            return (c, f"f(m) = (m+2)^{c} - 1")
    return None
