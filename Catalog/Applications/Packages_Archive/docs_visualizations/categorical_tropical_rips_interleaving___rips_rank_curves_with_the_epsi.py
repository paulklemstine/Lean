"""Visualization: Rips edge-count (Betti-0) curves and the stability band.

Generates a figure showing the rank curves of a point cloud and a perturbed copy,
together with the +/- epsilon horizontal shift band guaranteed by the stability
theorem. Saves to rips_rank_stability.png.
"""
from itertools import combinations
from typing import Callable, List, Sequence, Tuple

import matplotlib.pyplot as plt


def euclid(p: Tuple[float, ...], q: Tuple[float, ...]) -> float:
    return sum((a - b) ** 2 for a, b in zip(p, q)) ** 0.5


def rank_curve(points: Sequence[Tuple[float, ...]],
               d: Callable[[Tuple[float, ...], Tuple[float, ...]], float]
               ) -> Tuple[List[float], List[int]]:
    scales = sorted(d(points[i], points[j])
                    for i, j in combinations(range(len(points)), 2))
    xs, ys, c = [0.0], [0], 0
    for s in scales:
        c += 1
        xs.extend([s, s])
        ys.extend([ys[-1], c])
    xs.append(max(scales) * 1.2)
    ys.append(ys[-1])
    return xs, ys


def main() -> None:
    pts = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (2.0, 2.0), (2.0, 0.0)]
    pert = [(0.0, 0.0), (1.2, 0.0), (0.0, 0.85), (2.1, 1.9), (1.9, 0.1)]
    eps = max(abs(euclid(pts[i], pts[j]) - euclid(pert[i], pert[j]))
              for i, j in combinations(range(len(pts)), 2))
    xA, yA = rank_curve(pts, euclid)
    xB, yB = rank_curve(pert, euclid)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.step(xA, yA, where="post", label="rank curve of d", lw=2)
    ax.step(xB, yB, where="post", label="rank curve of d'", lw=2)
    ax.step([x + eps for x in xA], yA, where="post", ls="--", alpha=0.5,
            label=f"d shifted by +eps={eps:.2f}")
    ax.set_xlabel("scale t")
    ax.set_ylabel("edge count  ncard(M.obj(t))")
    ax.set_title("Vietoris-Rips rank curves and the epsilon-stability band")
    ax.legend()
    fig.tight_layout()
    fig.savefig("rips_rank_stability.png", dpi=150)
    print("saved rips_rank_stability.png; sup perturbation eps =", round(eps, 4))


if __name__ == "__main__":
    main()
