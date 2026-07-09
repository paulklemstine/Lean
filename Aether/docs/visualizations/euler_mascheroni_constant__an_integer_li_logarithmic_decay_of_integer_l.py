"""Visualization: decay of integer linear forms vs. the rigidity floor.

Plots |a_n + b_n*x| for x = sqrt(2) (irrational, forms -> 0) against the
constant rigidity floor 1/q for a rational x = p/q (forms can never drop below
it).  This is a direct visual statement of Theorem 1.
"""

from __future__ import annotations

from decimal import Decimal, getcontext
from fractions import Fraction
from math import sqrt
from typing import Iterator

import matplotlib.pyplot as plt

getcontext().prec = 60


def convergents_of(x: Fraction, n_terms: int) -> Iterator[Fraction]:
    p2, p1, q2, q1 = 0, 1, 1, 0
    frac = x
    for _ in range(n_terms):
        a = frac.numerator // frac.denominator
        p2, p1 = p1, a * p1 + p2
        q2, q1 = q1, a * q1 + q2
        yield Fraction(p1, q1)
        rem = frac - a
        if rem == 0:
            break
        frac = 1 / rem


def main() -> None:
    root2 = Fraction(Decimal(2).sqrt())
    ns, forms = [], []
    for k, conv in enumerate(convergents_of(root2, 12)):
        a, b = -conv.numerator, conv.denominator
        ns.append(k)
        forms.append(abs(float(a + b * root2)))

    p, q = 22, 7  # rational control x = 22/7, floor 1/q
    floor = 1.0 / q

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(ns, forms, "o-", label=r"$|a_n + b_n\sqrt{2}|$ (irrational)")
    ax.axhline(floor, color="crimson", ls="--",
               label=r"rigidity floor $1/q$ for $x=22/7$")
    ax.set_xlabel("n")
    ax.set_ylabel(r"$|a_n + b_n x|$  (log scale)")
    ax.set_title("Theorem 1: forms for an irrational pierce the rational floor")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("integer_forms_decay.png", dpi=150)
    print("wrote integer_forms_decay.png")


if __name__ == "__main__":
    main()
