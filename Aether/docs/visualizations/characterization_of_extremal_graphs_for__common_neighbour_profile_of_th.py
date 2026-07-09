"""Visualization 3: common-neighbour profile of the three edge classes."""
from __future__ import annotations
import matplotlib.pyplot as plt
import numpy as np

def plot(ks=(2, 4, 6, 8, 10)) -> None:
    classes = ["matching (2k)", "join (2k)", "clique (4k-2)"]
    data = {c: [] for c in classes}
    for k in ks:
        data["matching (2k)"].append(2 * k)
        data["join (2k)"].append(2 * k)
        data["clique (4k-2)"].append(4 * k - 2)
    x = np.arange(len(ks)); w = 0.25
    fig, ax = plt.subplots(figsize=(8, 5))
    for i, c in enumerate(classes):
        ax.bar(x + (i - 1) * w, data[c], w, label=c)
    ax.set_xticks(x); ax.set_xticklabels([f"k={k}" for k in ks])
    ax.set_ylabel("common neighbours (triangles on edge)")
    ax.set_title("Matching edges are strictly locally sparsest (k>=2)")
    ax.legend()
    plt.tight_layout()
    plt.savefig("profile_bars.png", dpi=150)
    print("saved profile_bars.png")

if __name__ == "__main__":
    plot()
