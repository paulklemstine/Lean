from typing import Callable, List
import sympy as sp

def q_one_row(cf: Callable[[int], sp.Expr], n_max: int) -> List[sp.Expr]:
    """One-row functions [q_0, ..., q_{n_max}] from the Newton recursion."""
    q: List[sp.Expr] = [sp.Integer(1)]
    for n in range(1, n_max + 1):
        acc = sp.Integer(0)
        k = 0
        while 2 * k <= n - 1:
            acc += 2 * cf(k) * q[n - 1 - 2 * k]
            k += 1
        q.append(sp.expand(acc / n))
    return q
