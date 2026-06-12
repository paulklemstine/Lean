"""Visualization: empirical sparsity of stereographic attention vs N.

For each context size N, samples N spread keys around a query and counts how many
are active at a fixed threshold tau. Plots #active and the N/tau Markov bound on a
log-log scale, alongside the conjectured sqrt(N) trend. Saved to sparsity_scaling.png.
Requires numpy and matplotlib.
"""
from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def count_active(n: int, tau: float, dim: int, rng: np.random.Generator) -> int:
    q = np.zeros(dim)
    keys = rng.uniform(-6.0, 6.0, size=(n, dim))
    d2 = ((keys - q) ** 2).sum(axis=1)
    scores = 1.0 / (1.0 + d2)
    return int((scores >= tau).sum())


def main() -> None:
    rng = np.random.default_rng(0)
    tau, dim = 0.1, 3
    ns = np.unique(np.logspace(1.5, 4.5, 20).astype(int))
    active = np.array([np.mean([count_active(int(n), tau, dim, rng) for _ in range(5)]) for n in ns])

    plt.figure(figsize=(7, 5))
    plt.loglog(ns, active, "o-", label="#active (empirical)")
    plt.loglog(ns, np.sqrt(ns) * (active[0] / np.sqrt(ns[0])), "g--", label="~ sqrt(N) (conjectured)")
    plt.loglog(ns, ns / tau, "r:", label="N/tau (Markov bound)")
    plt.xlabel("context size N")
    plt.ylabel("number of active keys")
    plt.title(f"Stereographic attention sparsity (tau={tau}, dim={dim})")
    plt.legend()
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig("sparsity_scaling.png", dpi=130)
    print("saved sparsity_scaling.png")


if __name__ == "__main__":
    main()
