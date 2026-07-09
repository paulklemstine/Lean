from typing import Dict

Mono = Dict[int, float]  # tower height -> real exponent

def mono_cmp(m1: Mono, m2: Mono) -> int:
    """Transmonomial dominance order: scan tower heights from highest to lowest;
    the first height at which the exponents differ decides, larger exponent wins.
    Returns -1 if m1 < m2, 0 if equal, +1 if m1 > m2.  Complexity O(k log k)."""
    for h in sorted(set(m1) | set(m2), reverse=True):
        a1, a2 = m1.get(h, 0.0), m2.get(h, 0.0)
        if a1 != a2:
            return -1 if a1 < a2 else 1
    return 0
