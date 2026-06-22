"""Visualization: the softmax Fisher matrix F = diag(pi) - pi pi^T as a heatmap,
with its eigenvalue spectrum (all >= 0, one zero eigenvalue for the gauge mode).
Requires numpy and matplotlib.
"""
from typing import List
import math
import numpy as np
import matplotlib.pyplot as plt


def softmax(z: List[float]) -> List[float]:
    m = max(z); e = [math.exp(zi - m) for zi in z]; t = sum(e)
    return [ei / t for ei in e]


def main() -> None:
    z = [1.3, -0.7, 2.1, 0.0, -1.5]
    pi = np.array(softmax(z))
    F = np.diag(pi) - np.outer(pi, pi)
    eigs = np.sort(np.linalg.eigvalsh(F))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))
    im = ax1.imshow(F, cmap="coolwarm", vmin=-F.max(), vmax=F.max())
    ax1.set_title(r"Fisher matrix  $F=\mathrm{diag}(\pi)-\pi\pi^\top$")
    fig.colorbar(im, ax=ax1, fraction=0.046)

    ax2.bar(range(len(eigs)), eigs, color="#2563eb")
    ax2.axhline(0, color="k", lw=0.8)
    ax2.set_title("Eigenvalues of F (all >= 0; one ~0 gauge mode)")
    ax2.set_xlabel("index"); ax2.set_ylabel("eigenvalue")
    fig.tight_layout()
    fig.savefig("fisher_spectrum.png", dpi=150)
    print("smallest eigenvalue:", eigs[0])
    print("wrote fisher_spectrum.png")


if __name__ == "__main__":
    main()
