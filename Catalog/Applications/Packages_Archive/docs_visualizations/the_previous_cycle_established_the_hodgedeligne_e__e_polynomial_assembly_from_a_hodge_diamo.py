from fractions import Fraction
from typing import Callable, Dict, Tuple

def epolynomial(h: Callable[[int, int], int], dim: int) -> Dict[Tuple[int, int], int]:
    """Build E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} u^p v^q as a coefficient dict.

    Iterates over the (dim+1)^2 cells of the diamond, attaches the chessboard sign
    (-1)^{p+q} to each Hodge number, and records nonzero coefficients.
    Complexity: O(dim^2) ring operations.  Setting u=v=1 recovers χ.
    """
    coeffs: Dict[Tuple[int, int], int] = {}
    for p in range(dim + 1):
        for q in range(dim + 1):
            c = ((-1) ** (p + q)) * h(p, q)
            if c:
                coeffs[(p, q)] = coeffs.get((p, q), 0) + c
    return {k: v for k, v in coeffs.items() if v}