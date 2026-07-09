from typing import Sequence

Exponent = tuple[int, ...]
Monomial = tuple[float, Exponent]
TropPoly = list[Monomial]


def trop_poly_value_and_minimizers(
    f: TropPoly, w: Sequence[float], tol: float = 1e-9
) -> tuple[float, list[int]]:
    """
    Evaluate the min-plus tropical polynomial
        T(w) = min_a ( v(c_a) + <a, w> )
    and return (value, indices attaining the minimum).

    Membership in the corner locus / tropical hypersurface holds iff
    len(minimizers) >= 2.
    """
    values = [c + sum(ai * wi for ai, wi in zip(a, w)) for (c, a) in f]
    m = min(values)
    minimizers = [i for i, v in enumerate(values) if abs(v - m) <= tol]
    return m, minimizers
