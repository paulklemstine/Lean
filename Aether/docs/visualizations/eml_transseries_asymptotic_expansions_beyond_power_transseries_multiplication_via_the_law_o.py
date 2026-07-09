from typing import Dict, List, Tuple

Mono = Tuple[Tuple[int, float], ...]      # normalized (height, exponent) pairs
TSeries = Dict[Mono, float]               # transmonomial -> coefficient

def mono_mul(m1: Mono, m2: Mono) -> Mono:
    acc: Dict[int, float] = {}
    for h, a in m1:
        acc[h] = acc.get(h, 0.0) + a
    for h, a in m2:
        acc[h] = acc.get(h, 0.0) + a
    return tuple(sorted(((h, a) for h, a in acc.items() if a != 0.0), reverse=True))

def tseries_mul(f: TSeries, g: TSeries) -> TSeries:
    """Multiply transseries via the law of exponents: pairwise multiply transmonomials
    (adding exponents at each height) and collect like terms.  Complexity O(m*n)."""
    out: TSeries = {}
    for m1, c1 in f.items():
        for m2, c2 in g.items():
            m = mono_mul(m1, m2)
            out[m] = out.get(m, 0.0) + c1 * c2
    return {m: c for m, c in out.items() if c != 0.0}
