from __future__ import annotations

def divides_all(m: int, n: int) -> bool:
    """Decide whether m | (a^n - a) for every integer a.

    By the finite-verification lemma the truth value depends only on
    residues modulo m, so it suffices to test r in {0,...,m-1} using
    fast modular exponentiation. Complexity O(m log n).
    """
    return all((pow(r, n, m) - r) % m == 0 for r in range(m))
