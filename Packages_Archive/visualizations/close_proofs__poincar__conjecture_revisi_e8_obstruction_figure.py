"""Visualization: the E8 Dynkin/Gram structure and the parity obstruction.

Generates a figure with two panels:
  (left)  a heatmap of the E8 Gram matrix (diagonal all = 2 -> even),
  (right) value histogram Q(v) over v in {-1,0,1}^8 for E8 vs the standard form,
          highlighting that E8 never attains the odd value 1 (it is even) whereas
          the standard form does (it is odd).
Saves 'e8_obstruction.png'.
"""
from __future__ import annotations
from itertools import product
from typing import List
import matplotlib.pyplot as plt
import numpy as np

E8 = np.array([
    [2,-1,0,0,0,0,0,0],[-1,2,-1,0,0,0,0,0],[0,-1,2,-1,0,0,0,0],
    [0,0,-1,2,-1,0,0,0],[0,0,0,-1,2,-1,0,-1],[0,0,0,0,-1,2,-1,0],
    [0,0,0,0,0,-1,2,0],[0,0,0,0,-1,0,0,2]], dtype=int)
I8 = np.eye(8, dtype=int)

def values(G: np.ndarray) -> List[int]:
    return [int(v @ G @ v) for v in product([-1,0,1], repeat=8) if any(v)]

fig, ax = plt.subplots(1, 2, figsize=(13, 5))
im = ax[0].imshow(E8, cmap="coolwarm", vmin=-2, vmax=2)
ax[0].set_title("E8 Gram matrix (diagonal = 2: even)")
for i in range(8):
    for j in range(8):
        ax[0].text(j, i, str(E8[i, j]), ha="center", va="center", fontsize=8)
fig.colorbar(im, ax=ax[0], fraction=0.046)

ve8, vstd = values(E8), values(I8)
bins = np.arange(-0.5, max(max(ve8), max(vstd)) + 1.5, 1)
ax[1].hist(vstd, bins=bins, alpha=0.6, label="standard <1>^8 (odd: attains 1)")
ax[1].hist(ve8, bins=bins, alpha=0.6, label="E8 (even: never odd)")
ax[1].axvline(1, color="red", ls="--", lw=1.5, label="value 1 (odd)")
ax[1].set_xlabel("Q(v)"); ax[1].set_ylabel("count")
ax[1].set_title("Parity obstruction: E8 never hits an odd value")
ax[1].legend(fontsize=8)
plt.tight_layout()
plt.savefig("e8_obstruction.png", dpi=150)
print("saved e8_obstruction.png")
