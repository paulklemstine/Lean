from typing import Callable, List
import sympy as sp

def verify_plethysm(parts: List[int],
                    vertex: Callable[..., sp.Expr],
                    q_one_row: Callable[..., List[sp.Expr]],
                    X: List[sp.Symbol], t: sp.Symbol, bound: int) -> bool:
    """Return True iff S^t_lambda = phi_t(Q_lambda) for the given partition."""
    cc = lambda k: 1 - t ** (2 * k + 1)
    q_cl = q_one_row(lambda k: X[k], bound)
    q_def = q_one_row(lambda k: cc(k) * X[k], bound)
    Q = vertex(parts, q_cl, lambda k: sp.Integer(4))
    S = vertex(parts, q_def, lambda k: 4 / cc(k))
    phiQ = sp.expand(Q.subs({X[k]: cc(k) * X[k] for k in range(len(X))},
                            simultaneous=True))
    return sp.simplify(S - phiQ) == 0
