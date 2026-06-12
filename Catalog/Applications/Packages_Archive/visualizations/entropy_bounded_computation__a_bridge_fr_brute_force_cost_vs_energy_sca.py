"""EBC visualizations: brute-force cost vs. energy reference scales, and the
polynomial-vs-exponential entropy gap.

Generates two PNG figures:
  * ebc_brute_force_cost.png   — Landauer cost of brute-force key search vs key length
  * ebc_entropy_gap.png        — 2^n overtaking n^k (the unbounded entropy gap)

Requires matplotlib and numpy:  pip install matplotlib numpy
Run with:  python visualize.py
"""

from __future__ import annotations

import math

import numpy as np
import matplotlib.pyplot as plt

K_B: float = 1.380649e-23
ROOM_T: float = 300.0
TF: float = K_B * ROOM_T * math.log(2.0)  # Landauer per-bit cost, J/bit

# reference energy scales (joules)
REFERENCES = {
    "AA battery (~10 kJ)": 1.0e4,
    "1 kWh (3.6 MJ)": 3.6e6,
    "US annual energy (~1e20 J)": 1.0e20,
    "Sun's lifetime (~1.2e44 J)": 1.2e44,
}


def plot_brute_force_cost(path: str = "ebc_brute_force_cost.png") -> None:
    key_bits = np.arange(8, 320, 4)
    cost = np.array([2.0 ** float(n) * TF for n in key_bits])  # 2^n * tf
    fig, ax = plt.subplots(figsize=(9, 6))
    ax.semilogy(key_bits, cost, color="crimson", lw=2.5,
                label=r"brute-force cost $2^n\cdot k_BT\ln 2$")
    for name, energy in REFERENCES.items():
        ax.axhline(energy, ls="--", lw=1, alpha=0.7)
        ax.text(key_bits[0], energy * 1.4, name, fontsize=8, va="bottom")
    for n in (128, 256):
        ax.axvline(n, color="gray", ls=":", lw=1)
        ax.text(n + 2, cost[0], f"{n}-bit", rotation=90, fontsize=8, va="bottom")
    ax.set_xlabel("key length n (bits)")
    ax.set_ylabel("energy (joules, log scale)")
    ax.set_title("Thermodynamic cost of brute-force key search (bruteForce_cost)")
    ax.legend(loc="lower right")
    ax.grid(True, which="both", alpha=0.2)
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    print(f"wrote {path}")


def plot_entropy_gap(path: str = "ebc_entropy_gap.png", k: int = 5) -> None:
    n = np.arange(1, 45)
    exp_curve = 2.0 ** n.astype(float)
    poly_curve = n.astype(float) ** k
    fig, ax = plt.subplots(figsize=(9, 6))
    ax.semilogy(n, exp_curve, color="navy", lw=2.5, label=r"$2^n$ (exponential)")
    ax.semilogy(n, poly_curve, color="darkorange", lw=2.5, label=rf"$n^{k}$ (polynomial)")
    # mark permanent crossover
    cross = next((m for m in n if all(2.0 ** float(j) > float(j) ** k
                                      for j in range(m, m + 20))), None)
    if cross is not None:
        ax.axvline(cross, color="green", ls=":", lw=1.5)
        ax.text(cross + 0.3, poly_curve[0], f"permanent crossover n={cross}",
                rotation=90, fontsize=8, va="bottom", color="green")
    ax.set_xlabel("problem size n")
    ax.set_ylabel("work (log scale)")
    ax.set_title("Exponential overtakes polynomial: the unbounded entropy gap")
    ax.legend(loc="upper left")
    ax.grid(True, which="both", alpha=0.2)
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    print(f"wrote {path}")


def main() -> None:
    plot_brute_force_cost()
    plot_entropy_gap()


if __name__ == "__main__":
    main()
