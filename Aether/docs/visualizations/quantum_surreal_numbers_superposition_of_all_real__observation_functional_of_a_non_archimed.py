from __future__ import annotations
from typing import List, Sequence, Tuple

ORDER = 12

def series_mul(a: Tuple[float, ...], b: Tuple[float, ...]) -> Tuple[float, ...]:
    out = [0.0] * ORDER
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                if i + j < ORDER:
                    out[i + j] += x * y
    return tuple(out)

def series_add(a: Tuple[float, ...], b: Tuple[float, ...]) -> Tuple[float, ...]:
    return tuple(x + y for x, y in zip(a, b))

def series_inverse(a: Tuple[float, ...]) -> Tuple[float, ...]:
    a0 = a[0]
    if abs(a0) < 1e-15:
        raise ValueError("not appreciable: order-0 term is zero")
    u = tuple((c / a0) if i else 0.0 for i, c in enumerate(a))
    res = tuple(1.0 if i == 0 else 0.0 for i in range(ORDER))
    term = res
    negu = tuple(-c for c in u)
    for _ in range(ORDER - 1):
        term = series_mul(term, negu)
        res = series_add(res, term)
    return series_mul(res, tuple((1.0 / a0) if i == 0 else 0.0 for i in range(ORDER)))

def observed_distribution(amplitudes: Sequence[Tuple[float, ...]]) -> List[float]:
    """Return observed probabilities p_i = st(alpha_i^2 / sum_j alpha_j^2)."""
    z = tuple(0.0 for _ in range(ORDER))
    for a in amplitudes:
        z = series_add(z, series_mul(a, a))
    if abs(z[0]) < 1e-15:
        raise ValueError("state not admissible: total weight is not appreciable")
    zi = series_inverse(z)
    return [series_mul(series_mul(a, a), zi)[0] for a in amplitudes]
