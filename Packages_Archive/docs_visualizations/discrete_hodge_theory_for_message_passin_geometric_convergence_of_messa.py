"""
Visualization: message-passing convergence to the harmonic subspace.

Plots, for a path graph's Hodge (graph) Laplacian, the residual energy
||T^k x0 - h|| against depth k on a log scale, overlaid with the theoretical
geometric bound rho^k with rho = 1 - mu/lambda_max.  Demonstrates Theorems on
distance-to-harmonics decay and the optimal spectral step.
"""
from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def path_laplacian(m: int) -> np.ndarray:
    e = np.zeros((m, m - 1))
    for j in range(m - 1):
        e[j, j] = -1.0
        e[j + 1, j] = 1.0
    return e @ e.T  # graph Laplacian = up-Laplacian on nodes


def main() -> None:
    m = 8
    Delta = path_laplacian(m)
    n = Delta.shape[0]
    eig = np.linalg.eigvalsh(Delta)
    lam_max = float(eig[-1])
    mu = float(eig[eig > 1e-9].min())
    rho = 1.0 - mu / lam_max
    alpha = 1.0 / lam_max
    T = np.eye(n) - alpha * Delta

    # harmonic target = projection onto constants (kernel of graph Laplacian)
    ones = np.ones(n) / np.sqrt(n)
    rng = np.random.default_rng(7)
    x0 = rng.standard_normal(n)
    h = np.outer(ones, ones) @ x0

    depths = list(range(0, 60))
    res = []
    xk = x0.copy()
    for _ in depths:
        res.append(np.linalg.norm(xk - h))
        xk = T @ xk
    bound = [(rho ** k) * np.linalg.norm(x0 - h) for k in depths]

    plt.figure(figsize=(8, 5))
    plt.semilogy(depths, res, "o-", ms=4, label="measured  ||Tᵏx₀ − h||")
    plt.semilogy(depths, bound, "--", label=f"bound  ρᵏ·‖r₀‖,  ρ = {rho:.3f}")
    plt.xlabel("depth k (number of message-passing layers)")
    plt.ylabel("distance to harmonic subspace")
    plt.title(f"Message passing converges to harmonics (path graph, m={m})")
    plt.legend()
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig("hodge_convergence.png", dpi=140)
    print("saved hodge_convergence.png")


if __name__ == "__main__":
    main()
