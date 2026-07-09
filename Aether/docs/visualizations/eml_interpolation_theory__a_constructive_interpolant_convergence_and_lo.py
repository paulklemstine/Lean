"""Visualization: convergence of the EML interpolant and the n^(-alpha) rate.

Generates two panels:
  (left)  f(x) = sqrt(x) and its width-n piecewise-linear EML interpolants;
  (right) measured sup-error vs the theoretical bound 2L/n^alpha on log-log axes,
          confirming the slope -alpha of the Hölder-Jackson rate.
Requires matplotlib + numpy. Saves 'eml_jackson_rate.png'.
"""
from __future__ import annotations

import math
from typing import Callable, List

import numpy as np
import matplotlib.pyplot as plt


def pw_lin_interp(f: Callable[[float], float], n: int, x: float) -> float:
    k: int = min(n - 1, int(math.floor(n * x)))
    a: float = k / n
    b: float = (k + 1) / n
    return f(a) + (f(b) - f(a)) / (b - a) * (x - a)


def sup_error(f: Callable[[float], float], n: int, m: int = 4001) -> float:
    xs = np.linspace(0.0, 1.0, m)
    return float(max(abs(f(x) - pw_lin_interp(f, n, x)) for x in xs))


def main() -> None:
    f: Callable[[float], float] = math.sqrt
    L, alpha = 1.0, 0.5
    xs = np.linspace(0.0, 1.0, 1000)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.plot(xs, [f(x) for x in xs], "k-", lw=2.5, label="f(x)=sqrt(x)")
    for n in (2, 4, 8):
        ax1.plot(xs, [pw_lin_interp(f, n, x) for x in xs], "--",
                 label=f"interpolant n={n}")
    ax1.set_title("EML interpolant converges to the target")
    ax1.set_xlabel("x"); ax1.set_ylabel("value"); ax1.legend(); ax1.grid(True, alpha=0.3)

    ns = [2 ** k for k in range(1, 11)]
    errs = [sup_error(f, n) for n in ns]
    bnds = [2.0 * L / n ** alpha for n in ns]
    ax2.loglog(ns, errs, "o-", label="measured sup-error")
    ax2.loglog(ns, bnds, "s--", label="bound 2L/n^alpha")
    ax2.set_title("Hölder-Jackson rate: slope = -alpha = -1/2")
    ax2.set_xlabel("width n"); ax2.set_ylabel("error"); ax2.legend(); ax2.grid(True, which="both", alpha=0.3)

    fig.tight_layout()
    fig.savefig("eml_jackson_rate.png", dpi=130)
    print("saved eml_jackson_rate.png")


if __name__ == "__main__":
    main()
