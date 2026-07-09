"""Visualization: the Airy functions vs. the best exponential-polynomial
approximations, illustrating that no q*exp(p) can match Ai/Bi as a solution.

Generates a PNG with two panels:
  (left)  Ai(x), Bi(x) over [-12, 4];
  (right) the residual airyCoeff(q,p) - X*q for several (q,p), showing it is
          never the zero polynomial (always a nonzero curve).
"""
from __future__ import annotations
from typing import List
import numpy as np
import matplotlib.pyplot as plt
from scipy import special

Poly = List[float]


def deriv(p: Poly) -> List[float]:
    return [i * p[i] for i in range(1, len(p))] or [0.0]


def polyval(p: Poly, x):
    return sum(c * x ** i for i, c in enumerate(p))


def airy_coeff_val(q: Poly, p: Poly, x):
    qp, pp = deriv(q), deriv(p)
    qpp, ppp = deriv(qp), deriv(pp)
    return (polyval(qpp, x) + 2 * polyval(qp, x) * polyval(pp, x)
            + polyval(q, x) * polyval(ppp, x)
            + polyval(q, x) * polyval(pp, x) ** 2)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    x = np.linspace(-12, 4, 800)
    ai, _, bi, _ = special.airy(x)
    ax1.plot(x, ai, label="Ai(x)")
    ax1.plot(x, bi, label="Bi(x)")
    ax1.set_ylim(-0.6, 1.2)
    ax1.set_title("Airy functions: genuine non-elementary solutions")
    ax1.set_xlabel("x"); ax1.legend(); ax1.grid(alpha=0.3)

    xs = np.linspace(-2, 2, 400)
    cases = {
        "q=1, p=x": ([1.0], [0.0, 1.0]),
        "q=x^2, p=2x": ([0, 0, 1.0], [0.0, 2.0]),
        "q=1, p=-x^2": ([1.0], [0.0, 0.0, -1.0]),
    }
    for name, (q, p) in cases.items():
        resid = [airy_coeff_val(q, p, t) - t * polyval(q, t) for t in xs]
        ax2.plot(xs, resid, label=name)
    ax2.axhline(0, color="k", lw=0.8)
    ax2.set_title("Residual airyCoeff(q,p) - x*q  (never identically 0)")
    ax2.set_xlabel("x"); ax2.legend(); ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("airy_obstruction.png", dpi=150)
    print("wrote airy_obstruction.png")


if __name__ == "__main__":
    main()
