"""
Cobweb / convergence visualization for the EML fixed-point iteration
f(x) = e * log(x + 100) on [0, 20], rho = 1/30.

Left panel: cobweb diagram showing the staircase converging to x*.
Right panel: log-scale plot of the true error vs. the certified a-priori
envelope |x_1 - x_0| * rho^n / (1 - rho).

Requires matplotlib + numpy.
"""

from __future__ import annotations

import math
from typing import List

import numpy as np
import matplotlib.pyplot as plt


def f(x: float, a: float = 1.0, b: float = 1.0, c: float = 100.0) -> float:
    return math.exp(a) * math.log(b * x + c)


def main() -> None:
    rho = 1.0 / 30.0
    x0 = 0.0
    n_steps = 8

    # iteration
    seq: List[float] = [x0]
    for _ in range(40):
        seq.append(f(seq[-1]))
    xstar = seq[-1]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.2))

    # ---- cobweb diagram ----
    xs = np.linspace(0, 20, 400)
    ax1.plot(xs, [f(x) for x in xs], "b-", lw=2, label=r"$f(x)=e\,\log(x+100)$")
    ax1.plot(xs, xs, "k--", lw=1, label=r"$y=x$")
    cx = x0
    for _ in range(n_steps):
        fy = f(cx)
        ax1.plot([cx, cx], [cx, fy], "r-", lw=0.9)
        ax1.plot([cx, fy], [fy, fy], "r-", lw=0.9)
        cx = fy
    ax1.plot([xstar], [xstar], "go", ms=9, label=fr"$x^*\approx{xstar:.4f}$")
    ax1.set_xlabel("$x_n$")
    ax1.set_ylabel("$x_{n+1}=f(x_n)$")
    ax1.set_title("Cobweb diagram: convergence to the fixed point")
    ax1.legend(loc="lower right")
    ax1.grid(alpha=0.3)

    # ---- error vs certified envelope ----
    ns = list(range(n_steps + 1))
    step0 = abs(seq[1] - seq[0])
    true_err = [abs(seq[n] - xstar) for n in ns]
    envelope = [step0 * rho**n / (1 - rho) for n in ns]
    ax2.semilogy(ns, true_err, "ro-", label="true error $|x_n-x^*|$")
    ax2.semilogy(ns, envelope, "b^--",
                 label=r"a-priori bound $|x_1-x_0|\,\rho^n/(1-\rho)$")
    ax2.set_xlabel("iteration $n$")
    ax2.set_ylabel("error (log scale)")
    ax2.set_title(r"Certified $O(\rho^n)$ geometric convergence")
    ax2.legend()
    ax2.grid(alpha=0.3, which="both")

    fig.tight_layout()
    fig.savefig("eml_fixedpoint_convergence.png", dpi=150)
    print("saved eml_fixedpoint_convergence.png")


if __name__ == "__main__":
    main()
