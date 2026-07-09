from typing import Dict, List, Optional, Tuple

Mono = Dict[int, float]
Series = List[Tuple[Mono, float]]


def compare_mono(a: Mono, b: Mono) -> int:
    for h in sorted(set(a) | set(b), reverse=True):
        ea, eb = a.get(h, 0.0), b.get(h, 0.0)
        if ea < eb: return -1
        if ea > eb: return 1
    return 0


def leading_term(s: Series) -> Optional[Tuple[Mono, float]]:
    """Extract the valuation (orderTop) and leading coefficient of a finite
    transseries, or None for the zero series. The dominant transmonomial is the
    maximum under `compare_mono`; its coefficient is the leading coefficient.
    Underlies the asymptotic comparison theorem (a nonzero series has a genuine
    leading term: `not_agree_zero_of_ne_zero`)."""
    nz = [(m, c) for (m, c) in s if c != 0.0]
    if not nz:
        return None
    best = nz[0]
    for term in nz[1:]:
        if compare_mono(term[0], best[0]) > 0:
            best = term
    return best
