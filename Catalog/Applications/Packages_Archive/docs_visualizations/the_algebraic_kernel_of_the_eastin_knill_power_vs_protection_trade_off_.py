"""Visualize the power-vs-protection trade-off: as a code's detection
error epsilon grows from 0, the maximal achievable logical commutator
(non-commutativity, hence computational power) grows linearly, in line
with the approximate-Eastin-Knill bound ||[L(A),L(B)]|| <= 2 eps ||B||."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

Matrix = np.ndarray


def random_code(dim: int, rank: int, seed: int = 0) -> Matrix:
    rng = np.random.default_rng(seed)
    M = rng.standard_normal((dim, rank)) + 1j * rng.standard_normal((dim, rank))
    Q, _ = np.linalg.qr(M)
    return Q @ Q.conj().T


def main() -> None:
    dim, rank = 6, 3
    P = random_code(dim, rank, seed=1)
    rng = np.random.default_rng(2)
    eps_grid = np.linspace(0.0, 1.0, 40)
    measured = []
    for eps in eps_grid:
        worst = 0.0
        for _ in range(200):
            # A perturbed scalar operator: detectable up to error ~eps.
            E = rng.standard_normal((dim, dim)) + 1j * rng.standard_normal((dim, dim))
            E /= np.linalg.norm(E)
            A = 2.0 * np.eye(dim) + eps * E
            B = rng.standard_normal((dim, dim)) + 1j * rng.standard_normal((dim, dim))
            B /= np.linalg.norm(B)
            LA, LB = P @ A @ P, P @ B @ P
            worst = max(worst, float(np.linalg.norm(LA @ LB - LB @ LA)))
        measured.append(worst)

    plt.figure(figsize=(8, 5))
    plt.plot(eps_grid, measured, "o-", label="measured max ||[L(A), L(B)]||")
    plt.plot(eps_grid, 2 * eps_grid, "--", label="bound  2 eps ||B||")
    plt.xlabel("detection error  eps")
    plt.ylabel("logical non-commutativity")
    plt.title("Approximate Eastin–Knill: power vs. protection trade-off")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("eastin_knill_tradeoff.png", dpi=150)
    print("saved eastin_knill_tradeoff.png")


if __name__ == "__main__":
    main()
