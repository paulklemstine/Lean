from typing import Callable, Dict, List, Tuple
from fractions import Fraction

Monomial = Tuple[Tuple[int, int], ...]
Poly = Dict[Monomial, Fraction]


def newton_one_row(num_rows: int) -> List[Poly]:
    """Compute q_0, ..., q_{num_rows} via the Schur-Q Newton recursion.

    q_0 = 1;  q_{m+1} = (1/(m+1)) * sum_{k=0}^{floor(m/2)} 2 * p_{2k+1} * q_{m-2k}.
    Coefficients are exact rationals; monomials are products of odd power sums
    p_{2k+1} encoded by the variable index k.
    """
    def mon_mul(a: Monomial, b: Monomial) -> Monomial:
        e: Dict[int, int] = {}
        for i, x in a:
            e[i] = e.get(i, 0) + x
        for i, x in b:
            e[i] = e.get(i, 0) + x
        return tuple(sorted((i, x) for i, x in e.items() if x))

    def scale(c: Fraction, poly: Poly) -> Poly:
        return {m: c * v for m, v in poly.items()}

    def add(a: Poly, b: Poly) -> Poly:
        out = dict(a)
        for m, v in b.items():
            nv = out.get(m, Fraction(0)) + v
            if nv == 0:
                out.pop(m, None)
            else:
                out[m] = nv
        return out

    qs: List[Poly] = [{(): Fraction(1)}]
    for mp1 in range(1, num_rows + 1):
        m = mp1 - 1
        acc: Poly = {}
        for k in range(m // 2 + 1):
            pk: Poly = {(((k, 1),)): Fraction(2)}
            term = {mon_mul(mm, ((k, 1),)): Fraction(2) * v
                    for mm, v in qs[m - 2 * k].items()}
            acc = add(acc, term)
        qs.append(scale(Fraction(1, mp1), acc))
    return qs
