"""Heatmap of the semicube intersection pattern in Q(4) = Q(2) x Q(2)."""
from itertools import product
import numpy as np
import matplotlib.pyplot as plt


def all_vertices(n):
    return [frozenset(i for i, b in enumerate(bits) if b)
            for bits in product((False, True), repeat=n)]


def run(n=4):
    V = all_vertices(n)
    scs = [(i, b) for i in range(n) for b in (True, False)]
    m = len(scs)
    M = np.zeros((m, m), dtype=int)
    for a, (i, b) in enumerate(scs):
        for c, (j, d) in enumerate(scs):
            M[a, c] = sum(1 for v in V if (i in v) == b and (j in v) == d)
    labels = [f"{i}{'T' if b else 'F'}" for i, b in scs]
    plt.figure(figsize=(7, 6))
    plt.imshow(M, cmap="viridis")
    plt.xticks(range(m), labels, rotation=90); plt.yticks(range(m), labels)
    plt.colorbar(label="common vertices")
    plt.title("Semicube pairwise intersection sizes in Q(4)\\n"
              "(zeros = opposite pairs = only obstruction)")
    plt.tight_layout(); plt.savefig("intersection_heatmap.png", dpi=150)
    print("wrote intersection_heatmap.png")


if __name__ == "__main__":
    run()
