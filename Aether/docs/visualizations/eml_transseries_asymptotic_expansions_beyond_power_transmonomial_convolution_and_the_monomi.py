from typing import Dict, Tuple

TransMono = Dict[int, float]

def term_mul(g: TransMono, a: float, h: TransMono, b: float
             ) -> Tuple[TransMono, float]:
    """Monomial law: term(g,a)*term(h,b) = term(g+h, a*b)."""
    result: TransMono = {}
    for k in set(g) | set(h):
        v = g.get(k, 0.0) + h.get(k, 0.0)
        if v != 0.0:
            result[k] = v
    return result, a * b
