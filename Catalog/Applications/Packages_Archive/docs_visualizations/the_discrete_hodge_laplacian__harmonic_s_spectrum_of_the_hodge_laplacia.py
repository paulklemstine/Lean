"""Visualization: the spectrum of the Hodge Laplacian and its harmonic gap."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def hodge_laplacian(e: np.ndarray, d: np.ndarray) -> np.ndarray:
    return d.T @ d + e @ e.T

def main() -> None:
    e = np.array([[-1.0, 1.0], [-1.0, 1.0], [-1.0, 1.0]])
    d = np.array([[1.0, -1.0, 0.0]])
    delta = hodge_laplacian(e, d)
    eigvals = np.linalg.eigvalsh(delta)
    plt.figure(figsize=(7, 4.5))
    colors = ["crimson" if abs(v) < 1e-9 else "steelblue" for v in eigvals]
    plt.bar(range(len(eigvals)), eigvals, color=colors)
    plt.axhline(0.0, color="black", lw=0.8)
    plt.xlabel("eigenvalue index")
    plt.ylabel(r"eigenvalue $\lambda_i$ of $\Delta$")
    plt.title("Spectrum of the Hodge Laplacian\n(red = harmonic / zero eigenvalue, blue = positive)")
    plt.xticks(range(len(eigvals)))
    plt.grid(True, axis="y", ls=":")
    plt.tight_layout()
    plt.savefig("hodge_spectrum.png", dpi=150)
    print("eigenvalues:", np.round(eigvals, 6))
    print("saved hodge_spectrum.png")

if __name__ == "__main__":
    main()
