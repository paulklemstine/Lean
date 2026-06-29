"""
visualize_capacity.py — Visualize exact-inversion capacity vs. collision deficit.

Generates a figure with two panels:
  (left)  For random functions f: [n] -> [m] with varying m, the mean image size
          |Im f| (= exact-inversion capacity) and the theoretical curve
          m * (1 - (1 - 1/m)^n). Capacity rises toward n as the codomain grows.
  (right) Decomposition |dom| = |Im f| + collision_deficit for a sweep of m,
          shown as a stacked bar (capacity vs. deficit).

Self-contained; requires matplotlib + numpy. Run: python visualize_capacity.py
"""
from __future__ import annotations
from typing import List
import numpy as np
import matplotlib.pyplot as plt


def image_size(f: np.ndarray) -> int:
    return int(np.unique(f).size)


def mean_capacity(n: int, m: int, trials: int, rng: np.random.Generator) -> float:
    return float(np.mean([image_size(rng.integers(0, m, size=n)) for _ in range(trials)]))


def main() -> None:
    rng = np.random.default_rng(0)
    n = 64
    ms: List[int] = [2, 4, 8, 16, 32, 64, 128, 256, 512]
    trials = 300

    emp = [mean_capacity(n, m, trials, rng) for m in ms]
    theo = [m * (1 - (1 - 1 / m) ** n) for m in ms]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(ms, emp, "o-", label="empirical mean |Im f|")
    ax1.plot(ms, theo, "k--", label=r"$m(1-(1-1/m)^n)$")
    ax1.axhline(n, color="r", ls=":", label="domain size n (max capacity)")
    ax1.set_xscale("log", base=2)
    ax1.set_xlabel("codomain size m")
    ax1.set_ylabel("exact-inversion capacity  |Im f|")
    ax1.set_title(f"Capacity of random f:[{n}] -> [m]")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    caps = np.array(emp)
    deficits = n - caps
    idx = np.arange(len(ms))
    ax2.bar(idx, caps, label="capacity |Im f|", color="#2c7fb8")
    ax2.bar(idx, deficits, bottom=caps, label="collision deficit", color="#de2d26")
    ax2.set_xticks(idx)
    ax2.set_xticklabels([str(m) for m in ms])
    ax2.set_xlabel("codomain size m")
    ax2.set_ylabel("count")
    ax2.set_title("Decomposition: n = capacity + deficit")
    ax2.legend()

    plt.tight_layout()
    plt.savefig("capacity_visualization.png", dpi=150)
    print("wrote capacity_visualization.png")


if __name__ == "__main__":
    main()
