"""Visualization: attention output stays inside the convex hull of value vectors."""
from __future__ import annotations
import math
from typing import List
import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial import ConvexHull


def attn_weights(q: np.ndarray, ks: np.ndarray) -> np.ndarray:
    scores = ks @ q
    scores = scores - scores.max()
    e = np.exp(scores)
    return e / e.sum()


def main() -> None:
    rng = np.random.default_rng(0)
    ks = rng.normal(size=(8, 2))            # 8 keys in R^2
    vs = rng.normal(size=(8, 2)) * 3.0      # 8 values in R^2

    fig, ax = plt.subplots(figsize=(7, 7))
    hull = ConvexHull(vs)
    for simplex in hull.simplices:
        ax.plot(vs[simplex, 0], vs[simplex, 1], "k-", lw=1)
    ax.scatter(vs[:, 0], vs[:, 1], c="tab:blue", s=60, label="value vectors")

    # Sweep many random queries; every output lands inside the hull.
    outs = []
    for _ in range(400):
        q = rng.normal(size=2) * rng.uniform(0.2, 4.0)
        w = attn_weights(q, ks)
        outs.append(w @ vs)
    outs = np.array(outs)
    ax.scatter(outs[:, 0], outs[:, 1], c="tab:red", s=8, alpha=0.5,
               label="attention outputs")

    ax.set_title("Confinement law: outputs always lie in the convex hull of values")
    ax.legend()
    ax.set_aspect("equal")
    plt.savefig("attention_confinement.png", dpi=150, bbox_inches="tight")
    print("saved attention_confinement.png")


if __name__ == "__main__":
    main()
