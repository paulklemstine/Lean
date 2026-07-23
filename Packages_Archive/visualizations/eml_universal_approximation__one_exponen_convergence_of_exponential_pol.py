"""Visualization: exponential-polynomial approximations converging to a target.

Produces a figure with (left) the target sin(3x) overlaid with degree-N
exponential-polynomial fits, and (right) the sup-norm error vs. degree.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def exp_poly_fit(f, a, b, degree, n=2000):
    xs = np.linspace(a, b, n)
    u = np.exp(xs)
    D = np.vander(u, N=degree + 1, increasing=True)
    c, *_ = np.linalg.lstsq(D, f(xs), rcond=None)
    return c


def eval_fit(c, xs):
    u = np.exp(xs)
    return np.vander(u, N=len(c), increasing=True) @ c


def main() -> None:
    a, b = 0.0, 2.0
    f = lambda x: np.sin(3.0 * x)
    xs = np.linspace(a, b, 600)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4.5))

    ax1.plot(xs, f(xs), "k", lw=2.5, label="target sin(3x)")
    errs, degs = [], list(range(1, 13))
    for N in degs:
        c = exp_poly_fit(f, a, b, N)
        approx = eval_fit(c, xs)
        errs.append(float(np.max(np.abs(approx - f(xs)))))
        if N in (2, 4, 8, 12):
            ax1.plot(xs, approx, lw=1.2, label=f"N={N}")
    ax1.set_title("Exponential-polynomial approximation of sin(3x)")
    ax1.set_xlabel("x"); ax1.legend()

    ax2.semilogy(degs, errs, "o-")
    ax2.set_title("Uniform (sup-norm) error vs degree N")
    ax2.set_xlabel("degree N"); ax2.set_ylabel("sup error")
    ax2.grid(True, which="both", alpha=0.3)

    fig.tight_layout()
    fig.savefig("exp_poly_convergence.png", dpi=150)
    print("saved exp_poly_convergence.png")


if __name__ == "__main__":
    main()
