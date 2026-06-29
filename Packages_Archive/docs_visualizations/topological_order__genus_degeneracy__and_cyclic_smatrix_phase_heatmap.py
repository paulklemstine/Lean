"""Visualization: heatmap of the phase of the cyclic S-matrix (DFT) for Z_n.

Generates a figure showing arg(S_{a,b}) = 2 pi a b / n as a colored grid,
making the Fourier structure of the abelian-anyon S-matrix visible.
Requires matplotlib + numpy.
"""
from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def cyclic_smatrix_phase(n: int) -> np.ndarray:
    a = np.arange(n).reshape(-1, 1)
    b = np.arange(n).reshape(1, -1)
    return (2 * np.pi * (a * b % n) / n)


def main() -> None:
    n = 8
    phase = cyclic_smatrix_phase(n)
    plt.figure(figsize=(5, 4.5))
    plt.imshow(phase, cmap="twilight", origin="lower")
    plt.colorbar(label="arg S_{a,b} = 2 pi a b / n")
    plt.title(f"Cyclic anyon S-matrix phases, Z_{n}")
    plt.xlabel("b"); plt.ylabel("a")
    plt.tight_layout()
    plt.savefig("cyclic_smatrix_phase.png", dpi=150)
    print("wrote cyclic_smatrix_phase.png")


if __name__ == "__main__":
    main()
