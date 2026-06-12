from itertools import product
from typing import List, Sequence, Tuple

Monomial = Tuple[float, Tuple[float, ...]]

def trop_eval(monomials: List[Monomial], x: Sequence[float]) -> float:
    """Tropical (min-plus) evaluation: min over monomials of coeff + <exp, x>."""
    return min(c + sum(e * xi for e, xi in zip(exp, x)) for c, exp in monomials)

def trop_mul(P: List[Monomial], Q: List[Monomial]) -> List[Monomial]:
    """Tropical product: coefficients add, exponent vectors add, over all pairs."""
    return [(c1 + c2, tuple(a + b for a, b in zip(e1, e2)))
            for (c1, e1), (c2, e2) in product(P, Q)]

def verify_eval_mul(P: List[Monomial], Q: List[Monomial],
                    x: Sequence[float], tol: float = 1e-9) -> bool:
    """Runtime witness of Theorem 4.3: eval(P (x) Q) = eval(P) + eval(Q)."""
    lhs = trop_eval(trop_mul(P, Q), x)
    rhs = trop_eval(P, x) + trop_eval(Q, x)
    return abs(lhs - rhs) <= tol
