"""Visualize the tropical lower bound vs the true p-adic valuation of a
Cauchy convolution, and the gap (cancellation) between them.

Requires matplotlib. Produces 'tropical_bound.png'.
"""
import math
from fractions import Fraction
from typing import Callable, List, Sequence
import matplotlib.pyplot as plt


def p_adic_valuation(p: int) -> Callable[[Fraction], float]:
    def v(x: Fraction) -> float:
        if x == 0:
            return math.inf
        x = Fraction(x); num, den = abs(x.numerator), x.denominator
        def order(m: int) -> int:
            c = 0
            while m % p == 0:
                m //= p; c += 1
            return c
        return float(order(num) - order(den))
    return v


def main() -> None:
    p = 2
    v = p_adic_valuation(p)
    a = [Fraction(1)] * 16          # all-ones
    b = [Fraction(1)] * 16          # (a*b)(n) = n+1
    ua = [v(x) for x in a]
    ub = [v(x) for x in b]
    N = 15
    ns: List[int] = list(range(N + 1))
    bound: List[float] = [min(ua[k] + ub[n - k] for k in range(n + 1)) for n in ns]
    true: List[float] = [v(sum((a[k] * b[n - k] for k in range(n + 1)), Fraction(0))) for n in ns]

    fig, ax = plt.subplots(figsize=(9, 5))
    ax.step(ns, bound, where="mid", label="tropical lower bound", linewidth=2)
    ax.step(ns, true, where="mid", label="true v_2((a*b)(n)) = v_2(n+1)", linewidth=2)
    ax.fill_between(ns, bound, true, step="mid", alpha=0.2, label="gap (cancellation)")
    ax.set_xlabel("index n")
    ax.set_ylabel("valuation")
    ax.set_title("Tropical Convolution Bound: all-ones * all-ones, p = 2")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("tropical_bound.png", dpi=150)
    print("wrote tropical_bound.png")


if __name__ == "__main__":
    main()
