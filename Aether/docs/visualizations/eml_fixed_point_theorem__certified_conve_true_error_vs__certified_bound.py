"""Semilog plot of true error vs. a priori / a posteriori bounds.

Shows geometric (linear-on-semilog) decay and that both certificates upper-bound
the true error at every iterate. Requires matplotlib + numpy.
"""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt


def f(a: float, x: float) -> float:
    return math.exp(a) * math.log(x + 2.0)


def main(a: float = 0.1, x0: float = 1.5, rho: float = 0.3684) -> None:
    orbit = [x0]
    for _ in range(25):
        orbit.append(f(a, orbit[-1]))
    x_star = orbit[-1]
    first = abs(orbit[1] - orbit[0])

    ns = list(range(0, 12))
    true_err = [abs(orbit[n] - x_star) for n in ns]
    apriori = [rho**n / (1 - rho) * first for n in ns]
    apost = [rho / (1 - rho) * abs(orbit[n + 1] - orbit[n]) for n in ns]

    plt.figure(figsize=(8, 5))
    plt.semilogy(ns, true_err, "ko-", label="true error")
    plt.semilogy(ns, apriori, "b^--", label="a priori bound")
    plt.semilogy(ns, apost, "rs--", label="a posteriori bound")
    plt.title("EML iteration: true error vs. certified bounds")
    plt.xlabel("iteration n"); plt.ylabel("error (log scale)")
    plt.legend(); plt.grid(alpha=0.3, which="both")
    plt.tight_layout()
    plt.savefig("eml_error_bounds.png", dpi=150)
    print("saved eml_error_bounds.png")


if __name__ == "__main__":
    main()
