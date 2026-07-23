from typing import List, Sequence, Tuple

Poly = List[int]

def poly_eval(coeffs: Poly, x: int) -> int:
    result, power = 0, 1
    for c in coeffs:
        result += c * power
        power *= x
    return result

def poly_degree(coeffs: Poly) -> int:
    return max((i for i, c in enumerate(coeffs) if c != 0), default=0)

def fiber_lower_bound(f: Poly, A: Sequence[int]) -> Tuple[float, int]:
    """Return (|A|/k, |f(A)|) and assert the fiber bound |A| <= k*|f(A)|."""
    k: int = poly_degree(f)
    image = {poly_eval(f, a) for a in A}
    n: int = len(set(A))
    assert n <= k * len(image), "fiber bound violated"
    return n / k, len(image)
