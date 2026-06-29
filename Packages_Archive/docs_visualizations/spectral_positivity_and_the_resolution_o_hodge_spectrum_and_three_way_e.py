"""
Visualization: the Hodge spectrum and the three-way energy split.

Generates a two-panel figure:
  (left)  the sorted eigenvalue spectrum of the Hodge Laplacian Delta, with the
          zero eigenvalue(s) highlighted as the harmonic / topological component;
  (right) the energy split of a random edge-signal into its coexact, exact, and
          harmonic parts (the resolution of the identity in action).

Requires: numpy, matplotlib.   Run:  python3 _viz_spectrum.py
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def hodge_laplacian(d: np.ndarray, e: np.ndarray) -> np.ndarray:
    return d.T @ d + e @ e.T


def orthogonal_projector(cols: np.ndarray) -> np.ndarray:
    if cols.size == 0 or np.linalg.matrix_rank(cols) == 0:
        n = cols.shape[0]
        return np.zeros((n, n))
    return cols @ np.linalg.pinv(cols)


def kernel_basis(m: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    _, s, vh = np.linalg.svd(m)
    rank = int(np.sum(s > tol))
    return vh[rank:].T


def main() -> None:
    # A complex with all three components nontrivial: two triangles sharing an edge,
    # one filled (gives coexact), one hollow (gives a harmonic loop).
    rng = np.random.default_rng(7)
    # vertices 0..3; edges; one filled triangle.
    e = np.array([                      # edges x vertices (gradient d0)
        [-1.0, 1.0, 0.0, 0.0],          # 0-1
        [0.0, -1.0, 1.0, 0.0],          # 1-2
        [-1.0, 0.0, 1.0, 0.0],          # 0-2
        [0.0, 0.0, -1.0, 1.0],          # 2-3
        [0.0, -1.0, 0.0, 1.0],          # 1-3
    ])
    # one filled triangle (0,1,2): curl d1 on edges [0-1, 1-2, 0-2]
    d = np.array([[1.0, 1.0, -1.0, 0.0, 0.0]])

    delta = hodge_laplacian(d, e)
    eig = np.sort(np.linalg.eigvalsh(delta))

    P_co = orthogonal_projector(d.T)
    P_ex = orthogonal_projector(e)
    P_ha = orthogonal_projector(kernel_basis(delta))
    x = rng.standard_normal(delta.shape[0])
    energies = [np.linalg.norm(P_co @ x) ** 2,
                np.linalg.norm(P_ex @ x) ** 2,
                np.linalg.norm(P_ha @ x) ** 2]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.2))

    colors = ["#d62728" if abs(v) < 1e-8 else "#1f77b4" for v in eig]
    ax1.bar(range(len(eig)), eig, color=colors)
    ax1.set_title("Hodge Laplacian spectrum (red = harmonic, eigenvalue 0)")
    ax1.set_xlabel("index")
    ax1.set_ylabel("eigenvalue")
    ax1.axhline(0, color="black", linewidth=0.8)

    labels = ["coexact\n(curl-derived)", "exact\n(gradient)", "harmonic\n(loop)"]
    ax2.bar(labels, energies, color=["#9467bd", "#2ca02c", "#d62728"])
    ax2.set_title("Energy split of a random signal (resolution of identity)")
    ax2.set_ylabel("squared norm of component")

    fig.tight_layout()
    fig.savefig("hodge_spectrum.png", dpi=140)
    print("wrote hodge_spectrum.png")
    print("spectrum:", np.round(eig, 4))
    print("energy split (coexact, exact, harmonic):", np.round(energies, 4))


if __name__ == "__main__":
    main()
