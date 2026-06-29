"""Tropical Differential Equations: Power-Series Solutions — numerical demonstrations.

This self-contained script implements truncated formal power series over the
rationals and verifies, on concrete examples, the main results of the paper:

  * order_derivativeFun_eq      ord(f) = k+1  =>  ord(f') = k          (char 0)
  * order_iterate_derivativeFun ord(f) = n    =>  ord(d^i f) = n - i
  * order_diff_monomial         ord( prod_i (d^i f)^{e_i} ) = sum_i e_i (n - i)
  * order_sum_eq_of_unique_min  unique earliest term => order of sum = its order
  * tropical_balancing          a vanishing sum ties its minimal order >= twice
  * order_diffPoly_ge           ord(P(f)) >= min over terms (growth lower bound)
  * tropical_FTDA (containment) a classical solution => its order is balanced

Run directly:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Sequence, Tuple

INF = float("inf")
Series = Dict[int, Fraction]  # exponent -> coefficient (sparse, nonzero entries)


# --------------------------------------------------------------------------- #
# Core power-series arithmetic (all functions inlined, type-hinted)           #
# --------------------------------------------------------------------------- #
def normalize(s: Series) -> Series:
    """Drop zero coefficients so that the support is exactly the nonzero terms."""
    return {e: c for e, c in s.items() if c != 0}


def order(s: Series) -> float:
    """Order = index of lowest nonzero coefficient; +inf for the zero series."""
    s = normalize(s)
    return float(min(s)) if s else INF


def add(*series: Series) -> Series:
    """Sum of finitely many series (tropically: min of orders, as a lower bound)."""
    out: Series = {}
    for s in series:
        for e, c in s.items():
            out[e] = out.get(e, Fraction(0)) + c
    return normalize(out)


def scale(lam: Fraction, s: Series) -> Series:
    """Scalar multiple; nonzero lam preserves order."""
    return normalize({e: lam * c for e, c in s.items()})


def mul(a: Series, b: Series) -> Series:
    """Cauchy product (tropically: order adds)."""
    out: Series = {}
    for ea, ca in a.items():
        for eb, cb in b.items():
            out[ea + eb] = out.get(ea + eb, Fraction(0)) + ca * cb
    return normalize(out)


def power(s: Series, e: int) -> Series:
    """Integer power; tropically multiplies the order by e."""
    out: Series = {0: Fraction(1)}
    for _ in range(e):
        out = mul(out, s)
    return out


def derivative(s: Series) -> Series:
    """Formal derivative d/dX; over char 0 it lowers the order by exactly 1."""
    return normalize({e - 1: Fraction(e) * c for e, c in s.items() if e >= 1})


def iterate_derivative(s: Series, i: int) -> Series:
    """i-th formal derivative."""
    for _ in range(i):
        s = derivative(s)
    return s


def monomial(s: Series, exps: Dict[int, int]) -> Series:
    """Differential monomial  prod_i (d^i s)^{exps[i]}."""
    out: Series = {0: Fraction(1)}
    for i, e in exps.items():
        out = mul(out, power(iterate_derivative(s, i), e))
    return out


def predicted_monomial_order(n: int, exps: Dict[int, int]) -> int:
    """Theorem D / order_diff_monomial:  sum_i e_i (n - i)."""
    return sum(e * (n - i) for i, e in exps.items())


def term_orders(terms: Sequence[Series]) -> List[float]:
    return [order(t) for t in terms]


def is_balanced(terms: Sequence[Series]) -> bool:
    """tropical_balancing: the minimum term-order is attained at least twice."""
    orders = [o for o in term_orders(terms) if o != INF]
    if not orders:
        return True
    m = min(orders)
    return orders.count(m) >= 2


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def X_pow(n: int, coeff: int = 1) -> Series:
    return {n: Fraction(coeff)}


def demo_derivation_rule() -> None:
    print("=" * 70)
    print("Theorem C  order_derivativeFun_eq:  ord f = k+1  =>  ord f' = k")
    print("=" * 70)
    # f = X^5 + 3 X^7 - X^9 ,  ord = 5,  expect ord f' = 4
    f: Series = add(X_pow(5), X_pow(7, 3), X_pow(9, -1))
    print(f"f      = {pretty(f)}   ord = {order(f)}")
    fp = derivative(f)
    print(f"f'     = {pretty(fp)}   ord = {order(fp)}   (predicted 4)")
    assert order(fp) == 4
    print("Iterated rule (order_iterate_derivativeFun): ord(d^i f) = n - i")
    for i in range(0, 6):
        di = iterate_derivative(f, i)
        print(f"  ord(d^{i} f) = {order(di)}   predicted {5 - i}")
        assert order(di) == 5 - i
    print("OK\n")


def demo_monomial_formula() -> None:
    print("=" * 70)
    print("Theorem D  order_diff_monomial:  ord(prod (d^i f)^{e_i}) = sum e_i (n-i)")
    print("=" * 70)
    n = 5
    f: Series = add(X_pow(n), X_pow(n + 2, 2))  # ord f = 5
    cases: List[Dict[int, int]] = [
        {1: 2, 2: 1},   # (f')^2 f''  -> 3n - 4 = 11
        {0: 1, 3: 1},   # f * f'''    -> n + (n-3) = 7
        {2: 3},         # (f'')^3     -> 3(n-2) = 9
    ]
    for exps in cases:
        got = order(monomial(f, exps))
        pred = predicted_monomial_order(n, exps)
        print(f"  exps={exps}:  ord = {got},  predicted = {pred}")
        assert got == pred
    print("OK\n")


def demo_unique_minimum() -> None:
    print("=" * 70)
    print("Theorem A  order_sum_eq_of_unique_min: unique earliest term sets the order")
    print("=" * 70)
    terms = [X_pow(2), X_pow(5), X_pow(7)]
    s = add(*terms)
    print(f"  terms have orders {term_orders(terms)}; unique min = 2")
    print(f"  ord(sum) = {order(s)}  (predicted 2);  sum nonzero = {normalize(s) != {}}")
    assert order(s) == 2 and normalize(s) != {}
    print("  => balancing FAILS, so this relation cannot vanish.")
    print(f"  is_balanced = {is_balanced(terms)} (False)\n")


def demo_balancing_and_ftda() -> None:
    print("=" * 70)
    print("Theorem B/E  tropical_balancing & tropical_FTDA on  X y' - 3 y = 0")
    print("=" * 70)
    print("Classical solution f = X^3:")
    f = X_pow(3)
    t1 = mul(X_pow(1), derivative(f))   # X f'
    t2 = scale(Fraction(-3), f)         # -3 f
    total = add(t1, t2)
    print(f"  X f'  = {pretty(t1)}  ord {order(t1)}")
    print(f"  -3 f  = {pretty(t2)}  ord {order(t2)}")
    print(f"  sum   = {pretty(total)}  ord {order(total)}  (vanishes)")
    print(f"  balanced (min attained >= twice): {is_balanced([t1, t2])}")
    assert normalize(total) == {} and is_balanced([t1, t2])

    print("\nTropical FTDA containment: scan candidate orders n for X y' - 3 y.")
    print("Both terms have tropical order n, so balancing holds for ALL n,")
    print("but the leading coefficients (n) and (-3) cancel only at n = 3:")
    for n in range(1, 7):
        fn = X_pow(n)
        s = add(mul(X_pow(1), derivative(fn)), scale(Fraction(-3), fn))
        classical = normalize(s) == {}
        bal = is_balanced([mul(X_pow(1), derivative(fn)), scale(Fraction(-3), fn)])
        tag = "  <-- classical solution" if classical else ""
        print(f"  n={n}: balanced={bal}, classical solution={classical}{tag}")
        assert bal  # balancing necessary for every n
        if classical:
            assert n == 3
    print("OK\n")


def demo_growth_lower_bound() -> None:
    print("=" * 70)
    print("Theorem F  order_diffPoly_ge:  ord(P(f)) >= min over term orders")
    print("=" * 70)
    # P(f) = (f')^2 + f'' , generic f of order n
    for n in range(2, 6):
        f = add(X_pow(n), X_pow(n + 1, 7))  # ord f = n
        term1 = power(derivative(f), 2)      # (f')^2 , order 2(n-1)
        term2 = iterate_derivative(f, 2)     # f''    , order n-2
        Pf = add(term1, term2)
        lower = min(predicted_monomial_order(n, {1: 2}),
                    predicted_monomial_order(n, {2: 1}))
        print(f"  n={n}: ord P(f)={order(Pf)} >= trop bound {lower}")
        assert order(Pf) >= lower
    print("OK\n")


# --------------------------------------------------------------------------- #
def pretty(s: Series) -> str:
    s = normalize(s)
    if not s:
        return "0"
    parts = []
    for e in sorted(s):
        c = s[e]
        parts.append(f"({c})X^{e}")
    return " + ".join(parts)


def main() -> None:
    demo_derivation_rule()
    demo_monomial_formula()
    demo_unique_minimum()
    demo_balancing_and_ftda()
    demo_growth_lower_bound()
    print("All numerical checks passed — results consistent with the formal theorems.")


if __name__ == "__main__":
    main()
