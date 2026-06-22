"""
Visualization: the distance-reduction walk between two contingency tables.

Generates a figure with two panels:
  (left)  the L1 distance to the target decreasing along the connecting walk;
  (right) heatmaps of the start, an intermediate, and the target table.

Requires: matplotlib, numpy.  Run: python visualization.py
"""
from __future__ import annotations
from typing import List, Optional, Tuple
import numpy as np
import matplotlib.pyplot as plt

Table = List[List[int]]


def apply_move(u: Table, i: int, ip: int, j: int, jp: int) -> Table:
    w = [row[:] for row in u]
    w[i][jp] += 1; w[ip][j] += 1; w[i][j] -= 1; w[ip][jp] -= 1
    return w


def distance(u: Table, v: Table) -> int:
    return sum(abs(u[i][j] - v[i][j]) for i in range(len(u)) for j in range(len(u[0])))


def find_aligned_move(u: Table, v: Table) -> Optional[Tuple[int, int, int, int]]:
    m, n = len(u), len(u[0])
    d = [[u[i][j] - v[i][j] for j in range(n)] for i in range(m)]
    surplus = next(((i, j) for i in range(m) for j in range(n) if d[i][j] > 0), None)
    if surplus is None:
        return None
    i, j = surplus
    jp = next(jj for jj in range(n) if d[i][jj] < 0)
    ip = next(ii for ii in range(m) if d[ii][jp] > 0)
    return (i, ip, j, jp)


def walk(u: Table, v: Table) -> List[Table]:
    seq = [u]
    cur = [r[:] for r in u]
    while cur != v:
        idx = find_aligned_move(cur, v)
        assert idx is not None
        cur = apply_move(cur, *idx)
        seq.append(cur)
    return seq


def main() -> None:
    u = [[5, 0, 0], [0, 5, 0], [0, 0, 5]]
    v = [[2, 2, 1], [2, 1, 2], [1, 2, 2]]
    seq = walk(u, v)
    dists = [distance(t, v) for t in seq]

    fig = plt.figure(figsize=(12, 4.5))

    ax0 = fig.add_subplot(1, 4, 1)
    ax0.plot(range(len(dists)), dists, "o-", color="#2a6f97", lw=2)
    ax0.set_title("L1 distance to target")
    ax0.set_xlabel("basic move #"); ax0.set_ylabel("distance")
    ax0.grid(alpha=0.3)

    picks = [0, len(seq) // 2, len(seq) - 1]
    titles = ["start u", "intermediate", "target v"]
    vmax = max(max(max(r) for r in t) for t in seq)
    for k, (p, t) in enumerate(zip(picks, titles)):
        ax = fig.add_subplot(1, 4, k + 2)
        arr = np.array(seq[p])
        im = ax.imshow(arr, cmap="viridis", vmin=0, vmax=vmax)
        for (i, j), val in np.ndenumerate(arr):
            ax.text(j, i, int(val), ha="center", va="center",
                    color="white" if val < vmax / 2 else "black")
        ax.set_title(t); ax.set_xticks([]); ax.set_yticks([])
    fig.colorbar(im, ax=fig.axes[1:], fraction=0.025)
    fig.suptitle("Distance-reduction walk via basic 2x2 swap moves "
                 "(margins fixed throughout)", fontsize=13)
    plt.savefig("markov_walk.png", dpi=130, bbox_inches="tight")
    print("saved markov_walk.png")


if __name__ == "__main__":
    main()
