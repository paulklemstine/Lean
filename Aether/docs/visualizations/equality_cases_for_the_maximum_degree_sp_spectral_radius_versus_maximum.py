"""Visualisation: spectral radius versus maximum degree across signed graphs.

Generates a scatter plot of (Delta, rho) pairs for a family of signed graphs,
with the diagonal rho = Delta marking the Delta-bound ceiling.  Equality realisers
(complete graphs K_n^+) sit exactly on the line; generic random signed graphs lie
strictly below it.  Requires numpy and matplotlib.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def spectral_radius(A: np.ndarray) -> float:
    return float(np.max(np.abs(np.linalg.eigvalsh(A))))


def max_degree(A: np.ndarray) -> float:
    return float(np.abs(A).sum(axis=1).max())


def complete_positive(n: int) -> np.ndarray:
    return np.ones((n, n)) - np.eye(n)


def random_signed_graph(n: int, density: float, rng: np.random.Generator) -> np.ndarray:
    A = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < density:
                A[i, j] = A[j, i] = 1.0 if rng.random() < 0.5 else -1.0
    return A


def main() -> None:
    rng = np.random.default_rng(7)
    rand_d, rand_rho = [], []
    for _ in range(600):
        n = int(rng.integers(3, 14))
        A = random_signed_graph(n, float(rng.uniform(0.2, 1.0)), rng)
        D = max_degree(A)
        if D == 0:
            continue
        rand_d.append(D)
        rand_rho.append(spectral_radius(A))

    comp_d, comp_rho = [], []
    for n in range(2, 14):
        A = complete_positive(n)
        comp_d.append(max_degree(A))
        comp_rho.append(spectral_radius(A))

    lim = max(rand_d + comp_d) + 1
    plt.figure(figsize=(7, 7))
    plt.plot([0, lim], [0, lim], "k--", label=r"ceiling $\rho=\Delta$")
    plt.scatter(rand_d, rand_rho, s=18, alpha=0.5, label="random signed graphs")
    plt.scatter(comp_d, comp_rho, s=70, marker="*", color="crimson",
                label=r"$K_n^+$ (equality realisers)")
    plt.xlabel(r"maximum degree $\Delta$")
    plt.ylabel(r"spectral radius $\rho(A)$")
    plt.title("Spectral radius respects the maximum-degree ceiling")
    plt.legend()
    plt.tight_layout()
    plt.savefig("spectral_vs_degree.png", dpi=150)
    print("saved spectral_vs_degree.png")


if __name__ == "__main__":
    main()
