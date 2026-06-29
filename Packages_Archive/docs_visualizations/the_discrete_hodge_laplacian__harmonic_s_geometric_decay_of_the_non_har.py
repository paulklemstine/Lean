"""Visualization: geometric decay of the non-harmonic residual under diffusion."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def hodge_laplacian(e: np.ndarray, d: np.ndarray) -> np.ndarray:
    return d.T @ d + e @ e.T

def harmonic_projection(delta: np.ndarray, x: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    w, q = np.linalg.eigh(delta)
    cols = [q[:, i] for i in range(len(w)) if abs(w[i]) < tol]
    b = np.column_stack(cols) if cols else np.zeros((delta.shape[0], 0))
    return b @ (b.T @ x) if b.shape[1] else np.zeros_like(x)

def main() -> None:
    np.random.seed(3)
    e = np.array([[-1.0, 1.0], [-1.0, 1.0], [-1.0, 1.0]])
    d = np.array([[1.0, -1.0, 0.0]])
    delta = hodge_laplacian(e, d)
    lam_max = float(np.linalg.eigvalsh(delta).max())
    x = np.random.randn(3)
    px = harmonic_projection(delta, x)
    depths = np.arange(0, 60)
    plt.figure(figsize=(8, 5))
    for a in [0.5 / lam_max, 1.0 / lam_max, 1.5 / lam_max]:
        s = np.eye(3) - a * delta
        res = []
        xk = x.copy()
        for _ in depths:
            res.append(np.linalg.norm(xk - px))
            xk = s @ xk
        plt.semilogy(depths, res, marker="o", ms=3, label=f"a = {a:.3f}")
    plt.xlabel("diffusion depth k")
    plt.ylabel(r"$\|S^k x - P x\|$ (log scale)")
    plt.title("Diffusion relaxes the non-harmonic part to zero;\nthe harmonic projection P x is conserved")
    plt.legend()
    plt.grid(True, which="both", ls=":")
    plt.tight_layout()
    plt.savefig("residual_decay.png", dpi=150)
    print("saved residual_decay.png")

if __name__ == "__main__":
    main()
