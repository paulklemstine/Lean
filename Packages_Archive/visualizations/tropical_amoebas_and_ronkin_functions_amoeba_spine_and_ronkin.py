"""
visualize_amoeba.py -- render the amoeba spine, order-map regions, and the
Maslov-deformed Ronkin function for f = 1 + z + w.

Requires: numpy, matplotlib.  Run:  python3 visualize_amoeba.py
"""
from __future__ import annotations
import math
from typing import List, Tuple
import numpy as np
import matplotlib.pyplot as plt

Support = List[Tuple[float, Tuple[int, int]]]
SUPPORT: Support = [(1.0, (0, 0)), (1.0, (1, 0)), (1.0, (0, 1))]

def forms(x: float, y: float) -> List[float]:
    return [math.log(c) + mx * x + my * y for c, (mx, my) in SUPPORT]

def trop(x: float, y: float) -> float:
    return max(forms(x, y))

def ronkin(x: float, y: float, t: float) -> float:
    A = forms(x, y); M = max(A)
    return M + t * math.log(sum(math.exp((a - M) / t) for a in A))

def main() -> None:
    R, n = 4.0, 400
    xs = np.linspace(-R, R, n); ys = np.linspace(-R, R, n)
    X, Y = np.meshgrid(xs, ys)
    label = np.zeros_like(X); spine = np.zeros_like(X)
    ronk = np.zeros_like(X); t = 0.25
    for i in range(n):
        for j in range(n):
            A = forms(X[i, j], Y[i, j])
            label[i, j] = int(np.argmax(A))
            spine[i, j] = max(A)
            ronk[i, j] = ronkin(X[i, j], Y[i, j], t)

    fig, ax = plt.subplots(1, 3, figsize=(16, 5))
    ax[0].imshow(label, extent=[-R, R, -R, R], origin="lower", cmap="Set2")
    ax[0].set_title("Order map: dominance regions (slopes m_k)")
    cs = ax[1].contour(X, Y, spine, levels=25, cmap="viridis")
    ax[1].set_title("Amoeba spine  trop f = max_i A_i")
    ax[1].clabel(cs, inline=True, fontsize=7)
    cs2 = ax[2].contour(X, Y, ronk, levels=25, cmap="magma")
    ax[2].set_title(f"Deformed Ronkin R_t, t={t}")
    ax[2].clabel(cs2, inline=True, fontsize=7)
    for a in ax: a.set_xlabel("log|z|"); a.set_ylabel("log|w|")
    plt.tight_layout()
    plt.savefig("amoeba_visualization.png", dpi=140)
    print("saved amoeba_visualization.png")

if __name__ == "__main__":
    main()
