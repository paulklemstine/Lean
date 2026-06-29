"""Visualize convergence-to-harmonic decay and the optimal-step parabola.

Requires numpy and matplotlib.  Saves 'hodge_convergence.png'.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def up_laplacian_cycle(n: int) -> np.ndarray:
    edges = [(i, (i + 1) % n) for i in range(n)]
    B = np.zeros((n, len(edges)))
    for e, (u, v) in enumerate(edges):
        B[u, e], B[v, e] = -1.0, 1.0
    return B.T @ B            # edge up-Laplacian = B^T B

def main() -> None:
    L = up_laplacian_cycle(6)
    vals, vecs = np.linalg.eigh(L)
    vals = np.where(np.abs(vals) < 1e-9, 0.0, vals)
    mu = float(vals[vals > 1e-9].min()); lam = float(vals.max())
    K = vecs[:, vals <= 1e-9]
    alpha = 1.0 / lam; rho = 1.0 - mu / lam

    rng = np.random.default_rng(2)
    x = rng.standard_normal(L.shape[0])
    h = K @ (K.T @ x); r = x - h

    depths = np.arange(0, 30)
    dist2, bound = [], []
    y = x.copy()
    for k in depths:
        dist2.append(float((y - h) @ (y - h)))
        bound.append(rho ** int(k) * float(r @ r))
        y = y - alpha * (L @ y)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4))
    ax1.semilogy(depths, dist2, "o-", label=r"$\|T^k x - h\|^2$")
    ax1.semilogy(depths, bound, "--", label=r"$\rho^k\,\|r\|^2$ bound")
    ax1.set_xlabel("depth k"); ax1.set_ylabel("distance to harmonic (log)")
    ax1.set_title("Convergence to the harmonic projection"); ax1.legend()

    a = np.linspace(1e-3, 2.0 / lam - 1e-3, 400)
    rho_a = 1.0 - a * mu * (2.0 - a * lam)
    ax2.plot(a, rho_a)
    ax2.axvline(1.0 / lam, color="r", ls="--", label=r"$\alpha^*=1/\lambda$")
    ax2.scatter([1.0 / lam], [1.0 - mu / lam], color="r", zorder=5)
    ax2.set_xlabel(r"step $\alpha$"); ax2.set_ylabel(r"contraction $\rho(\alpha)$")
    ax2.set_title(r"Optimal step: $\rho(1/\lambda)=1-\mu/\lambda$"); ax2.legend()

    fig.tight_layout(); fig.savefig("hodge_convergence.png", dpi=130)
    print("saved hodge_convergence.png")

if __name__ == "__main__":
    main()
