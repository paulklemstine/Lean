from typing import List, Tuple

def factorization_type_small(coeffs: Tuple[int, ...], p: int) -> Tuple[int, ...]:
    """Frobenius cycle type (partition of deg) of a monic poly of degree <= 3
    over F_p: peel off linear factors (fixed points), then the leftover of
    degree 2 or 3 without an F_p-root is a single irreducible factor."""
    poly: List[int] = list(coeffs) + [1]
    n = len(coeffs)
    degrees: List[int] = []
    changed = True
    while changed and len(poly) > 1:
        changed = False
        for r in range(p):
            v = 0
            for c in reversed(poly):
                v = (v * r + c) % p
            if v == 0:
                d = len(poly) - 1
                quo, rem = [0] * d, poly[-1]
                for i in range(d - 1, -1, -1):
                    quo[i] = rem
                    rem = (poly[i] + r * rem) % p
                poly, changed = quo, True
                degrees.append(1)
                break
    if n - len(degrees) >= 2:
        degrees.append(n - len(degrees))
    return tuple(sorted(degrees))
