"""Visualization: the iterated tent map tent^[k] and the exploding oscillation
count. Saves a multi-panel figure of tent^[1..4] over [0,1]."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def tent(x: np.ndarray) -> np.ndarray:
    return 1.0 - np.abs(2.0 * x - 1.0)


def iterated_tent(k: int, x: np.ndarray) -> np.ndarray:
    y = x.copy()
    for _ in range(k):
        y = tent(y)
    return y


x = np.linspace(0.0, 1.0, 4001)
fig, axes = plt.subplots(2, 2, figsize=(10, 7))
for ax, k in zip(axes.ravel(), (1, 2, 3, 4)):
    ax.plot(x, iterated_tent(k, x), lw=1.2, color="#1f77b4")
    ax.set_title(f"tent^[{k}]  —  {2**k} oscillations, deep size {2*k}")
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(alpha=0.3)
fig.suptitle("Depth folds the interval: 2^k oscillations from 2k neurons",
             fontsize=13)
fig.tight_layout()
fig.savefig("deep_tent_oscillations.png", dpi=150)
print("saved deep_tent_oscillations.png")
