"""
Visualization: convergence of the Euler-Mascheroni approximants.

Plots the two-sided bracket  seq(n) = H_n - ln(n+1)  <  gamma  <  seq'(n) = H_n - ln n
together with the certified envelope gamma +/- 1/n, showing the O(1/n) rate.
Requires matplotlib. Run with:  python viz_convergence.py
"""

from __future__ import annotations

import math
import matplotlib.pyplot as plt

GAMMA: float = 0.5772156649015328606


def harmonic(n: int) -> float:
    return math.fsum(1.0 / k for k in range(1, n + 1))


def seq_lower(n: int) -> float:
    return harmonic(n) - math.log(n + 1)


def seq_upper(n: int) -> float:
    return harmonic(n) - math.log(n)


def main() -> None:
    ns = list(range(1, 201))
    lower = [seq_lower(n) for n in ns]
    upper = [seq_upper(n) for n in ns]
    env_hi = [GAMMA + 1.0 / n for n in ns]
    env_lo = [GAMMA - 1.0 / n for n in ns]

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.axhline(GAMMA, color="black", lw=1.2, label=r"$\gamma$")
    ax.plot(ns, lower, color="tab:blue", lw=1.6,
            label=r"$\mathrm{seq}(n)=H_n-\ln(n+1)$ (lower)")
    ax.plot(ns, upper, color="tab:red", lw=1.6,
            label=r"$\mathrm{seq}'(n)=H_n-\ln n$ (upper)")
    ax.fill_between(ns, env_lo, env_hi, color="gray", alpha=0.15,
                    label=r"certified envelope $\gamma\pm 1/n$")
    ax.set_xlabel("n")
    ax.set_ylabel("approximant value")
    ax.set_title("Two-sided convergence to the Euler-Mascheroni constant")
    ax.set_ylim(GAMMA - 0.25, GAMMA + 0.25)
    ax.legend(loc="upper right")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("gamma_convergence.png", dpi=150)
    print("saved gamma_convergence.png")


if __name__ == "__main__":
    main()
