from itertools import product
from typing import List, Sequence, Tuple

Monomial = Tuple[float, Tuple[float, ...]]

def on_hypersurface(monomials: List[Monomial], x: Sequence[float],
                    tol: float = 1e-9) -> bool:
    """Membership test x in V(P): the defining minimum is attained at least twice."""
    vals = [c + sum(e * xi for e, xi in zip(exp, x)) for c, exp in monomials]
    m = min(vals)
    return sum(1 for v in vals if abs(v - m) <= tol) >= 2

def in_union(P: List[Monomial], Q: List[Monomial], x: Sequence[float],
             tol: float = 1e-9) -> bool:
    """Theorem 5.5: x in V(P (x) Q) iff x in V(P) or x in V(Q).

    Uses the union law to avoid expanding the |P|*|Q| product monomials:
    cost O(n(|P| + |Q|)) instead of O(n |P| |Q|).
    """
    return on_hypersurface(P, x, tol) or on_hypersurface(Q, x, tol)
