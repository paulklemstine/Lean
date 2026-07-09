from typing import Dict, List, Tuple

TransMono = Dict[int, float]  # tower height -> real exponent (zeros omitted)


def normalize(m: TransMono) -> TransMono:
    """Canonical form: drop zero exponents."""
    return {h: a for h, a in m.items() if a != 0.0}


def mono_compare(m1: TransMono, m2: TransMono) -> int:
    """
    Lexicographic asymptotic dominance comparison of two transmonomials.

    Scans tower heights from HIGHEST to LOWEST; the first height at which the
    exponents differ decides the order (larger exponent at the higher height
    dominates).  Returns -1 (m1 dominated by m2), 0 (equal), or +1 (m1 dominates).

    This is the computational realization of mono_lt_mono_of_height and
    mono_lt_mono_same.  Complexity O(k log k) for k nonzero exponents.
    """
    m1, m2 = normalize(m1), normalize(m2)
    for h in sorted(set(m1) | set(m2), reverse=True):
        a1, a2 = m1.get(h, 0.0), m2.get(h, 0.0)
        if a1 < a2:
            return -1
        if a1 > a2:
            return 1
    return 0


def leading_term(terms: List[Tuple[TransMono, float]]) -> Tuple[TransMono, float]:
    """
    Extract the leading (most dominant) term of a finitely-supported transseries,
    realizing the valuation orderTop.  Complexity O(k) comparisons via mono_compare.
    """
    best: Tuple[TransMono, float] = ({}, 0.0)
    found = False
    for m, c in terms:
        if c == 0.0:
            continue
        if not found or mono_compare(m, best[0]) > 0:
            best, found = (m, c), True
    return best
