"""Visualization: certified geometric convergence and depth-stable growth.

Generates two panels:
  (left)  log-scale actual error vs the certified Banach bound for the
          concrete EML operator f(x) = e*log(x+100), rho = 1/30;
  (right) depth-K Lipschitz growth: Bernoulli floor <= (1+rho)^K <= exp(K*rho),
          contrasted with feedforward L^K blow-up.
"""
from __future__ import annotations
import math
import matplotlib.pyplot as plt


def main() -> None:
    a, b, c, rho = 1.0, 1.0, 100.0, 1.0 / 30.0
    f = lambda x: math.exp(a) * math.log(b * x + c)

    # fixed point
    xs = 0.0
    for _ in range(200):
        xs = f(xs)

    x0 = 5.0
    seq = [x0]
    for _ in range(9):
        seq.append(f(seq[-1]))
    c0 = abs(seq[1] - seq[0])
    ns = list(range(len(seq)))
    actual = [abs(v - xs) + 1e-18 for v in seq]
    bound = [c0 * rho ** n / (1 - rho) for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.semilogy(ns, actual, "o-", label="actual |x_n - x*|")
    ax1.semilogy(ns, bound, "s--", label="certified bound")
    ax1.set_xlabel("iteration n")
    ax1.set_ylabel("error (log scale)")
    ax1.set_title("EML certified geometric convergence (rho = 1/30)")
    ax1.legend()
    ax1.grid(True, which="both", alpha=0.3)

    Ks = list(range(1, 81))
    floor = [1 + K * rho for K in Ks]
    exact = [(1 + rho) ** K for K in Ks]
    ceil = [math.exp(K * rho) for K in Ks]
    ff = [1.5 ** K for K in Ks]
    ax2.plot(Ks, floor, label="Bernoulli floor 1+K*rho")
    ax2.plot(Ks, exact, label="(1+rho)^K  EML residual")
    ax2.plot(Ks, ceil, label="exp(K*rho) ceiling")
    ax2.plot(Ks, ff, label="feedforward 1.5^K", linestyle=":")
    ax2.set_yscale("log")
    ax2.set_xlabel("depth K")
    ax2.set_ylabel("Lipschitz constant (log scale)")
    ax2.set_title("Depth-stable vs exponential growth")
    ax2.legend()
    ax2.grid(True, which="both", alpha=0.3)

    fig.tight_layout()
    fig.savefig("eml_bridge_visualization.png", dpi=150)
    print("saved eml_bridge_visualization.png")


if __name__ == "__main__":
    main()
