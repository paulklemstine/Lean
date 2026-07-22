from fractions import Fraction
from typing import Dict, List


def non_archimedean_witness(standards: List[Dict[Fraction, Fraction]]
                            ) -> Dict[Fraction, Fraction]:
    """Construct a surreal strictly greater than every element of a given finite list
    of surreals, exhibiting the non-Archimedean witness M with n < M for all n in N.

    We take the maximum leading exponent E over the inputs and return w^{E+1}, which
    dominates every input.  This realizes the boundedness principle finitarily and
    powers the proof that F is a proper subset of No.  Complexity O(sum of #terms)."""
    max_exp = Fraction(0)
    for s in standards:
        nz = {e: c for e, c in s.items() if c != 0}
        if nz:
            max_exp = max(max_exp, max(nz))
    return {max_exp + 1: Fraction(1)}
