"""Visualization: geometric energy decay envelope and the logarithmic depth ladder."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

def cycle_laplacian(n: int) -> np.ndarray:
    L = np.zeros((n, n))
    for i in range(n):
        j = (i + 1) % n
        L[i, i] += 1.0; L[j, j] += 1.0; L[i, j] -= 1.0; L[j, i] -= 1.0
    return L

def main() -> None:
    L = cycle_laplacian(12)
    vals, vecs = np.linalg.eigh(L)
    alpha = 1.0 / float(vals[-1])
    rho = max((1 - alpha * v) ** 2 for v in vals if v > 1e-9)
    rng = np.random.default_rng(2)
    x = rng.standard_normal(12)
    for i in range(len(vals)):
        if vals[i] < 1e-9:
            x = x - (vecs[:, i] @ x) * vecs[:, i]
    e0 = float(x @ x)

    ks = list(range(0, 81))
    actual, bound = [], []
    v = x.copy()
    for k in ks:
        actual.append(float(v @ v))
        bound.append((rho ** k) * e0)
        v = v - alpha * (L @ v)

    fig, ax = plt.subplots(1, 2, figsize=(12, 5))
    ax[0].semilogy(ks, bound, "r--", label=r"envelope $\rho^k\,\|x\|^2$")
    ax[0].semilogy(ks, actual, "b-", label="actual residual energy")
    ax[0].set_xlabel("depth k"); ax[0].set_ylabel("Dirichlet energy")
    ax[0].set_title("Geometric energy decay"); ax[0].legend(); ax[0].grid(True, which="both", alpha=0.3)

    epss = [10.0 ** (-d) for d in range(1, 9)]
    depths = [max(0, math.ceil(math.log(e / e0) / math.log(rho))) for e in epss]
    ax[1].plot([-math.log10(e) for e in epss], depths, "go-")
    ax[1].set_xlabel(r"decades of accuracy  $-\log_{10}\varepsilon$")
    ax[1].set_ylabel("required depth N")
    ax[1].set_title("Logarithmic depth law (linear in decades)")
    ax[1].grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("hodge_depth_law.png", dpi=140)
    print("Saved hodge_depth_law.png")

if __name__ == "__main__":
    main()
