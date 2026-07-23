from __future__ import annotations


def unsat_certificate(n: int, k: int, m: int, q: int = 2) -> str:
    """Return 'UNSAT-FORCED' iff q^n*S^m < |C|^m, else 'INCONCLUSIVE'.

    Exact integer comparison; never errs in the forced direction.
    """
    s: int = (n * q) ** k - (n * (q - 1)) ** k
    first_moment: int = (q ** n) * s ** m
    num_formulas: int = ((n * q) ** k) ** m
    return "UNSAT-FORCED" if first_moment < num_formulas else "INCONCLUSIVE"
