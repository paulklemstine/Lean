from __future__ import annotations
from typing import Tuple

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

def appreciable_inverse(a: Tuple[float, ...]) -> Tuple[float, ...]:
    """Truncated inverse of an appreciable series via the Neumann (geometric) series.

    Writing a = a0 (1 + u) with u of positive valuation, 1/a = (1/a0) sum (-u)^k,
    which terminates modulo eps^ORDER because u has no order-0 term.
    """
    a0 = a[0]
    if abs(a0) < 1e-15:
        raise ValueError("element is not appreciable (order-0 term is zero)")
    u = tuple((c / a0) if i else 0.0 for i, c in enumerate(a))
    res = tuple(1.0 if i == 0 else 0.0 for i in range(ORDER))
    term = res
    negu = tuple(-c for c in u)
    for _ in range(ORDER - 1):
        term = series_mul(term, negu)
        res = series_add(res, term)
    return series_mul(res, tuple((1.0 / a0) if i == 0 else 0.0 for i in range(ORDER)))
